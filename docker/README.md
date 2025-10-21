# Docker

Ce dossier contient les définitions Docker spécifiques à chaque service du projet.

## Structure
| Dossier | Description |
|----------|-------------|
| `api/` | Dockerfile pour l’API Python. |
| `web/` | Dockerfile et configuration Nginx pour le front-end. |
| `database/` | Dockerfile pour la base de données (PostgreSQL ou autre). |

## Bonnes pratiques
- Chaque sous-dossier contient un fichier `.dockerignore`.
- Les images sont nommées selon le format : `xlabs/<service>:<version>`.
