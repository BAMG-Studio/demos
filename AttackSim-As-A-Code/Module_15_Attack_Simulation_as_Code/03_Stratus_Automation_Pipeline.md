# 03 - Stratus Automation Pipeline

## CLI Pattern
```
stratus warmup <scenario>
stratus detonate <scenario> --profile sandbox-attack-sim --region us-east-1
stratus cleanup <scenario>
```

## CI/CD Integration
- Runner: GitHub Actions/CodeBuild scheduled weekly.
- Steps: assume role → run selected scenarios → collect JSON output → upload to S3 `attack-sim-results/`.
- Fail pipeline if detection missing or cleanup failed.

## Inputs
- Scenario list YAML with allowlist per run.
- Max concurrent runs to limit spend.

Outcome: Push-button or scheduled attack sims with artifacts stored.