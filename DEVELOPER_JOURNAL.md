# Developer Journal — Rackspace Managed Security Project

## Project: Rackspace Managed Security Operations Center (SOC)
**Duration:** 8–12 weeks  
**Goal:** Build enterprise-scale, multi-account AWS security platform with threat detection, incident response automation, and compliance posture management.

---

## Phase 1: Foundation (Weeks 1–2)

### Week 1: Multi-Account Setup & CloudTrail Centralization

#### Session 1.1: AWS Organizations & Account Structure
**Date:** [YYYY-MM-DD]  
**Goal:** Establish multi-account AWS organization with security account as central hub.

**What I expected to happen:**
- AWS Organizations enabled in management account
- Security account created and accessible
- Cross-account IAM roles configured for Terraform

**What actually happened:**
[Document your experience here]

**Evidence (commands + outputs):**
```bash
aws organizations describe-organization
aws sts get-caller-identity --profile security
```

**What broke (root cause):**
[Document any issues encountered]

**Fix (what changed):**
[Document how you resolved issues]

**Security considerations:**
- Secrets handling: Used IAM roles instead of long-term credentials
- Least privilege: Created minimal cross-account roles for Terraform
- Logging/audit: Enabled CloudTrail in management account

**What I learned:**
- AWS Organizations provides centralized billing and policy management
- Cross-account roles enable secure multi-account access without credential sharing
- Security account should be isolated with restricted access
- CloudTrail must be enabled before creating other resources for audit trail

**Next steps:**
- [ ] Verify all accounts accessible via AWS CLI profiles
- [ ] Document account IDs in `.env` file
- [ ] Proceed to Session 1.2: CloudTrail Centralization

---

## Phase 2: Detection & Monitoring (Weeks 3–4)

### Week 3: GuardDuty & SecurityHub

#### Session 3.1: GuardDuty Multi-Account Enablement
**Date:** [YYYY-MM-DD]  
**Goal:** Deploy GuardDuty across all accounts with delegated admin in security account.

**What I expected to happen:**
- GuardDuty delegated admin enabled in security account
- GuardDuty enabled in all member accounts
- Findings aggregated in security account

**What actually happened:**
[Document your experience here]

**Evidence (commands + outputs):**
```bash
aws guardduty list-detectors --profile security
aws guardduty get-detector --detector-id <id> --profile security
```

**What broke (root cause):**
[Document any issues]

**Fix (what changed):**
[Document resolution]

**Security considerations:**
- Secrets handling: GuardDuty uses IAM roles
- Least privilege: GuardDuty service role has minimal permissions
- Logging/audit: GuardDuty findings logged to CloudTrail

**What I learned:**
- GuardDuty requires 30 days to establish baseline
- Delegated admin simplifies multi-account management
- GuardDuty findings include severity and remediation steps
- Integration with SecurityHub enables centralized view

**Next steps:**
- [ ] Enable SecurityHub in security account
- [ ] Aggregate GuardDuty findings in SecurityHub

---

## Phase 3: Incident Response Automation (Weeks 5–6)

### Week 5: Lambda Playbooks & SSM Automation

#### Session 5.1: Lambda Playbooks for Incident Response
**Date:** [YYYY-MM-DD]  
**Goal:** Develop Lambda functions for automated incident response.

**What I expected to happen:**
- Lambda playbooks created for common incident scenarios
- Playbooks tested locally with moto
- Playbooks deployed to security account
- EventBridge rules trigger playbooks on findings

**What actually happened:**
[Document your experience here]

**Evidence (commands + outputs):**
```bash
aws lambda list-functions --profile security
python3 phase-3-incident-response/scripts/test_playbooks.py
```

**What broke (root cause):**
[Document any issues]

**Fix (what changed):**
[Document resolution]

**Security considerations:**
- Secrets handling: Lambda uses IAM roles, no credentials in code
- Least privilege: Lambda execution role has minimal permissions
- Logging/audit: Lambda logs sent to CloudWatch

