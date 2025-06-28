#!/bin/bash

# Uitleenschrift Health Check Script
# Controleert status van alle services

set -e

echo "🔍 Uitleenschrift Health Check"
echo "================================="

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running!"
    exit 1
fi

# Check if containers are running
echo "📊 Container Status:"
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "🌐 Health Checks:"

# Check local health endpoint
echo -n "Local (http://localhost:5001/health): "
if curl -s -f http://localhost:5001/health >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

# Check public endpoint if domain is configured
if [ -f .env ]; then
    source .env
    if [ -n "$DOMAIN_NAME" ]; then
        echo -n "Public (https://$DOMAIN_NAME/health): "
        if curl -s -f https://$DOMAIN_NAME/health >/dev/null 2>&1; then
            echo "✅ OK"
        else
            echo "❌ FAILED"
        fi
    fi
fi

echo ""
echo "📋 Service Logs (last 10 lines):"
echo "--------------------------------"

echo "🏠 App logs:"
docker-compose -f docker-compose.prod.yml logs --tail=10 app 2>/dev/null || echo "App container not running"

echo ""
echo "🔗 Cloudflare logs:"
docker-compose -f docker-compose.prod.yml logs --tail=10 cloudflared 2>/dev/null || echo "Cloudflare tunnel not running (normal if using token)"

echo ""
echo "🔄 Watchtower logs:"
docker-compose -f docker-compose.prod.yml logs --tail=10 watchtower 2>/dev/null || echo "Watchtower not running"

echo ""
echo "💾 Disk Usage:"
echo "Database size: $(du -h ./instance/uitleenschrift.db 2>/dev/null || echo 'Not found')"
echo "Docker images: $(docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "(uitleenschrift|cloudflare|watchtower)" || echo 'No images found')"

echo ""
echo "🎉 Health check completed!"
