````markdown
# Hands-on — IaC (Terraform), CaC (Ansible), and Packer

## Goal
Practice the enterprise workflow: design → gate checks → evidence → rollback.

This hands-on is intentionally usable even without cloud credentials.

## Step 1 — Run the “gates” and capture evidence

```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
./scripts/ci_local.sh
```

Paste outputs into `Developer_Journal.md` as your evidence packet.

## Step 2 — Write a minimal environment plan (design exercise)
In `Developer_Journal.md`, describe an environment you’d build with IaC:
- VPC/networking
- compute (Kubernetes nodes or app instances)
- IAM roles/policies
- logging destination
- secrets strategy

Keep it one page.

## Step 3 — Terraform workflow (optional if you have Terraform)

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

Record:
- the plan summary
- any policy failures you would want to enforce

## Step 4 — Rollback story
Write a rollback plan in `Implementation_Summary.md`:
- revert the IaC change and re-apply
- restore from known-good state (image / snapshot)
- incident comms and evidence

````