**What I learned:**
- Lambda enables serverless incident response
- Playbooks should be idempotent (safe to run multiple times)
- Error handling is critical for production playbooks
- Testing with moto enables local development

**Next steps:**
- [ ] Deploy SSM Automation documents
- [ ] Execute IR drill

---

## Phase 4: Compliance & Posture (Weeks 7–8)

### Week 7: Config Rules & Automated Remediation

#### Session 7.1: Config Rules for Compliance Frameworks
**Date:** [YYYY-MM-DD]  
**Goal:** Deploy Config rules for CIS, PCI, HIPAA compliance.

**What I expected to happen:**
- Config rules created for CIS AWS Foundations Benchmark
- Config rules created for PCI DSS 3.2.1
- Compliance dashboard showing pass/fail status

**What actually happened:**
[Document your experience here]

**Evidence (commands + outputs):**
```bash
aws configservice describe-config-rules --profile security
aws configservice describe-compliance-by-config-rule --profile security
```

**What broke (root cause):**
[Document any issues]

**Fix (what changed):**
[Document resolution]

**Security considerations:**
- Secrets handling: Config rules use IAM roles
- Least privilege: Config rules have minimal permissions
- Logging/audit: Config changes logged to CloudTrail

**What I learned:**
- Config rules evaluate resources against desired state
- Custom rules enable organization-specific compliance checks
- Remediation can be automated via SSM Automation
- Compliance dashboard provides executive visibility

**Next steps:**
- [ ] Enable automated remediation for non-compliant resources
- [ ] Test remediation with non-compliant resources

---

## Phase 5: Advanced Scenarios (Weeks 9–12)

### Week 9: Purple Team Exercises

#### Session 9.1: Purple Team Exercise Planning
**Date:** [YYYY-MM-DD]  
**Goal:** Plan and execute purple team exercise using Stratus Red Team.

**What I expected to happen:**
- Stratus Red Team scenarios selected
- Detection rules validated
- Exercise executed safely
- Detection coverage measured

**What actually happened:**
[Document your experience here]

**Evidence (commands + outputs):**
```bash
./phase-5-advanced/purple-team/run_purple_team_exercise.sh
python3 phase-5-advanced/purple-team/validate_detections.py
```

**What broke (root cause):**
[Document any issues]

**Fix (what changed):**
[Document resolution]

**Security considerations:**
- Secrets handling: Exercise used test resources only
- Least privilege: Exercise used minimal permissions
- Logging/audit: All exercise actions logged for review

**What I learned:**
- Purple team exercises validate detection capabilities
- Stratus Red Team provides safe attack simulation
- Detection gaps should be addressed with new rules
- Regular exercises maintain team readiness

**Next steps:**
- [ ] Analyze detection gaps
- [ ] Update detection rules

---

## Key Lessons Learned

### Technical Insights
1. [Document key technical insights here]
2. [Document key technical insights here]
3. [Document key technical insights here]

### Operational Insights
1. [Document key operational insights here]
2. [Document key operational insights here]
3. [Document key operational insights here]

### Security Insights
1. [Document key security insights here]
2. [Document key security insights here]
3. [Document key security insights here]

---

## Challenges & Solutions

### Challenge 1: [Challenge Title]
**Problem:** [Describe the problem]  
**Solution:** [Describe the solution]  
**Outcome:** [Describe the outcome]

---

## Portfolio Materials

### Artifacts Created
- [ ] Architecture diagram (PNG/PDF)
- [ ] Implementation summary (Markdown)
- [ ] Terraform code (GitHub)
- [ ] Lambda playbooks (GitHub)
- [ ] SIEM dashboards (Screenshots)
- [ ] Compliance reports (PDF)
- [ ] Interview talking points (Markdown)

---

**Project Status:** In Progress  
**Last Updated:** 2025-01-XX  
**Next Review:** [YYYY-MM-DD]
