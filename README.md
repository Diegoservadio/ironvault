# IronVault 🛡️

> **Resilienza ransomware per le PMI italiane** — Architettura ibrida on-premises + AWS con disaster recovery automatico

[![NIS2 Compliant](https://img.shields.io/badge/NIS2-Compliant-1D9E75?style=flat-square)](https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:decreto.legislativo:2024-09-04;138)
[![AWS Free Tier](https://img.shields.io/badge/AWS-Free%20Tier-FF9900?style=flat-square&logo=amazon-aws)](https://aws.amazon.com/free)
[![RPO 60min](https://img.shields.io/badge/RPO-60%20minuti-0C447C?style=flat-square)](##risultati-misurati)
[![RTO 2min](https://img.shields.io/badge/RTO-~2%20minuti-1D9E75?style=flat-square)](##risultati-misurati)
[![ITS Academy](https://img.shields.io/badge/ITS%20Academy-Tech%20Talent%20Factory-378ADD?style=flat-square)](https://www.its-academy.it)

---

## 📋 Descrizione

IronVault è il progetto finale del corso ITS Cloud & Security 2024-2026 sviluppato da **DN Security Labs** (Diego Servadio & Naween Mapa).

Il progetto risponde a una reale esigenza aziendale: lo **Studio Contabilità Milano**, uno studio commercialista con 12 clienti, 3 dipendenti e zero IT interno, aveva bisogno di una soluzione di protezione ransomware accessibile economicamente, conforme alla Direttiva NIS2 e con RTO misurabile.

IronVault dimostra che è possibile costruire un'architettura professionale con **tecnologie open source e AWS Free Tier**, con un costo operativo di circa 15 euro/mese.

---

## 🏗️ Architettura

```
┌─────────────────────────────────────────────┐     ┌──────────────────────────────────┐
│         ON-PREMISES (VMware)                 │     │        AWS CLOUD eu-north-1      │
│                                             │     │                                  │
│  ┌─────────────────┐  ┌──────────────────┐  │     │  ┌────────────────────────────┐  │
│  │ PMI-FileServer  │  │ PMI-WindowsServer│  │     │  │   S3 pmi-backup-airgap     │  │
│  │ Ubuntu 22.04    │  │ Windows Server   │  │     │  │   Object Lock COMPLIANCE   │  │
│  │ .140            │  │ 2022 — AD/GPO    │  │     │  │   30 giorni retention      │  │
│  │ Docker/Grafana  │  │ .141             │  │─────┼─▶│   IAM DENY delete          │  │
│  │ backup.sh       │  │ SMB shares       │  │     │  │   Bucket Policy DENY       │  │
│  └────────┬────────┘  └──────────────────┘  │     │  └──────────────┬─────────────┘  │
│           │                                  │     │                 │                │
│  ┌─────────────────┐                         │     │  ┌─────────────▼─────────────┐  │
│  │ PMI-Reception   │  ◀── SMB ──────────────┘     │  │   EC2 t3.micro            │  │
│  │ Windows 10      │                               │  │   pmi-recovery-role       │  │
│  │ laura.bianchi   │                               │  │   RTO: ~2 minuti          │  │
│  │ F: G: H: mapped │                               │  │   Standby — 0 euro        │  │
│  └─────────────────┘                               │  └───────────────────────────┘  │
└─────────────────────────────────────────────┘     └──────────────────────────────────┘
```

---

## 📊 Risultati Misurati

| Metrica | Valore | Note |
|---------|--------|------|
| **RPO** | 60 minuti | Backup automatico ogni ora via cron |
| **RTO** | ~2 minuti | Misurato live con `time bash recovery.sh` |
| **File ripristinati** | 144/144 (100%) | Da S3 su EC2 in ~3 secondi |
| **Costo demo** | 0 euro | AWS Free Tier |
| **Costo PMI reale** | ~15 euro/mese | 50 dipendenti, 500 GB dati |
| **Conformità NIS2** | Art. 21 — completo | Tutti i requisiti mappati |

---

## 🛠️ Stack Tecnologico

### On-premises
- **VMware Workstation** — virtualizzazione su Lenovo ThinkBook 16 G6 (32 GB RAM)
- **Ubuntu Server 22.04 LTS** — file server, backup agent, monitoring
- **Windows Server 2022** — Active Directory, Group Policy, SMB
- **Windows 10** — postazione client (Laura Bianchi)
- **Docker + Docker Compose** — stack Grafana/Prometheus/Node Exporter
- **Apache2** — intranet aziendale su porta 80
- **Python 3 + cryptography (Fernet)** — simulazione ransomware

### Cloud AWS (eu-north-1 — Stoccolma)
- **Amazon S3** — Object Lock COMPLIANCE 30 giorni, Versioning, Lifecycle Policy
- **IAM** — Least Privilege, DENY esplicito su DeleteObject
- **Amazon EC2** — t3.micro, Instance Profile per recovery senza credenziali hardcoded
- **CloudWatch** — alarm su accessi non autorizzati
- **SNS** — notifiche email su alert
- **CloudTrail** — audit log tutte le chiamate API

---

## 🚀 Sequenza della Demo

```
1. Laura apre Outlook Web → vede email fake ADE
2. Scarica PDF allegato → cartella Downloads
3. Doppio click sul dropper (icona PDF) → ransomware parte
4. F: G: H: si cifrano | sito intranet → pagina rossa
5. Grafana: SECURE → UNDER ATTACK | email alert arriva
6. aws s3 rm → AccessDenied (air-gap dimostrato)
7. aws ec2 start-instances → SSH → time bash recovery.sh
8. 144 file ripristinati | sito torna online | RTO: ~2 min
```

---

## 📁 Struttura del Repository

```
ironvault/
├── README.md                    # Questa documentazione
├── index.html                   # Sito web DN Security Labs (GitHub Pages)
│
├── scripts/                     # Script principali
│   ├── ubuntu/
│   │   ├── backup.sh            # Backup orario su S3
│   │   ├── reset_demo.sh        # Reset completo per ripetere la demo
│   │   ├── check_demo.sh        # 6 verifiche pre-demo
│   │   ├── ransomware_sim.py    # Simulazione attacco (solo uso didattico)
│   │   ├── trigger_server.py    # HTTP server per trigger da Windows
│   │   └── recovery.sh          # Recovery su EC2
│   └── windows/
│       └── reset_windows.bat    # Reset cartelle Windows post-demo
│
├── aws/                         # Configurazioni AWS
│   ├── iam-policy.json          # Policy IAM pmi-s3-write-only
│   ├── bucket-policy.json       # Bucket Policy DENY assoluto
│   ├── lifecycle.json           # Lifecycle Policy S3
│   └── event-selectors.json     # CloudTrail data events
│
├── monitoring/                  # Stack Docker monitoring
│   ├── docker-compose.yml       # Grafana + Prometheus + Node Exporter
│   ├── prometheus.yml           # Configurazione scrape
│   ├── alert_rules.yml          # Regola alert AltaAttivitaDisco
│   └── ironvault_dashboard.json # Dashboard SOC personalizzata
│
└── docs/                        # Documentazione
    ├── IronVault_Tesina_v3.docx
    ├── IronVault_Presentazione_v3.pptx
    └── IronVault_Guida_Demo.docx
```

---

## ⚙️ Setup Rapido

### Prerequisiti
- VMware Workstation Pro
- AWS CLI v2 installato su Ubuntu
- Account AWS con Free Tier attivo
- Python 3 con libreria `cryptography`

### 1. Configurazione AWS

```bash
# Configura credenziali
aws configure

# Crea bucket S3 con Object Lock
aws s3api create-bucket \
  --bucket pmi-backup-airgap-2024 \
  --region eu-north-1 \
  --create-bucket-configuration LocationConstraint=eu-north-1

aws s3api put-object-lock-configuration \
  --bucket pmi-backup-airgap-2024 \
  --object-lock-configuration '{"ObjectLockEnabled":"Enabled","Rule":{"DefaultRetention":{"Mode":"COMPLIANCE","Days":30}}}'

# Applica policy IAM e Bucket Policy
aws iam create-policy --policy-name pmi-s3-write-only \
  --policy-document file://aws/iam-policy.json

aws s3api put-bucket-policy \
  --bucket pmi-backup-airgap-2024 \
  --policy file://aws/bucket-policy.json
```

### 2. Avvio stack monitoraggio

```bash
cd monitoring/
docker compose up -d
# Grafana disponibile su http://192.168.143.140:3000
```

### 3. Configurazione backup automatico

```bash
# Aggiungi al crontab
crontab -e
# Inserisci:
0 * * * * /home/pmiuser/backup.sh
```

### 4. Check pre-demo

```bash
bash check_demo.sh
# Output atteso: TUTTO OK — DEMO PRONTA PER LA PRESENTAZIONE
```

---

## 🔒 Protezioni S3 Implementate

| Protezione | Livello | Cosa blocca |
|-----------|---------|-------------|
| Object Lock COMPLIANCE | Oggetto | Delete singoli — anche da root AWS |
| IAM DENY esplicito | Utente | Delete da `pmi-backup-agent` |
| Bucket Policy DENY | Bucket | Delete da chiunque — incluso admin console |
| Versioning | Oggetto | Recupero versioni precedenti |
| Lifecycle Policy | Bucket | Gestione automatica costi |

---

## 📋 Conformità NIS2 Art. 21

| Requisito | Implementazione |
|-----------|----------------|
| Continuità operativa | EC2 recovery — RTO ~2 min |
| Backup e ripristino | S3 Object Lock COMPLIANCE — RPO 60 min |
| Controllo degli accessi | IAM + Active Directory + NTFS |
| Politiche di sicurezza | GPO IronVault-Security-Policy |
| Gestione degli incidenti | Procedura DR + alert automatico Grafana |
| Utilizzo crittografia | S3 SSE + HTTPS in transito |

---

## ⚠️ Disclaimer

Gli script di simulazione ransomware inclusi in questo repository sono sviluppati **esclusivamente per scopi didattici** nell'ambito del progetto ITS. Operano solo su macchine virtuali VMware isolate e non implementano capacità di propagazione in rete, comunicazione con server C2 o meccanismi di persistenza. L'uso al di fuori del contesto didattico è vietato.

---

## 👥 Team

| Nome | Ruolo nel progetto |
|------|-------------------|
| **Diego Servadio** | Cloud infrastructure — AWS, Ubuntu, backup, monitoring |
| **Naween Mapa** | Windows infrastructure — Active Directory, GPO, NIS2 |

**DN Security Labs** — ITS Academy Tech Talent Factory 2024-2026

---

## 📄 Licenza

Questo progetto è sviluppato a scopo didattico nell'ambito del percorso ITS Cloud & Security.
Tutti i diritti riservati — DN Security Labs © 2026
