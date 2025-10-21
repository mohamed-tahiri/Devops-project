#!/bin/bash
set -e

cd "$(dirname "$0")/src"

echo "[INFO] Lancement du serveur Uvicorn..."
# Lancement en avant-plan pour que le container reste vivant
exec uvicorn main:app --host 0.0.0.0 --port 8000
