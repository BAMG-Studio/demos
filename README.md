# Rackspace Managed Security Operations Center (SOC) — Enterprise Project

## Quick Start

This is a **production-grade, multi-account AWS security operations platform** implementing enterprise-scale threat detection, incident response automation, and compliance posture management.

### Prerequisites

```bash
# Verify tools installed
terraform version      # >= 1.5
aws --version         # v2
python3 --version     # >= 3.9
docker --version      # latest
jq --version          # latest
```

### Setup (5 minutes)

```bash
# 1. Clone environment variables
cp .env.example .env
nano .env  # Edit with your AWS account IDs

# 2. Source environment
source .env

# 3. Configure AWS CLI profiles
aws configure --profile security
aws configure --profile prod
aws configure --profile dev

# 4. Validate setup
./phase-1-foundation/scripts/validate_foundation.sh

# 5. Create Python virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Project Structure

```
RACKSPACE_MANAGED_SECURITY_PROJECT/
├── PROJECT_OVERVIEW.md                    # Full project documentation
├── CREDENTIALS_AND_SETUP.md               # Detailed setup guide
├── DEVELOPER_JOURNAL.md                   # Implementation log
├── 
├── phase-1-foundation/                    # Weeks 1–2: CloudTrail, Config, KMS
│   ├── terraform/                         # IaC for foundation
│   ├── scripts/                           # Setup & validation scripts
│   └── evidence/                          # Screenshots & outputs
│
├── phase-2-detection/                     # Weeks 3–4: GuardDuty, SecurityHub, SIEM
│   ├── terraform/                         # IaC for detection services
│   ├── opensearch/                        # SIEM configuration
│   ├── scripts/                           # Log ingestion & dashboards
│   └── evidence/                          # Detection dashboards
│
├── phase-3-incident-response/             # Weeks 5–6: Lambda, SSM, Forensics
│   ├── terraform/                         # IaC for IR infrastructure
│   ├── lambda/                            # Playbook functions
│   ├── ssm-automation/                    # SSM Automation documents
│   ├── scripts/                           # Playbook testing & drills
│   └── evidence/                          # IR drill results
│
├── phase-4-compliance/                    # Weeks 7–8: Config Rules, Remediation
│   ├── terraform/                         # IaC for compliance
│   ├── config-rules/                      # CIS, PCI, HIPAA rules
│   ├── scripts/                           # Compliance reporting
│   └── evidence/                          # Compliance reports
│
├── phase-5-advanced/                      # Weeks 9–12: Purple Team, ServiceNow, Metrics
│   ├── purple-team/                       # Stratus Red Team scenarios
│   ├── servicenow-integration/            # ServiceNow API integration
│   ├── cost-optimization/                 # Cost analysis
│   ├── metrics-dashboards/                # KPI dashboards
│   └── evidence/                          # Exercise results
│
├── docs/                                  # Architecture, runbooks, talking points
├── tests/                                 # Unit & integration tests
└── .github/workflows/                     # CI/CD pipelines
```

---

## Phase Breakdown

### Phase 1: Foundation (Weeks 1–2)
**Goal:** Establish secure-by-default AWS baseline with centralized logging and compliance monitoring.

**Deliverables:**
- Multi-account AWS Organizations setup
- CloudTrail organization trail (multi-region, integrity validation)
- AWS Config with compliance rules
- KMS encryption for logs

**Quick Start:**
```bash
cd phase-1-foundation/terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply
```

**Validation:**
```bash
./phase-1-foundation/scripts/validate_foundation.sh
```

---

### Phase 2: Detection & Monitoring (Weeks 3–4)
**Goal:** Deploy threat detection and centralized SIEM for log analysis.

**Deliverables:**
- GuardDuty multi-account enablement
- SecurityHub aggregation with custom insights
- EventBridge rules for finding routing
- OpenSearch SIEM cluster with dashboards

**Key Services:**
- GuardDuty (managed threat detection)
- SecurityHub (findings aggregation)
- EventBridge (event routing)
- OpenSearch (SIEM)

---

### Phase 3: Incident Response Automation (Weeks 5–6)
**Goal:** Automate incident response with Lambda playbooks and forensics collection.

**Deliverables:**
- Lambda playbooks for common incident scenarios
- SSM Automation documents for response actions
- Forensics pipeline with evidence preservation
- IR drill with MTTR measurement

**Playbooks:**
- Isolate EC2 instance
- Collect forensics (memory, disk, logs)
- Remediate security group rules
- Notify security team

---

### Phase 4: Compliance & Posture (Weeks 7–8)
**Goal:** Implement continuous compliance monitoring and automated remediation.

**Deliverables:**
- AWS Config rules for CIS, PCI, HIPAA
- Automated remediation via SSM Automation
- Compliance dashboard
- Audit evidence export

**Compliance Frameworks:**
- CIS AWS Foundations Benchmark
- PCI DSS 3.2.1
- HIPAA (optional)

---

### Phase 5: Advanced Scenarios (Weeks 9–12)
**Goal:** Validate detections, optimize costs, and integrate with enterprise tools.

**Deliverables:**
- Purple team exercises with Stratus Red Team
- ServiceNow incident management integration
- Security cost analysis and optimization
- KPI dashboards (MTTR, detection rate, etc.)

---

## Key Technologies

| Component | Service | Purpose |
|-----------|---------|---------|
| **Logging** | CloudTrail, VPC Flow Logs | Centralized audit trail |
| **Detection** | GuardDuty, SecurityHub | Managed threat detection |
| **Routing** | EventBridge | Real-time event processing |
| **SIEM** | OpenSearch | Log analysis & threat hunting |
| **Response** | Lambda, SSM Automation | Automated playbooks |
| **Forensics** | S3 (Object Lock), EBS Snapshots | Evidence preservation |
| **Compliance** | AWS Config, Config Rules | Continuous compliance |
| **IaC** | Terraform | Infrastructure as Code |

---

## Success Criteria

### Phase 1 ✓
- [ ] Multi-account setup with cross-account roles
- [ ] CloudTrail logs flowing to central S3 bucket
- [ ] AWS Config recording all resources
- [ ] Terraform plan validates without errors

### Phase 2 ✓
- [ ] GuardDuty findings visible in SecurityHub
- [ ] EventBridge rules routing findings
- [ ] OpenSearch cluster ingesting logs
- [ ] SIEM dashboard showing log volume

### Phase 3 ✓
- [ ] Lambda playbooks execute successfully
- [ ] SSM Automation documents created
- [ ] Forensics S3 bucket with Object Lock
- [ ] IR drill completed with evidence

### Phase 4 ✓
- [ ] Config rules evaluating resources
- [ ] Compliance dashboard showing status
- [ ] Auto-remediation fixing non-compliant resources
- [ ] Audit evidence exported

### Phase 5 ✓
- [ ] Purple team exercise completed
- [ ] ServiceNow integration syncing incidents
- [ ] Cost analysis identifying savings
- [ ] KPI dashboard showing metrics

---

## Documentation

- **[PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)** — Full project scope, architecture, phases
- **[CREDENTIALS_AND_SETUP.md](CREDENTIALS_AND_SETUP.md)** — AWS account setup, IAM roles, .env configuration
- **[DEVELOPER_JOURNAL.md](DEVELOPER_JOURNAL.md)** — Implementation log (fill as you progress)
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** — Detailed architecture diagrams
- **[docs/RUNBOOKS.md](docs/RUNBOOKS.md)** — Incident response runbooks
- **[docs/PLAYBOOK_REFERENCE.md](docs/PLAYBOOK_REFERENCE.md)** — Lambda/SSM playbook documentation
- **[docs/COMPLIANCE_MAPPING.md](docs/COMPLIANCE_MAPPING.md)** — Control → AWS service mapping
- **[docs/INTERVIEW_TALKING_POINTS.md](docs/INTERVIEW_TALKING_POINTS.md)** — Portfolio & interview prep

---

## Common Commands

```bash
# Phase 1: Foundation
cd phase-1-foundation/terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply

