# 03 - Data Model & Fields

## Core Field Set
- Identity: `user`, `user_type`, `role`, `source_ip`
- Resource: `account_id`, `region`, `resource_id`, `service`, `action`
- Network: `src`, `src_port`, `dst`, `dst_port`, `protocol`
- HTTP: `method`, `path`, `status`, `ua`
- Outcome: `result`, `error_code`
- Time: `@timestamp`

## Mapping Examples
- CloudTrail → map `eventName`→`action`, `userIdentity.arn`→`user`, `sourceIPAddress`→`src`.
- VPC Flow → map `srcaddr`, `dstaddr`, `dstport`, `action`, `bytes`.

## Quality Checks
- Ensure `@timestamp` aligns to event time (not ingest time).
- Add GeoIP on `src` for dashboards.

Outcome: Consistent schema to power alerts/dashboards across sources.