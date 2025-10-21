FROM python:3.11-slim

WORKDIR /app

# Copier les fichiers
COPY tools/my-app /app

# Installer pip à jour et les dépendances
RUN python3 -m pip install --upgrade pip \
    && pip install --no-cache-dir -r src/requirements.txt

# Rendre le script exécutable
RUN chmod +x /app/app.sh

# Exposer le port
EXPOSE 8000

# Lancer l'application
CMD ["/app/app.sh"]
