#!/bin/bash

# Nginx and SSL Setup Script for ves-booking.io.vn
# This script automates the setup of Nginx with SSL/HTTPS

set -e

DOMAIN="ves-booking.io.vn"
NGINX_CONF="/etc/nginx/sites-available/${DOMAIN}.conf"
NGINX_ENABLED="/etc/nginx/sites-enabled/${DOMAIN}.conf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTBOT_SUCCESS=false

echo "🚀 Setting up Nginx with SSL for ${DOMAIN}..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root or with sudo"
    exit 1
fi

# Check if domain resolves
echo "📡 Checking DNS for ${DOMAIN}..."
if ! dig +short ${DOMAIN} | grep -q .; then
    echo "⚠️  Warning: ${DOMAIN} does not resolve. Make sure DNS is configured correctly."
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install Nginx if not installed
if ! command -v nginx &> /dev/null; then
    echo "📦 Installing Nginx..."
    apt update
    apt install -y nginx
else
    echo "✅ Nginx is already installed"
fi

# Install Certbot if not installed
if ! command -v certbot &> /dev/null; then
    echo "📦 Installing Certbot..."
    apt update
    apt install -y certbot python3-certbot-nginx
else
    echo "✅ Certbot is already installed"
fi

# Create certbot webroot directory
echo "📁 Creating certbot webroot directory..."
mkdir -p /var/www/certbot

# Copy nginx configuration (use initial config without SSL first)
echo "📝 Copying Nginx configuration..."

