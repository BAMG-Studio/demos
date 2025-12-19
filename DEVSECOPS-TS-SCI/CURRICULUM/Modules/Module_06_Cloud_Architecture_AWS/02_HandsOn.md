````markdown
# Hands-on — Cloud Architecture (AWS)

## Goal
Practice describing and validating a secure, auditable AWS architecture.

## Step 1 — Draw a one-page architecture
In `Developer_Journal.md`, sketch (text is fine):
- accounts (shared services, dev, prod, logging/security)
- VPCs and subnets
- where CI runs
- where artifacts live
- where logs go

## Step 2 — Evidence mindset (no cloud access required)
Capture local evidence:

```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
./scripts/ci_local.sh
```

This mirrors the “every change produces evidence” model.

## Step 3 — Optional AWS checks (if configured)

```bash
aws sts get-caller-identity
aws configure list
```

Record the outputs, then write:
- what that identity should and should not be allowed to do
- what role separation you’d enforce for CI vs humans

````
