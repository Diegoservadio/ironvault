# Configurazioni AWS IronVault

Tutti i file JSON per configurare l'infrastruttura AWS da zero.

## File

| File | Descrizione | Comando di applicazione |
|------|-------------|------------------------|
| `iam-policy.json` | Policy IAM per pmi-backup-agent (ALLOW write + DENY delete) | `aws iam create-policy` |
| `bucket-policy.json` | Bucket Policy con DENY assoluto su delete + permessi CloudTrail | `aws s3api put-bucket-policy` |
| `lifecycle.json` | Lifecycle: Glacier dopo 30gg, eliminazione dopo 365gg | `aws s3api put-bucket-lifecycle-configuration` |
| `event-selectors.json` | CloudTrail data events per S3 | `aws cloudtrail put-event-selectors` |

## Applicazione completa

```bash
# 1. Crea bucket con Object Lock
aws s3api create-bucket \
  --bucket pmi-backup-airgap-2024 \
  --region eu-north-1 \
  --create-bucket-configuration LocationConstraint=eu-north-1

aws s3api put-object-lock-configuration \
  --bucket pmi-backup-airgap-2024 \
  --object-lock-configuration \
  '{"ObjectLockEnabled":"Enabled","Rule":{"DefaultRetention":{"Mode":"COMPLIANCE","Days":30}}}'

# 2. Applica Bucket Policy
aws s3api put-bucket-policy \
  --bucket pmi-backup-airgap-2024 \
  --policy file://bucket-policy.json \
  --region eu-north-1

# 3. Applica Lifecycle Policy
aws s3api put-bucket-lifecycle-configuration \
  --bucket pmi-backup-airgap-2024 \
  --lifecycle-configuration file://lifecycle.json \
  --region eu-north-1

# 4. Crea policy IAM e utente backup agent
aws iam create-policy \
  --policy-name pmi-s3-write-only \
  --policy-document file://iam-policy.json

# 5. Configura CloudTrail data events
aws cloudtrail put-event-selectors \
  --trail-name ironvault-audit-trail \
  --event-selectors file://event-selectors.json \
  --region eu-north-1
```

## Rimozione protezioni a fine progetto

```bash
# Rimuovi Bucket Policy (necessario per eliminare il bucket)
aws s3api delete-bucket-policy \
  --bucket pmi-backup-airgap-2024 \
  --region eu-north-1
```
