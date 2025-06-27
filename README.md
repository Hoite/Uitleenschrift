# 📚 Uitleenschrift

Een elegante Flask web applicatie om bij te houden welke boeken je hebt uitgeleend en aan wie.

![Python](https://img.shields.io/badge/python-v3.8+-blue.svg)
![Flask](https://img.shields.io/badge/flask-2.0+-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Docker](https://img.shields.io/badge/docker-ready-blue.svg)
![Build Status](https://github.com/Hoite/Uitleenschrift/workflows/Build%20and%20Push%20Docker%20Image/badge.svg)
![Docker Image](https://img.shields.io/badge/docker%20hub-hoite%2Fuitleenschrift-blue)

## ✨ Functionaliteiten

- **👤 Gebruikersbeheer**: Veilige registratie, login en sessie management
- **📖 Uitleningen bijhouden**: Beheer al je uitgeleende boeken met alle relevante details
- **🖼️ Automatische boekomslagen**: Covers worden automatisch opgehaald via Google Books API
- **🖨️ Print functionaliteit**: Print overzichten van uitgeleende boeken (compact & volledig)
- **📊 Dashboard**: Overzicht van alle uitgeleende boeken met covers
- **📝 Bewerken**: Wijzig uitleengegevens en markeer boeken als teruggegeven
- **🔄 Cover verversen**: Handmatig nieuwe covers ophalen voor bestaande boeken
- **📈 Statistieken**: Totaal uitgeleend, nog uitgeleend, teruggegeven
- **🇳🇱 Nederlandse datum notatie**: DD/MM/YYYY formaat
- **📱 Responsive design**: Bootstrap styling voor alle apparaten

## 🚀 Installatie en gebruik

### 📋 Vereisten
- Python 3.8 of hoger
- pip (Python package manager)

### ⚡ Quick Start

1. **Clone de repository**
   ```bash
   git clone https://github.com/Hoite/Uitleenschrift.git
   cd Uitleenschrift
   ```

2. **Maak een virtuele omgeving**
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate  # Linux/Mac
   # of
   .venv\Scripts\activate     # Windows
   ```

3. **Installeer dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configureer de applicatie**
   ```bash
   cp .env.example .env
   # Bewerk .env met je eigen instellingen
   ```

5. **Start de applicatie**
   ```bash
   python app.py
   # of gebruik het start script
   ./start.sh
   ```

4. **Applicatie starten**
   ```bash
   /Users/hoite/Dev/Uitleenschrift/.venv/bin/python app.py
   ```

5. **Open je browser**
   Ga naar `http://localhost:5000` om de applicatie te gebruiken.

## Gebruik

1. **Registreer een account** of log in als je al een account hebt
2. **Voeg uitleningen toe** via de "Nieuwe Uitlening" knop
3. **Bekijk je dashboard** om een overzicht te krijgen van al je uitleningen
4. **Markeer boeken als teruggegeven** wanneer je ze terugkrijgt
5. **Bewerk uitleningen** om gegevens aan te passen

## Database

De applicatie gebruikt SQLite als database, die automatisch wordt aangemaakt als `uitleenschrift.db` in de hoofdmap van de applicatie.

## Beveiliging

⚠️ **Belangrijk**: Voor productiegebruik moet je:
- De `SECRET_KEY` in `app.py` wijzigen naar een veilige, willekeurige string
- HTTPS gebruiken
- Een productie-database configureren (PostgreSQL, MySQL, etc.)

## Functies per pagina

### Dashboard
- Overzicht van alle uitgeleende boeken met covers
- Statistieken (totaal uitgeleend, nog uitgeleend, teruggegeven)
- Snelle acties (markeren als teruggegeven, bewerken, cover verversen, verwijderen)
- Recente teruggegeven boeken
- Visuele boekomslagen voor betere herkenbaarheid

### Nieuwe Uitlening
- Formulier om nieuwe uitlening toe te voegen
- Automatische cover ophaling via Google Books API
- Verplichte velden: titel, auteur, uitgeleend aan, datum
- Optionele velden: verwachte teruggave, notities

### Bewerken
- Alle gegevens van een uitlening aanpassen
- Status wijzigen (uitgeleend/teruggegeven)
- Snelle knop om als teruggegeven te markeren

### Boekomslagen
- Automatische ophaling bij nieuwe uitleningen
- Handmatige verversing via "Cover verversen" knop
- Fallback placeholder voor boeken zonder cover
- Optimale beeldkwaliteit (zoekt naar hoogste resolutie)

## Technische details

- **Framework**: Flask (Python)
- **Database**: SQLite met SQLAlchemy ORM
- **Authenticatie**: Flask-Login
- **Forms**: Flask-WTF + WTForms
- **Frontend**: Bootstrap 5 + Bootstrap Icons
- **Wachtwoord beveiliging**: Werkzeug password hashing
- **Deployment**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **Hosting**: Docker container met Cloudflare tunnel

## 🐳 Docker Deployment

### Lokaal Testen
```bash
# Build en run met Docker Compose
docker-compose up --build

# Of alleen build
docker build -t uitleenschrift .
docker run -p 5000:5000 --env-file .env uitleenschrift
```

### Productie Deployment
```bash
# Download deployment script
wget https://raw.githubusercontent.com/Hoite/Uitleenschrift/main/deploy.sh
chmod +x deploy.sh

# Configureer environment
cp .env.example .env
# Edit .env met je eigen waardes

# Deploy
./deploy.sh
```

Zie [DEPLOYMENT.md](DEPLOYMENT.md) voor complete server setup instructies.

## 🔄 Automatische Updates

- **GitHub Actions**: Bouwt automatisch nieuwe Docker images bij commits
- **Watchtower**: Checkt en update containers automatisch
- **Health Checks**: Monitort applicatie status

## Mogelijke uitbreidingen

- Email notificaties voor late teruggaves
- Barcode scanning voor boeken
- Export functionaliteit (CSV, PDF)
- Categorie/genre tags
- Foto's van boeken
- Multiple leners per boek
- Geschiedenis/logboek van wijzigingen
- Multi-tenant support voor meerdere gebruikers
