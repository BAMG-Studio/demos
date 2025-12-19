# Concepts (plain English) — Compliance and audit readiness

## What auditors want (simple)
Auditors usually ask:
- what controls exist
- whether they are followed
- proof that they happened

Plain English: “Show me that only the right people can change production, and that you can prove what changed and when.”

## Evidence as a byproduct
DevSecOps helps because:
- changes go through pipelines
- pipelines generate reports
- artifacts are versioned

So evidence is produced automatically instead of being assembled manually.

## Common evidence categories (safe and generic)
- change management (PRs, approvals)
- build and test results
- security scan reports (SAST/SCA)
- deployment logs
- access reviews / least privilege
- incident records and postmortems

## Risk register mindset
Not everything is “fixed immediately.”
What matters is:
- known gaps are documented
- compensating controls exist
- timelines and owners are defined
