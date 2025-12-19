# 02 - OpenSearch Hands-On

## Steps
- Create domain (dev): t3.small, fine-grained auth, IP allowlist.
- Ingest CloudTrail via Firehose → index `cloudtrail-*`.
- Build dashboard: events over time, top services, failed API calls.
- Create monitor: root login >0 → SNS/Slack.

Validation: send sample events; confirm dashboard and monitor fire.