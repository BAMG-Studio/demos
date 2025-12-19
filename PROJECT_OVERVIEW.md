# Rackspace Managed Security Operations Center (SOC) — Enterprise Project

## Executive Summary
This project implements a **production-grade, multi-account AWS security operations platform** aligned with Rackspace's managed security services. It demonstrates enterprise-scale threat detection, incident response automation, compliance posture management, and forensics capabilities.

**Target Audience:** Rackspace Cyber/Cloud Security Engineers, SOC Analysts, Security Architects  
**Duration:** 8–12 weeks (hands-on implementation)  
**Complexity:** Advanced (multi-account, event-driven, forensics-grade)

---

## Project Objectives

### Primary Goals
1. **Centralized Threat Detection** — Multi-account log aggregation, real-time alerting, threat hunting
2. **Automated Incident Response** — Event-driven playbooks, forensics collection, evidence preservation
3. **Compliance Posture Management** — Continuous compliance monitoring, remediation automation, audit readiness
4. **Security Metrics & Reporting** — KPIs, MTTR, detection coverage, executive dashboards

### Secondary Goals
- Cost optimization for security tooling
- Integration with ServiceNow for ticketing
- Purple team exercises (attack simulation + detection validation)
- Forensics pipeline for incident investigation

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    AWS Multi-Account Setup                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │  Prod Acct   │  │  Dev Acct    │  │  Sandbox     │           │
│  │  (Workloads) │  │  (Workloads) │  │  (Testing)   │           │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘           │
│         │                 │                 │                    │
│         └─────────────────┼─────────────────┘                    │
│                           │                                      │
│                    ┌──────▼──────┐                               │
│                    │ Security    │                               │
│                    │ Account     │                               │
│                    │ (Central)   │                               │
│                    └──────┬──────┘                               │
│                           │                                      │
│         ┌─────────────────┼─────────────────┐                   │
│         │                 │                 │                   │
│    ┌────▼────┐    ┌──────▼──────┐   ┌─────▼─────┐              │
│    │CloudTrail│    │GuardDuty    │   │SecurityHub│              │
│    │Logs      │    │Findings     │   │Findings   │              │
│    └────┬─────┘    └──────┬──────┘   └─────┬─────┘              │
│         │                 │                 │                    │
│         └─────────────────┼─────────────────┘                    │
│                           │                                      │
│                    ┌──────▼──────────┐                           │
│                    │ EventBridge     │                           │
│                    │ (Event Router)  │                           │
│                    └──────┬──────────┘                           │
│                           │                                      │
│         ┌─────────────────┼─────────────────┐                   │
│         │                 │                 │                   │
│    ┌────▼────┐    ┌──────▼──────┐   ┌─────▼─────┐              │
│    │OpenSearch│   │Lambda       │   │SNS/Email  │              │
│    │SIEM      │   │Playbooks    │   │Alerts     │              │
│    └──────────┘   └──────┬──────┘   └───────────┘              │
│                          │                                       │
│                   ┌──────▼──────┐                                │
│                   │SSM Automation│                               │
│                   │(IR Response) │                               │
│                   └──────────────┘                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Project Phases

### Phase 1: Foundation (Weeks 1–2)
- Multi-account setup with AWS Organizations
- Cross-account IAM roles for security account
- CloudTrail centralization (multi-region, integrity validation)
- AWS Config aggregation
- **Deliverable:** Terraform IaC for foundation, evidence of log flow

### Phase 2: Detection & Monitoring (Weeks 3–4)
- GuardDuty multi-account enablement
- SecurityHub aggregation + custom insights
- EventBridge rules for finding routing
- OpenSearch SIEM setup (log ingestion, parsing, enrichment)
- **Deliverable:** Detection dashboard, sample alerts, SIEM queries

### Phase 3: Incident Response Automation (Weeks 5–6)
- Lambda-based playbooks (isolation, forensics, remediation)
- SSM Automation for response actions
- Forensics pipeline (memory dump, disk snapshot, log collection)
- Evidence preservation (S3 with Object Lock)
- **Deliverable:** Runbooks, playbook code, IR drill results

### Phase 4: Compliance & Posture (Weeks 7–8)
- AWS Config rules (CIS, PCI, HIPAA mappings)
- Automated remediation (SSM Automation)
- Compliance dashboard (Config Aggregator)
- Audit evidence collection
- **Deliverable:** Compliance report, remediation evidence

### Phase 5: Advanced Scenarios (Weeks 9–12)
- Purple team exercises (Stratus Red Team + detection validation)
- Cost optimization analysis
- ServiceNow integration (ticketing)
- Metrics & KPI dashboards
- **Deliverable:** Purple team report, cost analysis, integration docs

