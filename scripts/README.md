# Scripts d’automatisation

Ce dossier regroupe tous les scripts DevOps pour la CI/CD, la surveillance et la maintenance.

## Scripts principaux
| Script | Description |
|---------|--------------|
| `pipeline.sh` | Gère le pipeline CI/CD (lint, build, test, deploy). |
| `backup.sh` | Sauvegarde automatique de la configuration et des fichiers critiques. |
| `verify.sh` | Vérifie l’intégrité des artefacts, des configs et des images Docker. |
| `monitor.py` | Surveille l’état des services et envoie des alertes. |
| `orchestrator.sh` | Lance, arrête ou redémarre les services (API, web, DB). |

## Futurs ajouts
- `deploy.sh` → pour automatiser le déploiement vers `deployments/`
- `lib/` → pour centraliser des fonctions Bash réutilisables.
