# Module 1: Real-World Case Study - Enterprise DevSecOps Organization

## Case Study Overview

**Company:** TechStartup Inc. (Fictional)  
**Size:** 150 employees, $20M annual revenue  
**Previous State:** Single AWS account, growing security concerns  
**Challenge:** Rapid growth requiring secure multi-account architecture  
**Solution:** AWS Organizations with proper governance  
**Result:** 99.8% security incident prevention, 40% faster incident response  

---

## 📖 The Story

### Phase 1: The Crisis (Months -6 to 0)

#### The Situation

TechStartup Inc. was a successful SaaS company running everything in a single AWS account:

```
One AWS Account (123456789999)
├── Production Apps (Flask microservices)
├── Development Environment (developers' testing)
├── Logging & Analytics (CloudWatch, S3)
├── Data Warehouse (customer data)
├── Security Tools (GuardDuty, Security Hub)
└── Staging & QA (pre-production testing)
```

**The Problems:**

1. **Security Incident - April 2023**
   - Junior developer's laptop was compromised
   - Attacker gained AWS access key from compromised git repository
   - Attacker logged into the AWS account and disabled CloudTrail
   - Successfully deleted 3 weeks of audit logs
   - Attempted to create 50 EC2 instances for crypto mining
   - Estimated potential damage: $50,000/week if not stopped
   - Detection: Only found due to hourly billing alert, not security monitoring

2. **Compliance Issues - May 2023**
   - SOC 2 audit revealed: "No segregation of production and development"
   - PCI-DSS audit: "Customer data accessible by all developers"
   - ISO 27001 review: "No audit trail separation between environments"
   - Result: Audit failure, loss of a major enterprise customer worth $500K/year

3. **Cost Overruns - June 2023**
   - Developer accidentally left 10 GPU instances running in expensive region
   - Cost: $15,000/month (was on auto-scaling)
   - Detection: Monthly AWS bill shocked the finance team
   - No way to prevent without restarting every EC2 instance hourly

4. **Team Friction - July 2023**
   - Operations team: "Developers are breaking production!"
   - Developers: "We can't develop anything without ops approval!"
   - Security team: "We don't trust anyone with production access!"
   - CEO: "We need to grow 10x without breaking stuff"

#### The Decision

CEO hired a DevSecOps consultant (you!) to restructure AWS accounts.

**Budget:** $200K for implementation + $15K/month ongoing  
**Timeline:** 6 weeks to implement  
**Risk tolerance:** LOW - Must not affect current production revenue

---

### Phase 2: The Plan (Weeks 1-2)

#### Analysis

You conducted a 2-week analysis and discovered:

**Current State:**
- 1 AWS account
- 15 team members (5 devs, 3 ops, 4 security, 1 data, 2 managers)
- 23 microservices
- 850 GB of customer data
- 200+ CloudWatch metrics
- 4 million API calls/month

**Required Structure:**
```
TechStartup Organization
├── Management Account (billing, SSO)
├── Security OU
│   ├── Security-Logging (immutable audit logs)
│   └── Security-Tools (GuardDuty, Inspector, Security Hub)
├── Production OU
│   ├── Production-Primary (live services)
│   └── Production-Secondary (backup/DR)
├── NonProduction OU
│   ├── Development (active development)
│   ├── Testing (QA testing)
│   └── Staging (pre-production)
└── Sandbox OU
    └── Attack-Simulation (security testing, pentests)
```

**Cost Estimate:**
```
AWS Organizations: $0
CloudTrail (org-wide): $20/month
S3 (audit logs): $50/month
GuardDuty: $30/month
Security Hub: $25/month
Config: $50/month
Additional EC2/RDS: $3,000/month (moved from single account)
—————————————
TOTAL: $3,175/month (+$150 vs single account)

Benefit: Prevent $500K breach = 3,330x ROI
```

#### Team Buy-in

**Executive Presentation:**

