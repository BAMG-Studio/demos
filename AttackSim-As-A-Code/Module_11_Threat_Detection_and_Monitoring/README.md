# Module 11: Threat Detection & Monitoring – Master Guide

## 🎯 Module Overview
Threat Detection & Monitoring turns raw telemetry into actionable security signals. You will centralize logs, enable managed detections, build custom alerts, and validate everything with purple-team simulations (Stratus Red Team). This module assumes IAM foundations (Module 10) and the multi-account org (Module 1).

## 📚 What You'll Learn
- ✅ Detection foundations: signals, events, findings, alerts
- ✅ Log centralization: CloudTrail (all regions), VPC Flow Logs, DNS, ALB, WAF
- ✅ Managed detections: GuardDuty, Security Hub, Inspector, Detective (glue logic)
- ✅ Alerting: CloudWatch metrics/alarms, EventBridge routing, SNS/Slack
- ✅ SIEM workflows: OpenSearch (dashboards, monitors), Athena queries
- ✅ Custom detections: rule writing, threat intel, allow/deny lists
- ✅ Validation: attack simulation with Stratus Red Team and sample playbooks
- ✅ Operations: runbooks, noise reduction, cost control, KPIs

## 🛠 Hands-On Emphasis
Console-first walkthroughs with optional CLI/Terraform snippets. Every section includes: what, why, how (tech + layman), and validation steps.

## 🗺️ Learning Plan (2-3 weeks)
- **Week 1:** Logging & centralization (CloudTrail, Flow Logs), Security Hub baseline
- **Week 2:** GuardDuty deep dive, CloudWatch alerts, OpenSearch dashboards
- **Week 3:** Custom detections, threat intel, purple-team validations with Stratus

## 📁 Files
```
Module_11_Threat_Detection_and_Monitoring/
├── README.md
├── 01_Detection_Fundamentals.md
├── 02_Log_Centralization_CloudTrail_FlowLogs.md
├── 03_GuardDuty_SecurityHub_Detective.md
├── 04_CloudWatch_Alerts_EventBridge_Routing.md
├── 05_OpenSearch_SIEM_Dashboards.md
├── 06_Custom_Detections_Threat_Intel.md
├── 07_Attack_Simulation_Validation.md
└── PORTFOLIO_Interview_Resume.md
```

## ✅ Success Criteria
- [ ] Organization-level CloudTrail on in all regions, immutable storage
- [ ] VPC Flow Logs + DNS query logs centralized
- [ ] GuardDuty + Security Hub enabled org-wide
- [ ] EventBridge routes key findings to SNS/Slack + playbooks
- [ ] CloudWatch alarms for root use, CloudTrail tampering, IAM anomalies
- [ ] OpenSearch dashboards & monitors live
- [ ] Custom rules deployed (backdoor IAM user, SG 0.0.0.0/0, S3 public)
- [ ] Stratus Red Team runs prove detections & responses work
- [ ] KPIs tracked (MTTD/MTTR, alert-to-signal ratio)

## 🔗 Dependencies
- Module 1 (AWS Organizations), Module 10 (IAM). Uses the same log archive bucket and central security account patterns.

## 💰 Cost Snapshot (per month, small lab)
| Service | Est. Cost | Notes |
| --- | --- | --- |
| CloudTrail (org, all regions) | ~$2-5 | Depends on event volume (ingest + S3 storage) |
| VPC Flow Logs | ~$3-8 | Per GB to S3/OpenSearch; throttle in lab |
| GuardDuty | ~$2-5 | Free 30 days; then per event/GB |
| Security Hub | ~$3-6 | Per finding/region; free 30 days |
| OpenSearch (dev 1-zone) | ~$20-30 | Use smallest t3.small / auto-pause if possible |
| CloudWatch Logs | ~$1-3 | Based on ingestion + retention |
| SNS/Email | ~$0 | Free tier covers low volume |

## 🚀 Start Here
1) Read `01_Detection_Fundamentals.md`
2) Enable org-level CloudTrail + Flow Logs (`02_...`)
3) Turn on GuardDuty/Security Hub (`03_...`)
4) Wire alerts with EventBridge + SNS (`04_...`)
5) Stand up OpenSearch dashboards (`05_...`)
6) Add custom rules + threat intel (`06_...`)
7) Validate with Stratus Red Team (`07_...`)

Ready? Let’s detect and respond! 🔎