#!/usr/bin/env python3
"""
Python script to generate secure secrets for Local AI Packaged
Usage: python generate-secrets.py
"""

import secrets
import string
import os

def generate_secure_key(length=64):
    """Generate a secure random hex key"""
    return secrets.token_hex(length // 2)

def generate_secure_password(length=16):
    """Generate a secure random password"""
    alphabet = string.ascii_letters + string.digits + string.punctuation
    return ''.join(secrets.choice(alphabet) for _ in range(length))

def generate_env_file():
    """Generate a complete .env file with all secrets"""
    
    secrets_dict = {
        'N8N_ENCRYPTION_KEY': generate_secure_key(64),
        'N8N_USER_MANAGEMENT_JWT_SECRET': generate_secure_key(64),
        'N8N_BASIC_AUTH_PASSWORD': generate_secure_password(16),
        'POSTGRES_PASSWORD': generate_secure_password(32),
        'JWT_SECRET': generate_secure_key(64),
        'ANON_KEY': generate_secure_key(64),
        'SERVICE_ROLE_KEY': generate_secure_key(64),
        'DASHBOARD_PASSWORD': generate_secure_password(16),
        'NEO4J_AUTH': f"neo4j:{generate_secure_password(16)}",
        'CLICKHOUSE_PASSWORD': generate_secure_password(16),
        'MINIO_ROOT_PASSWORD': generate_secure_password(16) + 'aA1',
        'LANGFUSE_SALT': generate_secure_key(32),
        'NEXTAUTH_SECRET': generate_secure_key(64),
        'ENCRYPTION_KEY': generate_secure_key(64),
        'WEBUI_SECRET_KEY': generate_secure_key(64),
        'FLOWISE_PASSWORD': generate_secure_password(16),
        'SECRETKEY': generate_secure_key(64),
    }
    
    env_content = f"""# Local AI Packaged - Complete Configuration for phucduong.duckdns.org
# Generated on {os.path.basename(__file__)}

# === Domain Configuration ===
DOMAIN=phucduong.duckdns.org
ACME_EMAIL=your-email@domain.com

# === Security Keys (Auto-generated - CHANGE THESE!) ===
"""
    
    for key, value in secrets_dict.items():
        env_content += f"{key}={value}\n"
    
    env_content += """
# === Service URLs (Auto-configured) ===
WEBUI_URL=https://webui.phucduong.duckdns.org
N8N_URL=https://n8n.phucduong.duckdns.org
FLOWISE_URL=https://flowise.phucduong.duckdns.org
NEO4J_URL=https://neo4j.phucduong.duckdns.org
LANGFUSE_URL=https://langfuse.phucduong.duckdns.org
SEARXNG_URL=https://search.phucduong.duckdns.org
SUPABASE_URL=https://supabase.phucduong.duckdns.org
QDRANT_URL=https://qdrant.phucduong.duckdns.org

# === GPU Configuration ===
DOCKER_PROFILE=cpu

# === Traefik Configuration ===
TRAEFIK_NETWORK=traefik_default
TRAEFIK_ENABLE=true

# === Notes ===
# 1. Change ACME_EMAIL to your actual email
# 2. Review and update passwords if needed
# 3. Ensure DNS records point to your server
# 4. Check firewall rules for ports 80/443
"""
    
    with open('.env', 'w') as f:
        f.write(env_content)
    
    print("✅ Complete .env file created with secure secrets!")
    print()
    print("Next steps:")
    print("1. Edit .env file and update ACME_EMAIL")
    print("2. Run: python verify-traefik.py")
    print("3. Deploy: make start-existing-traefik")
    print()
    print("IMPORTANT: Backup this .env file in a secure location!")

def print_individual_secrets():
    """Print individual secrets for manual configuration"""
    print("Individual secrets:")
    print()
    print(f"N8N_ENCRYPTION_KEY={generate_secure_key(64)}")
    print(f"N8N_USER_MANAGEMENT_JWT_SECRET={generate_secure_key(64)}")
    print(f"WEBUI_SECRET_KEY={generate_secure_key(64)}")
    print(f"JWT_SECRET={generate_secure_key(64)}")
    print(f"POSTGRES_PASSWORD={generate_secure_password(32)}")
    print()

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "--individual":
        print_individual_secrets()
    else:
        generate_env_file()