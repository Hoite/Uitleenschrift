# Gebruik Python 3.11 slim image
FROM python:3.11-slim

# Maak non-root user vroeg in het proces
RUN groupadd -r appuser && useradd -r -g appuser -u 1000 -m appuser

# Stel werkdirectory in en verander eigendom
WORKDIR /app
RUN chown appuser:appuser /app

# Installeer systeem dependencies en ruim direct op
RUN apt-get update && apt-get install -y \
    gcc \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apt/archives/*

# Switch naar non-root user voor de rest van de build
USER appuser

# Kopieer requirements eerst voor betere caching
COPY --chown=appuser:appuser requirements.txt .

# Installeer Python dependencies in user space
RUN pip install --no-cache-dir --user -r requirements.txt

# Kopieer applicatie code
COPY --chown=appuser:appuser . .

# Maak instance directory voor database
RUN mkdir -p /app/instance && chmod 755 /app/instance

# Expose poort
EXPOSE 5000

# Stel environment variabelen in
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PYTHONPATH=/app
ENV PATH="/home/appuser/.local/bin:${PATH}"

# Healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

# Start commando
CMD ["python", "app.py"]
