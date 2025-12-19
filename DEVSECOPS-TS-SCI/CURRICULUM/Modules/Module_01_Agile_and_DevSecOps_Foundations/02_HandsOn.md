# Hands-on

## Goal
Run one demo locally and observe how “automation gates” feel in practice.

## Steps

```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
./scripts/bootstrap.sh
./scripts/demo_service.sh local
./scripts/ci_local.sh
```

## Expected outputs
- The demo service starts and returns a health response.
- Tests pass.
- Linting and basic security checks run.
