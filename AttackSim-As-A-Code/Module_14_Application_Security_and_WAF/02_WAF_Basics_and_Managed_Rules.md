# 02 - WAF Basics & Managed Rules

## Deploy WAF Web ACL
- Scope: CloudFront (global) or Regional (ALB/API GW).
- Add AWS Managed Rule Groups: Core rule set, Admin protection, Known bad inputs, Anonymous IP/VPN.
- Set action: count first, then block.

## Logging
- Enable WAF logging to S3/Kinesis Data Firehose → S3/OpenSearch.
- Add sampled requests.

## Validation
- Send test XSS payload; ensure rule blocks after switch from count to block.

Outcome: Baseline WAF protection with managed rule coverage.