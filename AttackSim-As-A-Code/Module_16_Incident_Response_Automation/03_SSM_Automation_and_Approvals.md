# 03 - SSM Automation & Approvals

## Use Cases
- Public S3 bucket fix
- Security group revert
- Restart CloudTrail/Config

## Steps
- Create/attach SSM documents; set parameters and approvers (for prod).
- Link to Config rules or EventBridge to auto-run.

## Validation
- Introduce violation; confirm Automation runs and status COMPLIANT.

Outcome: Reliable, auditable remediations with optional human approval.