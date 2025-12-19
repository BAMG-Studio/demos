# 01 - Detection Fundamentals

## Why It Matters (Plain Speak)
Detection is how you notice bad or weird things before they become incidents. Logs are raw events; detections turn them into signals; alerts ask humans/automation to act.

## Mental Model
- **Event:** raw fact (e.g., `ConsoleLogin`).
- **Signal/Finding:** rule matched (e.g., GuardDuty `UnauthorizedAccess:IAMUser/ConsoleLogin`).
- **Alert:** routed, high-priority notification to a channel with enough context to act.
- **Response:** playbook step (contain, remediate, learn).

## Core AWS Pieces
- **CloudTrail** (audit), **VPC Flow Logs** (network), **Route 53 Resolver DNS query logs**, **ALB/WAF logs**, **EKS audit logs** (if used).
- **GuardDuty** (managed detections), **Security Hub** (aggregates + standards), **Detective** (graph investigation), **Inspector** (vuln), **Config** (drift).
- **EventBridge** (routing), **CloudWatch** (metrics/alarms/logs), **SNS/Chat** (notify), **OpenSearch/Athena** (search/dashboards), **S3** (immutable store).

## Reference Architecture (text)
1) All accounts send CloudTrail + VPC Flow Logs + DNS + WAF/ALB to **central log archive bucket** (S3) via Kinesis Firehose where needed.
2) **GuardDuty** + **Security Hub** enabled at org level; findings aggregated to security account.
3) **EventBridge** rules match critical findings → **SNS** (email/Slack) and **Lambda** (enrich, ticket, isolate).
4) **OpenSearch/Athena** read from S3 to search, dashboards, monitors.
5) **Stratus Red Team** generates attack traffic; results measured via findings/alerts.

## KPIs to Track
- **MTTD/MTTR** for critical findings
- **Alert-to-signal ratio** (noise)
- **Coverage**: % services logging, % accounts enrolled in GuardDuty/Security Hub
- **Time-to-log**: event → searchable latency

## Minimal Lab Setup (quick)
- One management + one member account.
- Org CloudTrail (all regions) to S3 log archive.
- GuardDuty + Security Hub delegated to security account.
- EventBridge rule for GuardDuty `severity >= 7` → SNS email.

## Validation Loop
1) Run Stratus scenario: `aws/guardduty/unauthorized_access_ec2_imds_credential_theft`.
2) Confirm GuardDuty finding arrives in delegated admin.
3) EventBridge triggers SNS email with finding details.
4) Document timestamp chain (event → finding → alert).

## Common Failure Modes
- CloudTrail only in one region; attackers use another.
- No DNS/Flow logs; blind to egress exfiltration.
- EventBridge targets misconfigured; findings drop.
- Alerts without runbooks; humans ignore or delay.

## Cost Control
- Use one CloudTrail for all regions; compress logs; S3 lifecycle.
- Start GuardDuty/Security Hub in free 30-day window; scope lab traffic small.
- Flow Logs to S3 (not OpenSearch) for archive; sample if volume heavy.

## Outcomes
By end of this module you will have signals flowing to a central place, high-severity alerts delivered, and proof they fire on simulated attacks.