# Validate Phase 1
./phase-1-foundation/scripts/validate_foundation.sh

# Phase 2: Detection (coming soon)
cd phase-2-detection/terraform
terraform init
terraform apply

# Phase 3: Incident Response (coming soon)
cd phase-3-incident-response/terraform
terraform init
terraform apply

# Run tests
pytest tests/ -v

# View logs
aws logs tail /aws/lambda/rackspace-soc-playbooks --follow --profile security
```

---

## Troubleshooting

### Issue: "Unable to assume role"
**Solution:** Verify trust policy in target account includes your principal ARN.

### Issue: "S3 bucket already exists"
**Solution:** Use globally unique bucket name (add timestamp or account ID).

### Issue: "Terraform state lock timeout"
**Solution:** Check DynamoDB table exists and is accessible.

### Issue: "Python boto3 import error"
**Solution:** Ensure venv is activated: `source venv/bin/activate`

### Issue: "AWS credentials not found"
**Solution:** Configure AWS CLI: `aws configure --profile security`

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

1. Review [CREDENTIALS_AND_SETUP.md](CREDENTIALS_AND_SETUP.md) to prepare your environment
2. Start with **Phase 1: Foundation** (Weeks 1–2)
3. Document your progress in [DEVELOPER_JOURNAL.md](DEVELOPER_JOURNAL.md)
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
**Status:** Ready for Implementation  
**Last Updated:** 2025-01-18