# Check if SSL certificates already exist
if [ -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; then
    echo "✅ SSL certificates found, using full SSL configuration"
    if [ -f "${SCRIPT_DIR}/ves-booking.io.vn.conf" ]; then
        cp "${SCRIPT_DIR}/ves-booking.io.vn.conf" "${NGINX_CONF}"
        echo "✅ SSL configuration copied to ${NGINX_CONF}"
    else
        echo "❌ SSL config file not found: ${SCRIPT_DIR}/ves-booking.io.vn.conf"
        exit 1
    fi
else
    echo "📋 SSL certificates not found, using initial HTTP-only configuration"
    echo "   Certbot will automatically add SSL configuration later"
    
    # Always use initial config if certificates don't exist - this is critical!
    if [ -f "${SCRIPT_DIR}/ves-booking.io.vn.conf.initial" ]; then
        cp "${SCRIPT_DIR}/ves-booking.io.vn.conf.initial" "${NGINX_CONF}"
        echo "✅ Initial configuration (HTTP only) copied to ${NGINX_CONF}"
        echo "   This config works without SSL certificates"
    else
        echo "❌ ERROR: Initial config file not found: ${SCRIPT_DIR}/ves-booking.io.vn.conf.initial"
        echo ""
        echo "   The initial config file is required when SSL certificates don't exist."
        echo "   Please ensure the file exists at: ${SCRIPT_DIR}/ves-booking.io.vn.conf.initial"
        echo ""
        echo "   Current script directory: ${SCRIPT_DIR}"
        echo "   Files in directory:"
        ls -la "${SCRIPT_DIR}"/*.conf* 2>/dev/null || echo "   (cannot list files)"
        exit 1
    fi
fi

# Create symbolic link
if [ -L "${NGINX_ENABLED}" ]; then
    echo "⚠️  Symbolic link already exists, removing..."
    rm "${NGINX_ENABLED}"
fi

ln -s "${NGINX_CONF}" "${NGINX_ENABLED}"
echo "✅ Symbolic link created"

# Remove default nginx site if it exists
if [ -L /etc/nginx/sites-enabled/default ]; then
    echo "🗑️  Removing default nginx site..."
    rm /etc/nginx/sites-enabled/default
fi

# Test nginx configuration
echo "🧪 Testing Nginx configuration..."
if nginx -t; then
    echo "✅ Nginx configuration is valid"
else
    echo "❌ Nginx configuration has errors. Please fix them before continuing."
    exit 1
fi

# Start and enable nginx
echo "🔄 Starting Nginx..."
systemctl start nginx
systemctl enable nginx
echo "✅ Nginx started and enabled"

# Configure firewall
echo "🔥 Configuring firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 'Nginx Full'
    echo "✅ UFW firewall configured"
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
    echo "✅ Firewalld configured"
else
    echo "⚠️  No firewall detected. Please manually open ports 80 and 443."
fi

# Obtain SSL certificate using certbot --nginx (automatically configures SSL)
# Temporarily disable exit on error for certbot (we handle failures manually)
set +e

echo ""
echo "🔒 Setting up SSL/HTTPS with Let's Encrypt..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Certbot will:"
echo "  ✓ Obtain SSL certificate from Let's Encrypt"
echo "  ✓ Automatically configure nginx with SSL"
echo "  ✓ Set up HTTP to HTTPS redirect"
echo "  ✓ Configure automatic certificate renewal"
echo ""

read -p "Enter your email address for Let's Encrypt notifications (or press Enter to skip): " EMAIL
echo

CERTBOT_SUCCESS=false

if [ -z "$EMAIL" ]; then
    echo "📧 Obtaining certificate without email..."
    if certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --register-unsafely-without-email --redirect; then
        CERTBOT_SUCCESS=true
        echo "✅ SSL certificate obtained and nginx configured successfully!"
    else
        echo "⚠️  Certbot with redirect failed. Trying without redirect..."
        if certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --register-unsafely-without-email; then
            CERTBOT_SUCCESS=true
            echo "✅ SSL certificate obtained and nginx configured successfully!"
        else
            echo "❌ Certbot failed. Common issues:"
            echo "   - DNS not pointing to this server"
            echo "   - Port 80 not accessible from internet"
            echo "   - Domain already has a certificate"
            echo ""
            echo "You can run manually later:"
            echo "   sudo certbot --nginx -d ${DOMAIN} -d www.${DOMAIN}"
        fi
    fi
else
    echo "📧 Obtaining certificate with email: ${EMAIL}..."
    if certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --email ${EMAIL} --redirect; then
        CERTBOT_SUCCESS=true
        echo "✅ SSL certificate obtained and nginx configured successfully!"
    else
        echo "⚠️  Certbot with redirect failed. Trying without redirect..."
        if certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --email ${EMAIL}; then
            CERTBOT_SUCCESS=true
            echo "✅ SSL certificate obtained and nginx configured successfully!"
        else
            echo "❌ Certbot failed. Common issues:"
            echo "   - DNS not pointing to this server"
            echo "   - Port 80 not accessible from internet"
            echo "   - Domain already has a certificate"
            echo ""
            echo "You can run manually later:"
            echo "   sudo certbot --nginx -d ${DOMAIN} -d www.${DOMAIN}"
        fi
    fi
fi

# Verify certificate if certbot succeeded
if [ "$CERTBOT_SUCCESS" = true ]; then
    echo ""
    echo "🔍 Verifying SSL certificate..."
    if [ -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; then
        echo "✅ SSL certificate files found"
        certbot certificates | grep -A 3 "${DOMAIN}" || true
    else
        echo "⚠️  Certificate files not found at expected location"
    fi
    
    # Test nginx config after certbot modifications
    echo ""
    echo "🧪 Testing nginx configuration after SSL setup..."
    if nginx -t; then
        echo "✅ Nginx configuration is valid"
    else
        echo "❌ Nginx configuration has errors after certbot setup"
        echo "   Please check: sudo nginx -t"
    fi
fi

# Re-enable exit on error
set -e

echo ""

# Reload nginx
echo "🔄 Reloading Nginx..."
systemctl reload nginx
echo "✅ Nginx reloaded"

# Verify services are running
echo ""
echo "🔍 Verifying setup..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check nginx status
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx is running"
else
    echo "❌ Nginx is not running"
fi

# Check if services are accessible
echo ""
echo "Testing service connectivity..."
if curl -s http://localhost:8080/api/health > /dev/null 2>&1; then
    echo "✅ API service (port 8080) is accessible"
else
    echo "⚠️  API service (port 8080) is not accessible. Make sure your backend is running."
fi

if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Admin portal (port 3000) is accessible"
else
    echo "⚠️  Admin portal (port 3000) is not accessible. Make sure your frontend is running."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Setup complete!"
echo ""

if [ "$CERTBOT_SUCCESS" = true ]; then
    echo "✅ SSL/HTTPS is configured!"
    echo ""
    echo "📋 Test your setup:"
    echo "   - Admin Portal: https://${DOMAIN}/admin"
    echo "   - API Health: https://${DOMAIN}/api/healthz"
    echo "   - API Base: https://${DOMAIN}/api"
    echo ""
    echo "🔒 SSL certificate will auto-renew via certbot timer"
else
    echo "⚠️  SSL certificate setup was skipped or failed"
    echo ""
    echo "📋 Your site is available via HTTP:"
    echo "   - Admin Portal: http://${DOMAIN}/admin"
    echo "   - API Health: http://${DOMAIN}/api/healthz"
    echo "   - API Base: http://${DOMAIN}/api"
    echo ""
    echo "🔒 To set up SSL later, run:"
    echo "   sudo certbot --nginx -d ${DOMAIN} -d www.${DOMAIN}"
fi

echo ""
echo "📋 Ensure services are running:"
echo "   1. Backend API on port 8080"
echo "   2. Admin portal on port 3000"
echo ""
echo "📚 For more information, see: nginx/SSL_SETUP.md"
