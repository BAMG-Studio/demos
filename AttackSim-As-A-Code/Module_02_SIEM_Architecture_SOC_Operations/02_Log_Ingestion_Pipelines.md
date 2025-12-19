# 02 - Log Ingestion Pipelines

## Sources (minimum viable)
- CloudTrail (all regions), VPC Flow Logs, DNS Resolver, ALB/WAF, GuardDuty findings.

## Transport Patterns
- CloudWatch Logs → Subscription → Lambda transform → Kinesis Firehose → S3/OpenSearch.
- S3->Athena for cold search; OpenSearch for hot.

## Normalization Steps
- Add `account_id`, `region`, `env`, `service`, `action`, `src`, `dst`, `user`, `http` fields.
- Timestamp normalization to `@timestamp` (UTC ISO8601).

## Validation
- Ingest CloudTrail sample; verify index exists, fields populated, timestamp correct.

Outcome: Repeatable ingestion pattern with normalized fields.