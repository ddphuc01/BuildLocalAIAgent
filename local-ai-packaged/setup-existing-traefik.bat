@echo off
REM Windows batch script to set up Local AI Packaged with existing Traefik

echo ================================================
echo Local AI Packaged - Traefik Integration Setup
echo Domain: phucduong.duckdns.org
echo ================================================
echo.

REM Check if Docker is running
echo Checking Docker...
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not running or not installed!
    pause
    exit /b 1
)

echo Docker is running.
echo.

REM Check if Traefik network exists
echo Checking Traefik network...
docker network ls | findstr traefik_default >nul
if %errorlevel% neq 0 (
    echo WARNING: traefik_default network not found!
    echo Make sure your Traefik is running and using 'traefik_default' network
    echo.
    echo Available networks:
    docker network ls | findstr traefik
    echo.
    pause
    exit /b 1
)

echo Traefik network found.
echo.

REM Check if .env exists
if not exist ".env" (
    echo Creating .env file from template...
    copy .env.traefik .env
    echo.
    echo IMPORTANT: Please edit .env file with your actual values!
    echo - Change all passwords and security keys
    echo - Update email address for notifications
    echo.
    notepad .env
    echo.
    echo After editing .env, run this script again.
    pause
    exit /b 0
)

echo .env file exists.
echo.

REM Show current configuration
echo Current configuration:
echo Domain: phucduong.duckdns.org
echo Services will be available at:
echo - https://webui.phucduong.duckdns.org (Open WebUI)
echo - https://n8n.phucduong.duckdns.org (n8n)
echo - https://flowise.phucduong.duckdns.org (Flowise)
echo - https://neo4j.phucduong.duckdns.org (Neo4j)
echo - https://langfuse.phucduong.duckdns.org (Langfuse)
echo - https://search.phucduong.duckdns.org (SearXNG)
echo - https://supabase.phucduong.duckdns.org (Supabase)
echo - https://qdrant.phucduong.duckdns.org (Qdrant)
echo.

REM Ask for confirmation
set /p confirm=Do you want to start the services? (y/n): 
if /i "%confirm%" neq "y" (
    echo Setup cancelled.
    pause
    exit /b 0
)

echo.
echo Starting services...
echo.

REM Start services
docker-compose -f docker-compose.existing-traefik.yml up -d

echo.
echo Services started! Checking status...
echo.

docker-compose -f docker-compose.existing-traefik.yml ps

echo.
echo Setup complete!
echo.
echo You can now access your services at the URLs listed above.
echo.
echo To check logs, run:
echo   docker-compose -f docker-compose.existing-traefik.yml logs -f
echo.
echo To stop services, run:
echo   docker-compose -f docker-compose.existing-traefik.yml down
echo.
pause