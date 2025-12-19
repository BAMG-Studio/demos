# Module 10: IAM Portfolio & Interview Materials - Job-Ready Materials

## 🎯 Three Portfolio Projects for Your Resume

### Project 1: Enterprise Multi-Account IAM Architecture Design

**Project Title:** Enterprise Identity & Access Management Architecture

**Business Context:**
Your company is scaling from 1 AWS account to 10 accounts across multiple teams and regions. You need to design a secure, manageable IAM structure that:
- Prevents unauthorized cross-account access
- Simplifies access management across teams
- Maintains audit trail
- Supports federation with corporate directory
- Implements least privilege throughout

**What You Build:**

```
Architecture Design Document:
├─ Current State Analysis
│  ├─ Single account (005965605891)
│  ├─ 50 IAM users
│  ├─ Manual access management
│  └─ No federation (passwords only)
│
├─ Proposed Multi-Account Structure
│  ├─ Management Account (billing, organization)
│  ├─ Dev Account (development team)
│  ├─ Staging Account (QA team)
│  ├─ Prod Account (production, limited access)
│  ├─ Security Account (monitoring, logs)
│  └─ Shared Services Account (tools, databases)
│
├─ Identity & Access Design
│  ├─ AWS SSO / Identity Center setup
│  ├─ Okta integration (federated auth)
│  ├─ Role architecture (by function, not by person)
│  ├─ Permission sets (Developer, Operator, Auditor)
│  └─ Cross-account trust policies
│
├─ Permission Boundaries
│  ├─ Developer boundary (can't touch IAM)
│  ├─ Operator boundary (can't delete in prod)
│  └─ Auditor boundary (read-only, all accounts)
│
├─ Security Controls
│  ├─ MFA requirements (by role)
│  ├─ CloudTrail centralization
│  ├─ GuardDuty implementation
│  └─ Access Analyzer automation
│
├─ Migration Plan
│  ├─ Phase 1: Set up new structure
│  ├─ Phase 2: Migrate 10% of users
│  ├─ Phase 3: Migrate 50% of users
│  ├─ Phase 4: Migrate 100% of users
│  └─ Phase 5: Decommission old setup
│
└─ Cost & Compliance
   ├─ AWS SSO cost: $0 (free with Organizations)
   ├─ Implementation effort: 40 hours
   ├─ Ongoing support: 5 hours/week
   ├─ Compliance: CIS AWS Foundations (Level 2)
   └─ ROI: 50% reduction in access management time
```

**How to Present:**

```
In interview:
  "I designed a multi-account IAM architecture for enterprise..."
  
  Problem: 50 users in single account, manual access, no audit trail
  
  Solution: AWS Organizations + AWS SSO + Okta federation
    → 6 accounts (dev, staging, prod, security, shared, mgmt)
    → Permission sets (Developer, Operator, Auditor)
    → Automated provisioning (JIT via Okta)
    → Centralized audit trail (CloudTrail to S3)
  
  Impact:
    ✓ 80% reduction in access requests
    ✓ Instant access revocation (vs 1 week manual)
    ✓ Full compliance audit capability
    ✓ Multi-account management simplified

Technical detail (if interviewer asks):
  "Permission boundaries were key. Developer role had full EC2/S3
   permissions, but boundary blocked IAM, preventing accidental
   privilege escalation. If dev credentials compromised, scope limited."
```

**Resume Bullet:**
```
✓ Architected multi-account IAM solution for 10+ AWS accounts
  using AWS Organizations, SSO, and Okta federation; enabled 50
  users across 6 accounts with automated provisioning (JIT),
  reducing access request cycle time from 1 week to minutes;
  implemented permission boundaries and least-privilege policies
  to prevent privilege escalation; achieved CIS Level 2 compliance
```

---

### Project 2: Automated IAM Compliance & Remediation Pipeline

**Project Title:** Continuous IAM Compliance Monitoring & Auto-Remediation

**Business Problem:**
IAM policies drift over time:
- Users accumulate permissions (access creep)
- Unused keys not rotated
- Old MFA devices not updated
- Policies not reviewed regularly
- No automation to enforce standards

**What You Build:**

```
Lambda-Based Automation Pipeline:
│
├─ Daily Audit Jobs
│  ├─ Check for unused access keys (> 90 days old)
│  │  └─ Action: Disable if unused, notify user
│  │
│  ├─ Check for unrotated access keys
│  │  └─ Action: Create new key, email to user
│  │
│  ├─ Check for users without MFA
│  │  └─ Action: Send reminder email, require setup in 7 days
│  │
│  └─ Check for unused IAM users (no login > 90 days)
│     └─ Action: Disable, flag for deletion after 30 days
│
├─ Weekly Analysis Jobs
│  ├─ Access Analyzer - find overly permissive access
│  │  └─ Action: Notify owner, request explanation
│  │
│  ├─ Policy simulator - test high-risk actions
│  │  └─ Action: Verify "Who can delete prod database?"
│  │
│  └─ IAM credential report - aggregate findings
│     └─ Action: Generate executive summary
│
├─ Remediation Actions
│  ├─ Auto-disable: Unused keys, old users, failed MFA
│  ├─ Auto-rotate: Keys, MFA devices
│  ├─ Auto-notify: Owners, managers, security team
│  └─ Manual approval: For destructive actions (user deletion)
│
└─ Reporting
   ├─ Daily summary: What was fixed, what needs attention
   ├─ Weekly report: Trends, improvements, recommendations
   ├─ Monthly dashboard: Compliance scorecard
   └─ Quarterly review: Policy effectiveness
```

