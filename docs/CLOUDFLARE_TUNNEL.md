# 🔗 Cloudflare Tunnel Setup Guide voor uitleenschrift.nl

Complete guide voor het opzetten van een Cloudflare tunnel voor je `uitleenschrift.nl` domein.

## 📋 Vereisten

- ✅ Domein `uitleenschrift.nl` gekoppeld aan Cloudflare
- ✅ Cloudflare account met Zero Trust toegang
- ✅ Server met Docker en Uitleenschrift geïnstalleerd

## 🚀 Methode 1: Tunnel Token (Aanbevolen)

### Stap 1: Tunnel Aanmaken

1. **Ga naar Cloudflare Dashboard**:
   ```
   https://one.dash.cloudflare.com
   ```

2. **Navigeer naar Zero Trust**:
   - Left sidebar → **Zero Trust**
   - **Access** → **Tunnels**

3. **Maak nieuwe tunnel**:
   - Klik **"Create a tunnel"**
   - Naam: `uitleenschrift`
   - Klik **"Save tunnel"**

### Stap 2: Connector Configuratie

1. **Kies environment**: **Docker**

2. **Kopieer de tunnel token**:
   ```bash
   # Voorbeeld token (vervang met jouw token):
   eyJhIjoiYWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXowMTIzNDU2Nzg5IiwidCI6IjEyMzQ1Njc4LTkwYWItY2RlZi0xMjM0LTU2Nzg5MGFiY2RlZiIsInMiOiJabVkyTVdZMlpEVXRabVkyTkMwMFltWXlMV0UzTlRjdE5URTNOemMzWW1Oak1EQTEifQ
   ```

### Stap 3: Public Hostname Setup

1. **Voeg hostname toe**:
   - **Subdomain**: `(leeg laten)`
   - **Domain**: `uitleenschrift.nl`
   - **Service Type**: `HTTP`
   - **URL**: `localhost:5001`

2. **Voeg WWW subdomain toe** (optioneel):
   - Klik **"Add a public hostname"**
   - **Subdomain**: `www`
   - **Domain**: `uitleenschrift.nl`
   - **Service Type**: `HTTP`
   - **URL**: `localhost:5001`

### Stap 4: Configuratie op Server

1. **Update .env bestand**:
   ```bash
   nano .env
   
   # Voeg jouw tunnel token toe:
   CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoiYWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXowMTIzNDU2Nzg5IiwidCI6IjEyMzQ1Njc4LTkwYWItY2RlZi0xMjM0LTU2Nzg5MGFiY2RlZiIsInMiOiJabVkyTVdZMlpEVXRabVkyTkMwMFltWXlMV0UzTlRjdE5URTNOemMzWW1Oak1EQTEifQ
   ```

2. **Deploy met tunnel**:
   ```bash
   ./deploy-production.sh
   ```

## 🔧 Methode 2: Tunnel Config (Geavanceerd)

### Stap 1: Cloudflared Installeren

```bash
# Download en installeer cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
```

### Stap 2: Authenticatie

```bash
# Login bij Cloudflare
cloudflared tunnel login

# Dit opent een browser - selecteer uitleenschrift.nl
```

### Stap 3: Tunnel Aanmaken

```bash
# Maak tunnel aan
cloudflared tunnel create uitleenschrift

# Noteer de tunnel ID die wordt weergegeven
# Bijvoorbeeld: 12345678-90ab-cdef-1234-567890abcdef
```

### Stap 4: DNS Configuratie

```bash
# Configureer DNS records
cloudflared tunnel route dns uitleenschrift uitleenschrift.nl
cloudflared tunnel route dns uitleenschrift www.uitleenschrift.nl
```

### Stap 5: Config File Setup

1. **Update cloudflared-config.yml**:
   ```bash
   nano cloudflared-config.yml
   
   # Vervang YOUR_TUNNEL_ID_HERE met jouw tunnel ID:
   tunnel: 12345678-90ab-cdef-1234-567890abcdef
   credentials-file: /etc/cloudflared/12345678-90ab-cdef-1234-567890abcdef.json
   
   ingress:
     - hostname: uitleenschrift.nl
       service: http://host.docker.internal:5000
     - hostname: www.uitleenschrift.nl
       service: http://host.docker.internal:5000
     - service: http_status:404
   ```

2. **Kopieer credentials**:
   ```bash
   # Maak credentials directory
   mkdir -p tunnel-credentials
   
   # Kopieer tunnel credentials
   cp ~/.cloudflared/12345678-90ab-cdef-1234-567890abcdef.json ./tunnel-credentials/
   ```

3. **Update .env**:
   ```bash
   # Voeg tunnel ID toe aan .env
   echo "CLOUDFLARE_TUNNEL_ID=12345678-90ab-cdef-1234-567890abcdef" >> .env
   ```

### Stap 6: Deploy met Config

```bash
# Deploy met config methode
COMPOSE_PROFILES=tunnel-config docker-compose -f docker-compose.prod.yml up -d
```

## 🔍 Verificatie

### Test Local Access
```bash
curl http://localhost:5001/health
```

### Test Public Access
```bash
# Test hoofddomein
curl https://uitleenschrift.nl/health

# Test WWW subdomain
curl https://www.uitleenschrift.nl/health
```

### Check Tunnel Status
```bash
# Check tunnel logs
docker-compose -f docker-compose.prod.yml logs cloudflared

# Of in Cloudflare dashboard:
# Zero Trust → Access → Tunnels → uitleenschrift
```

## 🛠️ Troubleshooting

### Tunnel Verbindt Niet

1. **Check logs**:
   ```bash
   docker-compose -f docker-compose.prod.yml logs cloudflared
   ```

2. **Verify token/config**:
   ```bash
   # Test token geldigheid
   echo $CLOUDFLARE_TUNNEL_TOKEN | base64 -d | jq .
   ```

3. **Check local app**:
   ```bash
   curl http://localhost:5001/health
   ```

### DNS Problemen

1. **Check DNS propagatie**:
   ```bash
   nslookup uitleenschrift.nl
   dig uitleenschrift.nl
   ```

2. **Verify Cloudflare DNS settings**:
   - Ga naar Cloudflare Dashboard → DNS
   - Check of CNAME records bestaan voor tunnel

### SSL/TLS Issues

1. **Check Cloudflare SSL settings**:
   - SSL/TLS → Overview
   - Zet op **"Full"** of **"Full (strict)"**

2. **Test HTTPS**:
   ```bash
   curl -I https://uitleenschrift.nl
   ```

## 🎯 Best Practices

- ✅ **Gebruik Token methode** voor eenvoud
- ✅ **Monitor tunnel logs** regelmatig
- ✅ **Setup health checks** voor monitoring
- ✅ **Backup tunnel config** en credentials
- ✅ **Test beide domeinen** (met en zonder www)

## 🔄 Updates en Onderhoud

### Tunnel Token Verversen
```bash
# Bij token verloop:
# 1. Genereer nieuwe token in Cloudflare Dashboard
# 2. Update .env bestand
# 3. Restart containers
docker-compose -f docker-compose.prod.yml restart cloudflared
```

### Config Updates
```bash
# Bij config wijzigingen:
nano cloudflared-config.yml
docker-compose -f docker-compose.prod.yml restart cloudflared-config
```

## 🎉 Klaar!

Je tunnel is nu actief! Je Uitleenschrift applicatie is bereikbaar op:

- 🌐 **https://uitleenschrift.nl**
- 🌐 **https://www.uitleenschrift.nl**

Met automatische SSL, DDoS bescherming en global CDN via Cloudflare!
