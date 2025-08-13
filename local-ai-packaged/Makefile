.PHONY: help start stop restart logs status clean update backup restore

# Default target
help:
	@echo "Local AI Packaged - Available Commands:"
	@echo ""
	@echo "  make start          - Start all services with auto-detected GPU"
	@echo "  make start-cpu      - Start all services with CPU only"
	@echo "  make start-gpu      - Start all services with NVIDIA GPU"
	@echo "  make stop           - Stop all services"
	@echo "  make restart        - Restart all services"
	@echo "  make status         - Show service status"
	@echo "  make logs           - Show all service logs"
	@echo "  make logs-<service> - Show specific service logs"
	@echo "  make clean         - Stop and remove all containers and volumes"
	@echo "  make update        - Update all service images"
	@echo "  make backup        - Backup all data volumes"
	@echo "  make restore       - Restore data from backup"

# Service management
start:
	@python start_services.py start

start-cpu:
	@python start_services.py start --profile cpu

start-gpu:
	@python start_services.py start --profile gpu-nvidia

stop:
	@python start_services.py stop

restart: stop start

status:
	@python start_services.py status

logs:
	@python start_services.py logs

logs-%:
	@python start_services.py logs $*

# Maintenance
clean:
	@echo "🧹 Cleaning up all containers and volumes..."
	@docker-compose down -v --remove-orphans
	@docker system prune -f

update:
	@echo "🔄 Updating all service images..."
	@docker-compose pull
	@docker-compose up -d

# Backup and restore
backup:
	@echo "💾 Creating backup..."
	@mkdir -p backups/$(shell date +%Y%m%d_%H%M%S)
	@docker run --rm -v ollama_data:/data -v $(PWD)/backups/$(shell date +%Y%m%d_%H%M%S):/backup alpine tar czf /backup/ollama_data.tar.gz /data
	@docker run --rm -v supabase_data:/data -v $(PWD)/backups/$(shell date +%Y%m%d_%H%M%S):/backup alpine tar czf /backup/supabase_data.tar.gz /data
	@docker run --rm -v n8n_data:/data -v $(PWD)/backups/$(shell date +%Y%m%d_%H%M%S):/backup alpine tar czf /backup/n8n_data.tar.gz /data
	@echo "✅ Backup completed in backups/$(shell date +%Y%m%d_%H%M%S)/"

restore:
	@echo "🔄 Restoring from backup..."
	@echo "Please specify backup directory: make restore BACKUP_DIR=YYYYMMDD_HHMMSS"

restore-%:
	@echo "🔄 Restoring from backup $*..."
	@docker run --rm -v ollama_data:/data -v $(PWD)/backups/$*:/backup alpine sh -c "tar xzf /backup/ollama_data.tar.gz -C / --strip-components=1"
	@docker run --rm -v supabase_data:/data -v $(PWD)/backups/$*:/backup alpine sh -c "tar xzf /backup/supabase_data.tar.gz -C / --strip-components=1"
	@docker run --rm -v n8n_data:/data -v $(PWD)/backups/$*:/backup alpine sh -c "tar xzf /backup/n8n_data.tar.gz -C / --strip-components=1"
	@echo "✅ Restore completed from $*"

# Development
dev-setup:
	@echo "🔧 Setting up development environment..."
	@cp .env.example .env
	@echo "⚠️  Please edit .env with your configuration"
	@echo "✅ Development setup complete"

dev-reset:
	@echo "🔄 Resetting development environment..."
	@make clean
	@make dev-setup
	@echo "✅ Development environment reset"