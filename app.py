from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, DateField, SubmitField, TextAreaField
from wtforms.validators import InputRequired, Length, ValidationError, Optional
from wtforms.widgets import DateInput
from datetime import datetime, date
import os
import requests
import urllib.parse
from dotenv import load_dotenv

# Laad environment variabelen uit .env bestand (voor lokale development)
load_dotenv()

# Custom DateField voor DD/MM/YYYY formaat met date helpers
class DutchDateField(DateField):
    """DateField dat DD/MM/YYYY formaat ondersteunt met date helpers"""
    
    def __init__(self, label=None, validators=None, show_today_button=True, show_default_return=False, default_return_days=7, **kwargs):
        super(DutchDateField, self).__init__(label, validators, **kwargs)
        self.show_today_button = show_today_button
        self.show_default_return = show_default_return
        self.default_return_days = default_return_days
    
    def process_formdata(self, valuelist):
        if valuelist:
            date_str = valuelist[0]
            if date_str:
                try:
                    # Probeer DD/MM/YYYY formaat
                    self.data = datetime.strptime(date_str, '%d/%m/%Y').date()
                except ValueError:
                    try:
                        # Fallback naar ISO formaat (YYYY-MM-DD) voor browser date inputs
                        self.data = datetime.strptime(date_str, '%Y-%m-%d').date()
                    except ValueError:
                        self.data = None
                        raise ValueError('Ongeldige datum. Gebruik DD/MM/YYYY formaat.')
            else:
                self.data = None
    
    def _value(self):
        if self.data:
            return self.data.strftime('%d/%m/%Y')
        else:
            return ''

app = Flask(__name__)

# Configuratie via environment variabelen met veilige fallbacks
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL', 'sqlite:///instance/uitleenschrift.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Google Books API Key uit environment variabelen
GOOGLE_BOOKS_API_KEY = os.environ.get('GOOGLE_BOOKS_API_KEY', '')

# Flask configuratie
app.config['WTF_CSRF_ENABLED'] = True

db = SQLAlchemy(app)

# Flask-Login setup
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'
login_manager.login_message = 'Je moet ingelogd zijn om deze pagina te bekijken.'

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# Database Models
class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(120), nullable=False)
    uitleningen = db.relationship('Uitlening', backref='eigenaar', lazy=True)

