# Local AI Packaged 🚀

A comprehensive, self-hosted AI development environment that packages together the best open-source AI tools and platforms. Run everything locally with a single command!

## 🌟 What's Included

This package brings together essential AI tools and services:

| Service | Port | Purpose |
|---------|------|---------|
| **Ollama** | 11434 | Local LLM inference server |
| **Open WebUI** | 3000 | ChatGPT-like interface for your models |
| **n8n** | 5678 | Low-code workflow automation |
| **Supabase** | 5432/54321/54323 | Database, auth, and vector storage |
| **Flowise** | 3001 | No-code AI agent builder |
| **Neo4j** | 7474 | Knowledge graph database |
| **Qdrant** | 6333 | Vector similarity search engine |
| **SearXNG** | 8080 | Private metasearch engine |
| **Langfuse** | 3030 | LLM observability and analytics |
| **Caddy** | 80/443 | Reverse proxy with HTTPS |

## 🚀 Quick Start

### Prerequisites

- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)
- **Python 3.8+** (for the setup script)
- **Git** (for cloning)

### Installation

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   cd local-ai-packaged
   ```

2. **Configure environment variables**:
   ```bash
   # Copy the example file
   cp .env.example .env
   
   # Edit .env with your values
   # IMPORTANT: Replace all placeholder values with secure secrets!
   ```

3. **Start all services**:
   ```bash
   # Windows
   python start_services.py start
   
   # Linux/Mac
   python3 start_services.py start
   ```

4. **Access your services**:
   - **Open WebUI**: http://localhost:3000 (Chat with your models)
   - **n8n**: http://localhost:5678 (Create AI workflows)
   - **Flowise**: http://localhost:3001 (Build AI agents)
   - **Neo4j**: http://localhost:7474 (Knowledge graphs)
   - **Langfuse**: http://localhost:3030 (Monitor your LLMs)
   - **SearXNG**: http://localhost:8080 (Private search)
   - **Supabase Studio**: http://localhost:54323 (Database management)

## 🔧 GPU Support

The package automatically detects your GPU configuration:

### NVIDIA GPU
```bash
python start_services.py start --profile gpu-nvidia
```

### AMD GPU (Linux only)
```bash
python start_services.py start --profile gpu-amd
```

### CPU Only
```bash
python start_services.py start --profile cpu
```

## 📋 Service Details

### 1. **Ollama** - Your Local LLM Engine
- **Purpose**: Run open-source language models locally
- **Models**: Pull models like `llama2`, `mistral`, `codellama`, etc.
- **Usage**: 
  ```bash
  docker exec -it ollama ollama pull llama2
  docker exec -it ollama ollama pull mistral
  ```

### 2. **Open WebUI** - Chat Interface
- **Purpose**: ChatGPT-like interface for local models
- **Features**: 
  - Multi-model conversations
  - Document upload and RAG
  - Custom system prompts
  - User management
- **Setup**: Connects automatically to Ollama

### 3. **n8n** - Workflow Automation
- **Purpose**: Create AI-powered workflows without coding
- **Features**:
  - 400+ integrations
  - AI nodes for LLM calls
  - Vector database operations
  - Scheduled workflows
- **Credentials**: Default admin/admin (change immediately!)

### 4. **Supabase** - Backend Platform
- **Purpose**: Database, auth, and vector storage
- **Features**:
  - PostgreSQL database
  - Row-level security
  - Vector embeddings storage
  - Real-time subscriptions
- **Access**: Supabase Studio at http://localhost:54323

### 5. **Flowise** - AI Agent Builder
- **Purpose**: Visual builder for AI applications
- **Features**:
  - Drag-and-drop interface
  - Pre-built AI components
  - Integration with local models
  - API endpoints generation

### 6. **Neo4j** - Knowledge Graphs
- **Purpose**: Store and query connected data
- **Features**:
  - GraphRAG capabilities
  - Entity relationship mapping
  - Complex pattern matching
  - Visualization tools

### 7. **Qdrant** - Vector Database
- **Purpose**: High-performance vector similarity search
- **Features**:
  - Fast vector indexing
  - Hybrid search (dense + sparse)
  - Filtering capabilities
  - REST and gRPC APIs

### 8. **SearXNG** - Private Search
- **Purpose**: Metasearch without tracking
- **Features**:
  - Aggregates 70+ search engines
  - No user tracking
  - Customizable engines
  - Open-source and self-hosted

### 9. **Langfuse** - LLM Observability
- **Purpose**: Monitor and debug AI applications
- **Features**:
  - Request tracing
  - Cost tracking
  - Performance metrics
  - A/B testing

### 10. **Caddy** - Reverse Proxy
- **Purpose**: Secure access to all services
- **Features**:
  - Automatic HTTPS
  - Load balancing
  - Request routing
  - Security headers

## 🔐 Security Considerations

### Initial Setup
1. **Change all default passwords** in the .env file
2. **Generate secure secrets** for all services
3. **Update authentication** for n8n and Flowise
4. **Configure HTTPS** for production use

### Production Deployment
1. **Use strong passwords** for all services
2. **Enable HTTPS** with valid certificates
3. **Configure firewall** rules
4. **Regular updates** of all containers
5. **Monitor logs** for suspicious activity

## 🛠️ Management Commands

### Service Management
```bash
# Start services
python start_services.py start

