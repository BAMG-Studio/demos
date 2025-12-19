# 06 - Data Access Governance

## Controls
- IAM least privilege with resource conditions (`aws:PrincipalTag`, `s3:prefix`, `kms:EncryptionContext`).
- VPC endpoints + bucket policies to restrict to VPC/Egress.
- CloudTrail data events for S3; CloudWatch metrics for abnormal downloads.
- Macie + GuardDuty S3 protections.

## Validation
- Attempt access outside VPC endpoint → denied.
- Alarm on bulk S3 downloads.

Outcome: Access controlled by identity, network, and monitoring layers.