# Interview talk track — CI/CD at scale

## 30 seconds
"At scale you can’t let every team invent pipelines. I standardize a golden pipeline template so every repo gets the same build, tests, and security gates. Teams only customize the app-specific commands; everything else is consistent and auditable."

## 60 seconds
Add:
- artifacts are versioned and traceable
- production is protected by approvals
- least-privilege credentials for pipeline runners

## 120 seconds
Add:
- Jenkins shared libraries vs GitHub reusable workflows
- evidence outputs for TS/SCI / compliance
- rollback strategy (blue/green, canary, or rapid revert)
