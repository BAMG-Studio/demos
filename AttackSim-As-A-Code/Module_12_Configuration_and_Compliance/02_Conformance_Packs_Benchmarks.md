# 02 - Conformance Packs & Benchmarks

## Deploy Pack (CIS Starter)
- Security account → Config → Conformance packs → Deploy.
- Template: `Operational Best Practices for CIS` (AWS provided) or custom YAML.
- Parameters: log bucket, aggregator region, notification SNS optional.
- Scope: all accounts/regions via aggregator.

## Custom Pack Tips
- Start with 15–25 controls (S3 public, SG open, MFA root, CloudTrail ON, KMS enabled).
- Use parameters for tag-based scoping (e.g., `Env=Prod`).
- Version in CodeCommit/Git; deploy via CloudFormation StackSets.

## Validation
- Compliance view: check pack status → `CREATE_COMPLETE`.
- Sample noncompliance: open SG → rule NonCompliant.

## Reporting
- Use AWS Config advanced queries for per-account drill-down.
- Export compliance summary to S3 weekly (Athena/QuickSight optional).

Outcome: Benchmarks-as-code applied org-wide with clear compliance posture.