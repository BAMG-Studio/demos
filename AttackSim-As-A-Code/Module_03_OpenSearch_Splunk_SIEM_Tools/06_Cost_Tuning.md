# 06 - Cost Tuning

- Use S3 for raw + Athena for cold; limit hot retention.
- Compress/aggregate via Firehose; drop verbose debug fields.
- In Splunk, use summary indexes; in OpenSearch, ISM to warm/cold.

Outcome: SIEM cost stays predictable while retaining required data.