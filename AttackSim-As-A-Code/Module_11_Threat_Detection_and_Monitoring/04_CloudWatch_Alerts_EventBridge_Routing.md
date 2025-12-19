# 04 - CloudWatch Alerts & EventBridge Routing

## Goal
Turn findings into actionable alerts with sane routing and enrichment.

## EventBridge Rules (examples)
- **Rule:** GuardDuty severity >= 7 → Targets: SNS topic `sec-critical`, Lambda (enrich + ticket), Slack webhook (via Lambda or Chatbot).
- **Rule:** CloudTrail `ConsoleLogin` where `userIdentity.type` = `Root` → SNS `sec-high`.
- **Rule:** CloudTrail `DeleteTrail` or `StopLogging` → SNS `sec-critical`.
- **Rule:** IAM `CreateUser` or `AttachUserPolicy` outside CI role → SNS `sec-high`.

### Console Steps
1) EventBridge → Rules → Create rule.
2) Pattern: Event source = `aws.guardduty`, detail.severity >= 7.
3) Target: SNS topic (create `sec-critical`), optional Lambda for enrichment.
4) Add dead-letter queue (SQS) for reliability.

## CloudWatch Alarms (metrics)
- Metric filter on CloudTrail logs for `ConsoleLogin` by `Root` → Alarm → SNS `sec-critical`.
- Metric filter for `StopLogging` / `DeleteTrail`.
- Metric for `AccessDenied` spikes (possible tampering).

### Steps (Root Login Example)
1) CloudWatch Logs Insights or Metric Filters → Create filter.
2) Pattern: `{ ($.userIdentity.type = "Root") && ($.eventName = "ConsoleLogin") && ($.responseElements.ConsoleLogin = "Success") }`
3) Create metric namespace `Security`, metric name `RootLogin`.
4) Alarm threshold: >=1 over 5 minutes → SNS `sec-critical`.

## Enrichment Lambda (outline)
- Input: EventBridge event.
- Add fields: account alias, tags (env/app), links to Security Hub/GuardDuty console, playbook URL.
- Publish to Slack/Teams.

## Notification Hygiene
- Separate topics: `sec-critical`, `sec-high`, `sec-medium` (emails on critical only).
- Add runbook link in the message body.
- Include throttle/backoff to avoid floods.

## Validation
- Generate GuardDuty sample finding (high severity) → confirm SNS email.
- Use `aws cloudtrail put-event-selectors`? (not needed); instead create test event in EventBridge with sample payload.
- Simulate root login with `aws login profile root`? Safer: use AWS provided sample event to test the rule.

## Cost
Minimal (SNS + EventBridge rules tiny). CloudWatch metric filters may cost per log volume; scope to needed patterns.

Outcome: Critical detections reach humans with context and a runbook link; alarms catch log tampering/root use.