class Uitlening(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    boek_titel = db.Column(db.String(200), nullable=False)
    auteur = db.Column(db.String(100), nullable=False)
    uitgeleend_aan = db.Column(db.String(100), nullable=False)
    uitgeleend_vanaf = db.Column(db.Date, nullable=False, default=date.today)
    verwachte_teruggave = db.Column(db.Date, nullable=True)
    teruggegeven = db.Column(db.Boolean, default=False)
    notities = db.Column(db.Text, nullable=True)
    cover_url = db.Column(db.String(500), nullable=True)  # Voor boekcover URL
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    
    def __repr__(self):
        return f'<Uitlening {self.boek_titel} aan {self.uitgeleend_aan}>'

# Functie om boekomslag op te halen via Google Books API
def get_book_cover(titel, auteur):
    """
    Haal een boekomslag op via de Google Books API
    """
    if not GOOGLE_BOOKS_API_KEY:
        print("Geen Google Books API key geconfigureerd")
        return None
        
    try:
        # Maak een zoekquery
        query = f"{titel} {auteur}".strip()
        if not query:
            return None
            
        encoded_query = urllib.parse.quote(query)
        
        # Google Books API endpoint met API key
        url = f"https://www.googleapis.com/books/v1/volumes?q={encoded_query}&maxResults=1&key={GOOGLE_BOOKS_API_KEY}"
        
        # API call
        response = requests.get(url, timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            
            if 'items' in data and len(data['items']) > 0:
                book = data['items'][0]
                volume_info = book.get('volumeInfo', {})
                
                # Probeer een hoge kwaliteit cover te vinden
                image_links = volume_info.get('imageLinks', {})
                
                # Probeer verschillende cover grootten (van groot naar klein)
                for size in ['extraLarge', 'large', 'medium', 'small', 'thumbnail', 'smallThumbnail']:
                    if size in image_links:
                        cover_url = image_links[size]
                        # Forceer HTTPS voor veiligheid
                        if cover_url.startswith('http://'):
                            cover_url = cover_url.replace('http://', 'https://')
                        return cover_url
        
        return None
        
    except Exception as e:
        print(f"Fout bij ophalen boekomslag: {e}")
        return None

# Forms
class LoginForm(FlaskForm):
    username = StringField('Gebruikersnaam', validators=[InputRequired(), Length(min=4, max=20)])
    password = PasswordField('Wachtwoord', validators=[InputRequired(), Length(min=4, max=20)])
    submit = SubmitField('Inloggen')

class RegisterForm(FlaskForm):
    username = StringField('Gebruikersnaam', validators=[InputRequired(), Length(min=4, max=20)])
    email = StringField('Email', validators=[InputRequired(), Length(min=6, max=120)])
    password = PasswordField('Wachtwoord', validators=[InputRequired(), Length(min=4, max=20)])
    submit = SubmitField('Registreren')

    def validate_username(self, username):
        existing_user_username = User.query.filter_by(username=username.data).first()
        if existing_user_username:
            raise ValidationError('Deze gebruikersnaam bestaat al. Kies een andere.')

    def validate_email(self, email):
        existing_user_email = User.query.filter_by(email=email.data).first()
        if existing_user_email:
            raise ValidationError('Dit email adres is al geregistreerd. Kies een ander.')

class UitleningForm(FlaskForm):
    boek_titel = StringField('Boek Titel', validators=[InputRequired(), Length(min=1, max=200)])
    auteur = StringField('Auteur', validators=[InputRequired(), Length(min=1, max=100)])
    uitgeleend_aan = StringField('Uitgeleend aan', validators=[InputRequired(), Length(min=1, max=100)])
    uitgeleend_vanaf = DutchDateField('Uitgeleend vanaf', default=date.today, validators=[InputRequired()], show_today_button=True)
    verwachte_teruggave = DutchDateField('Verwachte teruggave (optioneel)', validators=[Optional()], show_today_button=True, show_default_return=True, default_return_days=14)
    notities = TextAreaField('Notities')
    submit = SubmitField('Uitlening toevoegen')

class BewerkenForm(FlaskForm):
    boek_titel = StringField('Boek Titel', validators=[InputRequired(), Length(min=1, max=200)])
    auteur = StringField('Auteur', validators=[InputRequired(), Length(min=1, max=100)])
    uitgeleend_aan = StringField('Uitgeleend aan', validators=[InputRequired(), Length(min=1, max=100)])
    uitgeleend_vanaf = DutchDateField('Uitgeleend vanaf', validators=[InputRequired()], show_today_button=True)
    verwachte_teruggave = DutchDateField('Verwachte teruggave (optioneel)', validators=[Optional()], show_today_button=True, show_default_return=True, default_return_days=14)
    notities = TextAreaField('Notities')
    teruggegeven = StringField('Teruggegeven (ja/nee)')
    submit = SubmitField('Wijzigingen opslaan')

# Routes
@app.route('/')
def index():
    if current_user.is_authenticated:
        return redirect(url_for('dashboard'))
    return render_template('index.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(username=form.username.data).first()
        if user and check_password_hash(user.password_hash, form.password.data):
            login_user(user)
            return redirect(url_for('dashboard'))
        flash('Ongeldige gebruikersnaam of wachtwoord')
    return render_template('login.html', form=form)

@app.route('/register', methods=['GET', 'POST'])
def register():
    form = RegisterForm()
    if form.validate_on_submit():
        hashed_password = generate_password_hash(form.password.data)
        new_user = User(
            username=form.username.data,
            email=form.email.data,
            password_hash=hashed_password
        )
        db.session.add(new_user)
        db.session.commit()
        flash('Registratie succesvol! Je kunt nu inloggen.')
        return redirect(url_for('login'))
    return render_template('register.html', form=form)

@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('Je bent uitgelogd.')
    return redirect(url_for('index'))

@app.route('/dashboard')
@login_required
def dashboard():
    uitgeleende_boeken = Uitlening.query.filter_by(user_id=current_user.id, teruggegeven=False).all()
    teruggegeven_boeken = Uitlening.query.filter_by(user_id=current_user.id, teruggegeven=True).all()
    
    # Statistieken
    totaal_uitgeleend = len(current_user.uitleningen)
    nog_uitgeleend = len(uitgeleende_boeken)
    teruggegeven = len(teruggegeven_boeken)
    
    stats = {
        'totaal': totaal_uitgeleend,
        'uitstaand': nog_uitgeleend,
        'teruggegeven': teruggegeven
    }
    
    # Voeg huidige datum toe aan template context
    return render_template('dashboard.html', 
                         uitgeleende_boeken=uitgeleende_boeken,
                         teruggegeven_boeken=teruggegeven_boeken,
                         stats=stats,
                         today=date.today())

@app.route('/nieuwe_uitlening', methods=['GET', 'POST'])
@login_required
def nieuwe_uitlening():
    form = UitleningForm()
    if form.validate_on_submit():
        # Haal automatisch een boekomslag op
        cover_url = get_book_cover(form.boek_titel.data, form.auteur.data)
        
        uitlening = Uitlening(
            boek_titel=form.boek_titel.data,
            auteur=form.auteur.data,
            uitgeleend_aan=form.uitgeleend_aan.data,
            uitgeleend_vanaf=form.uitgeleend_vanaf.data,
            verwachte_teruggave=form.verwachte_teruggave.data,
            notities=form.notities.data,
            cover_url=cover_url,
            user_id=current_user.id
        )
        db.session.add(uitlening)
        db.session.commit()
        
        if cover_url:
            flash('Uitlening succesvol toegevoegd! Boekomslag automatisch gevonden.')
        else:
            flash('Uitlening succesvol toegevoegd! (Geen boekomslag gevonden)')
        
        return redirect(url_for('dashboard'))
    return render_template('nieuwe_uitlening.html', form=form)

@app.route('/bewerken/<int:id>', methods=['GET', 'POST'])
@login_required
def bewerken_uitlening(id):
    uitlening = Uitlening.query.filter_by(id=id, user_id=current_user.id).first_or_404()
    form = BewerkenForm()
    
    if form.validate_on_submit():
        uitlening.boek_titel = form.boek_titel.data
        uitlening.auteur = form.auteur.data
        uitlening.uitgeleend_aan = form.uitgeleend_aan.data
        uitlening.uitgeleend_vanaf = form.uitgeleend_vanaf.data
        uitlening.verwachte_teruggave = form.verwachte_teruggave.data
        uitlening.notities = form.notities.data
        uitlening.teruggegeven = form.teruggegeven.data.lower() in ['ja', 'yes', 'true', '1']
        
        db.session.commit()
        flash('Uitlening succesvol bijgewerkt!')
        return redirect(url_for('dashboard'))
    
    # Pre-fill form with existing data
    if request.method == 'GET':
        form.boek_titel.data = uitlening.boek_titel
        form.auteur.data = uitlening.auteur
        form.uitgeleend_aan.data = uitlening.uitgeleend_aan
        form.uitgeleend_vanaf.data = uitlening.uitgeleend_vanaf
        form.verwachte_teruggave.data = uitlening.verwachte_teruggave
        form.notities.data = uitlening.notities
        form.teruggegeven.data = 'ja' if uitlening.teruggegeven else 'nee'
    
    return render_template('bewerken_uitlening.html', form=form, uitlening=uitlening)

@app.route('/verwijderen/<int:id>')
@login_required
def verwijderen_uitlening(id):
    uitlening = Uitlening.query.filter_by(id=id, user_id=current_user.id).first_or_404()
    db.session.delete(uitlening)
    db.session.commit()
    flash('Uitlening verwijderd!')
    return redirect(url_for('dashboard'))

@app.route('/markeer_teruggegeven/<int:id>')
@login_required
def markeer_teruggegeven(id):
    uitlening = Uitlening.query.filter_by(id=id, user_id=current_user.id).first_or_404()
    uitlening.teruggegeven = True
    db.session.commit()
    flash('Boek gemarkeerd als teruggegeven!')
    return redirect(url_for('dashboard'))

@app.route('/ververs_cover/<int:id>')
@login_required
def ververs_cover(id):
    """Route om handmatig een nieuwe boekomslag op te halen"""
    uitlening = Uitlening.query.filter_by(id=id, user_id=current_user.id).first_or_404()
    
    # Haal nieuwe cover op
    cover_url = get_book_cover(uitlening.boek_titel, uitlening.auteur)
    
    if cover_url:
        uitlening.cover_url = cover_url
        db.session.commit()
        flash('Boekomslag succesvol bijgewerkt!')
    else:
        flash('Geen boekomslag gevonden voor dit boek.')
    
    return redirect(url_for('dashboard'))

@app.route('/print_uitleningen')
@login_required
def print_uitleningen():
    """Route voor print-vriendelijke weergave van uitgeleende boeken"""
    uitgeleende_boeken = Uitlening.query.filter_by(user_id=current_user.id, teruggegeven=False).order_by(Uitlening.uitgeleend_vanaf.desc()).all()
    teruggegeven_boeken = Uitlening.query.filter_by(user_id=current_user.id, teruggegeven=True).order_by(Uitlening.uitgeleend_vanaf.desc()).limit(20).all()
    
    # Statistieken
    totaal_uitgeleend = len(current_user.uitleningen)
    nog_uitgeleend = len(uitgeleende_boeken)
    teruggegeven = len([u for u in current_user.uitleningen if u.teruggegeven])
    
    stats = {
        'totaal': totaal_uitgeleend,
        'uitstaand': nog_uitgeleend,
        'teruggegeven': teruggegeven
    }
    
    return render_template('print_uitleningen.html',
                         uitgeleende_boeken=uitgeleende_boeken,
                         teruggegeven_boeken=teruggegeven_boeken,
                         stats=stats,
                         today=date.today(),
                         gebruiker=current_user.username)

@app.route('/print_compact')
@login_required
def print_compact():
    """Compacte print-versie alleen met uitgeleende boeken"""
    uitgeleende_boeken = Uitlening.query.filter_by(user_id=current_user.id, teruggegeven=False).order_by(Uitlening.uitgeleend_vanaf.desc()).all()
    
    return render_template('print_compact.html',
                         uitgeleende_boeken=uitgeleende_boeken,
                         today=date.today(),
                         gebruiker=current_user.username)

@app.route('/health')
def health_check():
    """Health check endpoint voor Docker"""
    return {'status': 'healthy', 'timestamp': datetime.now().isoformat()}, 200

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
        
        # Check of de cover_url kolom bestaat, zo niet, voeg toe (eenvoudige migratie)
        try:
            # Probeer een query op de nieuwe kolom
            db.session.execute(db.text("SELECT cover_url FROM uitlening LIMIT 1"))
        except Exception:
            # Als het faalt, voeg de kolom toe
            try:
                db.session.execute(db.text("ALTER TABLE uitlening ADD COLUMN cover_url VARCHAR(500)"))
                db.session.commit()
                print("Cover URL kolom toegevoegd aan database")
            except Exception as e:
                print(f"Kon cover_url kolom niet toevoegen: {e}")
                
    # Configure Flask to listen on all interfaces for Docker
    app.run(debug=False, host='0.0.0.0', port=5000)
