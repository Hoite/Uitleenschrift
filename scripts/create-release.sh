#!/bin/bash

# GitHub Release Creator voor Uitleenschrift
# Gebruik: ./scripts/create-release.sh [version] [release-notes.md]

set -e

VERSION_FILE="VERSION"
REPO="Hoite/Uitleenschrift"

# Lees huidige versie
if [ ! -f "$VERSION_FILE" ]; then
    echo "❌ VERSION bestand niet gevonden!"
    exit 1
fi

current_version=$(cat "$VERSION_FILE")

# Gebruik opgegeven versie of huidige versie
VERSION=${1:-$current_version}
TAG="v$VERSION"

# Check of GitHub CLI geïnstalleerd is
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is niet geïnstalleerd!"
    echo "💡 Installeer met: brew install gh (macOS) of apt install gh (Ubuntu)"
    echo "🔗 Meer info: https://cli.github.com/"
    exit 1
fi

# Check of ingelogd bij GitHub
if ! gh auth status &> /dev/null; then
    echo "❌ Niet ingelogd bij GitHub!"
    echo "💡 Login met: gh auth login"
    exit 1
fi

echo "🎯 Creating GitHub Release voor Uitleenschrift $TAG"

# Check of tag al bestaat
if gh release view "$TAG" &> /dev/null; then
    echo "❌ Release $TAG bestaat al!"
    echo "💡 Bekijk bestaande releases: gh release list"
    exit 1
fi

# Release notes bestand of automatisch genereren
RELEASE_NOTES_FILE=${2:-""}

if [ -n "$RELEASE_NOTES_FILE" ] && [ -f "$RELEASE_NOTES_FILE" ]; then
    echo "📝 Gebruik custom release notes uit $RELEASE_NOTES_FILE"
    RELEASE_NOTES=$(cat "$RELEASE_NOTES_FILE")
else
    echo "🤖 Genereer automatische release notes..."
    
    # Get previous tag
    PREVIOUS_TAG=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "")
    
    if [ -n "$PREVIOUS_TAG" ]; then
        echo "📊 Vergelijking vanaf $PREVIOUS_TAG naar $TAG"
        
        # Genereer changelog
        RELEASE_NOTES="## 🚀 What's Changed

$(git log --pretty=format:"- %s" $PREVIOUS_TAG..HEAD | grep -E "(feat|fix|docs|refactor|perf|test|chore|style|ci|build)" | head -20 || echo "- Diverse verbeteringen en bugfixes")

## 📦 Docker Images
- \`hoite/uitleenschrift:latest\`
- \`hoite/uitleenschrift:$VERSION\`

## 🔄 Deployment
Voor productie deployment:
\`\`\`bash
# Specifieke versie deployen:
VERSION=$VERSION ./deploy-production.sh

# Of latest gebruiken (automatisch via Watchtower):
./deploy-production.sh
\`\`\`

## 🔗 Links
- [Productie Setup Guide](https://github.com/$REPO/blob/main/docs/PRODUCTION_SETUP.md)
- [Cloudflare Tunnel Setup](https://github.com/$REPO/blob/main/docs/CLOUDFLARE_TUNNEL.md)
- [Docker Hub](https://hub.docker.com/r/hoite/uitleenschrift)"
    else
        RELEASE_NOTES="## 🎉 Eerste Release

Welkom bij Uitleenschrift $TAG!

### ✨ Hoofdfunctionaliteiten:
- 📚 Uitleenbeheer met modern interface
- 🔍 Smart Book Lookup via Google Books API
- 🌍 Meertalige boeken ondersteuning
- 🌙 Dark mode met automatische switching
- 📱 Volledig responsive design
- 🐳 Production-ready Docker deployment
- 🔄 Automatische updates via Watchtower

## 📦 Docker Images
- \`hoite/uitleenschrift:latest\`
- \`hoite/uitleenschrift:$VERSION\`

## 🚀 Quick Start
\`\`\`bash
git clone https://github.com/$REPO.git
cd Uitleenschrift
./deploy-production.sh
\`\`\`"
    fi
fi

# Maak release aan
echo "🚀 Maak GitHub Release aan..."
gh release create "$TAG" \
    --title "Uitleenschrift $TAG" \
    --notes "$RELEASE_NOTES" \
    --repo "$REPO"

echo ""
echo "✅ GitHub Release $TAG succesvol aangemaakt!"
echo "🌐 Bekijk op: https://github.com/$REPO/releases/tag/$TAG"
echo ""
echo "📦 Docker images worden automatisch gebouwd en getagged:"
echo "   - hoite/uitleenschrift:latest"
echo "   - hoite/uitleenschrift:$VERSION"
echo ""
echo "🔄 Watchtower zal automatisch de nieuwe versie deployen naar productie."
