# Outils et scripts auxiliaires

Ce dossier contient les utilitaires utilisés pour le développement et l’administration du projet.

## Structure
- `my-app/` → script principal de lancement local (`app.sh`).
- `services/` → scripts Bash pour chaque service (API, web, DB).
- `test.sh` → script d’exécution des tests fonctionnels ou unitaires.

## Bonnes pratiques
- Tous les scripts doivent être exécutables (`chmod +x`).
- Préfixer les scripts par leur domaine (`db_`, `web_`, etc.).
