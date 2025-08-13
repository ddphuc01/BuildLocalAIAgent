# Traefik Integration Guide

This guide explains how to integrate your Local AI Packaged repository with an existing Traefik reverse proxy.

## Overview

The repository includes complete Traefik configuration that can replace the default Caddy setup. Traefik provides advanced routing, load balancing, and automatic HTTPS with Let's Encrypt.

## Quick Start with Traefik

### Option 1: Use Traefik Instead of Caddy (Recommended)

1. **Use the Traefik-specific compose file:**
   ```bash
   docker-compose -f docker-compose.traefik.yml up -d
   ```

2. **Access your services:**
   - Open WebUI: http://localhost/webui
   - n8n: http://localhost/n8n
   - Flowise: http://localhost/flowise
   - Neo4j Browser: http://localhost/neo4j
   - Langfuse: http://localhost/langfuse
   - SearXNG: http://localhost/search
   - Supabase Studio: http://localhost/supabase
   - Traefik Dashboard: http://localhost:8080/dashboard/

### Option 2: Integrate with Existing Traefik

If you already have Traefik running, you can integrate these services by:

1. **Copy the dynamic configurations:**
   ```bash
   cp dynamic/*.yml /path/to/your/traefik/dynamic/
   ```

2. **Update the docker-compose.yml** to use your existing Traefik network:
   ```yaml
   networks:
     default:
       external:
         name: traefik_default
   ```

3. **Remove the Traefik service** from docker-compose.traefik.yml and use your existing one.

## Configuration Details

### Service Routes

| Service | Path Prefix | Internal Port |
|---------|-------------|---------------|
| Open WebUI | `/webui` | 8080 |
| n8n | `/n8n` | 5678 |
| Flowise | `/flowise` | 3000 |
| Neo4j | `/neo4j` | 7474 |
| Langfuse | `/langfuse` | 3000 |
| SearXNG | `/search` | 8080 |
| Supabase | `/supabase` | 54323 |

### Environment Variables

Update your `.env` file with these Traefik-specific variables:

```bash
# Traefik Configuration
TRAEFIK_DASHBOARD_PORT=8080
TRAEFIK_API_ENABLED=true

# For production HTTPS
ACME_EMAIL=your-email@domain.com
DOMAIN=yourdomain.com
```

## Production Setup with HTTPS

1. **Enable HTTPS in traefik.yml:**
   ```yaml
   certificatesResolvers:
     letsencrypt:
       acme:
         email: your-email@domain.com
         storage: /etc/traefik/acme.json
         httpChallenge:
           entryPoint: web
   ```

2. **Update service labels for HTTPS:**
   ```yaml
   labels:
     - "traefik.http.routers.open-webui.tls.certResolver=letsencrypt"
     - "traefik.http.routers.open-webui.rule=Host(`ai.yourdomain.com`)"
   ```

3. **Create acme.json for certificates:**
   ```bash
   touch acme.json
   chmod 600 acme.json
   ```

## Advanced Configuration

### Custom Domains

Replace `localhost` with your domain in the dynamic configuration files:

```yaml
# In dynamic/*.yml files
rule: "Host(`ai.yourdomain.com`)"
```

### Load Balancing

Traefik automatically load balances between service replicas. Add replicas:

```yaml
services:
  open-webui:
    deploy:
      replicas: 3
```

### Health Checks

Add health checks to your services:

```yaml
labels:
  - "traefik.http.services.open-webui.loadbalancer.healthcheck.path=/health"
  - "traefik.http.services.open-webui.loadbalancer.healthcheck.interval=30s"
```

## Migration from Caddy to Traefik

1. **Stop Caddy services:**
   ```bash
   docker-compose down
   ```

2. **Start Traefik services:**
   ```bash
   docker-compose -f docker-compose.traefik.yml up -d
   ```

3. **Verify all services are accessible**

## Troubleshooting

### Common Issues

1. **Port conflicts:** Ensure ports 80, 443, and 8080 are available
2. **Network issues:** Verify all services are on the same network
3. **DNS resolution:** Check that your domain resolves correctly

### Debug Commands

```bash
# Check Traefik logs
docker-compose -f docker-compose.traefik.yml logs traefik

# Check service status
docker-compose -f docker-compose.traefik.yml ps

# Access Traefik dashboard
curl http://localhost:8080/api/http/routers
```

## Integration with External Traefik

If you have Traefik running outside Docker:

1. **Configure Traefik to use Docker provider**
2. **Ensure Docker socket is accessible**
3. **Update network configuration**

### Example External Traefik Configuration

```yaml
# traefik.yml
providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: "traefik_default"
```

## Security Considerations

1. **Use HTTPS in production**
2. **Configure proper authentication**
3. **Limit Traefik dashboard access**
4. **Use strong passwords**
5. **Enable rate limiting**

### Rate Limiting Example

```yaml
labels:
  - "traefik.http.middlewares.rate-limit.ratelimit.average=100"
  - "traefik.http.middlewares.rate-limit.ratelimit.burst=50"
  - "traefik.http.routers.open-webui.middlewares=rate-limit"
```

## Next Steps

1. **Configure custom domains**
2. **Set up HTTPS certificates**
3. **Add authentication middleware**
4. **Monitor service health**
5. **Set up backup and recovery**

For more advanced Traefik configurations, refer to the [official Traefik documentation](https://doc.traefik.io/traefik/).