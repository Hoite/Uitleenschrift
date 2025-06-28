# 📚 Uitleenschrift

Een elegante Flask web applicatie om bij te houden welke boeken je hebt uitgeleend en aan wie.

![Python](https://img.shields.io/badge/python-v3.8+-blue.svg)
![Flask](https://img.shields.io/badge/flask-2.0+-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Docker](https://img.shields.io/badge/docker-ready-blue.svg)
![Build Status](https://github.com/Hoite/Uitleenschrift/workflows/Build%20and%20Push%20Docker%20Image/badge.svg)

## ✨ Hoofdfunctionaliteiten

- **� Uitleenbeheer**: Voeg uitleningen toe, bewerk en markeer als teruggegeven
- **🖼️ Smart Book Lookup**: Automatische titel/auteur/cover import via Google Books API
- **� Multi-match Selectie**: Kies uit 3-5 boekmatches met visuele kaarten
- **🌍 Meertalig**: Ondersteunt Nederlandse, Engelse en internationale boeken
- **🌙 Dark Mode**: Automatische theme switching met localStorage persistence
- **� Gebruikersbeheer**: Veilige registratie en login
- **�️ Print Support**: Compacte en volledige overzichten
- **📊 Dashboard**: Statistieken en overzicht met boekomslagen
- **📱 Responsive**: Modern Bootstrap 5 design

## 🚀 Quick Start

### Met Docker (Aanbevolen)
```bash
# Clone repository
git clone https://github.com/Hoite/Uitleenschrift.git
cd Uitleenschrift

# Configureer environment
cp .env.example .env
# Bewerk .env met je Google Books API key

# Start met Docker Compose
docker-compose up --build
```

### Lokale Installatie
```bash
# Clone en setup
git clone https://github.com/Hoite/Uitleenschrift.git
cd Uitleenschrift

# Virtual environment
python3 -m venv .venv
source .venv/bin/activate  # Linux/Mac

# Installeer dependencies
pip install -r requirements.txt

# Configureer en start
cp .env.example .env
python app.py
```

Ga naar `http://localhost:5000` om de applicatie te gebruiken.

## 📖 Gebruik

1. **Registreer** een account of log in
2. **Voeg uitleningen toe** - typ titel/auteur en selecteer uit Google Books matches
3. **Beheer je boeken** - bekijk dashboard met covers, statistieken en snelle acties
4. **Dark mode** - klik op de maan/zon knop in de navbar
5. **Print overzichten** - gebruik de print functies voor fysieke lijsten

## 🏗️ Tech Stack

- **Backend**: Python Flask, SQLAlchemy, Flask-Login
- **Frontend**: Bootstrap 5, JavaScript, CSS Custom Properties
- **Database**: SQLite (ontwikkeling), PostgreSQL compatible
- **APIs**: Google Books API voor boekgegevens
- **Deployment**: Docker, Docker Compose, GitHub Actions
- **Features**: CSRF protection, password hashing, responsive design

## 📚 Documentatie

Volledige documentatie is beschikbaar in de [`docs/`](docs/) map:

- [**Deployment Guide**](docs/DEPLOYMENT.md) - Server setup en productie deployment
- [**Multi-Match Feature**](docs/MULTI_MATCH_IMPLEMENTATION.md) - Boek selectie functionaliteit
- [**Multilingual Support**](docs/MULTILANG_UPDATE.md) - Internationale boeken ondersteuning
- [**Dark Mode Implementation**](docs/DARK_MODE_IMPLEMENTATION.md) - Theme switching technische details

## 🐳 Production Deployment

Voor production deployment met automatische updates:

```bash
# Download deployment script
wget https://raw.githubusercontent.com/Hoite/Uitleenschrift/main/deploy.sh
chmod +x deploy.sh

# Configureer en deploy
cp .env.example .env
# Edit .env met productie waardes
./deploy.sh
```

Zie [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) voor complete server setup instructies.

## 🔄 Automatische Updates

- **GitHub Actions**: Bouwt automatisch Docker images bij commits
- **Watchtower**: Automatische container updates
- **Health Checks**: Monitort applicatie status

## 🤝 Contributing

1. Fork de repository
2. Maak een feature branch (`git checkout -b feature/nieuwe-functie`)
3. Commit je wijzigingen (`git commit -am 'Voeg nieuwe functie toe'`)
4. Push naar branch (`git push origin feature/nieuwe-functie`)
5. Maak een Pull Request

## 📄 Licentie

Dit project staat onder de MIT License - zie het [LICENSE](LICENSE) bestand voor details.

## 🙏 Dankbetuigingen

- Google Books API voor boekgegevens en covers
- Bootstrap voor het responsive framework
- Flask community voor de geweldige libraries

---

**Made with ❤️ in Nederland**