| Metric | Before | After | Impact |
|--------|--------|-------|--------|
| MTTD (Mean Time to Detect threat) | 4 hours | 2 minutes | 120x faster |
| Cost control | None | Org-wide SCPs | 30-40% cost reduction potential |
| Audit compliance | FAIL | PASS | $500K+ customer confidence |
| Developer productivity | Slow (ops approvals) | Fast (own account) | +20% development velocity |
| Security incidents/month | 2-3 | 0 (prevented by SCP) | $100K+ saved monthly |

**VP of Security signed off:** "This gives us control without slowing development."  
**VP of Engineering signed off:** "Our developers get autonomy in dev, safety in production."  
**CFO signed off:** "Prevents catastrophic losses, costs $150/month more, excellent ROI."

---

### Phase 3: The Implementation (Weeks 3-6)

#### Week 3: Foundation

**Monday-Tuesday: Create Organization**
```bash
# Create organization with all features
aws organizations create-organization --feature-set ALL

# Created OUs
aws organizations create-organizational-unit --parent-id r-xxxx --name Security
aws organizations create-organizational-unit --parent-id r-xxxx --name Production
aws organizations create-organizational-unit --parent-id r-xxxx --name NonProduction
aws organizations create-organizational-unit --parent-id r-xxxx --name Sandbox
```

**Status:** ✅ Organization created in 2 hours  
**Team reaction:** "That was easy... what's next?"

**Wednesday-Friday: Create Accounts**
```bash
# Created 7 new member accounts
- Security-Logging (000000000001)
- Security-Tools (000000000002)
- Production-Primary (000000000003)
- Production-Secondary (000000000004)
- Development (000000000005)
- Testing (000000000006)
- Staging (000000000007)
```

**Challenge:** Production account creation needed to be coordinated  
**Solution:** Did it Friday evening, verified during weekend  

**Status:** ✅ 7 accounts created  
**Team reaction:** "We're not breaking anything... are we?"

#### Week 4: Migration & Security Policies

**Monday-Tuesday: Migrate Production**
```
Original Account Data:
├── Production databases
├── 23 microservices
├── 850 GB customer data
└── Configuration management

Migration Strategy:
1. Snapshot all RDS databases
2. Snapshot all EBS volumes
3. Create AMI from production instances
4. Restore to new Production-Primary account
5. Validate functionality
6. Switch DNS to new account
7. Monitor for 24 hours
```

**Actual timeline:** 
- Snapshot creation: 2 hours
- Restore in new account: 3 hours
- Testing: 4 hours
- DNS cutover: 30 minutes
- Monitoring: 24 hours
- **Total: Less than 1 day**

**Customer impact:** ZERO (happened Friday night to Sunday morning)

**Tuesday evening: Production migrated successfully** ✅

**Wednesday-Friday: Implement SCPs**

Created and tested 5 SCPs:

**1. Baseline Security Protection (Root - All Accounts)**
```json
{
  "Sid": "PreventSecurityServiceDisable",
  "Effect": "Deny",
  "Action": [
    "cloudtrail:StopLogging",
    "guardduty:DeleteDetector",
    "securityhub:DisableSecurityHub",
    "config:StopConfigurationRecorder"
  ],
  "Resource": "*"
}
```

**Test result:** ✅ Developers tried to disable GuardDuty in dev account, blocked

**2. Cost Control (Root - All Accounts)**
```json
{
  "Sid": "DenyExpensiveRegions",
  "Effect": "Deny",
  "Action": "*",
  "Resource": "*",
  "Condition": {
    "StringNotEquals": {
      "aws:RequestedRegion": ["us-east-1", "us-west-2"]
    }
  }
}
```

**Test result:** ✅ Accidental eu-west-1 launch was blocked

**3. Production Protection (Production OU)**
```json
{
  "Sid": "DenyProuctionDataDeletion",
  "Effect": "Deny",
  "Action": [
    "rds:DeleteDBInstance",
    "s3:DeleteBucket",
    "dynamodb:DeleteTable"
  ],
  "Resource": "*"
}
```

**Test result:** ✅ Even root user couldn't delete production database

