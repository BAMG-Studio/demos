# Concepts (plain English) — Kubernetes and Helm

## What Kubernetes is
**Kubernetes (K8s)** is a platform that runs containers across many machines.

Plain English:
- A container is “your app in a box.”
- Kubernetes is the system that decides **where** those boxes run, **keeps them healthy**, and **replaces** them if they fail.

Kubernetes gives you:
- **Scheduling**: pick a node to run the workload.
- **Self-healing**: restart failed containers.
- **Scaling**: increase/decrease replicas.
- **Service discovery**: stable networking to reach workloads.
- **Rollouts/rollbacks**: controlled change.

## Core objects you must be able to explain
- **Cluster**: the whole environment.
- **Node**: a machine that runs workloads.
- **Namespace**: a “folder” for isolation.
- **Pod**: the smallest runnable unit (one or more containers).
- **Deployment**: declares desired state (replicas, update strategy).
- **Service**: stable endpoint to reach pods.
- **ConfigMap/Secret**: configuration (with different handling expectations).
- **Ingress**: HTTP routing to Services.

## What Helm is
**Helm** is the package manager for Kubernetes.

Plain English:
- YAML manifests get repetitive.
- Helm lets you template them and ship them as a versioned “chart.”
- You can deploy the same chart into many environments with different values.

## Why this matters (job requirement mapping)
This role calls out Kubernetes and Helm explicitly.

At scale you need:
- repeatable deployments
- consistent guardrails (security, logging, resource limits)
- a rollback story you can execute under pressure

## The enterprise-safe deployment model
Minimum guardrails you should talk about:
- **Namespaces per environment/team** (blast-radius control)
- **Resource requests/limits** (stability + scheduling)
- **Readiness/liveness probes** (safe rollouts)
- **Pod security controls** (non-root, drop capabilities)
- **Network policies** (default deny where possible)
- **Admission policies** (enforce “what good looks like”)

## TS/SCI mindset (non-sensitive)
Keep it generic and process-focused:
- assume constrained connectivity and tight change control
- prioritize deterministic builds and repeatable deploys
- produce evidence: “what ran, when, with which artifact, approved by whom”
