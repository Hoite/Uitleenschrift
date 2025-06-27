# Server Setup Guide

Deze guide helpt je om Uitleenschrift op je server te deployen met Docker en Cloudflare tunnel.

## 📋 Vereisten

- Server met Docker en Docker Compose geïnstalleerd
- Cloudflare account met tunnel toegang
- Domein (uitleenschrift.hoite.nl) gekoppeld aan Cloudflare

## 🚀 Server Setup

### 1. Server Voorbereiding

```bash
# Update server
sudo apt update && sudo apt upgrade -y

# Installeer Docker (Ubuntu/Debian)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Installeer Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Log uit en weer in voor Docker groep
```

### 2. Project Setup op Server

```bash
# Maak project directory
mkdir -p /opt/uitleenschrift
cd /opt/uitleenschrift

# Download deployment bestanden
wget https://raw.githubusercontent.com/Hoite/Uitleenschrift/main/docker-compose.prod.yml
wget https://raw.githubusercontent.com/Hoite/Uitleenschrift/main/deploy.sh
chmod +x deploy.sh

# Kopieer .env.example en configureer
wget https://raw.githubusercontent.com/Hoite/Uitleenschrift/main/.env.example -O .env
nano .env  # Vul je geheime sleutels in
```

### 3. Eerste Deployment

```bash
# Run deployment script
./deploy.sh

# Of handmatig met docker-compose
docker-compose -f docker-compose.prod.yml up -d
```

## 🌐 Cloudflare Tunnel Setup

### 1. Installeer Cloudflared

```bash
# Download en installeer cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
```

### 2. Authenticatie

```bash
# Login bij Cloudflare
cloudflared tunnel login
```

### 3. Tunnel Aanmaken

```bash
# Maak tunnel aan
cloudflared tunnel create uitleenschrift

# Kopieer tunnel ID uit output voor volgende stappen
```

### 4. DNS Configuratie

```bash
# Voeg DNS record toe (vervang TUNNEL_ID)
cloudflared tunnel route dns uitleenschrift uitleenschrift.hoite.nl
```

### 5. Tunnel Configuratie

Maak configuratiebestand: `/home/$USER/.cloudflared/config.yml`

```yaml
tunnel: TUNNEL_ID  # Vervang met jouw tunnel ID
credentials-file: /home/$USER/.cloudflared/TUNNEL_ID.json

ingress:
  - hostname: uitleenschrift.hoite.nl
    service: http://localhost:5000
  - service: http_status:404
```

### 6. Tunnel Service Instellen

```bash
# Installeer als systemd service
sudo cloudflared service install

# Start service
sudo systemctl start cloudflared
sudo systemctl enable cloudflared

# Check status
sudo systemctl status cloudflared
```

## 🔄 Automatische Updates

### Optie 1: Watchtower (Aanbevolen)

Watchtower is al geconfigureerd in `docker-compose.prod.yml` en zal automatisch naar nieuwe versies zoeken.

### Optie 2: Cron Job

```bash
# Voeg cron job toe voor dagelijkse updates
crontab -e

# Voeg deze regel toe (update elke dag om 3:00 AM)
0 3 * * * cd /opt/uitleenschrift && ./deploy.sh >> /var/log/uitleenschrift-deploy.log 2>&1
```

### Optie 3: Webhook (Geavanceerd)

Voor directe updates na GitHub commits kun je een webhook endpoint opzetten.

## 📊 Monitoring & Onderhoud

### Logs Bekijken

```bash
# Application logs
docker logs uitleenschrift-app

# Watchtower logs
docker logs uitleenschrift-watchtower

# Cloudflared logs
sudo journalctl -u cloudflared -f
```

### Health Check

```bash
# Lokale health check
curl http://localhost:5000/health

# Externe health check
curl https://uitleenschrift.hoite.nl/health
```

### Backup Database

```bash
# Backup instance directory (bevat SQLite database)
tar -czf backup-$(date +%Y%m%d).tar.gz /opt/uitleenschrift/instance/
```

## 🆘 Troubleshooting

### Container Start Problemen

```bash
# Check container status
docker ps -a

# Bekijk logs
docker logs uitleenschrift-app

# Herstart container
docker restart uitleenschrift-app
```

### Cloudflare Tunnel Problemen

```bash
# Check tunnel status
cloudflared tunnel info uitleenschrift

# Test tunnel connectivity
cloudflared tunnel --config /home/$USER/.cloudflared/config.yml run
```

### Database Problemen

```bash
# Access container voor database debugging
docker exec -it uitleenschrift-app /bin/bash

# Check database bestand
ls -la /app/instance/
```

## 🔐 Beveiliging

- Zorg dat `.env` bestand alleen door eigenaar leesbaar is: `chmod 600 .env`
- Update regelmatig je Docker images: `docker system prune -a`
- Monitor logs voor verdachte activiteit
- Gebruik sterke wachtwoorden voor admin accounts
- Overweeg rate limiting via Cloudflare

## 📞 Support

Voor vragen of problemen:
- GitHub Issues: https://github.com/Hoite/Uitleenschrift/issues
- Check logs eerst voor foutmeldingen
- Voeg relevante log output toe bij issue reports
