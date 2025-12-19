# 06 - Cost & Sizing

## Ingest Planning
- Estimate GB/day per source; choose hot vs cold retention.
- Hot (OpenSearch) 7–14 days; cold (S3+Athena) 90–365 days.

## Knobs
- Sampling on Flow Logs; filter noisy services; compress via Firehose.
- ILM/ISM policies to move warm/cold/delete.

## Example Lab Budget
- 5 GB/day hot, 7-day retention → ~35 GB hot (~$5-8 infra) + raw S3 ~$4.

Outcome: Predictable SIEM spend with retention aligned to needs.