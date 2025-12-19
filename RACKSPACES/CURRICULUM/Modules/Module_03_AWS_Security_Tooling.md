# Module 03 — AWS Security Tooling (IAM, KMS, GuardDuty, Config, CloudTrail, WAF)

## Objective
Configure and operate AWS-native controls for identity, encryption, detection, compliance, and web protection.

## Quickstart (Conceptual)
- IAM: prefer roles over users, permission boundaries, MFA.
- KMS: CMK with rotation enabled; use SSE-KMS for S3/EBS/RDS.
- GuardDuty: enable; route findings to Security Hub.
- Config: recorder + rules for S3/EC2/IAM; non-compliance alerts.
- CloudTrail: multi-region + integrity; central S3 bucket.
- WAF: managed + custom rules; rate limiting & geo restrictions.

## Evidence
- Screenshots/config exports; or IaC where applicable.

## Interview Talking Points
- Zero-trust IAM; envelope encryption; ML-based detection; continuous compliance; WAF tuning.
