# 🔒 SSL/HTTPS Setup Guide for ves-booking.io.vn

This guide will help you set up SSL/HTTPS on your VPS using Let's Encrypt (free SSL certificates).

## 📋 Prerequisites

- VPS with Ubuntu/Debian Linux
- Domain `ves-booking.io.vn` pointing to your VPS IP address
- Nginx installed
- Ports 80 and 443 open in firewall
- Root or sudo access

## 🔧 Step-by-Step Setup

### 1. Install Certbot (Let's Encrypt Client)

```bash
# Update package list
sudo apt update

# Install certbot and nginx plugin
sudo apt install -y certbot python3-certbot-nginx
```

### 2. Install Nginx (if not already installed)

```bash
sudo apt install -y nginx
```

### 3. Configure Firewall

```bash
# Allow HTTP and HTTPS traffic
sudo ufw allow 'Nginx Full'
# Or if using iptables:
# sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
# sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

### 4. Create Nginx Configuration Directory (if needed)

```bash
sudo mkdir -p /etc/nginx/sites-available
sudo mkdir -p /etc/nginx/sites-enabled
```

### 5. Copy Nginx Configuration

```bash
# Copy the configuration file to nginx sites-available
sudo cp nginx/ves-booking.io.vn.conf /etc/nginx/sites-available/ves-booking.io.vn.conf

# Create symbolic link to enable the site
sudo ln -s /etc/nginx/sites-available/ves-booking.io.vn.conf /etc/nginx/sites-enabled/

# Remove default nginx site (optional)
sudo rm /etc/nginx/sites-enabled/default
```

### 6. Create Directory for Certbot Challenge

```bash
sudo mkdir -p /var/www/certbot
```

### 7. Test Nginx Configuration

```bash
sudo nginx -t
```

If there are errors, fix them before proceeding.

### 8. Start Nginx

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 9. Obtain SSL Certificate

**Option A: Using Certbot with Nginx plugin (Recommended)**

```bash
sudo certbot --nginx -d ves-booking.io.vn -d www.ves-booking.io.vn
```

This will:
- Automatically obtain the certificate
- Configure nginx to use SSL
- Set up automatic renewal

**Option B: Manual Certificate Installation**

If you prefer to use the provided nginx config file:

```bash
# First, temporarily modify nginx config to allow HTTP only for certbot challenge
# Then run:
sudo certbot certonly --webroot -w /var/www/certbot -d ves-booking.io.vn -d www.ves-booking.io.vn

# After certificate is obtained, ensure the nginx config is correct and reload
sudo nginx -t
sudo systemctl reload nginx
```

### 10. Verify SSL Certificate

```bash
# Check certificate status
sudo certbot certificates

# Test SSL configuration
curl -I https://ves-booking.io.vn
```

### 11. Set Up Auto-Renewal

Certbot automatically sets up a renewal timer, but verify it:

```bash
# Check renewal timer
sudo systemctl status certbot.timer

# Test renewal (dry run)
sudo certbot renew --dry-run
```

### 12. Verify Nginx is Running

```bash
sudo systemctl status nginx
```

## 🔍 Verification

After setup, verify:

1. **HTTP redirects to HTTPS:**
   ```bash
   curl -I http://ves-booking.io.vn
   # Should return 301 redirect to https://
   ```

2. **HTTPS works:**
   ```bash
   curl -I https://ves-booking.io.vn
   # Should return 200 OK
   ```

3. **Admin portal accessible:**
   - Visit: `https://ves-booking.io.vn/admin`
   - Should proxy to `localhost:3000`

4. **API accessible:**
   - Visit: `https://ves-booking.io.vn/api/health` (or any API endpoint)
   - Should proxy to `localhost:8080/api`

## 🔄 Renewal

Let's Encrypt certificates expire every 90 days. Certbot automatically renews them, but you can manually renew:

```bash
sudo certbot renew
sudo systemctl reload nginx
```

## 🐛 Troubleshooting

### Certificate not obtained

1. **Check DNS:**
   ```bash
   dig ves-booking.io.vn
   # Should point to your VPS IP
   ```

2. **Check firewall:**
   ```bash
   sudo ufw status
   # Ports 80 and 443 should be open
   ```

3. **Check nginx is running:**
   ```bash
   sudo systemctl status nginx
   ```

### Nginx configuration errors

```bash
# Test configuration
sudo nginx -t

# Check error logs
sudo tail -f /var/log/nginx/error.log
```

### Services not accessible

1. **Check if services are running:**
   ```bash
   # Check admin portal (port 3000)
   curl http://localhost:3000
   
   # Check API (port 8080)
   curl http://localhost:8080/api/health
   ```

2. **Check nginx proxy logs:**
   ```bash
   sudo tail -f /var/log/nginx/ves-booking-error.log
   ```

### SSL certificate expired

```bash
# Renew certificate
sudo certbot renew --force-renewal
sudo systemctl reload nginx
```

## 📝 Additional Notes

- The nginx configuration includes security headers (HSTS, X-Frame-Options, etc.)
- CORS headers are configured for the API endpoint
- Max upload size is set to 10MB (adjust in nginx config if needed)
- Health check endpoint available at `/health`

## 🔐 Security Recommendations

1. **Keep Certbot updated:**
   ```bash
   sudo apt update && sudo apt upgrade certbot
   ```

2. **Monitor certificate expiration:**
   ```bash
   # Add to crontab to check monthly
   0 0 1 * * certbot renew --quiet && systemctl reload nginx
   ```

3. **Review security headers** in nginx config and adjust as needed

4. **Regular backups** of nginx configuration:
   ```bash
   sudo cp /etc/nginx/sites-available/ves-booking.io.vn.conf /backup/
   ```
