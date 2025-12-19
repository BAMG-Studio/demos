# Rackspace Cyber/Cloud Security Engineer — Live Projects Demo

This folder contains runnable demos, IaC samples, CI/CD security workflows, compliance mapping, and journals tailored to the Rackspace role.

## Contents
- `workflows/`: GitHub Actions security pipeline
- `iac/terraform/`: Secure AWS baseline (VPC/S3/IAM/KMS/CloudTrail/Config)
- `scripts/python/`: Security automation with boto3 (audit, IR, reporting)
- `docs/`: Layman explanations, STAR answers, interviewer questions

## Quick Start
1. Review docs in `docs/overview.md`.
2. Explore CI/CD in `workflows/security-pipeline.yml`.
3. Check IaC in `iac/terraform/secure_foundation/`.
4. Run Python demos:

```bash
python3 .RACKSPACES/scripts/python/audit_s3_public.py
python3 .RACKSPACES/scripts/python/incident_isolate_instance.py i-0123456789abcdef0
python3 .RACKSPACES/scripts/python/generate_compliance_report.py
```

## Notes
- AWS credentials must be configured via roles/temporary tokens.
- These demos are safe, read-only by default unless noted.
