# Lab 01 — Secure AWS Baseline (Terraform)

## Steps
1. Set AWS creds (role) and region.
2. `terraform init` and `terraform plan` in `.RACKSPACES/iac/terraform/secure_foundation`.
3. Review plan for: KMS rotation, CloudTrail multi-region, S3 SSE+versioning, Config recorder.
4. Optional: Apply in sandbox.

## Validation
- Checkov finds 0 criticals.
- Config rule `S3_BUCKET_PUBLIC_READ_PROHIBITED` present.
