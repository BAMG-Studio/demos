# 02 - EventBridge + Lambda Playbooks

## Core Playbooks
- EC2 compromise: isolate via quarantine SG; snapshot; tag; SNS.
- IAM credential compromise: disable key; deny-all inline policy; investigate CloudTrail; notify.
- GuardDuty critical routing: severity >=7 to SNS/Slack + ticket.

## Patterns
- Event pattern filters; DLQ (SQS); retry policies; idempotency keys.
- Enrich message with account tags/links to console/playbook.

## Validation
- Use GuardDuty sample findings; check Lambda exec + alert.

Outcome: Automated containment for highest-severity findings.