---

## Folder Structure

```
RACKSPACE_MANAGED_SECURITY_PROJECT/
├── PROJECT_OVERVIEW.md                    # This file
├── CREDENTIALS_AND_SETUP.md               # .env, AWS setup, prerequisites
├── DEVELOPER_JOURNAL.md                   # Learning log (filled during implementation)
├── 
├── phase-1-foundation/
│   ├── terraform/
│   │   ├── main.tf                        # Multi-account setup, CloudTrail, Config
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   ├── scripts/
│   │   ├── setup_organizations.sh         # AWS Org setup
│   │   └── validate_foundation.sh         # Verification script
│   └── evidence/
│       └── README.md                      # Store screenshots, outputs
│
├── phase-2-detection/
│   ├── terraform/
│   │   ├── guardduty.tf                   # GuardDuty multi-account
│   │   ├── securityhub.tf                 # SecurityHub aggregation
│   │   ├── eventbridge.tf                 # Event routing
│   │   └── opensearch.tf                  # SIEM cluster
│   ├── opensearch/
│   │   ├── index-templates.json           # Log index mappings
│   │   ├── ingest-pipelines.json          # Log parsing/enrichment
│   │   └── dashboards.json                # Kibana dashboards
│   ├── scripts/
│   │   ├── ingest_cloudtrail_logs.py      # CloudTrail → OpenSearch
│   │   ├── create_siem_dashboards.py      # Dashboard setup
│   │   └── test_detection_rules.py        # Rule validation
│   └── evidence/
│       └── README.md
│
├── phase-3-incident-response/
│   ├── terraform/
│   │   ├── lambda.tf                      # Lambda playbooks
│   │   ├── ssm_automation.tf              # SSM Automation docs
│   │   ├── s3_forensics.tf                # Evidence bucket (Object Lock)
│   │   └── iam_roles.tf                   # IR execution roles
│   ├── lambda/
│   │   ├── isolate_ec2_instance.py        # Playbook: isolate EC2
│   │   ├── collect_forensics.py           # Playbook: forensics collection
│   │   ├── remediate_sg_rule.py           # Playbook: fix SG rules
│   │   └── notify_incident.py             # Playbook: alerting
│   ├── ssm-automation/
│   │   ├── isolate_instance.yml           # SSM Automation document
│   │   ├── collect_evidence.yml           # SSM Automation document
│   │   └── remediate_config.yml           # SSM Automation document
│   ├── scripts/
│   │   ├── test_playbooks.py              # Local playbook testing
│   │   └── drill_incident_response.sh     # IR drill script
│   └── evidence/
│       └── README.md
│
├── phase-4-compliance/
│   ├── terraform/
│   │   ├── config_rules.tf                # CIS, PCI, HIPAA rules
│   │   ├── remediation.tf                 # Auto-remediation
│   │   └── aggregator.tf                  # Config Aggregator
│   ├── config-rules/
│   │   ├── cis_benchmark_rules.json       # CIS AWS Foundations
│   │   ├── pci_dss_rules.json             # PCI DSS 3.2.1
│   │   └── hipaa_rules.json               # HIPAA compliance
│   ├── scripts/
│   │   ├── generate_compliance_report.py  # Compliance dashboard
│   │   ├── map_findings_to_controls.py    # Control mapping
│   │   └── export_audit_evidence.py       # Evidence export
│   └── evidence/
│       └── README.md
│
├── phase-5-advanced/
│   ├── purple-team/
│   │   ├── stratus_scenarios.json         # Stratus Red Team scenarios
│   │   ├── run_purple_team_exercise.sh    # Exercise orchestration
│   │   └── validate_detections.py         # Detection validation
│   ├── servicenow-integration/
│   │   ├── incident_sync.py               # ServiceNow API integration
│   │   └── webhook_handler.py             # Incident webhook receiver
│   ├── cost-optimization/
│   │   ├── analyze_security_costs.py      # Cost analysis
│   │   └── recommendations.md             # Cost optimization tips
│   ├── metrics-dashboards/
│   │   ├── kpi_dashboard.json             # CloudWatch dashboard
│   │   └── calculate_metrics.py           # MTTR, detection rate, etc.
│   └── evidence/
│       └── README.md
│
├── docs/
│   ├── ARCHITECTURE.md                    # Detailed architecture
│   ├── RUNBOOKS.md                        # Incident response runbooks
│   ├── PLAYBOOK_REFERENCE.md              # Lambda/SSM playbook docs
│   ├── COMPLIANCE_MAPPING.md              # Control → AWS service mapping
│   ├── TROUBLESHOOTING.md                 # Common issues & fixes
│   └── INTERVIEW_TALKING_POINTS.md        # Portfolio/interview prep
│
├── tests/
│   ├── test_lambda_playbooks.py           # Unit tests for Lambda
│   ├── test_terraform.sh                  # Terraform validation
│   └── test_detection_rules.py            # Detection rule validation
│
├── .env.example                           # Environment variables template
├── Makefile                               # Build/deploy automation
└── README.md                              # Quick start guide
```

