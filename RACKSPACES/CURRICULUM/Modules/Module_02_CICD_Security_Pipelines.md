# Module 02 — CI/CD Security Pipelines (GitHub Actions)

## Objective
Integrate security gates: secrets (Gitleaks), SAST (Semgrep), SCA (Snyk), IaC (Checkov), Image scan (Trivy).

## Quickstart
- Pipeline file: `.RACKSPACES/workflows/security-pipeline.yml`
- Add repo secret `SNYK_TOKEN` if using Snyk.
- Trigger by pushing a branch or PR to `main`.

## Deliverables
- Run results with critical findings blocking merge; medium/low reported.

## Interview Talking Points
- Shift-left, fast feedback, risk-based gating, developer enablement.
