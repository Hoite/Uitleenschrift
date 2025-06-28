# 🚀 Quick Setup Guide voor uitleenschrift.nl

Je hebt je domein `uitleenschrift.nl` al gekoppeld aan Cloudflare. Hier zijn de stappen om je productie omgeving op te zetten:

## 📋 Checklist Voorbereiding

- ✅ Domein `uitleenschrift.nl` in Cloudflare
- ✅ Cloudflare account met Zero Trust toegang
- 🔄 Server met Docker (Ubuntu/Debian aanbevolen)
- 🔄 Code repository gecloned

## 🔗 Stap 1: Cloudflare Tunnel Opzetten

### Optie A: Token Methode (Makkelijkst)

1. **Ga naar Cloudflare Dashboard**:
   ```
   https://one.dash.cloudflare.com
   ```

2. **Maak tunnel aan**:
   - Zero Trust → Access → Tunnels
   - "Create a tunnel" → Naam: `uitleenschrift`
   - Kies "Docker" als connector
   - **Kopieer de tunnel token** (lange string)

3. **Configureer public hostname**:
   - Subdomain: `(leeg)`
   - Domain: `uitleenschrift.nl`
   - Service Type: `HTTP`
   - URL: `localhost:5001`

4. **Voeg WWW subdomain toe**:
   - "Add a public hostname"
   - Subdomain: `www`
   - Domain: `uitleenschrift.nl`
   - Service Type: `HTTP`
   - URL: `localhost:5001`

## 🖥️ Stap 2: Server Setup

```bash
# Clone repository
git clone https://github.com/[jouw-username]/Uitleenschrift.git
cd Uitleenschrift

# Kopieer productie template
cp .env.production .env

# Bewerk environment
nano .env
```

## ⚙️ Stap 3: Environment Configuratie

Bewerk `.env` en vul in:

```bash
# Secret key (genereer een sterke key)
SECRET_KEY=your-super-secure-secret-key-here-change-this-in-production

# Google Books API (optioneel, maar aanbevolen)
GOOGLE_BOOKS_API_KEY=your-google-books-api-key-here

# Cloudflare tunnel token (plak jouw token hier)
CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoiYWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXowMTIzNDU2Nzg5...

# Domain (al correct ingevuld)
DOMAIN_NAME=uitleenschrift.nl
ALLOWED_HOSTS=uitleenschrift.nl,www.uitleenschrift.nl

# Security (al correct ingevuld)
DEBUG=False
FLASK_ENV=production
```

## 🚀 Stap 4: Deployment

```bash
# Deploy applicatie
./deploy-production.sh

# Of handmatig:
COMPOSE_PROFILES=tunnel-token docker-compose -f docker-compose.prod.yml up -d
```

## 🔍 Stap 5: Verificatie

```bash
# Check status
./scripts/health-check.sh

# Test local
curl http://localhost:5001/health

# Test public (wacht 1-2 minuten voor propagatie)
curl https://uitleenschrift.nl/health
```

## 📱 Resultaat

Na succesvolle setup heb je:

- ✅ **Live website**: https://uitleenschrift.nl
- ✅ **WWW redirect**: https://www.uitleenschrift.nl
- ✅ **SSL/HTTPS**: Automatisch via Cloudflare
- ✅ **Auto-updates**: Via Watchtower
- ✅ **Monitoring**: Health checks
- ✅ **Backups**: Dagelijkse scripts

## 🛠️ Beheer Commando's

```bash
# Status check
./scripts/health-check.sh

# Backup maken
./scripts/backup.sh

# Logs bekijken
docker-compose -f docker-compose.prod.yml logs -f app

# Herstarten
docker-compose -f docker-compose.prod.yml restart

# Stoppen
docker-compose -f docker-compose.prod.yml down
```

## 🆘 Hulp Nodig?

- 📖 **Volledige documentatie**: `docs/PRODUCTION_SETUP.md`
- 🔗 **Cloudflare tunnel help**: `docs/CLOUDFLARE_TUNNEL.md`
- ⚡ **Features overzicht**: `docs/FEATURES.md`

## 🎯 Volgende Stappen (Optioneel)

1. **Automatische backups**: Setup crontab met `scripts/crontab-example`
2. **Monitoring**: Setup log rotation en alerting
3. **Performance**: Configure Cloudflare caching rules
4. **Security**: Enable Cloudflare security features

**Succes met je Uitleenschrift deployment! 🎉**
