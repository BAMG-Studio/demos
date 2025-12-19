# Interview talk track — Kubernetes and Helm

## 30 seconds
"Kubernetes runs our containers reliably across a fleet. I package deployments as Helm charts so teams ship consistent, versioned releases with a clear rollback story. The goal is repeatability: same chart, different environment values, and guardrails enforced by policy."

## 60 seconds
Add:
- readiness/liveness probes to make rollouts safe
- requests/limits so the scheduler makes good choices
- secrets handled separately from config
- blue/green or canary when risk is high

## 120 seconds
Add:
- platform guardrails: admission policies, pod security controls, namespace isolation
- evidence: artifact version → chart version → deployment event → approval record
- operating model: shared platform templates, app teams own values and app-specific config
