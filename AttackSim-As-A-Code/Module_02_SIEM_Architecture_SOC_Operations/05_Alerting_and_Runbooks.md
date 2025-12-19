# 05 - Alerting & Runbooks

## Alert Design
- Severity bands: Critical (page), High (notify), Medium (queue), Low (daily digest).
- Include context: account, region, user, src IP, link to runbook, console deep link.

## Examples
- GuardDuty severity >=7 → SNS/Slack + IR playbook.
- Root ConsoleLogin Success → page.
- StopLogging/DeleteTrail → page.
- IAM CreateUser/AccessKey outside CI roles → notify + ticket.

## Runbooks
- Each alert links to steps: triage data, containment, eradication, recovery, evidence path.

Outcome: Alerts that are actionable and mapped to documented runbooks.