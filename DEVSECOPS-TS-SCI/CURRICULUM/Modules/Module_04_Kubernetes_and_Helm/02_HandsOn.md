````markdown
# Hands-on — Kubernetes and Helm

## Goal
Practice the Kubernetes/Helm mental model using the existing container demo as the workload.

You’ll produce:
- a clear deployment plan
- evidence commands/outputs
- a rollback story

## Step 1 — Build and run the workload (container)

```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
./scripts/demo_service.sh docker
```

Expected behavior:
- Container runs and `/health` returns `{ "status": "ok" }`.

## Step 2 — Translate “docker run” into Kubernetes concepts
Map these ideas:
- `docker run -p 8080:8080` → **Service** (and maybe Ingress)
- `--env ...` → **ConfigMap/Secret**
- “restart if it dies” → **Deployment**
- “is it healthy?” → **readiness/liveness probes**

Write a short plan in `Developer_Journal.md`:
- namespace name
- number of replicas
- what probes you would use
- resource requests/limits (pick reasonable defaults)

## Step 3 — Create a Helm chart (optional build step)
If you have `helm` installed, create a chart skeleton:

```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
mkdir -p scratch
cd scratch
helm create demo-02
```

You don’t need to deploy yet; the goal is to understand:
- `Chart.yaml` (package metadata)
- `values.yaml` (environment-specific knobs)
- templates (Kubernetes manifests)

## Step 4 — Rollback plan (must-have)
Write a rollback plan in `Implementation_Summary.md`:
- fastest rollback (rapid revert to prior chart/app version)
- safety checks (verify readiness, error rate)
- how you would stop a bad rollout (pause, scale down, rollback)

## Evidence (capture these)
Paste outputs into `Developer_Journal.md`:

```bash
./scripts/ci_local.sh
```

This simulates the “gates before deploy” model.

````