#!/bin/bash
# ================================================================
# IronVault — Reset Demo
# DN Security Labs — ITS Academy Tech Talent Factory 2024-2026
# ================================================================
# Ripristina l'ambiente demo allo stato iniziale pulito.
# Scarica il backup master fisso da S3 e ripristina 144 file.
# ================================================================

BUCKET="pmi-backup-airgap-2024"
REGION="eu-north-1"
MASTER_FILE="/home/pmiuser/backup_master.txt"

echo "================================================"
echo "   IRONVAULT — RESET DEMO"
echo "   DN Security Labs"
echo "================================================"

# 1. Pulizia file .locked rimasti da attacchi precedenti
echo "[1/6] Pulizia file .locked rimasti..."
find /opt/pmi -name "*.locked" -delete 2>/dev/null
find /var/www/html -name "*.locked" -delete 2>/dev/null

# 2. Ripristino da backup master
echo "[2/6] Ripristino file da S3..."
BACKUP=$(cat "$MASTER_FILE" 2>/dev/null)

if [ -z "$BACKUP" ]; then
    echo "    ERRORE: backup_master.txt vuoto o mancante"
    exit 1
fi

echo "      Usando backup: $BACKUP"
aws s3 cp "s3://${BUCKET}/backups/${BACKUP}" /tmp/restore.tar.gz \
    --region "$REGION" 2>&1

if [ $? -ne 0 ]; then
    echo "    ERRORE: download da S3 fallito"
    exit 1
fi

sudo tar -xzf /tmp/restore.tar.gz -C / 2>/dev/null

# 3. Pulizia file .locked eventualmente inclusi nel backup
echo "[3/6] Pulizia file .locked post-restore..."
find /opt/pmi -name "*.locked" -delete 2>/dev/null

# 4. Riavvio Apache
echo "[4/6] Riavvio Apache..."
sudo systemctl restart apache2

# 5. Pulizia temporanei
echo "[5/6] Pulizia file temporanei..."
rm -f /tmp/restore.tar.gz

# 6. Verifica stato finale
echo "[6/6] Verifica stato finale..."
FILE_COUNT=$(find /opt/pmi -type f | wc -l)
APACHE_STATUS=$(systemctl is-active apache2)
LAST_BACKUP=$(aws s3 ls s3://${BUCKET}/backups/ --region ${REGION} 2>/dev/null | sort | tail -n 1 | awk '{print $3, $4}')

echo "File in /opt/pmi/: $FILE_COUNT"
echo "Sito web Apache: $APACHE_STATUS"
echo "Ultimo backup su S3:"
echo "$LAST_BACKUP"

if [ "$FILE_COUNT" -eq 144 ] && [ "$APACHE_STATUS" = "active" ]; then
    echo "================================================"
    echo "   RESET COMPLETATO — Demo pronta"
    echo "================================================"
else
    echo "================================================"
    echo "   ATTENZIONE: verificare stato sistema"
    echo "   File attesi: 144 — trovati: $FILE_COUNT"
    echo "================================================"
fi
