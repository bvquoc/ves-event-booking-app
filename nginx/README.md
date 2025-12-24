# 🌐 Nginx Configuration for ves-booking.io.vn

This directory contains Nginx configuration files and setup scripts for deploying the VES Booking application with HTTPS/SSL.

## 📁 Files

- **`ves-booking.io.vn.conf`** - Complete Nginx configuration with SSL/HTTPS
- **`SSL_SETUP.md`** - Detailed step-by-step SSL setup guide
- **`setup-nginx-ssl.sh`** - Automated setup script
- **`README.md`** - This file

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)

```bash
# Run the setup script (requires sudo)
sudo ./nginx/setup-nginx-ssl.sh
```

### Option 2: Manual Setup

1. **Install dependencies:**
   ```bash
   sudo apt update
   sudo apt install -y nginx certbot python3-certbot-nginx
   ```

2. **Copy configuration:**
   ```bash
   sudo cp nginx/ves-booking.io.vn.conf /etc/nginx/sites-available/ves-booking.io.vn.conf
   sudo ln -s /etc/nginx/sites-available/ves-booking.io.vn.conf /etc/nginx/sites-enabled/
   ```

3. **Test and reload:**
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

4. **Obtain SSL certificate:**
   ```bash
   sudo certbot --nginx -d ves-booking.io.vn -d www.ves-booking.io.vn
   ```

For detailed instructions, see **`SSL_SETUP.md`**.

## 🔧 Configuration Overview

The Nginx configuration provides:

### Routing

- **`/admin`** → Proxies to `http://localhost:3000` (Admin Portal)
- **`/api`** → Proxies to `http://localhost:8080/api` (Backend API)
- **`/`** → Redirects to `/admin`

### Security

- ✅ HTTPS/SSL with Let's Encrypt
- ✅ HTTP to HTTPS redirect
- ✅ Security headers (HSTS, X-Frame-Options, etc.)
- ✅ Modern SSL/TLS protocols (TLSv1.2, TLSv1.3)
- ✅ CORS support for API endpoints

### Prerequisites

Before setting up Nginx, ensure:

1. **DNS is configured:**
   - `ves-booking.io.vn` points to your VPS IP
   - `www.ves-booking.io.vn` points to your VPS IP (optional)

2. **Services are running:**
   - Backend API on `localhost:8080`
   - Admin Portal on `localhost:3000`

3. **Ports are open:**
   - Port 80 (HTTP)
   - Port 443 (HTTPS)

## 🔍 Verification

After setup, verify everything works:

```bash
# Test HTTP redirect
curl -I http://ves-booking.io.vn

# Test HTTPS
curl -I https://ves-booking.io.vn

# Test admin portal
curl -I https://ves-booking.io.vn/admin

# Test API
curl https://ves-booking.io.vn/api/health
```

## 🔄 Maintenance

### Renew SSL Certificate

Certbot automatically renews certificates, but you can manually renew:

```bash
sudo certbot renew
sudo systemctl reload nginx
```

### Update Configuration

After modifying the configuration file:

```bash
# Test configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### View Logs

```bash
# Access logs
sudo tail -f /var/log/nginx/ves-booking-access.log

# Error logs
sudo tail -f /var/log/nginx/ves-booking-error.log
```

## 🐛 Troubleshooting

See **`SSL_SETUP.md`** for detailed troubleshooting steps.

Common issues:

1. **Certificate not obtained** → Check DNS and firewall
2. **502 Bad Gateway** → Check if backend services are running
3. **403 Forbidden** → Check file permissions
4. **SSL errors** → Verify certificate paths in config

## 📚 Additional Resources

- [Nginx Documentation](https://nginx.org/en/docs/)
- [Certbot Documentation](https://certbot.eff.org/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