**4. Development Freedom (NonProduction OU)**
```json
{
  "Sid": "AllowExperimentation",
  "Effect": "Allow",
  "Action": "*",
  "Resource": "*"
}
```

**Test result:** ✅ Developers could experiment freely in dev account

**5. Sandbox Isolation (Sandbox OU)**
```json
{
  "Sid": "PreventCrosAccountAccess",
  "Effect": "Deny",
  "Action": "sts:AssumeRole",
  "Resource": "arn:aws:iam::*:role/*",
  "Condition": {
    "StringNotEquals": {
      "aws:SourceAccount": "[SANDBOX_ACCOUNT_ID]"
    }
  }
}
```

**Test result:** ✅ Attack simulations couldn't affect other accounts

**Status:** ✅ 5 SCPs created and tested  
**Incidents prevented during testing:** 3 accidental misconfigurations

#### Week 5: Logging & Monitoring

**Monday-Wednesday: Centralized Logging**

```bash
# Created organizational CloudTrail
aws cloudtrail create-trail \
  --name TechStartup-OrgTrail \
  --s3-bucket-name techstartup-cloudtrail-logs \
  --is-organization-trail \
  --enable-log-file-validation \
  --is-multi-region-trail
```

**Storage design:**
```
S3 Bucket Structure:
cloudtrail-logs/
├── 2024/01/01/account-123456789999/...
├── 2024/01/01/account-000000000001/...
├── 2024/01/01/account-000000000002/...
├── 2024/01/01/account-000000000003/...
├── 2024/01/01/account-000000000004/...
└── ...

Retention: 7 years (compliance requirement)
Cost: ~$50/month
Searchable: CloudTrail Insights queries
```

**Wednesday-Friday: CloudWatch Monitoring**

```bash
# Created alarms for suspicious activity
- Failed API calls from accounts
- CloudTrail logging stopped
- Multiple failed API attempts
- GuardDuty findings
- Configuration changes in production
```

**Example alarm:**
```json
{
  "AlarmName": "CloudTrail-Logging-Stopped",
  "MetricName": "CloudTrailStopLoggingCalls",
  "Threshold": 1,
  "Statistic": "Sum",
  "Period": 300,
  "EvaluationPeriods": 1,
  "AlarmActions": ["SNS Topic: security-team@techstartup.io"]
}
```

**Status:** ✅ Centralized logging operational  
**Logs analyzed:** 4.2 million events from all accounts

#### Week 6: Training & Cutover

**Monday: Team Training**

**Development team:**
- "You have full access to your Dev account"
- "Production? You have read-only access"
- "Try to delete something in production... watch it fail"
- Reaction: Laughter + relief ("Finally, I can't break production by accident!")

**Security team:**
- "All logs go to Security-Logging account"
- "You can't access applications in other accounts"
- "GuardDuty findings are centralized in Security-Tools"
- Reaction: Nodding ("This is what we've been asking for")

**Operations team:**
- "You manage Production accounts"
- "Developers manage their own Dev accounts"
- "SCPs prevent dangerous actions even for admins"
- Reaction: Smiling ("Finally, some peace")

**Tuesday-Wednesday: Go-live Verification**

Monitored all accounts for:
- CloudTrail logging operational: ✅
- GuardDuty running in all accounts: ✅
- Security Hub receiving findings: ✅
- All microservices functioning: ✅
- Zero customer impact: ✅

**Thursday: Customer Communication**

Sent email to customers:
```
"TechStartup has implemented enterprise-grade security infrastructure:
- Multi-account AWS organization with segregation of duties
- Automated threat detection and response
- Comprehensive audit logging and compliance monitoring
- Real-time security alerts and incident response

This further strengthens our commitment to your data security."
```

**Result:** 3 enterprise customers extended contracts based on security improvements

**Friday: Celebration**

Team gathering: "We went from a security disaster to enterprise-grade in 6 weeks!"

---

### Phase 4: 3 Months Post-Implementation

#### Results

**Security Improvements:**

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Security incidents/month | 3 | 0 | 100% reduction |
| MTTD (time to detect threat) | 4 hours | 2 minutes | 120x faster |
| False positives | 45% | 12% | 73% reduction |
| SLA compliance | 95% | 99.8% | +4.8% |

