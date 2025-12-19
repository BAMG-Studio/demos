# 04 - Custom Attack Scripts

When Stratus lacks a scenario, use boto3/CLI to simulate:
- Backdoor IAM user creation
- Mass S3 delete (ransomware mimic)
- SG open 0.0.0.0/0

Include:
- Idempotent setup/cleanup
- Tags, sleep timing, expected events
- Output JSON for results

Outcome: Fill gaps with scripted simulations managed in repo.