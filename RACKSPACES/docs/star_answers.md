# Behavioral — STAR Answers (Templates)

## Working Independently
- Situation: Multiple AWS accounts needed consistent security controls.
- Task: Implement logging, preventive controls, and automated compliance.
- Action: Built IaC modules, enabled CloudTrail/Config, added KMS encryption, scripted audits; documented decisions and progress.
- Result: Reduced high-risk findings by 87%; reusable automation.

## Change Management
- Situation: Encrypt existing S3 buckets without downtime.
- Task: Plan, test, approve, and rollout safely.
- Action: Piloted on test bucket, scheduled low-usage window, incremental updates, verified access, documented runbook.
- Result: Zero data loss/downtime; audited evidence ready.

## Team Collaboration
- Situation: Dev team faced repeated dependency CVEs.
- Task: Shift security left and reduce friction.
- Action: Integrated SCA in pipeline, dashboards, auto-PRs for updates, workshop training.
- Result: 75% vulnerability drop; faster remediation; developers empowered.
