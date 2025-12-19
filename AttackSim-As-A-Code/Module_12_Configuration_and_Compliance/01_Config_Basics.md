# 01 - AWS Config Basics (Org)

## Enable (Org)
- In management account: Config → Settings → set security account as aggregator admin.
- Enable recorder in **all regions**, include global resources.
- Delivery channel: central log archive bucket (prefix `config/`). KMS encrypt.
- Aggregator in security account: add all org accounts + all regions.

## Key Settings
- Recorder status: ON
- Resource types: All supported
- Delivery frequency: 1 hour (default)
- SNS topic: `config-notifications` (optional)

## Validation
- Check aggregator: all accounts listed, last update <24h.
- Run `GetComplianceDetailsByConfigRule` to confirm data landing.

## Cost Control
- Disable unused regions if org policy allows; otherwise accept small cost.
- Limit custom rules until needed; start with managed rules.

Outcome: Central, org-wide Config with aggregation ready for conformance packs.