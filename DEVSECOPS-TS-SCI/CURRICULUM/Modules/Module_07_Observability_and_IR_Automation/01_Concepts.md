# Concepts (plain English) — Observability and IR automation

## Observability vs monitoring
- **Monitoring** answers: “Is it down?”
- **Observability** answers: “Why is it behaving this way?”

## The three pillars
- **Logs**: discrete events (what happened).
- **Metrics**: numbers over time (how much/how often).
- **Traces**: request journey across services (where time is spent).

## What “good telemetry” means
At enterprise scale, you want:
- consistent fields (service name, environment, request id)
- low-noise signals (actionable alerts)
- retention and access controls
- evidence for audits and investigations

## Incident response automation (plain English)
Automation should reduce human toil:
- route alerts to the right team
- enrich with context (recent deploys, owner, runbook)
- open tickets automatically
- collect evidence (logs, config snapshots)

## Guardrails
Automation must be safe:
- least privilege for automation identities
- clear approvals for disruptive actions
- tamper-evident logging
