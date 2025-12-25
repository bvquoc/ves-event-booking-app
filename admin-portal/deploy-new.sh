#!/bin/bash

# VES Booking Admin Portal - Deploy New Source
# Stops current deployment, rebuilds, and restarts

set -e

echo "🔄 Deploying new source code..."
echo ""

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    echo "❌ PM2 is not installed. Please run ./deploy.sh first."
    exit 1
fi

# Check and update .env if needed
if [ -f ".env" ]; then
    CURRENT_API_URL=$(grep "^VITE_API_BASE_URL=" .env | cut -d '=' -f2 || echo "")
    if [[ "$CURRENT_API_URL" == http* ]]; then
        echo "⚠️  Current API URL uses IP address: $CURRENT_API_URL"
        echo ""
        echo "Are you using nginx with domain (e.g., https://ves-booking.io.vn)?"
        read -p "Update to use /api? (y/n) [y]: " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            echo "⚙️  Updating .env to use /api..."
            sed -i.bak "s|^VITE_API_BASE_URL=.*|VITE_API_BASE_URL=/api|" .env
            echo "✅ Updated API URL to: /api"
        fi
    else
        echo "✅ API URL already configured: $CURRENT_API_URL"
    fi
else
    echo "⚠️  No .env file found. Creating with default /api..."
    echo "VITE_API_BASE_URL=/api" > .env
    echo "✅ Created .env with API URL: /api"
fi

# Stop current deployment
echo "⏹️  Stopping current deployment..."
pm2 stop ves-admin-portal 2>/dev/null || echo "No running instance found"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build
echo "🔨 Building..."
npm run build

if [ ! -d "dist" ]; then
    echo "❌ Build failed! dist directory not found."
    exit 1
fi

# Restart with PM2
echo "🚀 Restarting server..."
pm2 restart ves-admin-portal || pm2 start ecosystem.config.cjs
pm2 save

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Commands:"
echo "  pm2 logs ves-admin-portal    # View logs"
echo "  pm2 status                   # View status"
echo ""