---

## Key Technologies & Services

| Component | Service | Purpose |
|-----------|---------|---------|
| **Log Aggregation** | CloudTrail, VPC Flow Logs, Application Logs | Centralized audit trail |
| **Threat Detection** | GuardDuty, SecurityHub | Managed threat detection |
| **Event Routing** | EventBridge | Real-time event processing |
| **SIEM** | OpenSearch (or Splunk) | Log analysis, threat hunting |
| **Incident Response** | Lambda, SSM Automation, EventBridge | Automated playbooks |
| **Forensics** | S3 (Object Lock), EBS Snapshots, Memory Dumps | Evidence preservation |
| **Compliance** | AWS Config, Config Rules, Aggregator | Continuous compliance |
| **Ticketing** | ServiceNow (optional) | Incident management |
| **IaC** | Terraform | Infrastructure as Code |
| **CI/CD** | GitHub Actions | Security pipeline |

---

## Success Criteria

### Phase 1
- [ ] Multi-account setup with cross-account roles
- [ ] CloudTrail logs flowing to central S3 bucket
- [ ] AWS Config recording all resources
- [ ] Terraform plan validates without errors

### Phase 2
- [ ] GuardDuty findings visible in SecurityHub
- [ ] EventBridge rules routing findings to Lambda/SNS
- [ ] OpenSearch cluster ingesting CloudTrail logs
- [ ] Sample SIEM dashboard showing log volume, top events

### Phase 3
- [ ] Lambda playbooks execute successfully (tested locally)
- [ ] SSM Automation documents created and tested
- [ ] Forensics S3 bucket with Object Lock enabled
- [ ] IR drill completed with evidence collected

### Phase 4
- [ ] Config rules evaluating resources
- [ ] Compliance dashboard showing pass/fail status
- [ ] Auto-remediation fixing non-compliant resources
- [ ] Audit evidence exported for compliance review

### Phase 5
- [ ] Purple team exercise completed with detection validation
- [ ] ServiceNow integration syncing incidents
- [ ] Cost analysis identifying optimization opportunities
- [ ] KPI dashboard showing MTTR, detection rate, etc.

---

## Credentials & Environment Setup

See `CREDENTIALS_AND_SETUP.md` for:
- AWS account structure (Organization, Security Account, Workload Accounts)
- IAM roles and cross-account permissions
- .env variables (API keys, endpoints, credentials)
- Prerequisites (Terraform, AWS CLI, Python, Docker)

---

## Learning Outcomes

By completing this project, you will:

1. **Design & Deploy** enterprise-scale security architecture on AWS
2. **Automate** threat detection, incident response, and compliance
3. **Integrate** multiple AWS security services into cohesive platform
4. **Analyze** security logs and hunt for threats using SIEM
5. **Respond** to incidents with automated playbooks and forensics
6. **Demonstrate** compliance with industry frameworks (CIS, PCI, HIPAA)
7. **Optimize** security costs and operational efficiency
8. **Communicate** security posture to executives and auditors

---

## Next Steps

1. Review `CREDENTIALS_AND_SETUP.md` to prepare your environment
2. Start with **Phase 1: Foundation** (Weeks 1–2)
3. Document your progress in `DEVELOPER_JOURNAL.md`
4. Store evidence (screenshots, outputs) in phase-specific `evidence/` folders
5. Upon completion, use portfolio materials in `docs/` for interviews

---

## Support & Resources

- **AWS Security Best Practices:** https://aws.amazon.com/security/best-practices/
- **Rackspace Managed Security:** https://www.rackspace.com/security
- **NIST Cybersecurity Framework:** https://www.nist.gov/cyberframework
- **CIS AWS Foundations Benchmark:** https://www.cisecurity.org/benchmark/amazon_web_services
- **OWASP Top 10 Cloud:** https://owasp.org/www-project-cloud-top-10/

---

**Project Version:** 1.0  
**Last Updated:** 2025-01-XX  
**Status:** Ready for Implementation