**Specific Prevented Incidents:**

1. **Incident 1: Compromised API Key**
   - Attacker tried to stop CloudTrail logging
   - SCP blocked it immediately
   - Incident detected in 2 minutes
   - Action taken: Rotated key, reviewed logs
   - Damage prevented: $50,000+ in potential cover-up

2. **Incident 2: Rogue Developer Process**
   - Accidentally developed for production instead of dev
   - Pushed code deleting data
   - SCP blocked DeleteTable in production
   - Code rejected before causing damage
   - Damage prevented: Data loss recovery ($100K+)

3. **Incident 3: Configuration Drift**
   - Non-prod account had overly permissive IAM roles
   - Developer could list customer data in prod
   - SCP prevented cross-account access
   - Issue identified and fixed
   - Damage prevented: Unauthorized data access

**Cost Impact:**

| Category | Monthly Cost | Notes |
|----------|--------------|-------|
| Organization infrastructure | $175 | CloudTrail, S3, monitoring |
| Compute (moved from single account) | $3,000 | Same as before, just segregated |
| **Net cost increase** | **$150** | vs. previous single account |
| **Prevented loss (1 incident average)** | **$50,000** | Per security incident |
| **ROI** | **333x** | Monthly benefit from incident prevention |

**Team Feedback:**

- **Developers:** "I can experiment in my account without breaking production" ⭐⭐⭐⭐⭐
- **Security team:** "Finally, we have visibility and control" ⭐⭐⭐⭐⭐
- **Operations:** "SCPs do the work for us, giving us peace" ⭐⭐⭐⭐⭐
- **CEO:** "Our enterprise customers are happier, risk is lower" ⭐⭐⭐⭐⭐

**Compliance Status:**

- ✅ SOC 2 audit: PASSED (segregation of duties)
- ✅ PCI-DSS audit: PASSED (customer data isolation)
- ✅ ISO 27001 audit: PASSED (change management)

**Retention Impact:**

- Lost customer #1 from before: Resold after security improvements ✅
- New contracts from 3 enterprises: Citing security infrastructure ✅
- Annual revenue impact: +$1.5M from improved security reputation

---

## 📊 Key Insights

### Why This Worked

1. **Executive Buy-in**
   - Showed ROI upfront (330x from incident prevention)
   - Proved no impact on operations (zero downtime migration)
   - Demonstrated compliance improvement

2. **Team Collaboration**
   - Developers got autonomy (own accounts)
   - Security got control (SCPs)
   - Operations got automation (policies)

3. **Proper Architecture**
   - Clear separation: Security, Production, Non-Production, Sandbox
   - Each team has domain and responsibility
   - Cross-cutting security via SCPs

4. **Enforcement Over Requests**
   - Instead of "please don't disable GuardDuty" (weak)
   - SCPs make it technically impossible (strong)
   - Frees teams to operate faster with safety

### What Would Have Happened Without Multi-Account

**Scenario: Data Breach (Simulated)**

```
Original single account:
- Attacker disables CloudTrail ✅ (Easy)
- Attacker deletes production databases ✅ (Easy)
- Attacker exfiltrates customer data ✅ (Easy)
- Evidence destroyed ✅ (Easy)
- Discovery: 3 months later on invoice (competitor notification)

With multi-account organization:
- Attacker disables CloudTrail ❌ (SCP blocks it)
- Attacker deletes production databases ❌ (SCP blocks it)
- Attacker exfiltrates data ❌ (Cross-account access denied)
- Evidence preserved ✅ (Immutable in Security-Logging account)
- Discovery: 2 minutes (GuardDuty alert)

Risk reduction: 99.8% (from multi-account isolation + SCPs)
```

---

## 🎓 Lessons for Your Implementation

### Lesson 1: Start with Why

**Why AWS Organizations?**
- Not "AWS best practice says so"
- But "We need to prevent incidents and pass audits"
- Make it relevant to your business

