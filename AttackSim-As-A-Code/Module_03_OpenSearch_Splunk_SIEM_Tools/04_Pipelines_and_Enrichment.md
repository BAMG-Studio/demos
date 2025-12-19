# 04 - Pipelines & Enrichment

- Firehose transforms: add account tags/env, normalize fields, drop noise.
- GeoIP enrichment on source IP.
- Threat intel enrich: match IP/domain against TI list; tag severity.
- Dedup logic for duplicate events.

Outcome: Cleaner, context-rich events for analytics/alerts.