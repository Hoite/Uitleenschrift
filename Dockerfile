# Gebruik Python 3.11 slim image
FROM python:3.11-slim

# Stel werkdirectory in
WORKDIR /app

# Installeer systeem dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Kopieer requirements eerst voor betere caching
COPY requirements.txt .

# Installeer Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Kopieer applicatie code
COPY . .

# Maak een non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Expose poort
EXPOSE 5000

# Stel environment variabelen in
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PYTHONPATH=/app

# Healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

# Start commando
CMD ["python", "app.py"]
