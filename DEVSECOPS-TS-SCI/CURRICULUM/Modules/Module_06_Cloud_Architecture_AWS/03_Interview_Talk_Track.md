# Interview talk track — AWS cloud architecture

## 30 seconds
"In enterprise AWS I design around boundaries: multi-account separation, least-privilege IAM roles, and centralized logging. The goal is to reduce blast radius and make every change traceable."

## 60 seconds
Add:
- VPC/subnet patterns and controlled egress
- centralized CloudTrail/log archive
- how CI/CD assumes roles rather than using static keys

## 120 seconds
Add:
- landing zone / guardrails and policy enforcement
- how you scale patterns across hundreds of apps
- how architecture supports incident response and audits