**Resume Bullet:**
```
✓ Engineered automated IAM compliance pipeline using Lambda,
  CloudWatch Events, and SNS; detects and remediates policy
  drift, unused keys, missing MFA, and inactive users; reduces
  manual compliance review time from 8 hours/week to 30 minutes
  via automated remediation; achieved 99.8% compliance score
```

---

### Project 3: Zero-Trust Cross-Account Access Implementation

**Project Title:** Secure Cross-Account Access with Zero-Trust Principles

**Business Problem:**
Partner companies need access to your S3 buckets:
- Partner A: Read customer data
- Partner B: Write transaction logs
- Partner C: Monthly reporting (time-limited)

**Resume Bullet:**
```
✓ Implemented zero-trust cross-account access architecture for
  3 partner companies with unique ExternalIds, IP restrictions,
  temporary credentials, and strict resource-level permissions;
  eliminated shared credentials (security risk) while maintaining
  full audit trail; reduced partner onboarding from 1 week to 1 day
```

---

## 💼 Interview Questions & Answers

### Question 1: "Tell us about a time you designed IAM policies"

**Good Answer:**
```
"I designed IAM policies for a development team that needed to
deploy to AWS. The team was small (3 developers), so initial
instinct was to give them admin access. But I implemented
least privilege instead:

Permissions they actually needed:
  - EC2: Start/stop instances (dev environment only)
  - S3: Upload/download build artifacts (dev bucket only)
  - CloudWatch: View logs (dev logs only)
  - CloudFormation: Deploy templates (dev stack only)

Permissions they didn't need:
  - RDS: Access to databases (DBAs handle that)
  - IAM: Create users or modify policies
  - Lambda: Invoke functions (not part of workflow)
  - Organization: Access to billing (finance team)

Implementation:
  - Created custom policy with specific actions
  - Scoped to development resources only
  - Added region restriction (us-east-1 dev only)
  - Tested in policy simulator before deployment

Result:
  - Developers could do their job (deploy code)
  - Had no unnecessary access (security reduced)
  - If credentials compromised, damage limited to dev env
  - Quarterly review caught creeping permissions, cleaned up

What I learned:
  - Every permission should have a business justification
  - Denying 'admin' doesn't mean 'can't work'
  - Regular reviews prevent access creep
  - Documentation is critical (why this permission?)"
```

### Question 2: "What's the difference between identity policies and resource policies?"

**Answer:**
```
"Great question. They work together:

Identity Policy:
  - Lives on: User, role, group
  - Controls: What that identity CAN do
  - Example: 'alice has permission to GetObject'

Resource Policy:
  - Lives on: S3 bucket, SQS queue, etc.
  - Controls: What can be done to THIS resource
  - Example: 'This bucket allows GetObject only from alice'

Why both?
  - Identity policies: Self-service, user/role level
  - Resource policies: Resource owner controls access
  - Cross-account access: Resource policy trusts other account
  - Public resources: Resource policy allows '*' principal"
```

### Question 3: "How do you handle credential rotation in production?"

**Answer:**
```
"Credential rotation is tricky in production. Here's how I handle it:

For long-term credentials (access keys):
  Challenge: Can't just disable old key (applications break)
  
  Solution (simultaneous rotation):
  1. Generate new access key
  2. Update all applications
  3. Monitor: Ensure old key isn't used anymore (CloudTrail)
  4. Deactivate old key (don't delete, keep for 7 days)
  5. Delete old key after 7 days confirmed no usage

For temporary credentials (STS):
  Challenge: Temporary credentials auto-expire (by design)
  
  Solution: Applications request new credentials before expiry
  - Lambda: Assume role on every function invocation
  - Long-running app: Refresh credentials every 30 minutes
  - EC2: Uses metadata service (auto-refreshes)
  
  Benefit: No rotation needed (they're temporary!)

Monitoring:
  - CloudTrail: Who rotated what, when
  - CloudWatch: Failed authentication attempts
  - Alerts: Rotation failures
  - Metrics: Days since last rotation"
```

---

## 🎓 Study Guide & Interview Tips

### Topics to Master

```
Must Know:
  ✓ Policy evaluation logic (allow, deny, conditions)
  ✓ Principal, Action, Resource, Condition
  ✓ AssumeRole mechanics (trust policy vs role policy)
  ✓ Permission boundaries
  ✓ Root account security
  ✓ MFA (why and how)
  ✓ Access keys vs STS tokens
  
Should Know:
  ✓ Cross-account access (ExternalId, trust)
  ✓ Federated authentication (SAML, OIDC)
  ✓ CloudTrail for audit
  ✓ Access Analyzer
  ✓ Credential rotation
  ✓ Session policies

Nice to Know:
  ✓ ABAC (attribute-based access control)
  ✓ AWS SSO / Identity Center
  ✓ GuardDuty IAM findings
  ✓ Custom policy templates
```

### Interview Success Tips

```
What Interviewers Care About:

1. You can explain policy evaluation
2. You understand real-world tradeoffs
3. You've actually designed and implemented this
4. You think like a security engineer

Green Flags to Show:

✅ "I implemented least privilege by..."
✅ "I automated credential rotation using..."
✅ "I detected anomalies with..."
✅ "I hardened the root account first..."
✅ "I used permission boundaries to..."
✅ "I audited policies using..."
```

---

**Congratulations on completing Module 10!**

You now have:
✅ 7 comprehensive IAM guides (39,000+ words)
✅ 3 portfolio projects you can build
✅ Interview Q&A with expert answers
✅ Real-world scenarios and best practices
✅ Job-ready resume bullets
✅ Implementation playbooks

**Next Module:** Module 11 - Threat Detection & Monitoring
