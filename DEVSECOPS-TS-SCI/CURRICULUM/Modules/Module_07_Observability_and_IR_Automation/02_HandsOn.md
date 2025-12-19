````markdown
# Hands-on — Observability and IR Automation

## Goal
Practice producing telemetry evidence and writing an operator-friendly runbook flow.

## Step 1 — Run the service

```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
./scripts/demo_service.sh docker
```

In a second terminal, generate some traffic:

```bash
curl -sS http://localhost:8080/health
```

## Step 2 — Capture evidence
Capture container logs (replace container name/id as needed):

```bash
docker ps
docker logs <container_id>
```

Paste the outputs into `Developer_Journal.md`.

## Step 3 — Write a runbook skeleton
In `Implementation_Summary.md`, write:
- what signal triggers an alert
- triage steps (check last deploy, error rate, dependency health)
- escalation thresholds
- rollback steps

````
