# Module 12: Configuration & Compliance – Master Guide

## What & Why
Use AWS Config + conformance packs to keep accounts continuously compliant (CIS/NIST), auto-remediate drift, and keep audit evidence ready. You’ll build posture-as-code and attach remediation with SSM Automation.

## Learning Outcomes
- Org-level AWS Config (all regions) with aggregators
- Conformance Packs + managed rules mapped to CIS/NIST
- Auto-remediation via SSM Automation and EventBridge
- Drift detection for guardrails (SCP, Config) and logging
- Audit evidence collection and reporting

## Path
1) `01_Config_Basics.md` – enable/aggregate, recorder/delivery
2) `02_Conformance_Packs_Benchmarks.md` – CIS/NIST mapping
3) `03_Remediation_SSM_Automation.md` – remediation playbooks
4) `04_SecurityHub_PostureOps.md` – score, exceptions, waivers
5) `05_Audit_Evidence.md` – evidence catalog, SAR/GDPR data
6) `06_Change_Drift_Guardrails.md` – drift watch, SCPs, alarms
7) `07_Portfolio_Resume.md` – bullets, artifacts

## Success Criteria
- Org-level Config recorder ON all regions + aggregator
- Conformance Pack deployed (CIS) with <24h compliance reports
- Auto-remediation attached to top 10 rules (S3 public, SG 0.0.0.0/0, MFA)
- Evidence delivered to bucket + dashboard
- Exceptions documented with expiry and business owner

## Cost Snapshot (small lab)
- Config recorder + evaluations: ~$3–8/mo depending on items/region count
- SSM Automation invocations: near $0 at lab volume
- SNS/EventBridge: negligible

## Validate
- Introduce noncompliant SG → auto-remediation fires
- S3 bucket public ACL → rule noncompliant then remediated
- Aggregator shows all accounts/regions green except test drift

Ready? Start with `01_Config_Basics.md`.