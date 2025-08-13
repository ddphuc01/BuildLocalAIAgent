@echo off
REM Windows batch script to switch between Caddy and Traefik reverse proxy configurations

echo Local AI Packaged - Proxy Switcher
echo ==================================
echo.
echo 1. Use Caddy (default)
echo 2. Use Traefik
echo 3. Check current configuration
echo 4. Exit
echo.

set /p choice=Select option [1-4]: 

if "%choice%"=="1" (
    echo Switching to Caddy configuration...
    if exist "docker-compose.yml" (
        echo Already using Caddy configuration
    ) else (
        echo Caddy configuration selected. Use: make start
    )
    goto :end
)

if "%choice%"=="2" (
    echo Switching to Traefik configuration...
    if exist "docker-compose.traefik.yml" (
        echo Switched to Traefik. Use: make start-traefik
    ) else (
        echo Traefik configuration not found
    )
    goto :end
)

if "%choice%"=="3" (
    echo Current configuration:
    if exist "docker-compose.yml" (
        echo Active: docker-compose.yml (Caddy)
    )
    if exist "docker-compose.traefik.yml" (
        echo Available: docker-compose.traefik.yml (Traefik)
    )
    goto :end
)

if "%choice%"=="4" (
    echo Exiting...
    exit /b 0
)

:end
echo.
echo Next steps:
echo - Run: make start (for Caddy)
echo - Run: make start-traefik (for Traefik)
echo - Access services at their respective URLs
pause