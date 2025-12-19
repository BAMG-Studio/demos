# 03 - Remediation with SSM Automation

## Pattern
Config Rule → NonCompliant → EventBridge → SSM Automation doc → Fix → Notify.

## Top Remediations to Attach
- S3 public read/write → attach `AWS-DisableS3BucketPublicAccess` or custom.
- SG 0.0.0.0/0 on 22/3389 → `AWS-DisablePublicAccessForSecurityGroup`.
- CloudTrail logging off → restart trail.
- Root account no MFA → notify + create IAM block policy.

## Steps (Console)
1) Config → Rules → select rule → Manage remediation.
2) Choose SSM document, set parameters (e.g., SG ID, ticket tag).
3) Set retry attempts; choose SNS topic for failures.

## Lambda Alternative
Use Lambda when remediation needs context (tags, business logic). Keep idempotent and log to S3.

## Validation
- Flip SG to 0.0.0.0/0 → confirm Automation runs and rule returns to COMPLIANT.
- Track execution in SSM → Automation → Executions.

Outcome: Drift fixed automatically with auditable runbooks.