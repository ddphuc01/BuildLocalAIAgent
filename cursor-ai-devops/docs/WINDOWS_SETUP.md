### Windows Setup - Python 3.10 and Node 18

1) Install Python 3.10+
- Download from https://www.python.org/downloads/windows/
- Run installer:
  - Check "Add Python to PATH"
  - Choose "Customize installation" → ensure pip is selected
  - Install for all users (optional)
- Verify in new PowerShell:
  - `py --version` (or `python --version`)
  - Should show 3.10.x

If python launches Microsoft Store instead:
- Open Settings → Apps → Advanced app settings → App execution aliases
- Turn off aliases for `python.exe` and `python3.exe`
- Open new PowerShell, try `py --version` again

2) Install Node.js LTS (>=18)
- Download from https://nodejs.org/en/download
- Install with defaults
- Verify: `node --version` and `npm --version`

3) Backend setup
```
cd C:\BuildLocalAIAgent\cursor-ai-devops\backend
py -3.10 -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

4) Frontend setup
```
cd C:\BuildLocalAIAgent\cursor-ai-devops\frontend
npm install
npm run dev
```


