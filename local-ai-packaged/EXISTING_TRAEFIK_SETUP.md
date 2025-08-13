# Hướng dẫn tích hợp với Traefik hiện có (phucduong.duckdns.org)

## Kiểm tra cấu hình Traefik hiện tại

### Bước 1: Kiểm tra Traefik đang chạy
```bash
# Windows PowerShell
docker ps | findstr traefik

# Kiểm tra logs
docker logs <traefik-container-name>
```

### Bước 2: Xác minh network
```bash
# Kiểm tra network traefik_default
docker network ls | findstr traefik

# Kiểm tra services trong network
docker network inspect traefik_default
```

## Cấu hình cho domain phucduong.duckdns.org

### Bước 1: Tạo file .env
```bash
# Copy file cấu hình
copy .env.traefik .env

# Chỉnh sửa file .env với giá trị thực tế của bạn
notepad .env
```

### Bước 2: Cập nhật các subdomain
Các dịch vụ sẽ được cấu hình với các subdomain sau:
- **Open WebUI**: https://webui.phucduong.duckdns.org
- **n8n**: https://n8n.phucduong.duckdns.org
- **Flowise**: https://flowise.phucduong.duckdns.org
- **Neo4j**: https://neo4j.phucduong.duckdns.org
- **Langfuse**: https://langfuse.phucduong.duckdns.org
- **SearXNG**: https://search.phucduong.duckdns.org
- **Supabase**: https://supabase.phucduong.duckdns.org
- **Qdrant**: https://qdrant.phucduong.duckdns.org

### Bước 3: Cập nhật file .env

Thay thế các giá trị placeholder trong `.env` với giá trị thực tế:

```env
# === Security Keys (Đổi tất cả các giá trị này) ===
N8N_ENCRYPTION_KEY=your-very-secure-key-here
N8N_USER_MANAGEMENT_JWT_SECRET=your-jwt-secret-here
N8N_BASIC_AUTH_PASSWORD=your-n8n-password
POSTGRES_PASSWORD=your-secure-postgres-password
JWT_SECRET=your-jwt-secret-key
ANON_KEY=your-anon-key-for-supabase
SERVICE_ROLE_KEY=your-service-role-key-for-supabase
DASHBOARD_PASSWORD=your-supabase-password
NEO4J_AUTH=neo4j/your-neo4j-password
WEBUI_SECRET_KEY=your-webui-secret-key
FLOWISE_PASSWORD=your-flowise-password
SECRETKEY=your-flowise-secret-key
```

## Triển khai với Traefik hiện có

### Cách 1: Sử dụng docker-compose.existing-traefik.yml

```bash
# Khởi động tất cả services với Traefik hiện có
docker-compose -f docker-compose.existing-traefik.yml up -d

# Kiểm tra logs
docker-compose -f docker-compose.existing-traefik.yml logs -f
```

### Cách 2: Tích hợp vào compose file hiện tại

Nếu bạn đã có docker-compose.yml riêng, thêm các labels sau vào services:

```yaml
services:
  open-webui:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.open-webui.rule=Host(`webui.phucduong.duckdns.org`)"
      - "traefik.http.routers.open-webui.entrypoints=websecure"
      - "traefik.http.routers.open-webui.tls.certresolver=letsencrypt"
      - "traefik.http.services.open-webui.loadbalancer.server.port=8080"
```

## Kiểm tra sau khi triển khai

### 1. Kiểm tra services đang chạy
```bash
docker-compose -f docker-compose.existing-traefik.yml ps
```

### 2. Kiểm tra logs nếu có lỗi
```bash
# Kiểm tra logs tổng quát
docker-compose -f docker-compose.existing-traefik.yml logs

# Kiểm tra logs từng service
docker-compose -f docker-compose.existing-traefik.yml logs open-webui
docker-compose -f docker-compose.existing-traefik.yml logs n8n
```

### 3. Kiểm tra truy cập qua HTTPS
Mở trình duyệt và truy cập:
- https://webui.phucduong.duckdns.org
- https://n8n.phucduong.duckdns.org
- https://flowise.phucduong.duckdns.org
- https://neo4j.phucduong.duckdns.org
- https://langfuse.phucduong.duckdns.org
- https://search.phucduong.duckdns.org
- https://supabase.phucduong.duckdns.org
- https://qdrant.phucduong.duckdns.org

## Xử lý lỗi thường gặp

### Lỗi certificate
Nếu gặp lỗi certificate, kiểm tra:
1. Traefik có đang chạy không
2. Port 80 và 443 có bị chặn không
3. DNS có đang trỏ đúng không

### Lỗi network
Nếu services không thể kết nối:
```bash
# Kiểm tra network
docker network ls
docker network inspect traefik_default

# Kiểm tra services trong network
docker network inspect traefik_default | grep -A 10 Containers
```

### Lỗi port conflict
Nếu gặp lỗi port đã được sử dụng:
```bash
# Kiểm tra port đang sử dụng
netstat -ano | findstr :8080
netstat -ano | findstr :3000
```

## Cập nhật và bảo trì

### Cập nhật services
```bash
# Pull images mới
docker-compose -f docker-compose.existing-traefik.yml pull

# Restart services
docker-compose -f docker-compose.existing-traefik.yml restart
```

### Dừng services
```bash
docker-compose -f docker-compose.existing-traefik.yml down

# Xóa volumes (cẩn thận - sẽ mất dữ liệu)
docker-compose -f docker-compose.existing-traefik.yml down -v
```

## Lưu ý bảo mật

1. **Đổi tất cả mật khẩu mặc định**
2. **Sử dụng HTTPS cho production**
3. **Cấu hình firewall nếu cần**
4. **Backup dữ liệu định kỳ**

## Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra logs của từng service
2. Kiểm tra cấu hình Traefik
3. Kiểm tra DNS resolution
4. Liên hệ nếu cần hỗ trợ thêm