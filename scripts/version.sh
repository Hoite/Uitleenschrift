#!/bin/bash

# Version Management Script voor Uitleenschrift
# Gebruik: ./scripts/version.sh [major|minor|patch|set X.Y.Z|current]

set -e

VERSION_FILE="VERSION"

if [ ! -f "$VERSION_FILE" ]; then
    echo "1.0.0" > "$VERSION_FILE"
    echo "📦 VERSION bestand aangemaakt met versie 1.0.0"
fi

current_version=$(cat "$VERSION_FILE")

# Parse versie delen
IFS='.' read -r major minor patch <<< "$current_version"

case "${1:-help}" in
    "current")
        echo "🏷️  Huidige versie: $current_version"
        ;;
    
    "major")
        major=$((major + 1))
        minor=0
        patch=0
        new_version="$major.$minor.$patch"
        echo "$new_version" > "$VERSION_FILE"
        echo "🚀 Major versie update: $current_version → $new_version"
        echo "⚠️  Dit is een breaking change! Overleg eerst voordat je dit gebruikt."
        ;;
    
    "minor")
        minor=$((minor + 1))
        patch=0
        new_version="$major.$minor.$patch"
        echo "$new_version" > "$VERSION_FILE"
        echo "✨ Minor versie update (nieuwe features): $current_version → $new_version"
        ;;
    
    "patch")
        patch=$((patch + 1))
        new_version="$major.$minor.$patch"
        echo "$new_version" > "$VERSION_FILE"
        echo "🔧 Patch versie update (bugfixes): $current_version → $new_version"
        ;;
    
    "set")
        if [ -z "$2" ]; then
            echo "❌ Geen versie opgegeven. Gebruik: ./scripts/version.sh set X.Y.Z"
            exit 1
        fi
        if [[ ! "$2" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "❌ Ongeldige versie format. Gebruik X.Y.Z (bijv. 1.2.3)"
            exit 1
        fi
        echo "$2" > "$VERSION_FILE"
        echo "📝 Versie handmatig ingesteld: $current_version → $2"
        ;;
    
    "help"|*)
        echo "📦 Uitleenschrift Version Manager"
        echo ""
        echo "🏷️  Huidige versie: $current_version"
        echo ""
        echo "Gebruik:"
        echo "  ./scripts/version.sh current       - Toon huidige versie"
        echo "  ./scripts/version.sh patch         - Verhoog patch versie (bugfixes)"
        echo "  ./scripts/version.sh minor         - Verhoog minor versie (nieuwe features)"
        echo "  ./scripts/version.sh major         - Verhoog major versie (breaking changes)"
        echo "  ./scripts/version.sh set X.Y.Z     - Stel specifieke versie in"
        echo ""
        echo "Semantic Versioning:"
        echo "  📦 MAJOR: Breaking changes (bijv. 1.0.0 → 2.0.0)"
        echo "  ✨ MINOR: Nieuwe features (bijv. 1.0.0 → 1.1.0)"
        echo "  🔧 PATCH: Bugfixes (bijv. 1.0.0 → 1.0.1)"
        echo ""
        echo "Na versie update:"
        echo "  1. git add VERSION"
        echo "  2. git commit -m 'bump: version to vX.Y.Z'"
        echo "  3. git push"
        echo "  4. GitHub Actions bouwt automatisch nieuwe Docker image"
        exit 0
        ;;
esac

if [ "$1" != "current" ] && [ "$1" != "help" ]; then
    echo ""
    echo "📋 Volgende stappen:"
    echo "  1. git add VERSION"
    echo "  2. git commit -m 'bump: version to v$(cat $VERSION_FILE)'"
    echo "  3. git push"
    echo "  4. GitHub Actions bouwt automatisch Docker image met tag v$(cat $VERSION_FILE)"
    echo ""
    echo "💡 Tip: Voeg release notes toe aan de commit beschrijving!"
fi
