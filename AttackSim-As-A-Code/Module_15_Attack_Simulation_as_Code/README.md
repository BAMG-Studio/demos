# Module 15: Attack Simulation as Code – Master Guide

## What & Why
Codify purple-team exercises so you can run repeatable, automated cloud attack simulations (Stratus Red Team, custom scripts) in CI/CD to validate detections and responses.

## Outcomes
- Safe sandbox patterns and guardrails for simulation
- Scenario catalog mapped to MITRE ATT&CK
- Automation via CLI/CI (GitHub Actions/CodeBuild) to run scheduled simulations
- Evidence collection + scoring (MTTD/MTTR, coverage)

## Path
1) `01_Planning_and_Safety.md`
2) `02_Scenario_Catalog_Mappings.md`
3) `03_Stratus_Automation_Pipeline.md`
4) `04_Custom_Attack_Scripts.md`
5) `05_Results_Scoring_and_Reporting.md`
6) `06_Playbook_Gaps_and_Tuning.md`
7) `07_Portfolio_Resume.md`

## Success Criteria
- Repo with scenario definitions + run scripts
- Scheduled run (weekly) in sandbox account with least-priv role
- Reports captured to S3 and routed to Slack/SNS
- Gaps identified and logged as issues/runbooks

Cost: small EC2 and API calls per run (~$5–$20/mo depending on frequency).