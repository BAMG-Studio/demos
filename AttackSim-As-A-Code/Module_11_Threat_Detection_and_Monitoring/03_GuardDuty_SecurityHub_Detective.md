# 03 - GuardDuty, Security Hub, Detective

## Goal
Enable managed detections and aggregation in the delegated security account across all org accounts/regions.

## GuardDuty (org-wide)
1) In management account, designate a delegated admin (security account) for GuardDuty.
2) In security account GuardDuty console: `Enable` → `Enable organization`.
3) Auto-enable for new accounts and all current regions.
4) Optional: S3 Protection + EKS Audit Log monitoring if used.
5) Suppress known-benign findings via filters with tags/patterns (keep short list).

### Validate
- Run GuardDuty sample finding (console → Settings → Generate sample findings).
- Confirm findings appear in security account and member accounts are enrolled.

## Security Hub (standards + aggregation)
1) In management account, set security account as delegated admin for Security Hub.
2) In security account Security Hub console: `Enable Security Hub`.
3) Auto-enable new accounts + regions.
4) Turn on standards: **CIS AWS Foundations** (benchmark), **AWS Foundational Security Best Practices**.
5) Integrations: GuardDuty, Inspector, Macie (if enabled), Config, IAM Access Analyzer.
6) Configure finding aggregator to security account/region.

### Validate
- View Security Hub → Findings; verify from all accounts.
- Disable noisy controls that are out-of-scope for lab (document exceptions).

## Detective (optional but useful)
1) In management account, designate security account as delegated admin for Detective.
2) In security account Detective console: enable for org, all regions used.
3) Data sources: VPC Flow Logs, CloudTrail, GuardDuty findings.

### Validate
- From a GuardDuty finding, click `Investigate in Detective` to see graph.

## Event Severity Guidance
- GuardDuty severity 0–3 (Low), 4–6 (Medium), 7–8.9 (High), 9–10 (Critical).
- Route >= 7 to humans; keep 4–6 for dashboards/weekly review.

## Cost Notes
- GuardDuty & Security Hub: free 30 days; then per GB/events. Keep lab minimal.
- Detective priced on volume; consider enabling in few regions for lab.

## Quick CLI (reference)
```bash
# GuardDuty delegated admin (management account)
aws guardduty enable-organization-admin-account --admin-account-id <sec-acct-id>
# Security Hub delegated admin
aws securityhub enable-organization-admin-account --admin-account-id <sec-acct-id>
```

Outcome: Managed detections flowing to the security account with standards enabled and ready to route alerts.