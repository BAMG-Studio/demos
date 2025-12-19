# 00 — Start Here: Quick Reference

## Quickstart: Demos
```bash
# Python demos
python3 .RACKSPACES/scripts/python/audit_s3_public.py
python3 .RACKSPACES/scripts/python/incident_isolate_instance.py i-0123456789abcdef0
python3 .RACKSPACES/scripts/python/generate_compliance_report.py
# Boto3 audit (requires AWS creds)
python3 .RACKSPACES/scripts/python/audit_s3_public_boto3.py
```

## Quickstart: Terraform Secure Baseline
```bash
cd .RACKSPACES/iac/terraform/secure_foundation
terraform init
terraform plan -var="project=rackspace-secure" -var="region=us-east-1"
```

## Quickstart: CloudFormation Equivalent
```bash
aws cloudformation deploy \
	--template-file .RACKSPACES/iac/cloudformation/secure_foundation.yml \
	--stack-name rackspace-secure-foundation \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameter-overrides Project=rackspace-secure TrailBucketName=rackspace-secure-cloudtrail-logs
```

## Quickstart: Security CI/CD (GitHub Actions)
- Commit and push changes to run `.RACKSPACES/workflows/security-pipeline.yml`.
- Store `SNYK_TOKEN` in repo secrets for SCA step.

## Key Folders
- `.RACKSPACES/workflows` — security pipeline
- `.RACKSPACES/iac/terraform` — secure AWS baseline
- `.RACKSPACES/iac/cloudformation` — CloudFormation equivalent
- `.RACKSPACES/scripts/python` — automation scripts
- `.RACKSPACES/docs` — explanations, STAR, questions, journal
- `.RACKSPACES/CURRICULUM` — this curriculum (index, modules, labs, playbooks)
- `.RACKSPACES/demo-app` — container for image scanning
- `.RACKSPACES/evidence` — store outputs/screenshots
