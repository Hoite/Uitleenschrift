# Uitleenschrift

Een eenvoudige Flask web applicatie om bij te houden welke boeken je hebt uitgeleend en aan wie.

## Functionaliteiten

- **Gebruikersbeheer**: Registreren, inloggen en uitloggen
- **Uitleningen bijhouden**: Voeg nieuwe uitleningen toe met alle relevante details
- **Automatische boekomslagen**: Cover wordt automatisch opgehaald via Google Books API
- **Print functionaliteit**: Print overzichten van uitgeleende boeken (compact & volledig)
- **Overzicht**: Zie in één oogopslag welke boeken nog uitstaan en welke terug zijn
- **Bewerken**: Wijzig uitleengegevens en markeer boeken als teruggegeven
- **Cover verversen**: Handmatig nieuwe covers ophalen voor bestaande boeken
- **Statistieken**: Dashboard met overzicht van al je uitleningen

## Installatie en gebruik

### Vereisten
- Python 3.8 of hoger
- pip (Python package manager)

### Stappen

1. **Clone of download de applicatie**
   ```bash
   cd /Users/hoite/Dev/Uitleenschrift
   ```

2. **Virtuele omgeving activeren** (al gedaan)
   De Python omgeving is al geconfigureerd.

3. **Packages installeren** (al gedaan)
   Alle benodigde packages zijn al geïnstalleerd.

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

## Mogelijke uitbreidingen

- Email notificaties voor late teruggaves
- Barcode scanning voor boeken
- Export functionaliteit (CSV, PDF)
- Categorie/genre tags
- Foto's van boeken
- Multiple leners per boek
- Geschiedenis/logboek van wijzigingen
