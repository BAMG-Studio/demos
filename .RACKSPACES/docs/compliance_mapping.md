# Compliance Mapping (Controls -> Evidence)

| Framework Control | Cloud Control / Service | Evidence / Verification |
| --- | --- | --- |
| NIST 800-53 AC-2 | IAM roles, least privilege, MFA | IAM policy review; Access Analyzer report |
| NIST 800-53 CM-2/6 | AWS Config recorder + rules | Config console showing rules, compliance summary |
| NIST 800-53 AU-2/6 | CloudTrail multi-region + integrity | Trail status + S3 log bucket with SSE-KMS and versioning |
| PCI-DSS Req 3 (Protect data) | KMS SSE for S3/EBS/RDS; TLS | Bucket encryption settings; RDS/EBS encryption flags |
| PCI-DSS Req 10 (Logging) | CloudTrail + centralized S3 | Trail enabled; log validation on; retention policy |
| SOX (Change/Access) | IAM SoD, CloudTrail, Config | Audit log exports; IAM role separation; Config history |
