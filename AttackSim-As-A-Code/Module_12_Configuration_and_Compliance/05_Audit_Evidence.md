# 05 - Audit Evidence & Reporting

## Evidence Catalog
- Store evidence in S3 `evidence/` with Object Lock (governance) if allowed.
- Include: Config snapshots, Security Hub CSV exports, IAM credential reports, trail digests.

## Generating Evidence
- Config advanced queries → export CSV to S3.
- Security Hub → Batch export findings weekly.
- IAM → credential report daily; store + hash.

## Traceability
- Tag evidence with `control`, `framework`, `period`, `owner`.
- Maintain runbook for evidence production.

## Auditor Hand-off
- Provide read-only role to evidence bucket with scoped policy.
- Include data dictionary + sampling guidance.

Outcome: Auditor-ready evidence with integrity and ownership.