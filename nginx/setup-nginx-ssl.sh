#!/bin/bash

# Nginx and SSL Setup Script for ves-booking.io.vn
# This script automates the setup of Nginx with SSL/HTTPS

set -e

DOMAIN="ves-booking.io.vn"
NGINX_CONF="/etc/nginx/sites-available/${DOMAIN}.conf"
NGINX_ENABLED="/etc/nginx/sites-enabled/${DOMAIN}.conf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Copy nginx configuration
echo "📝 Copying Nginx configuration..."
if [ -f "${SCRIPT_DIR}/ves-booking.io.vn.conf" ]; then
    cp "${SCRIPT_DIR}/ves-booking.io.vn.conf" "${NGINX_CONF}"
    echo "✅ Configuration copied to ${NGINX_CONF}"
else
    echo "❌ Configuration file not found: ${SCRIPT_DIR}/ves-booking.io.vn.conf"
    exit 1
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

# Obtain SSL certificate
echo "🔒 Obtaining SSL certificate from Let's Encrypt..."
echo "⚠️  This will prompt for your email address and agreement to terms."
read -p "Continue with SSL certificate setup? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --register-unsafely-without-email || {
        echo "⚠️  Certbot failed. You may need to run manually:"
        echo "   sudo certbot --nginx -d ${DOMAIN} -d www.${DOMAIN}"
    }
else
    echo "⏭️  Skipping SSL certificate setup. Run manually with:"
    echo "   sudo certbot --nginx -d ${DOMAIN} -d www.${DOMAIN}"
fi

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
echo "📋 Next steps:"
echo "   1. Ensure your backend API is running on port 8080"
echo "   2. Ensure your admin portal is running on port 3000"
echo "   3. Test the setup:"
echo "      - Admin: https://${DOMAIN}/admin"
echo "      - API: https://${DOMAIN}/api/health"
echo ""
echo "📚 For more information, see: nginx/SSL_SETUP.md"
