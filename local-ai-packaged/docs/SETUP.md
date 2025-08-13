# Local AI Packaged - Complete Setup Guide

## 🎯 Overview

This guide provides step-by-step instructions for setting up your complete local AI development environment. By the end of this guide, you'll have a fully functional AI ecosystem running on your machine.

## 📋 Pre-Installation Checklist

### System Requirements
- **Operating System**: Windows 10/11, macOS 10.15+, or Linux (Ubuntu 20.04+)
- **RAM**: Minimum 8GB (16GB+ recommended)
- **Storage**: 50GB+ free space (100GB+ recommended)
- **CPU**: 4+ cores (8+ cores recommended)
- **GPU**: Optional but recommended (NVIDIA/AMD)

### Required Software
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/Mac)
- [Docker Engine](https://docs.docker.com/engine/install/) (Linux)
- [Python 3.8+](https://www.python.org/downloads/)
- [Git](https://git-scm.com/downloads)

## 🚀 Step-by-Step Installation

### Step 1: Install Docker

#### Windows
1. Download Docker Desktop from the official website
2. Run the installer and follow the prompts
3. Restart your computer when prompted
4. Verify installation:
   ```powershell
   docker --version
   docker run hello-world
   ```

#### macOS
1. Download Docker Desktop for Mac
2. Install the .dmg file
3. Drag Docker to Applications
4. Verify installation:
   ```bash
   docker --version
   docker run hello-world
   ```

#### Linux (Ubuntu/Debian)
```bash
# Update package index
sudo apt update

# Install required packages
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up stable repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker $USER

# Verify installation
docker --version
docker run hello-world
```

### Step 2: Install Python

#### Windows
1. Download Python from python.org
2. Run installer (check "Add Python to PATH")
3. Verify installation:
   ```powershell
   python --version
   pip --version
   ```

#### macOS
```bash
# Using Homebrew
brew install python3

# Or download from python.org
python3 --version
```

#### Linux
```bash
sudo apt update
sudo apt install python3 python3-pip
python3 --version
```

### Step 3: Clone and Setup

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   cd local-ai-packaged
   ```

2. **Set up environment**:
   ```bash
   # Copy environment template
   cp .env.example .env
   
   # Edit the .env file with your settings
   nano .env  # or use your preferred editor
   ```

### Step 4: Configure Environment Variables

Edit `.env` with secure values:

```bash
# === Critical Security Settings ===
POSTGRES_PASSWORD=$(openssl rand -base64 32)
JWT_SECRET=$(openssl rand -base64 32)
N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)
WEBUI_SECRET_KEY=$(openssl rand -base64 32)
NEO4J_AUTH=neo4j:$(openssl rand -base64 32)

# === Service Configuration ===
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=$(openssl rand -base64 16)
FLOWISE_USERNAME=admin
FLOWISE_PASSWORD=$(openssl rand -base64 16)
```

### Step 5: GPU Configuration (Optional)

#### NVIDIA GPU Setup

**Windows**:
1. Install [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
2. Verify GPU access:
   ```powershell
   docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
   ```

**Linux**:
```bash
# Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# Verify
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```

#### AMD GPU Setup (Linux)
```bash
# Install ROCm
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
sudo apt update
sudo apt install rocm-dkms

# Add user to video group
sudo usermod -a -G video $USER

# Verify
docker run --rm --device=/dev/kfd --device=/dev/dri --group-add video rocm/rocm-terminal rocm-smi
```

### Step 6: Start Services

#### Option 1: Using Python Script (Recommended)
```bash
# Auto-detect GPU
python start_services.py start

# Force CPU
python start_services.py start --profile cpu

# Force NVIDIA GPU
python start_services.py start --profile gpu-nvidia

# Force AMD GPU (Linux)
python start_services.py start --profile gpu-amd
```

#### Option 2: Using Make
```bash
make start        # Auto-detect
make start-cpu    # Force CPU
make start-gpu    # Force NVIDIA GPU
```

#### Option 3: Using Docker Compose Directly
```bash
# CPU
DOCKER_PROFILE=cpu docker-compose --profile cpu up -d

# NVIDIA GPU
DOCKER_PROFILE=gpu-nvidia docker-compose --profile gpu-nvidia up -d
```

## 🔍 Verification

### Check Service Status
```bash
# Using Python script
python start_services.py status

# Using Make
make status

# Using Docker Compose
docker-compose ps
```

### Test Each Service

1. **Open WebUI**: http://localhost:3000
   - Should show chat interface
   - Connect to Ollama automatically

2. **n8n**: http://localhost:5678
   - Login with credentials from .env
   - Create a simple workflow

3. **Flowise**: http://localhost:3001
   - Create a new AI agent
   - Test with local LLM

4. **Neo4j**: http://localhost:7474
   - Login with neo4j/password
   - Run sample Cypher query

5. **Supabase Studio**: http://localhost:54323
   - Access database management
   - Create test tables

## 🎯 First-Time Configuration

### 1. Configure Ollama Models

```bash
# Pull popular models
docker exec -it ollama ollama pull llama2
docker exec -it ollama ollama pull mistral
docker exec -it ollama ollama pull codellama
docker exec -it ollama ollama pull llava

# List available models
docker exec -it ollama ollama list
```

### 2. Set Up n8n Workflows

1. Access n8n at http://localhost:5678
2. Create admin user (if prompted)
3. Install AI nodes:
   - Go to Settings → Community Nodes
   - Install "n8n-nodes-langchain"
   - Install "n8n-nodes-ollama"

### 3. Configure Flowise

1. Access Flowise at http://localhost:3001
2. Create new chatflow
3. Add Ollama LLM node
4. Test with your local model

### 4. Set Up Supabase

1. Access Supabase Studio at http://localhost:54323
2. Create new project
3. Set up authentication
4. Create vector extension:
   ```sql
   CREATE EXTENSION vector;
   ```

### 5. Configure Neo4j

1. Access Neo4j Browser at http://localhost:7474
2. Login with neo4j/your-password
3. Install APOC procedures:
   ```cypher
   CALL apoc.help('apoc');
   ```

## 🛠️ Advanced Configuration

### Custom Domain Setup

1. **Edit Caddyfile**:
   ```caddy
   yourdomain.com {
       reverse_proxy open-webui:8080
   }
   
   n8n.yourdomain.com {
       reverse_proxy n8n:5678
   }
   ```

2. **Update .env**:
   ```bash
   WEBUI_HOSTNAME=chat.yourdomain.com
   N8N_HOSTNAME=workflows.yourdomain.com
   ```

### Memory Optimization

#### Docker Memory Settings

**Windows/Mac**:
1. Open Docker Desktop settings
2. Go to Resources → Advanced
3. Set Memory: 8GB+
4. Set CPUs: 4+
5. Set Swap: 2GB+

**Linux**:
```bash
# Create daemon configuration
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "default-ulimits": {
    "memlock": {
      "Hard": -1,
      "Name": "memlock",
      "Soft": -1
    }
  },
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
```

### Model Storage Optimization

```bash
# Check model sizes
docker exec -it ollama du -sh /root/.ollama

# Remove unused models
docker exec -it ollama ollama rm model-name

# Use quantized models
docker exec -it ollama ollama pull llama2:7b-chat-q4_0
```

## 🔐 Security Hardening

### 1. Change Default Passwords

```bash
# Generate secure passwords
openssl rand -base64 32

# Update all service passwords
# Edit .env file with new passwords
```

### 2. Enable HTTPS

1. **Production Setup**:
   ```bash
   # Update Caddyfile for HTTPS
   yourdomain.com {
       reverse_proxy open-webui:8080
   }
   ```

2. **Let's Encrypt**:
   ```bash
   # Set email in .env
   LETSENCRYPT_EMAIL=your-email@domain.com
   ```

### 3. Firewall Configuration

**Linux (UFW)**:
```bash
# Allow only necessary ports
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

**Windows**:
1. Open Windows Defender Firewall
2. Create inbound rules for ports 3000, 5678, 8080
3. Restrict to specific IP ranges

## 📊 Monitoring Setup

### 1. Health Checks

```bash
# Create health check script
#!/bin/bash
curl -f http://localhost:3000/health || echo "Open WebUI down"
curl -f http://localhost:5678/health || echo "n8n down"
curl -f http://localhost:7474 || echo "Neo4j down"
```

### 2. Resource Monitoring

```bash
# Install monitoring tools
docker run -d --name=netdata \
  -p 19999:19999 \
  -v netdatalib:/var/lib/netdata \
  -v netdatacache:/var/cache/netdata \
  -v /etc/passwd:/host/etc/passwd:ro \
  -v /etc/group:/host/etc/group:ro \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /etc/os-release:/host/etc/os-release:ro \
  --restart unless-stopped \
  netdata/netdata
```

## 🔄 Backup and Recovery

### Automated Backup

```bash
# Create backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/$DATE"
mkdir -p $BACKUP_DIR

# Backup volumes
docker run --rm -v ollama_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/ollama.tar.gz /data
docker run --rm -v supabase_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/supabase.tar.gz /data
docker run --rm -v n8n_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/n8n.tar.gz /data

# Backup environment
cp .env $BACKUP_DIR/
```

### Recovery Process

```bash
# Restore from backup
BACKUP_DATE="20240101_120000"
docker run --rm -v ollama_data:/data -v /backups/$BACKUP_DATE:/backup alpine sh -c "tar xzf /backup/ollama.tar.gz -C / --strip-components=1"
```

## 🆘 Troubleshooting

### Common Issues

#### 1. Port Already in Use
```bash
# Check what's using port 3000
sudo lsof -i :3000
# Kill process or change port in docker-compose.yml
```

#### 2. Out of Memory
```bash
# Check memory usage
docker stats
# Increase Docker memory allocation
# Use smaller models
```

#### 3. GPU Not Detected
```bash
# Verify GPU access
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
# Check NVIDIA Container Toolkit installation
```

#### 4. Services Not Starting
```bash
# Check logs
docker-compose logs [service-name]
# Restart services
docker-compose restart [service-name]
```

### Debug Mode

```bash
# Start in debug mode
docker-compose --verbose up

# Check individual service
docker-compose logs -f [service-name]
```

## 📚 Next Steps

1. **Explore Services**: Start with Open WebUI and n8n
2. **Create Workflows**: Build your first AI workflow
3. **Customize Models**: Add your preferred LLMs
4. **Scale Up**: Add more services as needed
5. **Monitor Performance**: Set up monitoring tools

## 🤝 Support

- **Documentation**: Check docs/ folder
- **Issues**: Create GitHub issues
- **Community**: Join Discord/Slack
- **Updates**: Follow release notes

---

**Congratulations!** You now have a fully functional local AI development environment. Start building amazing AI applications! 🎉