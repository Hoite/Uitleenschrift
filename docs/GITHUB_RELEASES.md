# 📦 GitHub Releases Guide voor Uitleenschrift

Complete handleiding voor het gebruik van GitHub Releases in combinatie met semantic versioning.

## 🎯 Overzicht

GitHub Releases worden automatisch aangemaakt bij elke versie update via het VERSION bestand. Dit geeft je:

- 📋 **Automatische Changelogs** - Gegenereerd uit commit berichten
- 🏷️ **Version Tags** - Semantische versie tags (v1.0.0, v1.1.0, etc.)
- 📦 **Docker Links** - Directe links naar Docker Hub images
- 🚀 **Deployment Instructies** - Ready-to-use deployment commando's
- 📊 **Release Statistieken** - Download counts en gebruik metrics

## 🤖 Automatische Releases

### Workflow
1. **Versie Bump**: `./scripts/version.sh patch/minor/major`
2. **Commit & Push**: Wijzigingen naar GitHub
3. **Auto Release**: GitHub Actions maakt automatisch release aan
4. **Docker Build**: Nieuwe images met version tags

### Voorbeeld
```bash
# Patch versie (bugfix)
./scripts/version.sh patch
git add VERSION
git commit -m "fix: resolved dark mode table issue"
git push

# → Automatisch GitHub Release v1.0.1 wordt aangemaakt
# → Docker image hoite/uitleenschrift:1.0.1 wordt gebouwd
```

## 🛠️ Handmatige Releases

Voor meer controle over release content kun je handmatig releases aanmaken:

### Met GitHub CLI
```bash
# Basis release met auto-generated notes
./scripts/create-release.sh

# Specifieke versie
./scripts/create-release.sh 1.2.0

# Met custom release notes
./scripts/create-release.sh 1.2.0 release-notes.md
```

### Setup GitHub CLI
```bash
# Installeer GitHub CLI
brew install gh              # macOS
# of: apt install gh         # Ubuntu

# Login
gh auth login

# Test
gh release list
```

## 📝 Release Notes Templates

### Patch Release (1.0.0 → 1.0.1)
```markdown
## 🔧 Bugfixes

- Fixed dark mode table styling issue
- Resolved form validation edge case
- Updated health check timeout

## 📦 Docker Images
- `hoite/uitleenschrift:latest`
- `hoite/uitleenschrift:1.0.1`
```

### Minor Release (1.0.0 → 1.1.0)
```markdown
## ✨ Nieuwe Features

- 📚 Bulk book import functionaliteit
- 🔍 Advanced search filters
- 📊 Enhanced statistics dashboard

## 🔧 Verbeteringen

- Snellere book lookup API calls
- Verbeterde mobile responsiveness
- Updated dependencies

## 📦 Docker Images
- `hoite/uitleenschrift:latest`
- `hoite/uitleenschrift:1.1.0`

## 🚀 Deployment
```bash
VERSION=1.1.0 ./deploy-production.sh
```
```

### Major Release (1.0.0 → 2.0.0)
```markdown
## 🚨 Breaking Changes

- **Database Schema**: Updated user authentication system
- **API Changes**: Modified book lookup endpoints
- **Configuration**: New environment variables required

## 🎉 Nieuwe Features

- 👥 Multi-user support
- 🔐 Enhanced security
- ⚡ Performance improvements

## 📋 Migration Guide

### Voor bestaande installaties:
1. Backup je database: `./scripts/backup.sh`
2. Update environment: `cp .env.production .env`
3. Deploy: `VERSION=2.0.0 ./deploy-production.sh`

## 📦 Docker Images
- `hoite/uitleenschrift:latest`
- `hoite/uitleenschrift:2.0.0`
```

## 🔄 Release Workflow

### Automatisch (Aanbevolen)
```bash
# 1. Maak wijzigingen
git add .
git commit -m "feat: nieuwe functionaliteit"

# 2. Bump versie
./scripts/version.sh minor  # 1.0.0 → 1.1.0

# 3. Commit versie
git add VERSION
git commit -m "bump: version to v1.1.0"

# 4. Push (triggert automatische release)
git push
```

### Handmatig
```bash
# 1. Versie instellen
./scripts/version.sh set 1.2.0

# 2. Custom release notes maken
cat > release-notes.md << EOF
## ✨ Speciale Release

Deze release bevat belangrijke updates...
EOF

# 3. Release aanmaken
./scripts/create-release.sh 1.2.0 release-notes.md

# 4. Commit en push
git add VERSION
git commit -m "bump: version to v1.2.0"
git push
```

## 📊 Release Management

### Release Overzicht
```bash
# Lijst alle releases
gh release list

# Bekijk specifieke release
gh release view v1.0.1

# Download release assets
gh release download v1.0.1
```

### Release Statistieken
```bash
# Release details met download stats
gh api repos/Hoite/Uitleenschrift/releases | jq '.[] | {name: .name, downloads: [.assets[].download_count] | add}'
```

### Pre-releases
Voor beta versies:
```bash
gh release create v1.1.0-beta.1 \
    --title "Beta Release v1.1.0-beta.1" \
    --notes "Beta versie voor testing" \
    --prerelease
```

## 🎯 Best Practices

### ✅ Do's
- **Semantic Versioning**: Gebruik correcte versie bumps
- **Descriptive Commits**: Duidelijke commit berichten voor changelog
- **Test Before Release**: Valideer functionaliteit voor release
- **Backup First**: Maak backup voor major releases
- **Document Breaking Changes**: Duidelijke migration guides

### ❌ Don'ts
- **Skip Testing**: Nooit direct naar productie zonder test
- **Unclear Messages**: Vage commit berichten
- **Missing Migration**: Breaking changes zonder upgrade guide
- **Force Push**: Never force push naar main branch

## 🔗 Integraties

### Watchtower Updates
Watchtower detecteert automatisch nieuwe releases:
```bash
# Check watchtower logs voor updates
docker-compose -f docker-compose.prod.yml logs watchtower

# Forceer update check
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once
```

### Notifications
Setup Discord/Slack notifications:
```yaml
# In .github/workflows/release.yml
- name: Notify Discord
  uses: sarisia/actions-status-discord@v1
  with:
    webhook: ${{ secrets.DISCORD_WEBHOOK }}
    title: "New Release: ${{ steps.version.outputs.TAG }}"
```

## 📈 Release Analytics

Track release performance:
- **Download Counts**: Hoeveel mensen downloaden releases
- **Update Speed**: Hoe snel updates worden geadopteerd
- **Issue Reports**: Bug reports per release
- **Feature Usage**: Welke features worden gebruikt

## 🆘 Troubleshooting

### Release Fails
```bash
# Check GitHub Actions logs
gh run list
gh run view [run-id]

# Retry failed release
gh release delete v1.0.1 --yes
./scripts/create-release.sh 1.0.1
```

### Docker Build Issues
```bash
# Check Docker build logs in GitHub Actions
# Manual build test:
docker build --build-arg VERSION=1.0.1 -t test .
```

### Watchtower Not Updating
```bash
# Check watchtower logs
docker logs uitleenschrift-watchtower

# Force update
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once uitleenschrift-app
```

---

**Met GitHub Releases heb je nu een professionele release pipeline! 🚀**
