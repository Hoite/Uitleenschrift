# 🌐 Production Deployment Guide voor uitleenschrift.nl

Complete setup guide voor je eigen productieomgeving met het domein `uitleenschrift.nl` en Cloudflare tunnel.

## 📋 Overzicht Setup

Je hebt:
- ✅ Domein `uitleenschrift.nl` gekocht
- ✅ Domein gekoppeld aan Cloudflare
- 🔄 Server nodig voor hosting
- 🔄 Cloudflare tunnel configuratie

## 🚀 Stap-voor-Stap Setup

### 1. Server Voorbereiding

```bash
# Update server
sudo apt update && sudo apt upgrade -y

# Installeer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Installeer Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout en login opnieuw voor Docker groep
exit
```

### 2. Project Setup op Server

```bash
# Clone repository
git clone https://github.com/Hoite/Uitleenschrift.git
cd Uitleenschrift

# Kopieer productie environment template
cp .env.production .env

# Bewerk environment variabelen
nano .env
```

### 3. Environment Configuratie (.env)

```bash
# =========================
# APPLICATION SETTINGS  
# =========================
SECRET_KEY=your-super-secure-secret-key-here-change-this-in-production
DATABASE_URL=sqlite:///data/uitleenschrift.db

# =========================
# GOOGLE BOOKS API
# =========================
GOOGLE_BOOKS_API_KEY=your-google-books-api-key-here

# =========================
# CLOUDFLARE TUNNEL
# =========================
# Option 1: Tunnel Token (Aanbevolen - Makkelijkst)
CLOUDFLARE_TUNNEL_TOKEN=your-tunnel-token-here

# Option 2: Tunnel ID (Alternatief)
# CLOUDFLARE_TUNNEL_ID=your-tunnel-id-here

# =========================
# DOMAIN SETTINGS
# =========================
DOMAIN_NAME=uitleenschrift.nl
ALLOWED_HOSTS=uitleenschrift.nl,www.uitleenschrift.nl

# =========================
# SECURITY SETTINGS
# =========================
DEBUG=False
FLASK_ENV=production
```

### 4. Cloudflare Tunnel Setup

#### Optie A: Token Methode (Aanbevolen)

1. **Ga naar Cloudflare Dashboard**:
   - https://one.dash.cloudflare.com
   - Zero Trust → Access → Tunnels
   - "Create a tunnel" → Naam: "uitleenschrift"

2. **Configureer tunnel**:
   - **Public hostname**: `uitleenschrift.nl`
   - **Service Type**: HTTP
   - **URL**: `localhost:5001`

3. **Kopieer tunnel token**:
   ```bash
   # Voeg token toe aan .env
   echo "CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoiXXXXXX..." >> .env
   ```

#### Optie B: Config File Methode

1. **Installeer cloudflared**:
   ```bash
   wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
   sudo dpkg -i cloudflared-linux-amd64.deb
   ```

2. **Authenticatie**:
   ```bash
   cloudflared tunnel login
   ```

3. **Maak tunnel**:
   ```bash
   cloudflared tunnel create uitleenschrift
   ```

4. **Configureer DNS**:
   ```bash
   cloudflared tunnel route dns uitleenschrift uitleenschrift.nl
   cloudflared tunnel route dns uitleenschrift www.uitleenschrift.nl
   ```

5. **Update config file**:
   ```bash
   # Bewerk cloudflared-config.yml
   nano cloudflared-config.yml
   
   # Vervang YOUR_TUNNEL_ID_HERE met je echte tunnel ID
   # Kopieer je tunnel credentials naar tunnel-credentials/
   cp ~/.cloudflared/YOUR_TUNNEL_ID.json ./tunnel-credentials/
   ```

### 5. Deploy Applicatie

```bash
# Productie deployment
./deploy-production.sh

# Of handmatig voor token methode:
COMPOSE_PROFILES=tunnel-token docker-compose -f docker-compose.prod.yml up -d

# Of handmatig voor config methode:
COMPOSE_PROFILES=tunnel-config docker-compose -f docker-compose.prod.yml up -d
```

### 6. Verificatie

```bash
# Check status containers
docker-compose -f docker-compose.prod.yml ps

# Check logs
docker-compose -f docker-compose.prod.yml logs -f

# Test local access
curl http://localhost:5001/health

# Test public access
curl https://uitleenschrift.nl/health
```

## 🔧 Beheer Commando's

### Applicatie Beheer
```bash
# Complete health check
./scripts/health-check.sh

# Logs bekijken
docker-compose -f docker-compose.prod.yml logs -f app

# Applicatie herstarten
docker-compose -f docker-compose.prod.yml restart app

# Status controleren
docker-compose -f docker-compose.prod.yml ps
```

### Updates
```bash
# Handmatige update
./deploy-production.sh

# Watchtower doet automatische updates elke 5 minuten
# Check watchtower logs:
docker-compose -f docker-compose.prod.yml logs watchtower
```

### Backup
```bash
# Automatische backup met script
./scripts/backup.sh

# Of handmatig database backup
cp ./instance/uitleenschrift.db ./backups/uitleenschrift-$(date +%Y%m%d).db

# Setup automatische dagelijkse backup
crontab -e
# Voeg toe: 0 3 * * * cd /path/to/Uitleenschrift && ./scripts/backup.sh >> /var/log/uitleenschrift-backup.log 2>&1
```

## 🔍 Troubleshooting

### Cloudflare Tunnel Issues
```bash
# Check tunnel status
docker-compose -f docker-compose.prod.yml logs cloudflared

# Test local connection
curl http://localhost:5001/health

# Check Cloudflare tunnel dashboard
# https://one.dash.cloudflare.com → Zero Trust → Access → Tunnels
```

### Application Issues
```bash
# Check application logs
docker-compose -f docker-compose.prod.yml logs app

# Check health endpoint
curl http://localhost:5001/health

# Check environment variables
docker-compose -f docker-compose.prod.yml exec app env | grep -E "(SECRET_KEY|GOOGLE_BOOKS|DOMAIN)"
```

### Performance Monitoring
```bash
# Check resource usage
docker stats

# Check disk usage
df -h
docker system df

# Cleanup old containers/images
docker system prune -f
```

## 📊 Features Enabled

Met deze setup krijg je:

- ✅ **Public Access**: https://uitleenschrift.nl
- ✅ **WWW Redirect**: https://www.uitleenschrift.nl
- ✅ **SSL/TLS**: Automatisch via Cloudflare
- ✅ **DDoS Protection**: Via Cloudflare
- ✅ **Auto Updates**: Via Watchtower
- ✅ **Health Checks**: Automatische monitoring
- ✅ **Persistent Data**: Database blijft behouden bij updates
- ✅ **Backup Ready**: Eenvoudige backup procedures

## 🔐 Security Checklist

- ✅ Change SECRET_KEY in .env
- ✅ Set DEBUG=False
- ✅ Use HTTPS only (Cloudflare handles this)
- ✅ Regular backups scheduled
- ✅ Watchtower automatic updates enabled
- ✅ Health checks configured
- ✅ Non-root Docker containers

## 🎉 Je bent klaar!

Je Uitleenschrift applicatie is nu live op https://uitleenschrift.nl met:
- Automatische updates
- SSL beveiliging
- Professional hosting
- Global CDN via Cloudflare

Voor vragen of problemen, check de logs of maak een GitHub issue aan.
