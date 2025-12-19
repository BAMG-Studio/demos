# Course Structure & Roadmap (Enterprise DevSecOps)

This roadmap mirrors how an enterprise DevSecOps team actually works.

## How to use this repo like a real job

For each module:
1. Read `01_Concepts.md` (plain English + acronyms expanded)
2. Do `02_HandsOn.md` (commands + expected outputs)
3. Fill in `Developer_Journal.md` (what you tried, what broke, what you fixed)
4. Produce `Implementation_Summary.md` (what you built, risks, next hardening steps)
5. Practice `03_Interview_Talk_Track.md` (30/60/120 second versions)

## Roadmap (recommended order)

1. Foundations: Agile + DevSecOps mental model
2. CI/CD at scale (templates, reusable pipelines, gated releases)
3. Containers: Docker build hygiene + supply chain basics
4. Kubernetes + Helm: deployment patterns + rollback
5. IaC/CaC: Terraform + Ansible + Packer (golden images)
6. Cloud architecture (AWS patterns; translate to Azure/GCP)
7. Observability + incident response automation
8. Compliance + audit-ready evidence (TS/SCI mindset)
9. TS/SCI constraints + guardrails (operating model)

## Output expectations (what “enterprise grade” looks like)

- Every demo has: a runbook, a quick start, a risk register section, and rollback steps.
- Every pipeline has: least-privilege guidance, secret-handling guidance, and artifact traceability.
- Every module produces a concrete artifact you can discuss in an interview.
