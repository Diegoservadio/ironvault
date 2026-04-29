# Scripts IronVault

Script principali per la demo e la gestione dell'infrastruttura.

## Ubuntu (`scripts/ubuntu/`)

| Script | Quando usarlo |
|--------|--------------|
| `check_demo.sh` | **Sempre prima della demo** — 6 verifiche verde/rosso |
| `reset_demo.sh` | Reset completo — ripristina 144 file da backup S3 master |
| `backup.sh` | Backup manuale su S3 (automatico via cron ogni ora) |
| `ransomware_sim.py` | Simulazione attacco — cifra /opt/pmi/ e /var/www/html/ |
| `trigger_server.py` | HTTP server :8888 — riceve segnale dal ransomware Windows |
| `recovery.sh` | **Da eseguire sull'istanza EC2** — recovery da S3 |

### Configurazione cron backup automatico
```bash
crontab -e
# Aggiungere:
0 * * * * /home/pmiuser/backup.sh
```

### Avvio trigger server
```bash
nohup python3 /home/pmiuser/trigger_server.py > /tmp/trigger.log 2>&1 &
```

## Windows (`scripts/windows/`)

| Script | Quando usarlo |
|--------|--------------|
| `reset_windows.bat` | Reset cartelle di rete F: G: H: e locali dopo attacco |
| `ransomware_sim_windows.py` | Simulazione attacco da postazione Laura Bianchi |

> ⚠️ **DISCLAIMER**: Gli script di simulazione ransomware sono sviluppati esclusivamente per scopi didattici nell'ambito del progetto ITS. Operano solo su VM VMware isolate.
