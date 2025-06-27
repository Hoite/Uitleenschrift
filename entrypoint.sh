#!/bin/bash
set -e

echo "Entrypoint: Starting as $(whoami)"
echo "Entrypoint: Fixing permissions for instance directory"

# Ensure instance directory exists with correct permissions
mkdir -p /app/instance
chown -R appuser:appuser /app/instance
chmod -R 755 /app/instance

echo "Entrypoint: Directory permissions after fix:"
ls -la /app/instance

# Test SQLite access as appuser
echo "Entrypoint: Testing SQLite access as appuser..."
if runuser -u appuser -- python3 -c "import sqlite3; conn = sqlite3.connect('/app/instance/test.db'); conn.execute('CREATE TABLE test (id INTEGER)'); conn.close(); print('SQLite test successful')"; then
    echo "Entrypoint: SQLite test PASSED"
    runuser -u appuser -- rm -f /app/instance/test.db
else
    echo "Entrypoint: SQLite test FAILED - this is the root cause of the database issue"
    exit 1
fi

# Ensure database file has correct permissions if it exists
if [ -f "/app/instance/uitleenschrift.db" ]; then
    echo "Entrypoint: Found existing database, fixing permissions"
    chown appuser:appuser /app/instance/uitleenschrift.db
    chmod 664 /app/instance/uitleenschrift.db
else
    echo "Entrypoint: No existing database found, will be created by app"
fi

echo "Entrypoint: Final instance directory contents:"
ls -la /app/instance

echo "Entrypoint: Starting application as appuser"

# Start a background process to fix database permissions if needed
(
    sleep 5  # Give the app time to start and create the database
    if [ -f "/app/instance/uitleenschrift.db" ]; then
        echo "Entrypoint: Ensuring database file has correct permissions"
        chown appuser:appuser /app/instance/uitleenschrift.db
        chmod 664 /app/instance/uitleenschrift.db
    fi
) &

# Switch to appuser and start the application
exec runuser -u appuser -- python app.py
