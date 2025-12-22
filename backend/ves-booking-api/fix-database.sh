#!/bin/bash
# Quick fix script to create database if missing

echo "=== Fixing Database Issue ==="
echo ""

# Check if MySQL container is running
if ! docker ps | grep -q ves-booking-mysql; then
    echo "❌ MySQL container is not running"
    echo "Starting MySQL container..."
    docker-compose up -d mysql
    echo "Waiting for MySQL to be ready..."
    sleep 10
fi

# Check if database exists
echo "Checking if database exists..."
DB_EXISTS=$(docker exec ves-booking-mysql mysql -uroot -proot -e "SHOW DATABASES LIKE 'ves_booking_api';" 2>/dev/null | grep -c ves_booking_api || echo "0")

if [ "$DB_EXISTS" -eq "0" ]; then
    echo "❌ Database 'ves_booking_api' does not exist"
    echo "Creating database..."
    
    docker exec ves-booking-mysql mysql -uroot -proot -e "
        CREATE DATABASE IF NOT EXISTS ves_booking_api CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        GRANT ALL PRIVILEGES ON ves_booking_api.* TO 'vesbooking'@'%';
        GRANT ALL PRIVILEGES ON ves_booking_api.* TO 'root'@'%';
        FLUSH PRIVILEGES;
    "
    
    if [ $? -eq 0 ]; then
        echo "✅ Database created successfully!"
    else
        echo "❌ Failed to create database"
        exit 1
    fi
else
    echo "✅ Database 'ves_booking_api' already exists"
fi

# Verify database exists
echo ""
echo "Verifying database..."
docker exec ves-booking-mysql mysql -uroot -proot -e "SHOW DATABASES;" | grep ves_booking_api

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Database verification successful!"
    echo ""
    echo "Restarting app container..."
    docker-compose restart app
    
    echo ""
    echo "Waiting for app to start..."
    sleep 15
    
    echo ""
    echo "Checking app health..."
    docker inspect ves-booking-api --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown"
    
    echo ""
    echo "=== Fix Complete ==="
    echo "Run './docker-monitor.sh' to verify everything is working"
else
    echo "❌ Database verification failed"
    exit 1
fi

