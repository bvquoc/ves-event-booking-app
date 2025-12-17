#!/bin/bash

# VES Booking API - Local Development Startup Script

set -e

echo "🚀 Starting VES Booking API Local Environment..."
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Check Java version
JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 21 ]; then
    echo -e "${YELLOW}⚠️  Warning: Java 21+ is required. Current version: $JAVA_VERSION${NC}"
fi

# Step 1: Start MySQL
echo -e "${GREEN}📦 Step 1: Starting MySQL database...${NC}"
docker compose up -d mysql

# Wait for MySQL to be healthy
echo "⏳ Waiting for MySQL to be ready..."
timeout=60
counter=0
while ! docker compose exec -T mysql mysqladmin ping -h localhost -u root -proot --silent 2>/dev/null; do
    sleep 2
    counter=$((counter + 2))
    if [ $counter -ge $timeout ]; then
        echo -e "${RED}❌ MySQL failed to start within $timeout seconds${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✅ MySQL is ready!${NC}"
echo ""

# # Step 2: Start Application
# echo -e "${GREEN}🚀 Step 2: Starting Spring Boot application...${NC}"
# echo -e "${YELLOW}   Application will be available at: http://localhost:8080/api${NC}"
# echo -e "${YELLOW}   Default admin credentials: admin/admin${NC}"
# echo ""
# echo "Press Ctrl+C to stop the application"
# echo ""

# # Start the application
# ./mvnw spring-boot:run

