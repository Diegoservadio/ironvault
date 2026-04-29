# Stack Monitoraggio IronVault

Stack Docker con Grafana, Prometheus e Node Exporter per il monitoraggio real-time del file server e il rilevamento automatico del ransomware.

## Avvio

```bash
cd monitoring/
docker compose up -d
```

## Accesso

| Servizio | URL | Credenziali |
|----------|-----|-------------|
| Grafana Dashboard SOC | http://192.168.143.140:3000 | admin / Cammellorosa2026! |
| Prometheus | http://192.168.143.140:9090 | — |
| Node Exporter metrics | http://192.168.143.140:9100/metrics | — |

## File

| File | Descrizione |
|------|-------------|
| `docker-compose.yml` | Stack completo con configurazione SMTP Gmail |
| `prometheus.yml` | Scrape ogni 5 secondi da Node Exporter |
| `alert_rules.yml` | Alert `AltaAttivitaDisco` — soglia 1 MB/s scrittura disco |

## Come funziona il rilevamento

1. Node Exporter raccoglie le metriche I/O disco ogni 5 secondi
2. Prometheus valuta la regola `AltaAttivitaDisco`
3. Se la velocità di scrittura supera **1 MB/s**, scatta l'alert
4. Grafana invia email via Gmail SMTP con dettagli attacco e comando recovery
5. La dashboard SOC mostra **THREAT LEVEL: UNDER ATTACK**

## Configurazione Gmail SMTP

Nel file `docker-compose.yml` sostituire `<APP_PASSWORD_GMAIL>` con una password per app Gmail:
1. Account Google → Sicurezza → Verifica in due passaggi → Password per app
2. Nome app: `IronVault Grafana`
3. Copiare la password generata nel campo `GF_SMTP_PASSWORD`
