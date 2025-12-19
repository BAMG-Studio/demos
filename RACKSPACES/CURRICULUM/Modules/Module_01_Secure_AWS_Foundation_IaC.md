# Module 01 — Secure AWS Foundation (IaC)

## Objective
Provision secure-by-default AWS primitives with IaC: KMS (rotation), CloudTrail (multi-region, integrity), S3 encryption/versioning, AWS Config + rules.

## Prerequisites
- Terraform >= 1.5; AWS role/credentials.

## Quickstart
```bash
cd .RACKSPACES/iac/terraform/secure_foundation
terraform init
terraform plan -var="project=rackspace-secure" -var="region=us-east-1"
```

## Deliverables
- Terraform plan output screenshot.
- Evidence: S3 SSE, CloudTrail multi-region, Config recorder ON.

## Verification
- Checkov scan in CI passes; Config rule `S3_BUCKET_PUBLIC_READ_PROHIBITED` active.

## Interview Talking Points
- IaC consistency, least privilege, encryption by default, continuous audit.
