# Module 1: AWS Organizations & Multi-Account Security Architecture

## 🎯 Learning Objectives

By the end of this module, you will understand:
- ✅ Why multi-account AWS architecture is essential for security
- ✅ How AWS Organizations enable centralized governance
- ✅ Service Control Policies (SCPs) and their defensive power
- ✅ Organizational Unit (OU) design principles
- ✅ Cost considerations and best practices
- ✅ Real-world attack prevention through organizational controls

---

## 📚 Part 1: Foundational Concepts

### 1.1 What is AWS Organizations? (The Comprehensive Explanation)

#### **Technical Definition**
AWS Organizations is an AWS service that enables you to:
- Create and manage multiple AWS accounts within a centralized management interface
- Apply governance policies uniformly across all accounts
- Organize accounts into a tree-like hierarchy using Organizational Units (OUs)
- Consolidate billing across all member accounts
- Delegate administrative responsibilities while maintaining central control

#### **Layman's Explanation - The Corporate Analogy**

Imagine you run a large company with multiple divisions:

```
Corporate Headquarters (Management Account)
│
├── Finance Division (Finance OU)
│   ├── Accounting Department (Account)
│   └── Payroll Department (Account)
│
├── Engineering Division (Engineering OU)
│   ├── Backend Team (Account)
│   ├── Frontend Team (Account)
│   └── DevOps Team (Account)
│
└── Security Division (Security OU)
    ├── Threat Monitoring (Account)
    └── Compliance (Account)
```

The headquarters sets company-wide rules (like "all employees must use two-factor authentication"). Each division has a manager, but even the division manager must follow headquarters rules.

#### **Why This Matters for Defense**

In cybersecurity, a single AWS account is like a single office building. If someone breaks into that building, they can access everything. With AWS Organizations, you're building multiple secure buildings connected by a fortified central office.

**Real-World Attack Prevention:**
- If one account gets compromised, others remain secure
- Central policies prevent attackers from disabling security services in ANY account
- Compliance requirements apply automatically across all accounts
- Cost anomalies in one account don't affect others

---

### 1.2 Core Components of AWS Organizations

#### **Management Account (Root)**

**What it is:**
The master account that:
- Controls the entire organization
- Sets SCPs and policies
- Consolidates billing
- Cannot be removed from the organization

**Real-world analogy:**
Think of it as the CEO's office. Even the CEO has to follow company-wide security rules set by the board of directors.

**Security implication:**
Protect this account fiercely. If compromised, attackers control ALL member accounts.

**Best practice:**
- Use AWS SSO (Single Sign-On) for access
- Enable MFA on all users
- Use temporary credentials, not access keys
- Log all API calls to CloudTrail

**Cost:** $0 (no extra charge for AWS Organizations itself)

#### **Member Accounts**

**What they are:**
Separate AWS accounts managed by the organization
- Complete isolation from each other
- Own billing (but can be consolidated)
- Subject to organizational policies

**Real-world analogy:**
Branch offices that must follow headquarters rules but operate independently.

**Security implication:**
Separate accounts = compartmentalization = reduced blast radius if one is compromised.

**Examples in our course architecture:**
```
Organization: TRC-DevSecOps-Lab
├── Management (005965605891)
├── Security-Logging (for centralized logging)
├── Production (for live applications)
├── Development (for testing)
└── Sandbox (for attack simulations)
```

**Cost:** $0 per account (you pay for AWS services used, not the account itself)

#### **Organizational Units (OUs)**

**What they are:**
Logical containers for grouping accounts

**Real-world analogy:**
Departments in your company (Finance, Engineering, Marketing, Security)

**How they work:**
```
Root (Company-wide rules apply here)
├── Security OU (Strict rules: no data deletion, logging mandatory)
├── Production OU (Moderate rules: limited region access)
├── Development OU (Relaxed rules: more freedom to experiment)
└── Sandbox OU (Very relaxed: for testing and attacks)
```

**Security strategy:**
Different OUs = different policy sets = defense-in-depth

**Cost:** $0 (no charge for OUs)

---

### 1.3 Service Control Policies (SCPs) - Your Organizational Firewall

#### **What is an SCP?**

