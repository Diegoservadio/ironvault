#!/bin/bash
# ================================================================
# IronVault — Check Pre-Demo
# DN Security Labs — ITS Academy Tech Talent Factory 2024-2026
# ================================================================
# Esegue 6 verifiche pre-demo e mostra stato verde/rosso.
# Da eseguire sempre prima della presentazione.
# ================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

echo "================================================"
echo "   IRONVAULT — CHECK PRE-DEMO"
echo "   DN Security Labs"
echo "================================================"

# 1. Verifica Docker
echo -n "[1/6] Verifica Docker..."
GRAFANA=$(docker ps --filter "name=grafana" --format "{{.Names}}" 2>/dev/null)
PROMETHEUS=$(docker ps --filter "name=prometheus" --format "{{.Names}}" 2>/dev/null)
NODE=$(docker ps --filter "name=node" --format "{{.Names}}" 2>/dev/null)

if [ -n "$GRAFANA" ] && [ -n "$PROMETHEUS" ] && [ -n "$NODE" ]; then
    echo -e "    ${GREEN}OK${NC} — Grafana, Prometheus, Node Exporter attivi"
else
    echo -e "    ${RED}ERRORE${NC} — Uno o piu container Docker non attivi"
    echo "    FIX: cd /home/pmiuser && docker compose up -d"
    ERRORS=$((ERRORS+1))
fi

# 2. Verifica Apache
echo -n "[2/6] Verifica Apache..."
sudo systemctl is-active apache2 --quiet
APACHE_OK=$?
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/ 2>/dev/null)

if [ $APACHE_OK -eq 0 ] && [ "$HTTP_CODE" = "200" ]; then
    echo -e "    ${GREEN}OK${NC} — Apache attivo, intranet raggiungibile (HTTP 200)"
elif [ $APACHE_OK -eq 0 ]; then
    echo -e "    ${YELLOW}WARN${NC} — Apache attivo ma intranet risponde HTTP $HTTP_CODE"
else
    echo -e "    ${RED}ERRORE${NC} — Apache non attivo"
    echo "    FIX: sudo systemctl start apache2"
    ERRORS=$((ERRORS+1))
fi

# 3. Verifica connessione AWS
echo -n "[3/6] Verifica connessione AWS..."
AWS_USER=$(aws sts get-caller-identity --query 'Arn' --output text --region eu-north-1 2>/dev/null | awk -F'/' '{print $NF}')

if [ -n "$AWS_USER" ]; then
    echo -e "    ${GREEN}OK${NC} — AWS raggiungibile (utente: $AWS_USER)"
else
    echo -e "    ${RED}ERRORE${NC} — AWS non raggiungibile"
    echo "    FIX: verificare credenziali in ~/.aws/credentials"
    ERRORS=$((ERRORS+1))
fi

# 4. Verifica backup S3
echo -n "[4/6] Verifica backup S3..."
LAST_BACKUP=$(aws s3 ls s3://pmi-backup-airgap-2024/backups/ --region eu-north-1 2>/dev/null | sort | tail -n 1)

if [ -n "$LAST_BACKUP" ]; then
    BACKUP_DATE=$(echo "$LAST_BACKUP" | awk '{print $1, $2}')
    BACKUP_NAME=$(echo "$LAST_BACKUP" | awk '{print $4}')
    echo -e "    ${GREEN}OK${NC} — Ultimo backup: $BACKUP_DATE ($BACKUP_NAME)"
else
    echo -e "    ${RED}ERRORE${NC} — Nessun backup trovato su S3"
    echo "    FIX: bash /home/pmiuser/backup.sh"
    ERRORS=$((ERRORS+1))
fi

# 5. Verifica file demo
echo -n "[5/6] Verifica file demo..."
FILE_COUNT=$(find /opt/pmi -type f 2>/dev/null | wc -l)
LOCKED_COUNT=$(find /opt/pmi -name "*.locked" 2>/dev/null | wc -l)

if [ "$FILE_COUNT" -eq 144 ] && [ "$LOCKED_COUNT" -eq 0 ]; then
    echo -e "    ${GREEN}OK${NC} — 144 file presenti, nessun file .locked"
elif [ "$LOCKED_COUNT" -gt 0 ]; then
    echo -e "    ${RED}ERRORE${NC} — Trovati $LOCKED_COUNT file .locked — eseguire reset"
    echo "    FIX: bash /home/pmiuser/reset_demo.sh"
    ERRORS=$((ERRORS+1))
else
    echo -e "    ${YELLOW}WARN${NC} — File presenti: $FILE_COUNT (attesi 144)"
    ERRORS=$((ERRORS+1))
fi

# 6. Verifica permessi Apache
echo -n "[6/6] Verifica permessi Apache..."
PERMS=$(stat -c "%a" /var/www/html 2>/dev/null)

if [ "$PERMS" = "777" ]; then
    echo -e "    ${GREEN}OK${NC} — Permessi /var/www/html corretti (777)"
else
    echo -e "    ${YELLOW}WARN${NC} — Permessi /var/www/html: $PERMS (atteso 777)"
    echo "    FIX: sudo chmod 777 /var/www/html"
fi

echo "================================================"
if [ $ERRORS -eq 0 ]; then
    echo -e "   ${GREEN}TUTTO OK — DEMO PRONTA PER LA PRESENTAZIONE${NC}"
else
    echo -e "   ${RED}$ERRORS ERRORI RILEVATI — RISOLVERE PRIMA DELLA DEMO${NC}"
fi
echo "================================================"
