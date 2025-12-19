# 06 - Change & Drift Guardrails

## Guardrails
- SCPs for tamper-proofing: block `cloudtrail:StopLogging`, `config:Delete*`, `guardduty:Delete*`.
- Config rules for drift: detect changes to baseline SGs, IAM policies, bucket policies.
- CloudWatch alarms on Config recorder stopped.

## Detection → Action
- EventBridge rule on Config recorder stop → SNS critical.
- Lambda to revert unauthorized SG rule changes (see Module 5/16).

## Validation
- Attempt to stop Config or CloudTrail → AccessDenied via SCP.
- Modify SG → drift detected + auto-reverted.

Outcome: Prevent + detect + auto-correct drift on critical controls.