# Stop services
python start_services.py stop

# Check status
python start_services.py status

# View logs
python start_services.py logs
python start_services.py logs n8n  # Specific service
```

### Docker Commands
```bash
# Manual control
docker-compose up -d
docker-compose down
docker-compose restart

# View logs
docker-compose logs -f

# Update services
docker-compose pull
docker-compose up -d
```

## 📁 Data Persistence

All data is stored in Docker volumes:
- `ollama_data`: LLM models and cache
- `open_webui_data`: Chat history and settings
- `supabase_data`: Database files
- `n8n_data`: Workflows and credentials
- `flowise_data`: AI agent configurations
- `neo4j_data`: Knowledge graphs
- `qdrant_data`: Vector embeddings
- `searxng_data`: Search engine settings

**Backup these volumes** regularly to prevent data loss.

## 🐛 Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 3000-3030, 5678, 8080, 5432-5434 are available
2. **Memory issues**: Increase Docker memory allocation (minimum 8GB recommended)
3. **GPU not detected**: Check NVIDIA Docker runtime installation
4. **Services not starting**: Check logs with `python start_services.py logs`

### Performance Tuning

1. **Increase Docker resources**: 
   - Memory: 8GB+ (16GB recommended)
   - CPUs: 4+ cores
   - Swap: 2GB+

2. **Model selection**: 
   - Start with smaller models (7B parameters)
   - Use quantized models for lower memory usage

3. **Database optimization**:
   - Regular vacuum of PostgreSQL
   - Monitor disk space usage

## 🔄 Updates

### Service Updates
```bash
# Update all services
docker-compose pull
docker-compose up -d

# Update specific service
docker-compose pull n8n
docker-compose up -d n8n
```

### Model Updates
```bash
# Update Ollama models
docker exec -it ollama ollama pull llama2:latest
docker exec -it ollama ollama pull mistral:latest
```

## 📚 Documentation

- [Ollama Documentation](https://ollama.ai)
- [n8n Documentation](https://docs.n8n.io)
- [Supabase Documentation](https://supabase.com/docs)
- [Flowise Documentation](https://docs.flowiseai.com)
- [Neo4j Documentation](https://neo4j.com/docs)
- [Langfuse Documentation](https://langfuse.com/docs)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues**: Create GitHub issues for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Discord**: Join our community Discord server

---

**⚠️ Disclaimer**: This is a development environment. Use appropriate security measures for production deployments.