#!/bin/bash

# Script to switch between Caddy and Traefik reverse proxy configurations

set -e

echo "Local AI Packaged - Proxy Switcher"
echo "=================================="
echo ""
echo "1. Use Caddy (default)"
echo "2. Use Traefik"
echo "3. Check current configuration"
echo "4. Exit"
echo ""

read -p "Select option [1-4]: " choice

case $choice in
    1)
        echo "Switching to Caddy configuration..."
        if [ -f "docker-compose.yml" ]; then
            echo "Already using Caddy configuration"
        else
            ln -sf docker-compose.yml docker-compose.active.yml
            echo "Switched to Caddy. Use: make start"
        fi
        ;;
    2)
        echo "Switching to Traefik configuration..."
        if [ -f "docker-compose.traefik.yml" ]; then
            ln -sf docker-compose.traefik.yml docker-compose.active.yml
            echo "Switched to Traefik. Use: make start-traefik"
        else
            echo "Traefik configuration not found"
        fi
        ;;
    3)
        echo "Current configuration:"
        if [ -L "docker-compose.active.yml" ]; then
            current=$(readlink docker-compose.active.yml)
            echo "Active: $current"
        else
            echo "Active: docker-compose.yml (Caddy)"
        fi
        ;;
    4)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo ""
echo "Next steps:"
echo "- Run: make start (for Caddy)"
echo "- Run: make start-traefik (for Traefik)"
echo "- Access services at their respective URLs"