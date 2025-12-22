#!/bin/bash
# Docker Monitoring Script
# Quick health check for all containers

echo "=== VES Booking API - Container Health Check ==="
echo ""

# Check if containers are running
echo "📦 Container Status:"
docker ps --filter "name=ves-booking" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

# Check MySQL health
echo "🗄️  MySQL Container:"
if docker ps | grep -q ves-booking-mysql; then
    HEALTH=$(docker inspect ves-booking-mysql --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")
    echo "  Status: $HEALTH"
    
    if [ "$HEALTH" = "healthy" ]; then
        echo "  ✅ MySQL is healthy"
        
        # Show MySQL stats
        echo ""
        echo "  MySQL Statistics:"
        docker exec ves-booking-mysql mysqladmin -uroot -proot status 2>/dev/null | sed 's/^/    /'
        
        # Show current connections
        CONNECTIONS=$(docker exec ves-booking-mysql mysql -uroot -proot -e "SHOW STATUS LIKE 'Threads_connected';" 2>/dev/null | tail -1 | awk '{print $2}')
        echo "  Active Connections: $CONNECTIONS"
    else
        echo "  ⚠️  MySQL health check: $HEALTH"
    fi
else
    echo "  ❌ MySQL container is not running"
fi
echo ""

# Check App health
echo "🚀 Spring Boot App Container:"
if docker ps | grep -q ves-booking-api; then
    HEALTH=$(docker inspect ves-booking-api --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")
    echo "  Status: $HEALTH"
    
    if [ "$HEALTH" = "healthy" ]; then
        echo "  ✅ App is healthy"
    else
        echo "  ⚠️  App health check: $HEALTH"
    fi
    
    # Show recent logs for errors
    echo ""
    echo "  Recent Errors (last 20 lines):"
    docker logs ves-booking-api --tail=20 2>&1 | grep -i "error\|exception" | tail -5 | sed 's/^/    /' || echo "    No errors found"
else
    echo "  ❌ App container is not running"
fi
echo ""

# Resource usage
echo "💻 Resource Usage:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" ves-booking-mysql ves-booking-api 2>/dev/null || echo "  Containers not found"
echo ""

# Disk usage
echo "💾 Disk Usage:"
docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}" | head -5
echo ""

# Network connectivity test
echo "🔗 Network Test:"
if docker exec ves-booking-api ping -c 1 mysql > /dev/null 2>&1; then
    echo "  ✅ App can reach MySQL (ping successful)"
else
    echo "  ⚠️  App cannot ping MySQL (this might be normal if ping is disabled)"
    # Try alternative test
    if docker exec ves-booking-api sh -c "nc -z mysql 3306" > /dev/null 2>&1; then
        echo "  ✅ App can reach MySQL port 3306"
    else
        echo "  ❌ App cannot reach MySQL port 3306"
    fi
fi
echo ""

echo "=== End of Health Check ==="

