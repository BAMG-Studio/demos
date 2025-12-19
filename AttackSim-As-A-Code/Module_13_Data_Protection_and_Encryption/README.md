# Module 13: Data Protection & Encryption – Master Guide

## What & Why
Design and enforce encryption, key management, and data access controls across AWS. You’ll enable KMS policies, envelope encryption, secrets management, backups, and data classification.

## Learning Outcomes
- KMS multi-Region keys, key policies, grants, rotation
- S3/EBS/RDS/EFS encryption defaults + bucket policies blocking unencrypted puts
- Secrets Manager & Parameter Store usage/rotation
- DLP & discovery: Macie basics; S3 Object Lock and backups
- Access patterns: VPC endpoints, TLS, private access, data egress controls

## Path
1) `01_KMS_Foundations.md`
2) `02_Storage_Encryption_Controls.md`
3) `03_Secrets_Manager_and_Rotation.md`
4) `04_Data_Discovery_DLP_Macie.md`
5) `05_Backup_ObjectLock_Recovery.md`
6) `06_Data_Access_Governance.md`
7) `07_Portfolio_Resume.md`

## Success Criteria
- Default encryption ON for S3/EBS/RDS/EFS; bucket policy denies unencrypted uploads.
- KMS key policies least-priv; rotation enabled where applicable; CMKs used via grants.
- Secrets Manager in use with rotation for at least one DB secret; audit trail captured.
- Macie classification job run on target bucket; findings routed.
- Backups/versioning/object lock configured for critical data.

## Cost Snapshot (lab)
- KMS requests: ~$1–3/mo (low volume)
- Secrets Manager rotation: ~$0.40/secret/mo + Lambda rotate (tiny)
- Macie sample job: ~$1–5 depending on GB scanned
- Backup storage: varies; for lab keep minimal

Validate by creating an unencrypted PutObject (should be denied) and rotating a secret successfully.