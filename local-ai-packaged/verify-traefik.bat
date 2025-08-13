@echo off
REM Windows batch script to verify existing Traefik setup

echo ================================================
echo Verifying Existing Traefik Setup
echo Domain: phucduong.duckdns.org
echo ================================================
echo.

REM Check Docker
echo 1. Checking Docker...
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo    ❌ Docker is not running
    goto :error
)
echo    ✅ Docker is running
echo.

REM Check Traefik container
echo 2. Checking Traefik container...
docker ps --format "table {{.Names}}\t{{.Status}}" | findstr /i traefik >nul
if %errorlevel% neq 0 (
    echo    ❌ Traefik container not found
    goto :error
)
echo    ✅ Traefik container found
echo.

REM Check Traefik network
echo 3. Checking Traefik network...
docker network ls | findstr traefik_default >nul
if %errorlevel% neq 0 (
    echo    ❌ traefik_default network not found
    echo    Available networks:
    docker network ls | findstr traefik
    goto :error
)
echo    ✅ traefik_default network found
echo.

REM Check network connectivity
echo 4. Checking network connectivity...
docker network inspect traefik_default >nul 2>&1
if %errorlevel% neq 0 (
    echo    ❌ Cannot inspect traefik_default network
    goto :error
)
echo    ✅ Network connectivity verified
echo.

REM Check DNS resolution
echo 5. Checking DNS resolution...
nslookup phucduong.duckdns.org >nul 2>&1
if %errorlevel% neq 0 (
    echo    ⚠️  DNS resolution failed for phucduong.duckdns.org
    echo    Make sure your DNS is properly configured
) else (
    echo    ✅ DNS resolution working
)
echo.

REM Check if ports 80/443 are available
echo 6. Checking port availability...
netstat -ano | findstr :80 >nul
if %errorlevel% equ 0 (
    echo    ⚠️  Port 80 is in use - may conflict with Traefik
)
netstat -ano | findstr :443 >nul
if %errorlevel% equ 0 (
    echo    ⚠️  Port 443 is in use - may conflict with Traefik
)
if %errorlevel% neq 0 (
    echo    ✅ Ports 80/443 appear available
)
echo.

REM Display current Traefik services
echo 7. Current Traefik services:
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | findstr /v /c:"CONTAINER" > temp_services.txt
if exist temp_services.txt (
    type temp_services.txt
    del temp_services.txt
) else (
    echo    No services found
)
echo.

echo ================================================
echo Verification complete!
echo.
if "%errorlevel%" equ "0" (
    echo ✅ Your Traefik setup appears ready for integration.
    echo.
    echo Next steps:
    echo 1. Run: setup-existing-traefik.bat
    echo 2. Edit .env file with your secure values
    echo 3. Deploy services with: make start-existing-traefik
) else (
    echo ❌ Please fix the issues above before proceeding.
)
echo.
pause
exit /b 0

:error
echo.
echo ❌ Setup verification failed!
echo Please ensure:
echo 1. Docker is running
echo 2. Traefik is properly configured
echo 3. traefik_default network exists
echo 4. DNS is properly configured
echo.
pause
exit /b 1