**Technical:**
A JSON policy document that defines the maximum permissions available to accounts or OUs. SCPs filter IAM permissions but do NOT grant permissions.

**Layman's Explanation - The Constitution Analogy:**

Imagine a country with federal law and state law:
- **Federal Law (SCP):** "No state can abolish the court system" - applies to ALL states
- **State Law (IAM):** "State X allows businesses with licenses" - specific to that state

Even if a state Governor wanted to abolish courts, they CAN'T because federal law prevents it.

Similarly, even if an AWS account administrator has all IAM permissions, they CANNOT disable CloudTrail if an SCP forbids it.

#### **Key Characteristics of SCPs:**

| Characteristic | Meaning |
|---|---|
| **Denies First** | SCPs are restrictive, not permissive |
| **Always Apply** | Even administrators can't bypass SCPs |
| **Inherited** | Applied to OU applies to all child accounts |
| **Allows Later** | After SCP allows, IAM policies can grant |
| **Works Together** | SCP + IAM = Actual permission |

**Visual Example:**

```
SCP Permission: "Can you delete CloudTrail?"
├── SCP says "DENY" → Result: No (BLOCKED)
├── SCP says "ALLOW" + IAM says "DENY" → Result: No (IAM blocks)
├── SCP says "ALLOW" + IAM says "ALLOW" → Result: Yes (ALLOWED)
└── SCP says "DENY" + IAM says "ALLOW" → Result: No (SCP blocks)
```

---

### 1.4 How SCPs Prevent Attacks

#### **Scenario 1: The Rogue Administrator**

**Situation:**
An employee's AWS access key is compromised. The attacker gains access to an account with "Administrator" IAM policy.

**Without SCP:**
The attacker can:
- Disable CloudTrail (destroy audit logs)
- Delete AWS Config rules (hide misconfigurations)
- Disable GuardDuty (hide threats)
- Delete or modify data

Result: Complete cover-up, no forensic evidence

**With SCP (Baseline-Security-Protection):**
The attacker CANNOT:
- Disable CloudTrail (SCP blocks it)
- Delete AWS Config (SCP blocks it)
- Disable GuardDuty (SCP blocks it)

Result: Attacker's actions are fully logged and visible

#### **Scenario 2: Accidental Configuration Deletion**

**Situation:**
A developer accidentally writes code that deletes production security configurations.

**Without SCP:**
- Code runs → Production security disabled → Incident!

**With SCP (Baseline-Security-Protection):**
- Code runs → SCP blocks the deletion → Error message
- Developer notices the error, fixes the code
- No incident

#### **Scenario 3: Insider Threat - Cost Manipulation**

**Situation:**
A disgruntled employee tries to spin up 1000 EC2 instances to incur massive costs.

**Without SCP:**
- Instances are created → Large bill → Company loses money

**With SCP (Cost-Control-Policy):**
- Instances are created in any region? → Depends on SCP
- If SCP restricts to only us-east-1, attempt in us-west-2 fails
- SCP can limit EC2 instance types to only cost-effective options

Result: Cost is controlled at the organizational level

---

## 📊 Part 2: Multi-Account Architecture Design

### 2.1 Why Multi-Account? (Defense-In-Depth Strategy)

#### **Single Account Architecture - The Risk**

```
┌─────────────────────────────────────┐
│    One AWS Account (005965605891)   │
│  ┌──────────────────────────────┐   │
│  │ Production Apps              │   │
│  │ Development Environment       │   │
│  │ Security Tools               │   │
│  │ Logging & Audit              │   │
│  │ Sensitive Data               │   │
│  │ Public-facing API            │   │
│  └──────────────────────────────┘   │
│                                      │
│  Problem: If compromised,            │
│  everything is exposed               │
└─────────────────────────────────────┘
```

**Risks:**
- Blast radius: 100% of infrastructure
- Compliance violations: Everything in one basket
- Noisy logs: Hard to identify suspicious activity
- Shared quotas: Developer testing affects production

#### **Multi-Account Architecture - The Solution**

