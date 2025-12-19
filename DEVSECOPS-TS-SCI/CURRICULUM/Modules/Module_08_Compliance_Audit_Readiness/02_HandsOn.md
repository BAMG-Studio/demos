````markdown
# Hands-on — Compliance and Audit Readiness

## Goal
Create a small “evidence packet” from your local pipeline gates.

## Step 1 — Run the gates

```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
./scripts/ci_local.sh
```

## Step 2 — Build your evidence packet
In `Developer_Journal.md`, paste:
- the exact commands you ran
- key outputs (pass/fail)
- any security findings (even if informational)

## Step 3 — Write a control story
In `Implementation_Summary.md`, write 5 bullets:
- what control this evidence supports (example: “secure SDLC gates”)
- what tool produced the evidence
- where it would be stored in enterprise
- retention expectation
- who reviews it and how often

````
