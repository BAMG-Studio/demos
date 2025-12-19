# 04 - Data Discovery & DLP (Macie)

## Why
Find sensitive data in S3 (PII) and route findings.

## Steps
1) Enable Macie in security account; auto-enable members.
2) Create classification job against target buckets (tags/prefix filter).
3) Findings → Security Hub/EventBridge → SNS.

## Cost Control
- Scope to specific buckets/prefixes; one-time small job for lab.

## Validation
- Job completes; findings (if any) appear and route to SNS.

Outcome: Basic DLP visibility with routed findings.