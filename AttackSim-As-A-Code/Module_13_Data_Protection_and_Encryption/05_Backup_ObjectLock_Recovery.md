# 05 - Backup, Object Lock, Recovery

## Strategy
- S3 Versioning + Object Lock (governance) for critical logs/evidence.
- AWS Backup plans for RDS/EBS/EFS with vault + copy to secondary region.
- PITR for DynamoDB.

## Validation
- Simulate delete; recover via previous version/restore.
- Restore RDS snapshot test in sandbox.

Outcome: Resilient backups with tamper resistance and tested restores.