#!/bin/bash

# Uitleenschrift - Flask App Starter Script

echo "🚀 Starten van Uitleenschrift..."
echo ""

# Ga naar de juiste directory
cd "$(dirname "$0")"

# Activeer de virtual environment en start de app
echo "📚 Flask server start op http://localhost:5000"
echo "💡 Druk Ctrl+C om te stoppen"
echo ""

exec ./.venv/bin/python app.py
