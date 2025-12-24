#!/bin/bash

# VES Booking Admin Portal - Setup Script
set -e

echo "🚀 VES Booking Admin Portal Setup"
echo ""

# Check prerequisites
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
    echo "❌ Node.js and npm are required. Please install Node.js 18+ first."
    exit 1
fi

# Get configuration
echo "Deployment type:"
echo "  1) Using nginx with domain (e.g., https://ves-booking.io.vn) - Recommended"
echo "  2) Direct access (IP address)"
read -p "Select [1]: " DEPLOY_TYPE
DEPLOY_TYPE=${DEPLOY_TYPE:-1}

if [ "$DEPLOY_TYPE" = "1" ]; then
    # Using nginx with domain
    API_URL="/api"
    echo ""
    echo "✅ Using nginx with domain - API URL will be: /api"
    echo "   (API calls will go through nginx proxy)"
else
    # Direct access
    AUTO_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "")
    read -p "VPS IP address [$AUTO_IP]: " VPS_IP
    VPS_IP=${VPS_IP:-$AUTO_IP}
    
    read -p "Backend port [8080]: " BACKEND_PORT
    BACKEND_PORT=${BACKEND_PORT:-8080}
    
    API_URL="http://$VPS_IP:$BACKEND_PORT/api"
    echo ""
    echo "Configuration:"
    echo "  VPS IP: $VPS_IP"
    echo "  Backend: $BACKEND_PORT"
    echo "  API URL: $API_URL"
fi

read -p "Frontend port [3000]: " FRONTEND_PORT
FRONTEND_PORT=${FRONTEND_PORT:-3000}

echo ""
echo "Final configuration:"
echo "  Frontend port: $FRONTEND_PORT"
echo "  API URL: $API_URL"
echo ""

read -p "Continue? (y/n) " -n 1 -r
echo ""
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create .env
echo "⚙️  Creating .env..."
echo "VITE_API_BASE_URL=$API_URL" > .env

# Update port if needed
if [ "$FRONTEND_PORT" != "3000" ]; then
    sed -i.bak "s/-l 3000/-l $FRONTEND_PORT/g" package.json
fi

# Build
echo "🔨 Building..."
npm run build

# Install PM2
if ! command -v pm2 &> /dev/null; then
    echo "📦 Installing PM2..."
    npm install -g pm2 2>/dev/null || sudo npm install -g pm2
fi

# Start with PM2
echo "🚀 Starting server..."
pm2 stop ves-admin-portal 2>/dev/null || true
pm2 delete ves-admin-portal 2>/dev/null || true
pm2 start ecosystem.config.cjs
pm2 save

# Setup startup
read -p "Setup PM2 to start on boot? (y/n) [y]: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    STARTUP_CMD=$(pm2 startup | grep -o "sudo.*" || echo "")
    if [ -n "$STARTUP_CMD" ]; then
        echo "Run: $STARTUP_CMD"
        read -p "Run now? (y/n) [y]: " -n 1 -r
        echo ""
        [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]] && eval $STARTUP_CMD
    fi
fi

echo ""
echo "✅ Setup complete!"
if [ "$DEPLOY_TYPE" = "1" ]; then
    echo ""
    echo "📍 Access via nginx: https://ves-booking.io.vn/admin"
    echo "📍 Direct access: http://localhost:$FRONTEND_PORT"
else
    echo ""
    echo "📍 Access: http://$VPS_IP:$FRONTEND_PORT"
fi
echo ""
echo "Commands:"
echo "  pm2 logs ves-admin-portal    # View logs"
echo "  pm2 status                   # View status"
echo "  pm2 restart ves-admin-portal # Restart"
echo ""
