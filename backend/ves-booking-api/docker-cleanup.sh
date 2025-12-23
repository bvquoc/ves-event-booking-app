#!/bin/bash
# Docker Cleanup Script for VPS
# Safely removes unused Docker resources to free up disk space

echo "=== Docker Cleanup Script ==="
echo ""

# Show current disk usage
echo "📊 Current Docker disk usage:"
docker system df
echo ""

# Ask for confirmation
read -p "Do you want to clean up unused Docker resources? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo "🧹 Cleaning up..."

# Remove unused images (not used by any container)
echo "1. Removing unused images..."
docker image prune -a -f

# Remove unused build cache
echo "2. Removing unused build cache..."
docker builder prune -a -f

# Remove unused volumes (⚠️ be careful - only removes volumes not used by any container)
echo "3. Removing unused volumes..."
docker volume prune -f

# Remove unused networks
echo "4. Removing unused networks..."
docker network prune -f

# Final disk usage
echo ""
echo "✅ Cleanup complete!"
echo ""
echo "📊 Disk usage after cleanup:"
docker system df

