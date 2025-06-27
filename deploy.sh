#!/bin/bash

# Uitleenschrift Docker Deployment Script
# Dit script kan gebruikt worden op je server voor automatische updates

set -e

echo "🚀 Starting Uitleenschrift deployment..."

# Configuratie
IMAGE_NAME="hoite/uitleenschrift:latest"
CONTAINER_NAME="uitleenschrift-app"
COMPOSE_FILE="docker-compose.prod.yml"

# Check of .env bestand bestaat
if [ ! -f .env ]; then
    echo "❌ Error: .env bestand niet gevonden!"
    echo "Kopieer .env.example naar .env en vul de waardes in."
    exit 1
fi

# Pull de nieuwste image
echo "📥 Pulling latest Docker image..."
docker pull $IMAGE_NAME

# Zorg dat instance directory bestaat met juiste permissions
echo "📁 Creating instance directory..."
mkdir -p ./instance
chmod 755 ./instance

# Stop en verwijder oude container (als deze bestaat)
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "🛑 Stopping existing container..."
    docker stop $CONTAINER_NAME
fi

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "🗑️  Removing old container..."
    docker rm $CONTAINER_NAME
fi

# Start nieuwe container
echo "🔄 Starting new container..."
if [ -f "$COMPOSE_FILE" ]; then
    docker-compose -f $COMPOSE_FILE up -d
else
    docker run -d \
        --name $CONTAINER_NAME \
        --restart unless-stopped \
        -p 5000:5000 \
        --env-file .env \
        -v $(pwd)/instance:/app/instance \
        $IMAGE_NAME
fi

# Wacht even en check of container draait
sleep 5
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "✅ Deployment successful!"
    echo "🌐 Application should be running on port 5000"
    
    # Optioneel: run health check
    if command -v curl &> /dev/null; then
        echo "🔍 Running health check..."
        sleep 10
        if curl -f http://localhost:5000/health > /dev/null 2>&1; then
            echo "✅ Health check passed!"
        else
            echo "⚠️  Health check failed, but container is running"
        fi
    fi
else
    echo "❌ Deployment failed! Container is not running."
    echo "Check logs with: docker logs $CONTAINER_NAME"
    exit 1
fi

echo "🎉 Deployment completed successfully!"
