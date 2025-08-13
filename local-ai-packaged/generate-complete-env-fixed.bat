@echo off
REM Fixed Windows batch script to generate complete .env file with secure secrets

echo ================================================
echo Generating Complete .env File
echo Domain: phucduong.duckdns.org
echo ================================================
echo.

setlocal enabledelayedexpansion

REM Use PowerShell to generate secure random secrets
for /f %%i in ('powershell -Command "[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))"') do set "SECRET1=%%i"
for /f %%i in ('powershell -Command "[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))"') do set "SECRET2=%%i"
for /f %%i in ('powershell -Command "[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(16))"') do set "SECRET3=%%i"
for /f %%i in ('powershell -Command "[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(16))"') do set "SECRET4=%%i"
for /f %%i in ('powershell -Command "[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))"') do set "SECRET5=%%i"
for /f %%i in ('powershell -Command "[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))"') do set "SECRET6=%%i"
for /f %%i in ('powershell -Command "[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))"') do set "SECRET7=%%i"
for /f %%i in ('powershell -Command "[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(16))"') do set "SECRET8=%%i"
for /f %%i in ('powershell -Command "[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(16))"') do set "SECRET9=%%i"
for /f %%i in ('powershell -Command "[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(16))"') do set "SECRET10=%%i"

REM Create .env file with generated secrets
echo Creating .env file...
(
echo # Local AI Packaged - Complete Configuration for phucduong.duckdns.org
echo # Generated on %date% %time%
echo.
echo # === Domain Configuration ===
echo DOMAIN=phucduong.duckdns.org
echo ACME_EMAIL=your-email@domain.com
echo.
echo # === Security Keys (Auto-generated - CHANGE THESE!) ===
echo N8N_ENCRYPTION_KEY=%SECRET1%
echo N8N_USER_MANAGEMENT_JWT_SECRET=%SECRET2%
echo N8N_BASIC_AUTH_USER=admin
echo N8N_BASIC_AUTH_PASSWORD=%SECRET3%
echo.
echo # === Supabase Configuration ===
echo POSTGRES_PASSWORD=%SECRET4%
echo JWT_SECRET=%SECRET5%
echo ANON_KEY=%SECRET6%
echo SERVICE_ROLE_KEY=%SECRET7%
echo DASHBOARD_USERNAME=admin
echo DASHBOARD_PASSWORD=%SECRET8%
echo POOLER_TENANT_ID=local-ai-packaged
echo POOLER_DB_POOL_SIZE=5
echo.
echo # === Neo4j Configuration ===
echo NEO4J_AUTH=neo4j/%SECRET9%
echo.
echo # === Langfuse Configuration ===
echo CLICKHOUSE_PASSWORD=%SECRET10%
echo MINIO_ROOT_PASSWORD=%SECRET1:~0,16%aA1
echo LANGFUSE_SALT=%SECRET2:~16,16%
echo NEXTAUTH_SECRET=%SECRET3%
echo ENCRYPTION_KEY=%SECRET4%
echo.
echo # === Open WebUI Configuration ===
echo WEBUI_SECRET_KEY=%SECRET5%
echo.
echo # === Flowise Configuration ===
echo FLOWISE_USERNAME=admin
echo FLOWISE_PASSWORD=%SECRET6:~0,16%
echo SECRETKEY=%SECRET7%
echo.
echo # === Service URLs (Auto-configured) ===
echo WEBUI_URL=https://webui.phucduong.duckdns.org
echo N8N_URL=https://n8n.phucduong.duckdns.org
echo FLOWISE_URL=https://flowise.phucduong.duckdns.org
echo NEO4J_URL=https://neo4j.phucduong.duckdns.org
echo LANGFUSE_URL=https://langfuse.phucduong.duckdns.org
echo SEARXNG_URL=https://search.phucduong.duckdns.org
echo SUPABASE_URL=https://supabase.phucduong.duckdns.org
echo QDRANT_URL=https://qdrant.phucduong.duckdns.org
echo.
echo # === GPU Configuration ===
echo DOCKER_PROFILE=cpu
echo.
echo # === Traefik Configuration ===
echo TRAEFIK_NETWORK=traefik_default
echo TRAEFIK_ENABLE=true
echo.
echo # === Notes ===
echo # 1. Change ACME_EMAIL to your actual email
echo # 2. Review and update passwords if needed
echo # 3. Ensure DNS records point to your server
echo # 4. Check firewall rules for ports 80/443
echo # 5. Consider using stronger passwords for production
echo # 6. Store this file securely - it contains sensitive data
echo.
echo # === Service Access URLs ===
echo # Open WebUI: https://webui.phucduong.duckdns.org
echo # n8n: https://n8n.phucduong.duckdns.org
echo # Flowise: https://flowise.phucduong.duckdns.org
echo # Neo4j: https://neo4j.phucduong.duckdns.org
echo # Langfuse: https://langfuse.phucduong.duckdns.org
echo # SearXNG: https://search.phucduong.duckdns.org
echo # Supabase: https://supabase.phucduong.duckdns.org
echo # Qdrant: https://qdrant.phucduong.duckdns.org
echo.
echo # === Backup Instructions ===
echo # 1. Copy this file to a secure location
echo # 2. Consider using a password manager for sensitive values
echo # 3. Rotate secrets regularly for production environments
echo.
echo # === Support ===
echo # For issues, check: EXISTING_TRAEFIK_SETUP.md
echo # Or run: verify-traefik.bat
echo.
) > .env

echo.
echo ✅ Complete .env file created with secure secrets!
echo.
echo Next steps:
echo 1. Edit .env file: notepad .env
echo 2. Update ACME_EMAIL with your actual email
echo 3. Run: verify-traefik.bat
echo 4. Deploy: make start-existing-traefik
echo.
echo IMPORTANT: Backup this .env file in a secure location!
echo.
pause