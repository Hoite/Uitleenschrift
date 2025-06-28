# 📚 Uitleenschrift Documentation

Volledige technische documentatie voor de Uitleenschrift Flask applicatie.

## 📖 Overzicht

Uitleenschrift is een moderne Flask web applicatie voor het bijhouden van uitgeleende boeken met geavanceerde features zoals automatische boekgegevens import, multi-match selectie, dark mode en meer.

## 📋 Documentatie Index

### 🚀 Deployment & Operations
- [**DEPLOYMENT.md**](DEPLOYMENT.md) - Complete server setup en productie deployment guide
  - Docker deployment
  - Environment configuratie
  - Watchtower automatische updates
  - SSL/TLS setup
  - Monitoring en troubleshooting

### 🔍 Feature Documentatie
- [**MULTI_MATCH_IMPLEMENTATION.md**](MULTI_MATCH_IMPLEMENTATION.md) - Multi-match boek selectie feature
  - Google Books API integratie
  - Visuele kaart interface
  - AJAX endpoint implementatie
  - Frontend/backend architectuur

- [**MULTILANG_UPDATE.md**](MULTILANG_UPDATE.md) - Meertalige boeken ondersteuning
  - Internationale en Nederlandse boeken
  - Taalfiltering en deduplicatie
  - Language display indicators
  - API optimalisaties

- [**DARK_MODE_IMPLEMENTATION.md**](DARK_MODE_IMPLEMENTATION.md) - Dark mode feature
  - CSS custom properties
  - JavaScript theme switching
  - localStorage persistence
  - Accessibility en UX

## 🏗️ Architectuur Overzicht

### Backend Stack
- **Framework**: Flask 2.0+
- **Database**: SQLAlchemy ORM met SQLite/PostgreSQL
- **Authentication**: Flask-Login met Werkzeug password hashing
- **Forms**: Flask-WTF + WTForms met CSRF protection
- **APIs**: Google Books API voor boekgegevens

### Frontend Stack
- **UI Framework**: Bootstrap 5.3+
- **Icons**: Bootstrap Icons
- **JavaScript**: Vanilla JS met AJAX
- **Styling**: CSS Custom Properties voor theming
- **Responsive**: Mobile-first design

### Infrastructure
- **Containerization**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **Updates**: Watchtower voor automatische deployments
- **Monitoring**: Health checks en logging

## 🎯 Core Features

### User Management
- Secure user registration en authentication
- Session management met Flask-Login
- Password hashing en CSRF protection

### Book Management
- CRUD operaties voor uitleningen
- Automatische Google Books API lookup
- Multi-match selectie interface
- Cover image management

### Data Visualization
- Dashboard met statistieken
- Responsive book cards met covers
- Print-friendly layouts
- Dark/light theme support

### API Integration
- Google Books API voor boekgegevens
- Automatische cover image ophalen
- Multi-language search support
- Rate limiting en error handling

## 🔧 Development Guide

### Lokale Setup
```bash
# Clone repository
git clone https://github.com/Hoite/Uitleenschrift.git
cd Uitleenschrift

# Setup virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env met je Google Books API key

# Run application
python app.py
```

### Testing
```bash
# Run feature tests
python test_multimatch.py    # Multi-match functionality
python test_multilang.py     # Multi-language support
python test_darkmode.py      # Dark mode implementation
```

### Environment Variables
```bash
SECRET_KEY=your-secret-key-here
DATABASE_URL=sqlite:///instance/uitleenschrift.db
GOOGLE_BOOKS_API_KEY=your-google-books-api-key
```

## 📊 Database Schema

### Users Table
- `id` (Primary Key)
- `username` (Unique)
- `email` (Unique)
- `password_hash`

### Uitleningen Table
- `id` (Primary Key)
- `boek_titel`
- `auteur`
- `uitgeleend_aan`
- `uitgeleend_vanaf`
- `verwachte_teruggave`
- `teruggegeven` (Boolean)
- `notities`
- `cover_url`
- `user_id` (Foreign Key)

## 🔐 Security Features

- **CSRF Protection**: Flask-WTF CSRF tokens op alle forms
- **Password Security**: Werkzeug PBKDF2 password hashing
- **Session Management**: Secure Flask-Login sessions
- **Input Validation**: WTForms validators
- **SQL Injection Protection**: SQLAlchemy ORM
- **XSS Protection**: Jinja2 template auto-escaping

## 🚀 Performance Optimizations

- **Database**: SQLAlchemy connection pooling
- **Static Assets**: CDN voor Bootstrap/Icons
- **Images**: HTTPS enforcement voor covers
- **Caching**: Browser caching voor static assets
- **Compression**: Gzip compression in production

## 🎨 UI/UX Features

### Responsive Design
- Mobile-first Bootstrap 5 layout
- Adaptive navigation
- Touch-friendly interface

### Dark Mode
- CSS custom properties voor theming
- JavaScript localStorage persistence
- Smooth transitions
- Comprehensive component coverage

### Accessibility
- Semantic HTML
- ARIA labels waar nodig
- Keyboard navigation
- High contrast colors

## 📱 Mobile Support

- Responsive breakpoints
- Touch-friendly buttons
- Optimized form layouts
- Mobile print layouts

## 🔄 Update Workflow

### Development
1. Feature development op feature branch
2. Testing met lokale scripts
3. Pull request naar main branch

### Production
1. GitHub Actions bouwt Docker image
2. Watchtower detecteert nieuwe image
3. Automatische deployment met health checks
4. Rollback indien health checks falen

## 🐛 Troubleshooting

### Common Issues
- Google Books API quota limits
- Database migration problemen
- Docker volume permissions
- SSL certificate renewal

### Monitoring
- Health check endpoint: `/health`
- Application logs via Docker
- Watchtower update logs
- Server resource monitoring

---

Voor vragen of bijdragen, zie de main [README.md](../README.md) voor contact informatie.