```
┌──────────────────────────────────────────────────────────┐
│         AWS Organization (Root Account)                   │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │         Security OU (Isolated & Immutable)         │ │
│  │  ┌──────────────────────┐  ┌──────────────────────┐ │ │
│  │  │ Logging Account      │  │ Security-Tools Acct  │ │ │
│  │  │ • CloudTrail         │  │ • GuardDuty          │ │ │
│  │  │ • S3 Audit Logs      │  │ • Security Hub       │ │ │
│  │  │ • Config Rules       │  │ • Inspector          │ │ │
│  │  │ • No App Access      │  │ • Macie              │ │ │
│  │  └──────────────────────┘  └──────────────────────┘ │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │      Production OU (Strictest Controls)            │ │
│  │  ┌──────────────────────────────────────────────┐   │ │
│  │  │ Production Account (Prod-App)                │   │ │
│  │  │ • Live Applications                          │   │ │
│  │  │ • Customer Data                              │   │ │
│  │  │ • High Security SCPs                         │   │ │
│  │  │ • Read-only logging to Logging Account       │   │ │
│  │  └──────────────────────────────────────────────┘   │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │    Non-Production OU (Moderate Controls)           │ │
│  │  ┌──────────────────────┐  ┌──────────────────────┐ │ │
│  │  │ Dev Account          │  │ Test Account         │ │ │
│  │  │ • Code Testing       │  │ • QA Testing         │ │ │
│  │  │ • Feature Dev        │  │ • Staging Apps       │ │ │
│  │  │ • Medium SCPs        │  │ • Limited Data       │ │ │
│  │  └──────────────────────┘  └──────────────────────┘ │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │      Sandbox OU (Minimal Restrictions)             │ │
│  │  ┌──────────────────────────────────────────────┐   │ │
│  │  │ Sandbox Account (AttackSim Lab)              │   │ │
│  │  │ • Attack Simulations                         │   │ │
│  │  │ • Purple Team Testing                        │   │ │
│  │  │ • Malicious Traffic Testing                  │   │ │
│  │  │ • Minimal SCPs                               │   │ │
│  │  │ • Isolated from other accounts               │   │ │
│  │  └──────────────────────────────────────────────┘   │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

**Benefits:**

1. **Blast Radius Reduction**
   - Production compromised? Development still safe
   - Developers can experiment without affecting production
   - Cost anomaly in dev doesn't affect billing

2. **Compliance Satisfaction**
   - Each account's logs are isolated
   - Easier to prove separation of duties
   - Audit trails are clean and focused

3. **Security Control**
   - Each OU can have different policies
   - Production can be locked down tight
   - Dev can be relaxed for productivity

4. **Operational Efficiency**
   - Developers work independently
   - No noisy logs from dev interfering with security monitoring
   - Clear resource ownership

---

### 2.2 Recommended OU Structure for DevSecOps

#### **Structure #1: Role-Based (Recommended for most organizations)**

```
Root
├── Security
│   ├── Security-Logging
│   └── Security-Tools
├── Production
│   └── Production-Apps
├── NonProduction
│   ├── Development
│   └── Testing
└── Sandbox
    └── AttackSimulation
```

**Use cases:**
- Clear separation of concerns
- Security teams manage one set of OUs
- Development teams manage their own
- Easy to audit and manage

#### **Structure #2: Environment-Based (Alternative)**

```
Root
├── Management
│   └── Org-Management
├── Production
│   ├── Prod-Security
│   └── Prod-Apps
├── Development
│   ├── Dev-Security
│   └── Dev-Apps
└── Sandbox
    └── Testing
