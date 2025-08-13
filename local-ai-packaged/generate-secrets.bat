@echo off
REM Windows batch script to generate secure secrets for Local AI Packaged

echo ================================================
echo Generating Secure Secrets for Local AI Packaged
echo ================================================
echo.

REM Create secrets directory if it doesn't exist
if not exist "secrets" mkdir secrets

REM Generate N8N encryption key (32 bytes hex)
echo Generating N8N_ENCRYPTION_KEY...
set "N8N_KEY="
for /f "skip=1 delims=" %%i in ('certutil -hashfile nul SHA256') do (
    if not defined N8N_KEY set "N8N_KEY=%%i"
)
set "N8N_KEY=%N8N_KEY: =%"
set "N8N_KEY=%N8N_KEY:~0,64%"
echo N8N_ENCRYPTION_KEY=%N8N_KEY%
echo.

REM Generate N8N JWT secret (32 bytes hex)
echo Generating N8N_USER_MANAGEMENT_JWT_SECRET...
set "N8N_JWT="
for /f "skip=1 delims=" %%i in ('certutil -hashfile nul SHA256') do (
    if not defined N8N_JWT set "N8N_JWT=%%i"
)
set "N8N_JWT=%N8N_JWT: =%"
set "N8N_JWT=%N8N_JWT:~0,64%"
echo N8N_USER_MANAGEMENT_JWT_SECRET=%N8N_JWT%
echo.

REM Generate other required secrets
echo Generating additional secrets...
echo.

REM Generate WEBUI secret
set "WEBUI_SECRET="
for /f "skip=1 delims=" %%i in ('certutil -hashfile nul SHA256') do (
    if not defined WEBUI_SECRET set "WEBUI_SECRET=%%i"
)
set "WEBUI_SECRET=%WEBUI_SECRET: =%"
set "WEBUI_SECRET=%WEBUI_SECRET:~0,64%"
echo WEBUI_SECRET_KEY=%WEBUI_SECRET%

REM Generate JWT secret
set "JWT_SECRET="
for /f "skip=1 delims=" %%i in ('certutil -hashfile nul SHA256') do (
    if not defined JWT_SECRET set "JWT_SECRET=%%i"
)
set "JWT_SECRET=%JWT_SECRET: =%"
set "JWT_SECRET=%JWT_SECRET:~0,64%"
echo JWT_SECRET=%JWT_SECRET%

REM Generate Postgres password
set "POSTGRES_PASSWORD="
for /f "skip=1 delims=" %%i in ('certutil -hashfile nul SHA256') do (
    if not defined POSTGRES_PASSWORD set "POSTGRES_PASSWORD=%%i"
)
set "POSTGRES_PASSWORD=%POSTGRES_PASSWORD: =%"
set "POSTGRES_PASSWORD=%POSTGRES_PASSWORD:~0,32%"
echo POSTGRES_PASSWORD=%POSTGRES_PASSWORD%

echo.
echo ================================================
echo Secrets generated successfully!
echo.
echo Copy these values to your .env file:
echo.
echo N8N_ENCRYPTION_KEY=%N8N_KEY%
echo N8N_USER_MANAGEMENT_JWT_SECRET=%N8N_JWT%
echo WEBUI_SECRET_KEY=%WEBUI_SECRET%
echo JWT_SECRET=%JWT_SECRET%
echo POSTGRES_PASSWORD=%POSTGRES_PASSWORD%
echo.
echo Alternatively, run: generate-complete-env.bat
echo to create a complete .env file with all secrets
echo.
pause