# 07 - Attack Simulation & Validation (Stratus Red Team)

## Goal
Prove detections work by running controlled cloud-native attack simulations.

## Tooling
- **Stratus Red Team** (open source) – runs atomic-style AWS scenarios.
- Requires IAM role with least-priv permissions per scenario; use dedicated test account.

## Setup (fast)
1) Install: `brew install datadog-stratus-red-team` (or binary from releases).
2) Configure AWS profile for test account with GuardDuty/Security Hub enabled.
3) Dry run: `stratus validate --cloud aws` to ensure perms.

## Scenarios to Run (examples)
- `aws/guardduty/unauthorized_access_ec2_imds_credential_theft`
- `aws/guardduty/defense_evasion_disable_guardduty`
- `aws/exfiltration/s3_sync_sensitive_bucket`
- `aws/persistence/iam_create_user_and_access_key`

## Execution
```bash
stratus run aws/guardduty/unauthorized_access_ec2_imds_credential_theft \
  --profile test \
  --region us-east-1 \
  --cleanup # always clean
```

## What to Observe
- GuardDuty finding generated? severity? time-to-detect?
- EventBridge rule fired? SNS email received? Slack message enriched?
- OpenSearch/Athena entries present?
- Security Hub shows finding and workflow status change?

## Record the Timeline
- T0: Attack executed
- T1: Finding created
- T2: Alert delivered
- T3: Human/automation response started

Compute **MTTD = T1 - T0**, **MTTA = T2 - T1**, **MTTR = T3 - T0**.

## Playbook Tie-In
For each scenario, link to a runbook:
- Contain: disable access key / quarantine instance / revoke session tokens.
- Eradicate: remove backdoor user/policy.
- Recover: re-enable GuardDuty, verify CloudTrail logging.

## Safety
- Use test account; keep cleanup flag on.
- Avoid production credentials/resources.

Outcome: Evidence your detections and alerts function as intended, with measured response times.