### Lesson 2: Security Isn't Restrictive

**False:** SCPs = slower development

**True:** SCPs prevent catastrophic mistakes, enabling faster development safely

```
Without SCPs:
- Developer makes change
- Operations approval (1 day)
- Security review (1 day)
- Testing (1 day)
- Go-live (1 day)
- Recovery if incident (3 days)
Total: 7 days + risk

With SCPs:
- Developer makes change in own account
- Automated testing (minutes)
- Goes live in dev instantly
- Safer to promote because SCPs caught mistakes
- Go-live: 1 day
- Recovery never needed (SCP prevented it)
Total: 1 day + zero risk
```

### Lesson 3: Build Incrementally

**Week 1:** Organization + OUs (foundation)  
**Week 2:** Member accounts (structure)  
**Week 3:** Migrate one app (proof of concept)  
**Week 4:** Implement SCPs (safety)  
**Week 5:** Monitoring (visibility)  
**Week 6:** Team training (adoption)  

Don't try to do everything at once.

### Lesson 4: Communicate Constantly

**Week 1:** "We're restructuring for security"  
**Week 2:** "Migration plan in place, zero downtime expected"  
**Week 3:** "Migration complete, no incidents"  
**Week 4:** "SCPs prevent mistakes (testing now)"  
**Week 5:** "Monitoring fully operational"  
**Week 6:** "Developers can now move faster safely"  

Narrative matters as much as execution.

---

## 🚀 What TechStartup Did Next

**Month 4:** Implemented AWS SSO (Single Sign-On) for credential management  
**Month 5:** Added Attack Simulation account for security testing  
**Month 6:** Implemented automated incident response with Lambda  
**Month 12:** Achieved SOC 2 Type II certification  

---

## Your Turn

**Question:** What would YOUR organization's OU structure look like?

Think about:
- How many teams do you have?
- What environments do you need? (dev, staging, prod, etc.)
- What compliance requirements? (HIPAA, SOC 2, PCI-DSS, etc.)
- What shared services? (logging, monitoring, security tools)

**Answer:** This depends on your organization, which is why the architecture is customizable.

---

## 📈 Final Metrics

**6-Month Post-Implementation Review:**

```
Security Posture:
- MTTD: 4 hours → 2 minutes (99.95% improvement)
- Incidents prevented: 5 major + 20 minor
- Audit compliance: 3 standards passed

Financial Impact:
- Infrastructure cost: +$150/month
- Revenue from enterprise customers: +$1.5M/year
- Loss from security incidents: $0 (vs. $50K/incident history)
- ROI: 10,000x annually

Team Satisfaction:
- Developer velocity: +20%
- Security team morale: +300%
- Operations reliability: +99.8%

Customer Impact:
- Lost customers regained: 1
- New customers from security reputation: 3
- Support tickets about security: -95%
```

**Conclusion:**

What started as a security crisis became an organizational competitive advantage. The multi-account architecture with SCPs didn't just fix the problem—it transformed how the team thinks about security, enabling faster development with stronger guardrails.

---

## 📚 Case Study Takeaways

| Aspect | Before | After | Lesson |
|--------|--------|-------|--------|
| **Incident prevention** | Reactive (after-the-fact) | Proactive (prevented) | SCPs are preventive, not just detective |
| **Team trust** | Ops/Dev friction | Collaboration | Security enables teams, doesn't restrict them |
| **Compliance** | Failed audits | Passed audits | Architecture = compliance automation |
| **Cost control** | Surprises | Predictable | SCPs prevent expensive mistakes |
| **Speed** | Slow (approvals) | Fast (autonomous) | Safety enables speed |

---

**Case Study Status:** ✅ COMPLETE  
**Module:** 1 - AWS Organizations & Multi-Account Security  
**Applicability:** Any organization with 5+ AWS accounts, security/compliance needs, or growth plans

---

*This case study is based on common enterprise AWS patterns and real-world implementations. Names and specific numbers have been fictionalized for educational purposes, but the architecture and outcomes reflect actual production deployments.*
