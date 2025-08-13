# Local AI Packaged - Quick Start Guide

## 🚀 5-Minute Setup

### 1. Prerequisites Check
```bash
# Verify Docker is installed
docker --version

# Verify Python is installed
python --version
```

### 2. Quick Start Commands
```bash
# Clone and enter directory
git clone <your-repo-url>
cd local-ai-packaged

# Copy environment file
cp .env.example .env

# Edit .env with your settings (optional for quick start)
nano .env

# Start everything
python start_services.py start

# Or use Make
make start
```

### 3. Access Your Services

| Service | URL | Purpose |
|---------|-----|---------|
| **Open WebUI** | http://localhost:3000 | Chat with AI models |
| **n8n** | http://localhost:5678 | Build AI workflows |
| **Flowise** | http://localhost:3001 | Create AI agents |
| **Neo4j** | http://localhost:7474 | Knowledge graphs |
| **Langfuse** | http://localhost:3030 | Monitor AI usage |
| **SearXNG** | http://localhost:8080 | Private search |

## 🎯 First 3 Things to Try

### 1. Chat with AI (2 minutes)
1. Open http://localhost:3000
2. Start chatting immediately
3. Try: "Write a Python function to calculate fibonacci"

### 2. Create a Workflow (5 minutes)
1. Open http://localhost:5678
2. Create new workflow
3. Add "Webhook" trigger
4. Add "Ollama" node
5. Test with text generation

### 3. Build an AI Agent (5 minutes)
1. Open http://localhost:3001
2. Create new chatflow
3. Add "Ollama" LLM node
4. Add "Conversational Retrieval QA Chain"
5. Test with document Q&A

## 🔧 Essential Commands

```bash
# Service management
make start          # Start all services
make stop           # Stop all services
make status         # Check service status
make logs           # View all logs
make logs-n8n       # View n8n logs only

# Development
make clean          # Clean everything
make update         # Update all services
make backup         # Backup your data
```

## 📋 Default Credentials

| Service | Username | Password |
|---------|----------|----------|
| n8n | admin | From .env file |
| Flowise | admin | From .env file |
| Neo4j | neo4j | From .env file |
| Supabase | admin | From .env file |

## 🆘 Troubleshooting Quick Fixes

### Services won't start?
```bash
# Check what's running on ports
sudo lsof -i :3000
sudo lsof -i :5678

# Restart everything
make clean && make start
```

### Out of memory?
```bash
# Check Docker memory settings
# Increase to 8GB+ in Docker Desktop

# Use CPU instead of GPU
python start_services.py start --profile cpu
```

### GPU not detected?
```bash
# Force CPU mode
make start-cpu

# Check GPU support
python start_services.py start --profile gpu-nvidia
```

## 📊 Your AI Ecosystem is Ready!

You now have a complete AI development environment that includes:

- ✅ **Local ChatGPT** (Open WebUI + Ollama)
- ✅ **AI Workflow Builder** (n8n)
- ✅ **AI Agent Creator** (Flowise)
- ✅ **Knowledge Base** (Supabase + Neo4j)
- ✅ **Private Search** (SearXNG)
- ✅ **AI Monitoring** (Langfuse)

## 🎉 Next Steps

1. **Pull AI Models**:
   ```bash
   docker exec -it ollama ollama pull llama2
   docker exec -it ollama ollama pull mistral
   ```

2. **Explore Documentation**:
   - Read `EXPLANATION.md` for detailed explanations
   - Check `docs/ARCHITECTURE.md` for technical details
   - See `docs/SETUP.md` for advanced configuration

3. **Join Community**:
   - Report issues on GitHub
   - Share your workflows
   - Contribute improvements

## 🏁 You're All Set!

Your local AI development environment is running. Start building amazing AI applications with complete privacy and control! 🚀