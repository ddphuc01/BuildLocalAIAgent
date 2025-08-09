Param(
  [switch]$Frontend,
  [switch]$Stop,
  [int]$Port = 8000,
  [string]$Provider = "",
  [string]$OllamaModel = ""
)

$ErrorActionPreference = 'Stop'

function Write-Info($msg){ Write-Host ("[INFO] {0}" -f $msg) -ForegroundColor Cyan }
function Write-Warn($msg){ Write-Host ("[WARN] {0}" -f $msg) -ForegroundColor Yellow }
function Write-Err($msg){ Write-Host ("[ERROR] {0}" -f $msg) -ForegroundColor Red }

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$BackendDir = Join-Path $Root 'cursor-ai-devops\backend'
$FrontendDir = Join-Path $Root 'cursor-ai-devops\frontend'
$VenvPython = Join-Path $BackendDir '.venv\Scripts\python.exe'
$VenvPip = Join-Path $BackendDir '.venv\Scripts\pip.exe'
$PidFile = Join-Path $BackendDir '.uvicorn.pid'

if ($Stop) {
  if (Test-Path $PidFile) {
    $uvicornPid = Get-Content -Raw -Path $PidFile | ForEach-Object { $_.Trim() }
    if ($uvicornPid) {
      $pidNum = ($uvicornPid -replace '[^0-9]','')
      if ($pidNum) {
        try { Stop-Process -Id ([int]$pidNum) -ErrorAction Stop; Write-Info "Stopped backend (PID ${pidNum})" }
        catch { Write-Warn "Unable to stop PID ${pidNum}: $($_.Exception.Message)" }
      }
      Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
    }
  } else { Write-Warn "No PID file found ($PidFile)" }
  # Fallback: stop process bound to port if still alive
  try {
    $net = netstat -ano | Select-String ":$Port" | Select-Object -First 1
    if ($net) {
      $parts = ($net -split '\s+')
      $candPid = $parts[-1]
      if ($candPid -match '^[0-9]+$') { Stop-Process -Id ([int]$candPid) -ErrorAction SilentlyContinue; Write-Warn "Stopped process on port $Port (PID ${candPid})" }
    }
  } catch {}
  exit 0
}

Write-Info "Root: $Root"
Write-Info "Backend: $BackendDir"

if (-not (Test-Path $BackendDir)) { Write-Err "Backend directory not found"; exit 1 }

# Ensure Python present
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
  Write-Err "Python not found. Install Python 3.10+ (see docs/WINDOWS_SETUP.md)."; exit 1
}

# Create venv if missing
if (-not (Test-Path (Join-Path $BackendDir '.venv'))) {
  Write-Info "Creating virtual environment (.venv)"
  Push-Location $BackendDir
  python -m venv .venv
  Pop-Location
}

if (-not (Test-Path $VenvPython)) { Write-Err "Virtual env creation failed. Ensure Python 3.10+ is installed."; exit 1 }

# Install minimal deps
Write-Info "Installing backend dependencies (requirements-min.txt)"
& $VenvPip install -U pip setuptools wheel
& $VenvPip install -r (Join-Path $BackendDir 'requirements-min.txt')

# Export provider env if provided
if ($Provider) { $env:PROVIDER = $Provider }
if ($OllamaModel) { $env:OLLAMA_MODEL = $OllamaModel }

# Check if backend already healthy
function Test-Health {
  try { Invoke-RestMethod "http://127.0.0.1:$Port/health" -TimeoutSec 2 | Out-Null; return $true } catch { return $false }
}

$isUp = Test-Health
if (-not $isUp) {
  Write-Info "Starting backend (uvicorn on port $Port)"
  $args = @('-m','uvicorn','app.main:app','--host','127.0.0.1','--port',"$Port")
  $proc = Start-Process -FilePath $VenvPython -WorkingDirectory $BackendDir -ArgumentList $args -PassThru -WindowStyle Hidden
  if ($proc -and $proc.Id) { $proc.Id | Out-File -FilePath $PidFile -Encoding ascii -Force }
  Start-Sleep -Seconds 2
}

# Wait for health
for ($i=0; $i -lt 15; $i++) {
  if (Test-Health) { Write-Info "Backend healthy on http://127.0.0.1:$Port"; break }
  Start-Sleep -Seconds 1
}
if (-not (Test-Health)) { Write-Err "Backend failed to start"; exit 1 }

# Test K8s analyzer with demo.yaml
$Demo = Join-Path $BackendDir 'demo.yaml'
if (-not (Test-Path $Demo)) {
  @(
    'apiVersion: v1',
    'kind: Pod',
    'metadata:',
    '  name: demo',
    'spec:',
    '  containers:',
    '  - name: c',
    '    image: nginx:latest'
  ) | Out-File -FilePath $Demo -Encoding utf8 -Force
}

Write-Info "Analyzing demo.yaml"
try {
  $resp = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/api/k8s/analyze" -Method POST -InFile $Demo -ContentType 'text/plain' -TimeoutSec 10
  Write-Host $resp.Content
} catch { Write-Warn ("Analyzer request failed: {0}" -f $_.Exception.Message) }

if ($Frontend) {
  Write-Info "Frontend flag set; checking Node/npm"
  $hasNode = $null -ne (Get-Command node -ErrorAction SilentlyContinue)
  $hasNpm = $null -ne (Get-Command npm -ErrorAction SilentlyContinue)
  if (-not $hasNode -or -not $hasNpm) {
    Write-Warn "Node.js/npm not found. Install Node 18+ from https://nodejs.org/en/download"
  } else {
    Write-Info "Starting frontend dev servers (Vite + Electron)"
    Push-Location $FrontendDir
    npm install
    Start-Process -WorkingDirectory $FrontendDir -FilePath npm -ArgumentList 'run','dev:renderer' | Out-Null
    Start-Process -WorkingDirectory $FrontendDir -FilePath npm -ArgumentList 'run','dev:electron' | Out-Null
    Pop-Location
  }
}

Write-Info "Done. To stop backend: .\\run_dev.ps1 -Stop"


