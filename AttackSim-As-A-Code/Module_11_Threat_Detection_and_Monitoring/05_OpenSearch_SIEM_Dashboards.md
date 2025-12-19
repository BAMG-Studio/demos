# 05 - OpenSearch SIEM Dashboards

## Goal
Stand up a small OpenSearch domain (or Serverless collection) to search logs and build dashboards/monitors.

## Setup (dev-friendly)
1) Create OpenSearch (smallest dev): `t3.small.search`, 10–20 GB EBS, single AZ (lab only).
2) Access: fine-grained access control, master user, IP allowlist to your VPN/home. Disable public if possible.
3) Ingest: use Kinesis Firehose or CloudWatch Logs subscription to push CloudTrail/Flow/DNS to an index prefix (e.g., `cloudtrail-*`, `flow-*`).
4) Default index templates: set mappings for timestamps/IPs to avoid dynamic mapping bloat.

## Dashboards to Build
- **Authentication:** Console logins by user/role, failed vs success, root logins.
- **IAM Changes:** Create/Attach/Delete users, policies, access keys.
- **Network:** Top talkers from Flow Logs; denies; egress to uncommon ASNs.
- **GuardDuty Findings:** Count by severity/type/account/region over time.
- **DNS:** Queries to new/rare domains; NXDOMAIN spikes.

## Monitors (alerting from OpenSearch)
- Monitor: GuardDuty high severity count >=1 → notify SNS/Slack.
- Monitor: Root login event → notify.
- Monitor: Flow Logs egress to `0.0.0.0/0` unusual ports.

## Sample Queries (OpenSearch Dashboards Dev Tools)
```sql
-- Root login events
SELECT userIdentity.accountId, userIdentity.arn, eventTime
FROM cloudtrail-*
WHERE eventName = 'ConsoleLogin' AND userIdentity.type = 'Root' AND responseElements.ConsoleLogin = 'Success'
ORDER BY eventTime DESC

-- GuardDuty high severity counts
SELECT severity, COUNT(*) AS c
FROM guardduty-* WHERE severity >= 7
GROUP BY severity
ORDER BY c DESC
```

## Visualization Tips
- Use TSVB/Line for trends; Table for high-cardinality detail.
- Add filters for `accountId`, `region`, `env` tags.
- Create a landing dashboard with KPIs: MTTD (time from event to finding), alert volume, top findings.

## Cost Controls
- Use hot storage only; delete after 7–14 days; archive in S3.
- Consider OpenSearch Serverless (per-GB); or skip OpenSearch and use Athena queries for low volume.

Outcome: Searchable telemetry with dashboards and monitors that mirror your EventBridge/SNS alerts.