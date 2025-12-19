# 04 - Security Hub Posture Ops

## Why
Security Hub aggregates findings and scores; align with Config/Conformance Packs for posture tracking.

## Setup
- Delegated admin = security account.
- Standards: CIS, AWS Foundational Best Practices. Auto-enable new accounts/regions.
- Finding aggregator: central region.

## Ops Runbook
- Daily triage: High/Critical findings; set workflow status; assign owner.
- Weekly noise review: suppress/accept with expiration and reason.
- Monthly posture report: score per account; trend.

## Integrations
- Ingest Config, GuardDuty, Inspector, Macie, IAM Access Analyzer.
- Forward critical findings to EventBridge → SNS/Chat.

## Validation
- Generate sample findings; confirm aggregation and routing.

Outcome: Posture scoring with actionable triage and exception governance.