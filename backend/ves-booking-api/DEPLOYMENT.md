# 🚀 VPS Deployment Guide

This guide shows you how to deploy the VES Booking API on a VPS using Docker Compose.

## 📋 Prerequisites

- VPS with Ubuntu/Debian Linux
- Docker installed
- Docker Compose installed
- **Minimum:** 1GB RAM, 1 CPU core (optimized for small VPS)
- **Recommended:** 2GB RAM, 2 CPU cores (for better performance)
- **Your VPS:** 7.8GB RAM, 4 CPU cores ✅ (Excellent! Optimized configuration included)

## 🔧 Quick Start

### 1. Clone and Navigate to Project

```bash
git clone <your-repo-url>
cd ves-event-booking-app/backend/ves-booking-api
```

### 2. Build and Start Services

```bash
# Build and start all services (MySQL + Spring Boot App)
docker-compose up -d --build

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

### 3. Verify Deployment

```bash
# Check if services are running
docker-compose ps

# Test API
curl http://localhost:8080/api/categories

# Check MySQL
docker exec -it ves-booking-mysql mysql -uroot -proot -e "SHOW DATABASES;"
```

## 🔐 Environment Variables

You can customize the deployment by creating a `.env` file:

```bash
# .env file
DBMS_USERNAME=root
DBMS_PASSWORD=your_secure_password
MYSQL_ROOT_PASSWORD=your_secure_password
MYSQL_PASSWORD=your_secure_password
```

Then update `docker-compose.yml` to use these variables.

## 📊 Service Information

### Services

- **MySQL (MariaDB)**: Port `3306`

  - Container: `ves-booking-mysql`
  - Database: `ves_booking_api`
  - Username: `root` (default)
  - Password: `root` (default - **change in production!**)

- **Spring Boot API**: Port `8080`
  - Container: `ves-booking-api`
  - Base URL: `http://localhost:8080/api`
  - Swagger UI: `http://localhost:8080/api/swagger-ui.html`

### Resource Limits

**For Small VPS (1-2GB RAM):**

- **MySQL**: 384MB RAM limit, 192MB reserved, 0.5 CPU
- **Spring Boot App**: 512MB RAM limit, 256MB reserved, 1.0 CPU
- **Total**: ~896MB RAM limit, ~448MB reserved

**For Your VPS (7.8GB RAM, 4 CPU cores) - Current Configuration:**

- **MySQL**: 1GB RAM limit, 512MB reserved, 1.0 CPU
- **Spring Boot App**: 2GB RAM limit, 1GB reserved, 2.0 CPU
- **Total Docker**: ~3GB RAM limit, ~1.5GB reserved
- **Reserved for Frontend**: ~1-2GB RAM (for admin portal)
- **System overhead**: ~500MB-1GB for OS and Docker
- **Available**: ~7.8GB total (comfortable with room for frontend)

## 🛠️ Common Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Stop and remove volumes (⚠️ deletes data)
docker-compose down -v

# View logs
docker-compose logs -f app
docker-compose logs -f mysql

# Restart a service
docker-compose restart app
docker-compose restart mysql

# Rebuild and restart
docker-compose up -d --build

# Check resource usage
docker stats
```

## 🔄 Update Application

```bash
# Pull latest code
git pull

# Rebuild and restart
docker-compose up -d --build app

# Or restart all services
docker-compose up -d --build
```

## 💡 VPS Optimization Tips

### For Your VPS (7.8GB RAM, 4 CPU cores):

1. **Enable Swap** (safety measure, even with plenty of RAM):

```bash
# Check current swap
free -h
swapon --show

# Create 2GB swap file (optional but recommended)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Verify
free -h
```

2. **Resource Allocation Summary:**

   - **Backend (Docker)**: ~3GB RAM, 3 CPU cores
   - **Frontend (Admin Portal)**: ~1-2GB RAM, 1 CPU core
   - **System**: ~500MB-1GB RAM
   - **Available buffer**: ~1-2GB RAM

3. **Frontend Deployment Options:**

   - **Option A**: Nginx serving static files (lightweight, ~50MB RAM)
   - **Option B**: Node.js/Next.js app (requires ~500MB-1GB RAM)
   - **Option C**: Separate VPS for frontend (if needed)

4. **Monitor Resources:**

```bash
# Real-time monitoring
docker stats
htop  # or top
free -h
```

### For VPS with 1GB RAM:

1. **Enable Swap** (if not already enabled):

```bash
# Check swap
free -h

# Create 1GB swap file if needed
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

2. **Monitor Resource Usage**:

```bash
# Check memory usage
docker stats

# Check system resources
free -h
df -h
```

3. **Reduce Log Verbosity** (optional):
   Edit `application.yaml`:

```yaml
spring:
  jpa:
    show-sql: false # Disable SQL logging in production
```

4. **Stop Unused Services**:

```bash
# Stop unnecessary system services
sudo systemctl stop snapd  # If not using snap
sudo systemctl disable snapd
```

5. **Use Docker Resource Limits** (already configured):

- MySQL: 384MB max
- App: 512MB max
- Total: ~896MB + system overhead

### For VPS with 512MB RAM (Not Recommended):

If you must use 512MB VPS:

- Remove resource limits (let containers use what they need)
- Use SQLite instead of MySQL (requires code changes)
- Or use external database service

## 🐛 Troubleshooting

### Application won't start

```bash
# Check logs
docker-compose logs app

# Check if MySQL is healthy
docker-compose ps mysql

# Check database connection
docker exec -it ves-booking-mysql mysql -uroot -proot -e "SELECT 1;"
```

### Database connection errors

1. Ensure MySQL is healthy: `docker-compose ps mysql`
2. Check database exists: `docker exec -it ves-booking-mysql mysql -uroot -proot -e "SHOW DATABASES;"`
3. Verify environment variables in `docker-compose.yml`

### Port conflicts

If port 8080 or 3306 is already in use:

```yaml
# Edit docker-compose.yml
services:
  app:
    ports:
      - "8081:8080" # Change host port
  mysql:
    ports:
      - "3307:3306" # Change host port
```

## 🔒 Production Security Checklist

- [ ] Change default MySQL passwords
- [ ] Use environment variables for sensitive data
- [ ] Enable SSL/TLS for database connections
- [ ] Set up reverse proxy (Nginx) with SSL
- [ ] Configure firewall rules
- [ ] Set up log rotation
- [ ] Configure backup strategy
- [ ] Monitor resource usage
- [ ] Set up health monitoring

## 📝 Reverse Proxy Setup (Nginx)

Example Nginx configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🎯 Access Points

- **API Base**: `http://your-vps-ip:8080/api`
- **Swagger UI**: `http://your-vps-ip:8080/api/swagger-ui.html`
- **API Docs**: `http://your-vps-ip:8080/api/v3/api-docs`

## 📚 Default Users

After first startup, these users are created:

- **Admin**: `admin` / `admin` (⚠️ change password!)
- **User**: `user1` / `123456` (⚠️ change password!)
