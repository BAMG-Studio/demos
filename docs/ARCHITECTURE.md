# Rackspace Managed Security SOC — Architecture

## High-Level Architecture

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

## Component Details

### 1. Logging Layer (Phase 1)

**CloudTrail**
- Multi-region organization trail
- Log file validation (SHA-256 digest chains)
- KMS encryption at rest
- S3 storage with versioning and Object Lock

**AWS Config**
- Multi-account aggregator
- Continuous resource recording
- Compliance rule evaluation
- Automated remediation

**VPC Flow Logs** (Phase 2)
- Network traffic analysis
- Threat detection integration
- Forensics data source

### 2. Detection Layer (Phase 2)

**GuardDuty**
- Managed threat detection
- Multi-account delegated admin
- Finding types: EC2, IAM, S3, EKS, RDS
- 30-day baseline establishment

**SecurityHub**
- Findings aggregation
- Custom insights
- Compliance standards (CIS, PCI, HIPAA)
- Automated remediation triggers

**EventBridge**
- Real-time event routing
- Pattern-based filtering
- Multi-target delivery
- Dead-letter queue support

### 3. SIEM Layer (Phase 2)

**OpenSearch**
- Log centralization
- Full-text search
- Custom dashboards
- Threat hunting queries
- Alerting rules

**Index Strategy**
- CloudTrail logs: `cloudtrail-YYYY.MM.DD`
- GuardDuty findings: `guardduty-YYYY.MM.DD`
- SecurityHub findings: `securityhub-YYYY.MM.DD`
- Application logs: `app-YYYY.MM.DD`

### 4. Response Layer (Phase 3)

**Lambda Playbooks**
- Isolate EC2 instance
- Collect forensics
- Remediate security group rules
- Notify security team
- Create incident ticket

**SSM Automation**
- Multi-step workflows
- Approval gates
- Error handling
- Rollback capabilities

**Forensics Pipeline**
- Memory dumps (EC2 Instance Connect)
- EBS snapshots
- Log collection
- Evidence preservation (S3 Object Lock)

### 5. Compliance Layer (Phase 4)

**AWS Config Rules**
- CIS AWS Foundations Benchmark
- PCI DSS 3.2.1
- HIPAA (optional)
- Custom organization rules

**Remediation**
- Automatic via SSM Automation
- Manual approval workflows
- Exception management
- Audit trail

### 6. Integration Layer (Phase 5)

**ServiceNow**
- Incident creation
- Status synchronization
- CMDB integration
- Change management

**Metrics & Reporting**
- MTTR (Mean Time To Respond)
- Detection rate
- Remediation rate
- Cost per incident

---

## Data Flow

### Threat Detection Flow

```
1. Event occurs in workload account
   ↓
2. CloudTrail captures API call
   ↓
3. GuardDuty analyzes event
   ↓
4. Finding generated (if suspicious)
   ↓
5. SecurityHub aggregates finding
   ↓
6. EventBridge routes finding
   ↓
7. Lambda playbook triggered
   ↓
8. SSM Automation executes response
   ↓
9. Evidence collected to S3
   ↓
10. Incident created in ServiceNow
    ↓
11. Alert sent to security team
```

### Compliance Monitoring Flow

```
1. Resource created/modified in workload account
   ↓
2. AWS Config records change
   ↓
3. Config rule evaluates resource
   ↓
4. Non-compliance detected
   ↓
5. EventBridge triggers remediation
   ↓
6. SSM Automation remediates resource
   ↓
7. Config rule re-evaluates
   ↓
8. Compliance status updated
   ↓
9. Dashboard reflects change
```

---

## Security Considerations

### Defense in Depth

1. **Preventive Controls**
   - IAM policies (least privilege)
   - Security groups (network segmentation)
   - KMS encryption (data protection)
   - VPC endpoints (private connectivity)

2. **Detective Controls**
   - CloudTrail (audit logging)
   - GuardDuty (threat detection)
   - SecurityHub (findings aggregation)
   - Config rules (compliance monitoring)

3. **Responsive Controls**
   - Lambda playbooks (automated response)
   - SSM Automation (orchestrated actions)
   - Forensics pipeline (evidence collection)
   - Incident ticketing (tracking)

### Encryption Strategy

- **At Rest:** KMS CMK with automatic rotation
- **In Transit:** TLS 1.2+ for all communications
- **Key Management:** Separate keys per environment
- **Rotation:** 90-day automatic rotation

### Access Control

- **Cross-Account:** IAM roles with trust policies
- **Service Access:** Resource-based policies
- **User Access:** Federated identity (SSO)
- **Audit:** CloudTrail logging all access

---

## Scalability & Performance

### Multi-Account Design

- **Security Account:** Central hub for all security services
- **Workload Accounts:** Isolated application environments
- **Sandbox Account:** Safe testing environment
- **Management Account:** Billing and Organizations

### Log Volume Handling

- **CloudTrail:** 100+ GB/day typical enterprise
- **OpenSearch:** 3-node cluster for HA
- **Index Lifecycle:** 30-day hot, 90-day warm, archive
- **Retention:** 1 year in S3, 90 days in OpenSearch

### Cost Optimization

- **Reserved Capacity:** OpenSearch reserved instances
- **Log Filtering:** Exclude non-critical events
- **Compression:** S3 lifecycle policies
- **Tiering:** Hot/warm/cold storage strategy

---

## Disaster Recovery

### Backup Strategy

- **CloudTrail Logs:** S3 versioning + cross-region replication
- **Config Snapshots:** S3 with Object Lock
- **Forensics Evidence:** S3 with Object Lock (immutable)
- **SIEM Data:** OpenSearch snapshots to S3

### Recovery Procedures

1. **Log Loss:** Restore from S3 versioning
2. **Config Drift:** Remediate via Config rules
3. **Playbook Failure:** Manual response via runbooks
4. **SIEM Outage:** Query CloudTrail directly

---

## Monitoring & Alerting

### Key Metrics

- **Detection Latency:** Time from event to finding
- **Response Time:** Time from finding to action
- **Remediation Time:** Time from detection to resolution
- **False Positive Rate:** Percentage of non-critical findings

### Alerting Rules

- **Critical:** Immediate notification (Slack, email, SMS)
- **High:** Within 1 hour
- **Medium:** Within 4 hours
- **Low:** Daily digest

---

## Compliance Mapping

### CIS AWS Foundations Benchmark

| Control | Service | Implementation |
|---------|---------|-----------------|
| 1.1 | CloudTrail | Organization trail enabled |
| 1.2 | CloudTrail | Log file validation enabled |
| 1.3 | CloudTrail | S3 bucket encryption |
| 2.1 | CloudWatch | CloudTrail logs to CloudWatch |
| 2.2 | CloudWatch | Log group retention |
| 2.3 | CloudWatch | Unauthorized API calls alarm |
| 2.4 | CloudWatch | IAM policy changes alarm |
| 2.5 | CloudWatch | CloudTrail disabled alarm |

### PCI DSS 3.2.1

| Requirement | Service | Implementation |
|-------------|---------|-----------------|
| 10.1 | CloudTrail | Audit trail of access |
| 10.2 | CloudTrail | User identification |
| 10.3 | CloudTrail | Access to audit trails |
| 10.4 | CloudTrail | Invalid access attempts |
| 10.5 | CloudTrail | Audit trail protection |

---

## Next Steps

1. Review Phase 1 foundation deployment
2. Validate CloudTrail and Config setup
3. Proceed to Phase 2: Detection & Monitoring
4. Document architecture decisions in DEVELOPER_JOURNAL.md

---

**Last Updated:** 2025-01-18  
**Version:** 1.0
