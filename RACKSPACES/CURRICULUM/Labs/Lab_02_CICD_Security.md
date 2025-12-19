# Lab 02 — CI/CD Security

## Steps
1. Ensure `.RACKSPACES/workflows/security-pipeline.yml` exists.
2. Add `SNYK_TOKEN` repo secret.
3. Commit a test change and open a PR.
4. Observe jobs: gitleaks, semgrep, snyk, checkov, trivy.

## Validation
- Critical findings block merge.
- Medium/low generate issues or comments.