```

**Use cases:**
- Each environment is isolated
- Easy to mirror production in dev
- Better for organizations with separate teams per environment

#### **Our Course Architecture (Structure #1)**

We'll use the role-based approach because it's industry-standard for DevSecOps:

```
AWS Organization (Account 005965605891 - Management)
│
├── SECURITY OU (Immutable, Read-only for most)
│   ├── Security-Logging-Account
│   │   - CloudTrail (all logs from all accounts)
│   │   - S3 audit logging
│   │   - VPC Flow Logs aggregation
│   │   - No applications deployed
│   │   - Minimal IAM access (read-only)
│   │
│   └── Security-Tools-Account
│       - GuardDuty (threat detection)
│       - Security Hub (centralized findings)
│       - Inspector (vulnerability scanning)
│       - AWS Config (compliance checking)
│       - No applications deployed
│
├── PRODUCTION OU (Strictest Controls)
│   └── Production-Apps-Account
│       - Live applications
│       - Customer data
│       - Tightest SCPs
│       - Read-only access to logs (cannot delete)
│
├── NON-PRODUCTION OU (Moderate Controls)
│   ├── Development-Account
│   │   - Development builds
│   │   - Test data only (not production)
│   │   - Relaxed controls for productivity
│   │
│   └── Test-Account
│       - QA testing
│       - Staging applications
│       - Limited data sets
│
└── SANDBOX OU (Minimal Restrictions)
    └── AttackSimulation-Account
        - Attack simulation tests
        - Purple team operations
        - Controlled malware execution
        - Isolated from all other accounts
```

---

## 🛡️ Part 3: Service Control Policies - The Defensive Arsenal

### 3.1 SCP Types and When to Use Them

#### **Type 1: Baseline Security Protection (Root OU)**

**Purpose:**
Apply to entire organization - prevents disabling essential security services

**Protected services:**
- CloudTrail (audit logging)
- AWS Config (compliance tracking)
- GuardDuty (threat detection)
- Security Hub (findings aggregation)
- CloudWatch (monitoring)

**SCP Template:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyDisableCloudTrail",
      "Effect": "Deny",
      "Action": [
        "cloudtrail:StopLogging",
        "cloudtrail:DeleteTrail",
        "cloudtrail:UpdateTrail"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyDisableGuardDuty",
      "Effect": "Deny",
      "Action": [
        "guardduty:DeleteDetector",
        "guardduty:DeleteMembers",
        "guardduty:DisassociateFromMasterAccount"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyDisableSecurityHub",
      "Effect": "Deny",
      "Action": [
        "securityhub:DeleteInvitations",
        "securityhub:DisableSecurityHub",
        "securityhub:DisassociateFromMasterAccount"
      ],
      "Resource": "*"
    }
  ]
}
```

**Why this matters:**
If attacker gets into any account, they CANNOT cover their tracks by disabling logging.

**Cost impact:** $0 (SCPs are free)

#### **Type 2: Cost Control Policy (All OUs)**

**Purpose:**
Prevent expensive configurations

**Prevents:**
- Launching in expensive regions
- Using expensive instance types
- Uncontrolled multi-region replication

**SCP Template:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RestrictExpensiveRegions",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": [
            "us-east-1",
            "us-west-2"
          ]
        }
      }
    },
    {
      "Sid": "RestrictExpensiveInstances",
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances"
      ],
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "StringLike": {
          "ec2:InstanceType": [
            "p3.*",
            "p4.*",
            "x1.*",
            "x2.*"
          ]
        }
      }
    }
  ]
}
```

**Why this matters:**
Prevents accidental $10,000/day instance from running

**Cost impact:** $0 (SCPs are free) but saves thousands on EC2

#### **Type 3: Production Protection Policy (Production OU only)**

**Purpose:**
Strict controls for production environment

**Prevents:**
- Modifying production resources
- Deleting production data
- Disabling backups
- Changing IAM in production

**SCP Template:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyProductionDeletion",
      "Effect": "Deny",
      "Action": [
        "rds:DeleteDBInstance",
        "dynamodb:DeleteTable",
        "s3:DeleteBucket",
        "elasticache:DeleteCacheCluster"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:PrincipalArn": "arn:aws:iam::*:root"
        }
      }
    },
    {
      "Sid": "DenyIAMChangesInProd",
      "Effect": "Deny",
      "Action": [
        "iam:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "prod"
        }
      }
    }
  ]
}
```

**Why this matters:**
Prevents accidental deletion of production data or misconfiguration of security

**Cost impact:** $0 (prevents millions in potential data loss)

---

### 3.2 SCP Attachment Strategy

**Recommended Attachment Pattern:**

