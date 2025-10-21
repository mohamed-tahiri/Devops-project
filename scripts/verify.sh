#!/bin/bash
set -e

BASE_DIR=$(dirname "$0")/..
BACKUP_DIR="${BASE_DIR}/backups"
LATEST_BACKUP=$(ls -t ${BACKUP_DIR}/backup-*.tar.gz | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "[ERROR] No backups found to verify."
    exit 1
fi

echo "[INFO] Verifying ${LATEST_BACKUP}..."
sha256sum -c "${LATEST_BACKUP}.sha256"
echo "[INFO] Verification successful."
