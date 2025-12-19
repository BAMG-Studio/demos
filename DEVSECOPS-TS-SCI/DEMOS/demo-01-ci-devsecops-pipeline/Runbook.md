# Runbook — Demo 01 (CI DevSecOps Pipeline Template)

## Purpose
Provide a standard pipeline template that scales across many repositories.

## Procedure (copy/paste)
1) Copy this file into a target repo:
- `workflow_templates/ci.yml` → `.github/workflows/ci.yml`

2) Adjust the `working-directory` to point at that repo’s application folder.

3) Open a pull request; confirm the workflow runs.

## Validation
- Lint runs
- Tests run
- Dependency audit and Bandit run (may be informational)

## Troubleshooting
- If tests cannot import your package, ensure your repo’s test runner can find your source folder (e.g., add `tests/conftest.py` like in demo-02).
