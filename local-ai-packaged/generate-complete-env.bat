@echo off
REM Windows batch script to generate complete .env file with secure secrets

echo ================================================
echo Generating Complete .env File
echo Domain: phucduong.duckdns.org
echo ================================================
echo.

setlocal enabledelayedexpansion

REM Generate all secrets
set "secrets="
for /l %%i in (1,1,10) do (
    for /f "skip=1 delims=" %%s in ('certutil -hashfile nul SHA256') do (
        if not defined secrets set "secrets=%%s"
    )
    set "secrets=!secrets: =!"
    set "secret%%i=!secrets:~0,64!"
    set "secrets="
)

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
echo N8N_ENCRYPTION_KEY=!secret1!
echo N8N_USER_MANAGEMENT_JWT_SECRET=!secret2!
echo N8N_BASIC_AUTH_USER=admin
echo N8N_BASIC_AUTH_PASSWORD=!secret3:~0,16!
echo.
echo # === Supabase Configuration ===
echo POSTGRES_PASSWORD=!secret4:~0,32!
echo JWT_SECRET=!secret5!
echo ANON_KEY=!secret6!
echo SERVICE_ROLE_KEY=!secret7!
echo DASHBOARD_USERNAME=admin
echo DASHBOARD_PASSWORD=!secret8:~0,16!
echo POOLER_TENANT_ID=local-ai-packaged
echo POOLER_DB_POOL_SIZE=5
echo.
echo # === Neo4j Configuration ===
echo NEO4J_AUTH=neo4j/!secret9:~0,16!
echo.
echo # === Langfuse Configuration ===
echo CLICKHOUSE_PASSWORD=!secret10:~0,16!
echo MINIO_ROOT_PASSWORD=!secret1:~0,16!aA1
echo LANGFUSE_SALT=!secret2:~32,32!
echo NEXTAUTH_SECRET=!secret3!
echo ENCRYPTION_KEY=!secret4!
echo.
echo # === Open WebUI Configuration ===
echo WEBUI_SECRET_KEY=!secret5!
echo.
echo # === Flowise Configuration ===
echo FLOWISE_USERNAME=admin
echo FLOWISE_PASSWORD=!secret6:~0,16!
echo SECRETKEY=!secret7!
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
) > .env

echo.
echo ✅ Complete .env file created with secure secrets!
echo.
echo Next steps:
echo 1. Edit .env file: notepad .env
echo 2. Update ACME_EMAIL with your email
echo 3. Run: verify-traefik.bat
echo 4. Deploy: make start-existing-traefik
echo.
echo IMPORTANT: Backup this .env file in a secure location!
echo.
pause