#!/bin/bash

# Uitleenschrift Backup Script
# Maakt backup van database en belangrijke bestanden

set -e

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="uitleenschrift-backup-$DATE"

echo "🔄 Starting backup: $BACKUP_NAME"

# Maak backup directory
mkdir -p "$BACKUP_DIR"

# Backup database
if [ -f "./instance/uitleenschrift.db" ]; then
    echo "📊 Backing up database..."
    cp "./instance/uitleenschrift.db" "$BACKUP_DIR/database-$DATE.db"
    
    # Comprimeer database backup
    gzip "$BACKUP_DIR/database-$DATE.db"
    echo "✅ Database backup: $BACKUP_DIR/database-$DATE.db.gz"
else
    echo "⚠️  Database not found at ./instance/uitleenschrift.db"
fi

# Backup environment en config bestanden
echo "⚙️  Backing up configuration..."
tar -czf "$BACKUP_DIR/config-$DATE.tar.gz" \
    .env \
    cloudflared-config.yml \
    docker-compose.prod.yml \
    --exclude="*token*" \
    --exclude="*credentials*" \
    2>/dev/null || echo "⚠️  Some config files not found (normal for new setup)"

# Cleanup oude backups (houd laatste 7 dagen)
echo "🧹 Cleaning up old backups..."
find "$BACKUP_DIR" -name "*.gz" -mtime +7 -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete 2>/dev/null || true

# Toon backup overzicht
echo ""
echo "📋 Backup completed successfully!"
echo "📁 Backup directory: $BACKUP_DIR"
echo "📊 Available backups:"
ls -lah "$BACKUP_DIR" 2>/dev/null || echo "No backups found"

echo ""
echo "💾 To restore database:"
echo "   gunzip $BACKUP_DIR/database-$DATE.db.gz"
echo "   cp $BACKUP_DIR/database-$DATE.db ./instance/uitleenschrift.db"
echo "   docker-compose -f docker-compose.prod.yml restart app"
