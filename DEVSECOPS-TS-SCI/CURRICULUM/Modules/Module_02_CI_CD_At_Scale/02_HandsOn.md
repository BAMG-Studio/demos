# Hands-on — CI/CD at scale

## Goal
Practice a standard “pipeline gate” locally and learn what it would look like in GitHub Actions or Jenkins.

## Do it

```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
./scripts/bootstrap.sh
./scripts/ci_local.sh
```

## Translate to enterprise
- Local script = same checks a pipeline runs.
- `DEMOS/demo-01-ci-devsecops-pipeline/workflow_templates/ci.yml` = a template you copy into a repo.

## Expected outputs
- ruff passes
- tests pass
- pip-audit and bandit produce reports (may warn but should not block learning)
