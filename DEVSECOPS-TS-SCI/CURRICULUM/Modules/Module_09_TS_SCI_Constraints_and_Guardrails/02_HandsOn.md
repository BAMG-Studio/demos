````markdown
# Hands-on — TS/SCI constraints and guardrails

## Goal
Practice designing a delivery workflow that works under stricter constraints.

## Step 1 — Write your operating assumptions
In `Developer_Journal.md`, list assumptions like:
- no direct internet access for production systems
- controlled artifact sources
- approvals required for production deploy

## Step 2 — Define your guardrails
Write 8–12 bullets answering:
- what checks must run on every commit
- what must be blocked in CI
- what requires approvals
- how to handle secrets
- where evidence is stored

## Step 3 — Capture baseline evidence

```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
./scripts/ci_local.sh
```

Paste outputs as your “evidence artifact example.”

````
