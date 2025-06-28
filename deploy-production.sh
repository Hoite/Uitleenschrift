#!/bin/bash

# Uitleenschrift Production Deployment Script
# Voor uitleenschrift.nl productie omgeving

set -e

echo "🚀 Starting Uitleenschrift deployment for uitleenschrift.nl..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "💡 Copy .env.production to .env and configure your settings:"
    echo "   cp .env.production .env"
    echo "   nano .env"
    exit 1
fi

# Load environment variables
source .env

# Check required environment variables
if [ -z "$SECRET_KEY" ]; then
    echo "❌ Error: SECRET_KEY not set in .env"
    exit 1
fi

if [ -z "$GOOGLE_BOOKS_API_KEY" ]; then
    echo "⚠️  Warning: GOOGLE_BOOKS_API_KEY not set. Book lookup won't work."
fi

# Check domain configuration
DOMAIN_NAME=${DOMAIN_NAME:-uitleenschrift.nl}
echo "🌐 Deploying for domain: $DOMAIN_NAME"

# Determine tunnel method
if [ -n "$CLOUDFLARE_TUNNEL_TOKEN" ]; then
    echo "🔗 Using Cloudflare Tunnel with token authentication"
    COMPOSE_PROFILES="tunnel-token"
elif [ -n "$CLOUDFLARE_TUNNEL_ID" ] && [ -f "cloudflared-config.yml" ]; then
    echo "🔗 Using Cloudflare Tunnel with config file"
    COMPOSE_PROFILES="tunnel-config"
    
    # Validate tunnel config
    if [ ! -d "tunnel-credentials" ]; then
        echo "❌ Error: tunnel-credentials directory not found!"
        echo "💡 Make sure your tunnel credentials are in ./tunnel-credentials/"
        exit 1
    fi
else
    echo "⚠️  Warning: No Cloudflare tunnel configured. App will only be accessible locally."
    COMPOSE_PROFILES=""
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p instance
mkdir -p data

# Pull latest images
echo "📥 Pulling latest Docker images..."
docker-compose -f docker-compose.prod.yml pull

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose -f docker-compose.prod.yml down

# Start services with appropriate profile
echo "🚀 Starting services..."
if [ -n "$COMPOSE_PROFILES" ]; then
    COMPOSE_PROFILES=$COMPOSE_PROFILES docker-compose -f docker-compose.prod.yml up -d
else
    docker-compose -f docker-compose.prod.yml up -d app watchtower
fi

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Health check
echo "🔍 Performing health check..."
if curl -f http://localhost:5001/health > /dev/null 2>&1; then
    echo "✅ Application is healthy!"
else
    echo "❌ Health check failed!"
    echo "📋 Container logs:"
    docker-compose -f docker-compose.prod.yml logs app
    exit 1
fi

# Show status
echo "📊 Deployment status:"
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📍 Your application is now running:"
if [ -n "$CLOUDFLARE_TUNNEL_TOKEN" ] || [ -n "$CLOUDFLARE_TUNNEL_ID" ]; then
    echo "   🌐 Public: https://$DOMAIN_NAME"
    echo "   🌐 WWW: https://www.$DOMAIN_NAME"
fi
echo "   🏠 Local: http://localhost:5001"
echo ""
echo "📋 Useful commands:"
echo "   � Health check: ./scripts/health-check.sh"
echo "   💾 Backup: ./scripts/backup.sh"
echo "   �📄 View logs: docker-compose -f docker-compose.prod.yml logs -f"
echo "   🔄 Restart: docker-compose -f docker-compose.prod.yml restart"
echo "   🛑 Stop: docker-compose -f docker-compose.prod.yml down"
echo "   📊 Status: docker-compose -f docker-compose.prod.yml ps"
echo ""
echo "📚 Documentation:"
echo "   📖 Full setup: docs/PRODUCTION_SETUP.md"
echo "   🔗 Cloudflare tunnel: docs/CLOUDFLARE_TUNNEL.md"
echo "   ⚡ Features: docs/FEATURES.md"
echo ""
echo "🔄 Watchtower will automatically update your application when new versions are available."
