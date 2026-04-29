#!/bin/bash
# ================================================================
# IronVault — Recovery Script (EC2)
# DN Security Labs — ITS Academy Tech Talent Factory 2024-2026
# ================================================================
# Da eseguire sull'istanza EC2 i-0884e3a6ca3d093c7 dopo un attacco.
# Scarica l'ultimo backup da S3 e ripristina i file in /opt/pmi/.
#
# Comando con timer: time bash /home/ubuntu/recovery.sh
# ================================================================

BUCKET="pmi-backup-airgap-2024"
REGION="eu-north-1"

echo "=== IRONVAULT — Recovery su EC2 ==="
echo ""

# 1. Pulizia stato precedente
echo "[1/4] Pulizia stato precedente..."
sudo rm -rf /opt/pmi/fatture/* \
            /opt/pmi/documenti/* \
            /opt/pmi/configurazioni/* \
            /opt/pmi/database/* 2>/dev/null

# 2. Identificazione e download ultimo backup
echo "[2/4] Download ultimo backup da S3..."
BACKUP=$(aws s3 ls s3://${BUCKET}/backups/ \
    --region ${REGION} | sort | tail -n 1 | awk '{print $4}')

if [ -z "$BACKUP" ]; then
    echo "ERRORE: Nessun backup trovato su S3"
    exit 1
fi

echo "      Backup: $BACKUP"
aws s3 cp "s3://${BUCKET}/backups/${BACKUP}" /tmp/restore.tar.gz \
    --region "${REGION}"

if [ $? -ne 0 ]; then
    echo "ERRORE: Download da S3 fallito"
    exit 1
fi

# 3. Estrazione backup
echo "[3/4] Ripristino file..."
sudo tar -xzf /tmp/restore.tar.gz -C /
sudo chown -R ubuntu:ubuntu /opt/pmi 2>/dev/null
rm -f /tmp/restore.tar.gz

# 4. Verifica
echo "[4/4] Verifica..."
TOTALE=$(find /opt/pmi -type f 2>/dev/null | wc -l)

echo ""
echo "File ripristinati: $TOTALE"

if [ "$TOTALE" -eq 144 ]; then
    echo "=== RECOVERY COMPLETATO — RTO misurato ==="
else
    echo "=== ATTENZIONE: attesi 144, trovati $TOTALE ==="
fi
