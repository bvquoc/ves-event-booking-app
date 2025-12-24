# 🔒 SSL/HTTPS Setup Guide for ves-booking.io.vn

This guide will help you set up SSL/HTTPS on your VPS using Let's Encrypt (free SSL certificates).

## 📋 Prerequisites

- VPS with Ubuntu/Debian Linux
- Domain `ves-booking.io.vn` pointing to your VPS IP address
- Nginx installed
- Ports 80 and 443 open in firewall
- Root or sudo access

## 📝 Configuration Files

This setup includes two nginx configuration files:

1. **`ves-booking.io.vn.conf.initial`** - HTTP only (no SSL required)
   - Use this **before** obtaining SSL certificates
   - Allows nginx to start without SSL certificate errors
   - Certbot will automatically update it when you run `certbot --nginx`

2. **`ves-booking.io.vn.conf`** - Full SSL/HTTPS configuration
   - Use this **only if** you already have SSL certificates
   - Includes complete SSL configuration with security headers
   - Requires certificates to exist at `/etc/letsencrypt/live/ves-booking.io.vn/`

**Recommended approach:** Use the initial config first, then let certbot automatically configure SSL.

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

**IMPORTANT:** Use the initial configuration first (without SSL), then switch to SSL config after obtaining certificates.

```bash
# Option A: Use initial config (HTTP only, no SSL required)
# This allows nginx to start before certificates are obtained
sudo cp nginx/ves-booking.io.vn.conf.initial /etc/nginx/sites-available/ves-booking.io.vn.conf

# Option B: If you already have SSL certificates, use the main config
# sudo cp nginx/ves-booking.io.vn.conf /etc/nginx/sites-available/ves-booking.io.vn.conf

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

**Using Certbot with Nginx plugin (Recommended - Automatically configures SSL)**

Certbot's `--nginx` flag will automatically:
- Obtain the SSL certificate
- Modify your nginx configuration to add SSL
- Set up HTTP to HTTPS redirect
- Configure automatic renewal

```bash
# Interactive mode (will prompt for email)
sudo certbot --nginx -d ves-booking.io.vn -d www.ves-booking.io.vn

# Non-interactive mode (no email)
sudo certbot --nginx -d ves-booking.io.vn -d www.ves-booking.io.vn --non-interactive --agree-tos --register-unsafely-without-email

# With email (non-interactive)
sudo certbot --nginx -d ves-booking.io.vn -d www.ves-booking.io.vn --non-interactive --agree-tos --email your-email@example.com
```

**Important:** After running certbot, it will automatically modify your nginx configuration file to add SSL settings. You don't need to manually edit the config file.

**Note:** If you used the initial config (HTTP only), certbot will automatically convert it to HTTPS. If you used the full SSL config and certificates don't exist, use the initial config first, then run certbot.

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
