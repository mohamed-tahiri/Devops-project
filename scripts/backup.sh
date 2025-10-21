#!/bin/bash
set -e

BASE_DIR=$(dirname "$0")/..
BACKUP_DIR="${BASE_DIR}/backups"
SOURCE_DIR="${BASE_DIR}/app-data"
RETENTION_COUNT=5  # garder les 5 dernières sauvegardes

# Create backup
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="backup-${TIMESTAMP}.tar.gz"
BACKUP_PATH="${BACKUP_DIR}/${FILENAME}"

mkdir -p "${BACKUP_DIR}"
echo "[INFO] Creating backup..."
tar -czf "${BACKUP_PATH}" -C "${BASE_DIR}" "app-data"
sha256sum "${BACKUP_PATH}" > "${BACKUP_PATH}.sha256"
echo "[INFO] Backup created: ${BACKUP_PATH}"

# Cleanup old backups
echo "[INFO] Cleaning up old backups (keeping ${RETENTION_COUNT} latest)..."
BACKUPS_TO_DELETE=$(ls -1t ${BACKUP_DIR}/backup-*.tar.gz | tail -n +$((RETENTION_COUNT+1)))
for f in $BACKUPS_TO_DELETE; do
    echo "Deleting ${f} and ${f}.sha256"
    rm -f "$f" "${f}.sha256"
done
echo "[INFO] Cleanup complete."
