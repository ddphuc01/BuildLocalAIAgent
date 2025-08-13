#!/usr/bin/env python3
"""
Local AI Packaged - Service Management Script
This script manages the startup of all local AI services with GPU support detection.
"""

import os
import sys
import subprocess
import argparse
import platform
from pathlib import Path

def check_docker():
    """Check if Docker is installed and running."""
    try:
        subprocess.run(["docker", "--version"], check=True, capture_output=True)
        print("✅ Docker is installed")
        
        # Check if Docker daemon is running
        result = subprocess.run(["docker", "info"], capture_output=True, text=True)
        if result.returncode != 0:
            print("❌ Docker daemon is not running. Please start Docker Desktop first.")
            return False
        print("✅ Docker daemon is running")
        return True
    except subprocess.CalledProcessError:
        print("❌ Docker is not installed or not in PATH")
        return False

def check_gpu_support():
    """Check available GPU support on the system."""
    system = platform.system()
    
    if system == "Windows":
        # Check for NVIDIA GPU on Windows
        try:
            result = subprocess.run(["nvidia-smi"], capture_output=True, text=True)
            if result.returncode == 0:
                print("✅ NVIDIA GPU detected on Windows")
                return "gpu-nvidia"
        except FileNotFoundError:
            pass
    
    elif system == "Linux":
        # Check for NVIDIA GPU on Linux
        try:
            result = subprocess.run(["nvidia-smi"], capture_output=True, text=True)
            if result.returncode == 0:
                print("✅ NVIDIA GPU detected on Linux")
                return "gpu-nvidia"
        except FileNotFoundError:
            pass
        
        # Check for AMD GPU on Linux
        try:
            result = subprocess.run(["rocminfo"], capture_output=True, text=True)
            if result.returncode == 0:
                print("✅ AMD GPU detected on Linux")
                return "gpu-amd"
        except FileNotFoundError:
            pass
    
    elif system == "Darwin":
        # macOS - Apple Silicon
        if platform.machine() == "arm64":
            print("ℹ️  macOS Apple Silicon detected - GPU not available in Docker")
            return "cpu"
    
    print("ℹ️  No GPU detected or not supported, using CPU")
    return "cpu"

def setup_environment():
    """Set up the environment variables and check .env file."""
    env_file = Path(".env")
    
    if not env_file.exists():
        print("⚠️  .env file not found. Creating from .env.example...")
        example_file = Path(".env.example")
        if example_file.exists():
            import shutil
            shutil.copy(example_file, env_file)
            print("📋 Created .env file from .env.example")
            print("⚠️  Please update .env with your configuration before running again")
            return False
        else:
            print("❌ .env.example not found")
            return False
    
    return True

def start_services(profile):
    """Start all services using Docker Compose."""
    print(f"🚀 Starting Local AI Packaged services with profile: {profile}")
    
    # Set environment variable for Docker Compose
    env = os.environ.copy()
    env["DOCKER_PROFILE"] = profile
    
    # Build and start services
    cmd = ["docker-compose", "--profile", profile, "up", "-d", "--build"]
    
    try:
        subprocess.run(cmd, check=True, env=env)
        print("✅ Services started successfully!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to start services: {e}")
        return False

def stop_services():
    """Stop all services."""
    print("🛑 Stopping Local AI Packaged services...")
    try:
        subprocess.run(["docker-compose", "down"], check=True)
        print("✅ Services stopped successfully!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to stop services: {e}")
        return False

def show_status():
    """Show status of all services."""
    print("📊 Checking service status...")
    try:
        result = subprocess.run(["docker-compose", "ps"], capture_output=True, text=True)
        print(result.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to check status: {e}")
        return False

def show_logs(service=None):
    """Show logs for services."""
    if service:
        print(f"📋 Showing logs for {service}...")
        cmd = ["docker-compose", "logs", "-f", service]
    else:
        print("📋 Showing logs for all services...")
        cmd = ["docker-compose", "logs", "-f"]
    
    try:
        subprocess.run(cmd)
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to show logs: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description="Local AI Packaged Service Manager")
    parser.add_argument("action", choices=["start", "stop", "status", "logs"], 
                       help="Action to perform")
    parser.add_argument("--profile", choices=["cpu", "gpu-nvidia", "gpu-amd"], 
                       help="GPU profile to use")
    parser.add_argument("--service", help="Specific service for logs")
    
    args = parser.parse_args()
    
    # Change to script directory
    script_dir = Path(__file__).parent.absolute()
    os.chdir(script_dir)
    
    if not check_docker():
        sys.exit(1)
    
    if args.action == "start":
        if not setup_environment():
            sys.exit(1)
        
        profile = args.profile or check_gpu_support()
        start_services(profile)
        
        print("\n🎉 Local AI Packaged is ready!")
        print("\n📋 Access your services:")
        print("   • Open WebUI: http://localhost:3000")
        print("   • n8n: http://localhost:5678")
        print("   • Flowise: http://localhost:3001")
        print("   • Neo4j: http://localhost:7474")
        print("   • Langfuse: http://localhost:3030")
        print("   • SearXNG: http://localhost:8080")
        print("   • Supabase Studio: http://localhost:54323")
        
    elif args.action == "stop":
        stop_services()
    elif args.action == "status":
        show_status()
    elif args.action == "logs":
        show_logs(args.service)

if __name__ == "__main__":
    main()