# Module 16: Incident Response Automation – Master Guide

## What & Why
Automate containment, eradication, and evidence collection for common cloud incidents. Build EventBridge/Lambda/SSM playbooks wired to GuardDuty, Config, and custom detections.

## Outcomes
- IR playbook patterns (EC2 isolate, IAM credential disable, S3 public fix, SG revert)
- EventBridge routing, DLQs, retries
- SSM Automation for remediation with approvals where needed
- Forensics capture (snapshots, logs, metadata) and evidence storage
- Testing and drills for confidence

## Path
1) `01_IR_Strategy_and_Runbooks.md`
2) `02_EventBridge_Lambda_Playbooks.md`
3) `03_SSM_Automation_and_Approvals.md`
4) `04_Forensics_and_Evidence_Pipeline.md`
5) `05_Testing_Drills_and_SLOs.md`
6) `06_Portfolio_Resume.md`

## Success Criteria
- EventBridge rules for GuardDuty high/critical -> Lambda playbooks with DLQ
- S3 public bucket and SG open auto-remediation working
- Credential compromise playbook disabling keys + deny policy + notify
- Evidence stored in S3 with integrity controls; alerts reach humans <1 min

Cost: mostly free (Lambda/EventBridge/SNS), snapshots incur small storage.

Start with `01_IR_Strategy_and_Runbooks.md`.