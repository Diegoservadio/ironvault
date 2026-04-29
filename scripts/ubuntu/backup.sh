#!/bin/bash
# ================================================================
# IronVault — Backup Agent
# DN Security Labs — ITS Academy Tech Talent Factory 2024-2026
# ================================================================
# Eseguito automaticamente da cron ogni ora: 0 * * * *
# Crea un archivio tar.gz con timestamp e lo carica su S3
# ================================================================

BUCKET="pmi-backup-airgap-2024"
REGION="eu-north-1"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="/tmp/backup_${TIMESTAMP}.tar.gz"
LOG_FILE="/home/pmiuser/backup.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Avvio backup..." >> "$LOG_FILE"

# Crea archivio tar.gz di /opt/pmi/ e /var/www/html/
tar -czf "$BACKUP_FILE" /opt/pmi/ /var/www/html/ 2>/dev/null

if [ $? -ne 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERRORE: creazione archivio fallita" >> "$LOG_FILE"
    exit 1
fi

# Upload su S3
aws s3 cp "$BACKUP_FILE" "s3://${BUCKET}/backups/${TIMESTAMP}.tar.gz" \
    --region "$REGION" \
    --storage-class STANDARD

if [ $? -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] OK — Upload completato: ${TIMESTAMP}.tar.gz" >> "$LOG_FILE"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERRORE: upload S3 fallito" >> "$LOG_FILE"
fi

# Pulizia file temporaneo
rm -f "$BACKUP_FILE"
