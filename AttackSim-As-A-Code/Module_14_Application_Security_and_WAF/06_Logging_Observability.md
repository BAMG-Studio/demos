# 06 - Logging & Observability

## What to Log
- WAF logs to S3/OpenSearch; ALB access logs; API GW execution/access logs; CloudFront logs.
- App logs with request ID/correlation ID.

## Metrics/Alerts
- WAF block count spikes → SNS/Slack.
- 4xx/5xx rates; latency; auth failures.

## Dashboards
- Top blocked rules, top IPs/countries, rate-limit events, login failure trends.

Outcome: Visibility into app-layer attacks and performance with alerting.