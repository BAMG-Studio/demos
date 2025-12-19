# Demo 01 — CI DevSecOps Pipeline Pattern (Template)

## What this is
A copy/paste-ready **pipeline template** you can adapt to any repo.

Because GitHub only runs workflows from the repo root `.github/workflows/`, this demo stores templates under `workflow_templates/`.

## What it demonstrates
- CI (Continuous Integration): tests on every pull request
- Basic DevSecOps gates: lint + SAST/SCA style checks
- Enterprise scaling approach: “one golden pipeline” reused across many apps

## Use it
1) Copy `workflow_templates/ci.yml` into your target repo at `.github/workflows/ci.yml`
2) Adjust the few inputs (python version, working directory)

## Why this helps at scale
Instead of every team inventing a new pipeline, you standardize:
- the same safety checks
- the same artifact naming/tagging conventions
- the same logs and evidence outputs