```
Root OU
├─ Attach: Baseline-Security-Protection (applies to all)
├─ Attach: Cost-Control-Policy
└─ Attach: General-Governance-Policy

Production OU
├─ Attach: Production-Protection-Policy
└─ Attach: Resource-Lock-Policy

Non-Production OU
├─ Attach: Development-Allowance-Policy
└─ Attach: Tagging-Requirement-Policy

Sandbox OU
└─ Attach: Minimal-Restrictions-Policy
```

**Inheritance example:**
```
Baseline-Security (Root) + Cost-Control (Root) + Production-Protection (Prod OU)
                        = Combined effective policy for Production account
```

---

## 💰 Part 4: Cost Analysis

### 4.1 AWS Organizations Cost Breakdown

| Service | Cost | Notes |
|---------|------|-------|
| AWS Organizations | FREE | No charge for service itself |
| Management Account | Variable | Pay for AWS services used |
| Member Accounts | Variable | Pay for AWS services used |
| Service Control Policies | FREE | No charge for SCPs |
| CloudTrail (Organizational Trail) | $2.00 per 100K events | Logs from all accounts |
| AWS Config | $3.00 per rule/month | Aggregated across org |
| GuardDuty | $0.02 per million events | 30-day free trial per account |
| Security Hub | $5.00 per account/month | Flat rate for findings |

### 4.2 Estimated Monthly Cost for Course Architecture

```
Logging Account:
  - CloudTrail: $5/month (estimated)
  - S3 Storage: $10/month
  - Config: $15/month
  - Total: $30/month

Security-Tools Account:
  - GuardDuty: $10/month
  - Security Hub: $5/month
  - Inspector: $5/month
  - Total: $20/month

Production Account:
  - 1 small EC2: $15/month
  - RDS (small): $20/month
  - Total: $35/month

Development Account:
  - 1 small EC2: $15/month
  - Total: $15/month

Test Account:
  - Minimal resources
  - Total: $5/month

Sandbox Account:
  - Minimal, turned off when not in use
  - Total: $0-5/month

TOTAL ESTIMATED: $100-110/month
```

**Cost optimization tips:**
1. Turn off sandbox when not testing
2. Use smaller instances in non-production
3. Use AWS free tier where possible
4. Set up budget alerts to catch anomalies
5. Delete unused resources weekly

---

## 🎓 Key Takeaways

### **Why This Matters for Defense:**

1. **Attackers can't disable logging** - SCPs prevent it organization-wide
2. **Blast radius is limited** - One compromised account doesn't expose everything
3. **Compliance is automatic** - Policies apply without manual enforcement
4. **Defense-in-depth** - Multiple layers of protection
5. **Incident response is easier** - Issues are compartmentalized

### **Real-World Scenarios You Can Now Defend Against:**

| Threat | Defense |
|--------|---------|
| Attacker disables CloudTrail | SCP blocks it immediately |
| Malware spreads from dev to prod | Account isolation stops it |
| Rogue admin deletes data | Different account = different access |
| Cost anomaly in dev | Production account unaffected |
| Regulatory audit | Logs are clean and isolated per environment |

---

## 📋 Checklist: Before Moving to Next Module

- [ ] Understand what AWS Organizations is
- [ ] Know the difference between Management and Member accounts
- [ ] Understand how SCPs work (Deny-based, inherited, don't grant)
- [ ] Know why multi-account architecture is more secure
- [ ] Understand OU hierarchy and inheritance
- [ ] Know the main SCP types (baseline, cost, production, sandbox)
- [ ] Can calculate monthly costs for your architecture
- [ ] Ready to implement in Module 2

---

## 🔗 References & Further Reading

### Official AWS Documentation
- [AWS Organizations User Guide](https://docs.aws.amazon.com/organizations/)
- [Service Control Policies](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html)
- [Best Practices for AWS Organizations](https://aws.amazon.com/blogs/security/best-practices-for-aws-organizations/)

### Third-Party Resources
- [Prowler - AWS Security Assessment](https://prowler.pro/)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)

---

**Next Module:** Module 2 - Identity & Access Management (IAM) - The foundation of all AWS security

**Estimated Study Time:** 2-3 hours
**Hands-on Lab Time:** 2-3 hours
**Total Module Time:** 4-6 hours

---

*Course Version:* 1.0 | *Last Updated:* 2024 | *Status:* Production Ready
