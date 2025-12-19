# Portfolio / Interview Bullets (Module 11)

Use 2–3 bullets max per resume; expand in interviews.

## Resume Bullets (pick 2)
- Built org-wide AWS detection stack: centralized CloudTrail/Flow/DNS logging, GuardDuty + Security Hub delegated admin, EventBridge → SNS/Slack with runbooks; validated via Stratus Red Team.
- Deployed cost-aware SIEM on OpenSearch with dashboards for auth, IAM changes, network egress, GuardDuty findings; created monitors and metric filters for root login and log tampering.
- Authored custom detections (IAM backdoor, S3 public ACL, logging tamper) with noise suppression and threat intel allow/block lists; measured MTTD/MTTR improvements.

## Interview Talking Points
- Architecture choices: why org-level CloudTrail + S3 Object Lock; why EventBridge vs SIEM alerts.
- Tuning strategy: suppressions with expirations; tags to route alerts; balancing noise vs coverage.
- Validation: Stratus scenarios, timing chain (event → finding → alert → response).
- Cost controls: flow log scope, OpenSearch retention, GuardDuty free tier period.

## Artifacts to Show
- Diagram of detection pipeline.
- Screenshot of OpenSearch dashboard + GuardDuty findings.
- SNS/Slack alert example with enrichment + runbook link.
- Stratus run log showing finding + alert timestamps.

Outcome: Clear, credible evidence of threat detection and monitoring skills.