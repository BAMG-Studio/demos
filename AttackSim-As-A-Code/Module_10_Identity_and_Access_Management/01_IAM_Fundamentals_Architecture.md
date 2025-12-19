# Module 10: IAM Fundamentals & Architecture - Complete Deep Dive

## 📚 What is IAM (Identity & Access Management)?

### Technical Definition
Identity & Access Management (IAM) is the AWS service that controls **who** (principals) can **do what** (actions) **on which resources** (resources) **under what conditions** (conditions). It's implemented through a policy evaluation engine that checks policies when a principal attempts an AWS API call.

### Layman Analogy: Bank Teller Access Control

**Scenario:** Securing a bank with employees at different levels:

```
Who?         → Identity (Teller, Manager, Custodian)
Do What?     → Actions (Withdraw cash, approve loans, clean floors)
Which Resources? → Resources (Customer accounts, vault, lobby)
Conditions?  → Context (Business hours only, max withdrawal $10K, etc.)

Without IAM:
❌ Everyone has access to everything
❌ Cannot track who did what
❌ Compromised employee = entire bank at risk

With IAM:
✅ Teller: Can withdraw < $10K during business hours
✅ Manager: Can approve loans and withdraw < $100K
✅ Custodian: Can only access cleaning supplies
✅ Everything logged (CloudTrail = security camera)
✅ Compromised teller only affects customer accounts, not vault
```

### Why IAM Matters for Security

**Statistics:**
- 80% of cloud breaches involve compromised credentials
- Average cost of credential compromise: $4.3M
- Organizations with strong IAM: 60% lower breach cost
- NIST/CIS/SOC2 all require IAM controls

**Real Incident Example:**
```
2019 Capital One Breach:
- Root cause: Overly permissive IAM role on EC2 instance
- Attacker: Compromised EC2, used role credentials
- Impact: 100 million customer records stolen
- Cost: $750M settlement + reputation damage

Prevention:
✅ EC2 should NOT have admin credentials
✅ EC2 should only have S3 read access (not capital_one_customers bucket)
✅ Permission boundaries would have prevented it
```

---

## 🏗️ IAM Architecture - How It Works

### The Five Building Blocks

```
     User/Role/Service
     (Principal)
            ↓
     [Makes AWS API Call]
            ↓
     IAM Policy Engine
     (Evaluates policies)
            ↓
     [Checks: User policies, Resource policies, Permission boundaries, Session policies]
            ↓
     Allow or Deny?
            ↓
     [Action executed or blocked]
            ↓
     [CloudTrail logs: Success or Denial]
```

### Core Concepts

#### 1. Principal
**Who** is trying to perform the action?

Types:
- **IAM User:** Individual human (alice@company.com)
- **IAM Role:** Assumed identity (EC2 instance, Lambda, service, person)
- **Root Account:** Account owner (never use for daily work!)
- **Federated User:** External identity (from company directory)
- **Service Principal:** AWS service (Lambda, EC2, RDS, etc.)

Example:
```
Principal ARN: arn:aws:iam::005965605891:user/peter
Principal ARN: arn:aws:iam::005965605891:role/EC2-Application-Role
Principal ARN: arn:aws:iam::005965605891:root
Principal ARN: arn:aws:sts::005965605891:assumed-role/SwitchRole/session-name
```

#### 2. Action
**What** is the principal trying to do?

Format: `service:action`

Examples:
```
s3:GetObject       → Read S3 object
s3:PutObject       → Write S3 object
s3:*               → All S3 actions
iam:CreateUser     → Create IAM user
ec2:StartInstances → Start EC2 instance
```

#### 3. Resource
**Which resource** is being accessed?

Format: AWS ARN (Amazon Resource Name)

Examples:
```
arn:aws:s3:::my-bucket                    → S3 bucket
arn:aws:s3:::my-bucket/*                  → All objects in bucket
arn:aws:s3:::my-bucket/documents/*        → Objects in documents folder
arn:aws:ec2:us-east-1:005965605891:instance/i-1234567890abcdef0  → EC2 instance
arn:aws:iam::005965605891:user/alice      → IAM user
```

#### 4. Condition
**Under what conditions** is the action allowed?

Examples:
```
IpAddress              → Only from specific IP range
DateGreaterThan        → Only after specific date
StringEquals           → Only in specific region
Bool                   → Require MFA
```

Example Policy with Conditions:
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::my-bucket/*",
    "Condition": {
      "IpAddress": {
        "aws:SourceIp": "72.21.198.0/24"  // Only from office IP
      },
      "Bool": {
        "aws:MultiFactorAuthPresent": "true"  // Require MFA
      }
    }
  }]
}
```

#### 5. Effect
**Allow** or **Deny** the action

- **Allow:** Principal CAN perform action (if no explicit deny)
- **Deny:** Principal CANNOT perform action (explicit denies always win)

---

## 🔑 IAM Identities

### 1. IAM Users

**What:** Individual person's AWS account (like a username/password combo)

**When to use:** Development, testing, learning

**When NOT to use:** Production, shared credentials, automated services

**Best Practices:**
```
✅ One user per person (alice, bob, charlie)
✅ Strong passwords (min 14 characters, special chars, numbers)
✅ MFA enabled (Multi-Factor Authentication)
✅ Access keys rotated every 90 days
✅ No hardcoded credentials in code

❌ Shared users (dev-user, admin-shared)
❌ Console and programmatic access together (pick one or the other)
❌ Root account for daily work
❌ Credentials in code/GitHub/email
❌ Access keys older than 90 days
```

**Creating IAM User (Console):**

```
IAM Console → Users → "Create User"

Name: alice
  Description: Software developer for project X
  Tags:
    - Department: Engineering
    - Project: ProjectX

Access Type:
  ☑ Console access (password login)
  ☑ Programmatic access (access key for API/CLI)

Console Password:
  ☑ Autogenerate → share with user ONE TIME
  ☑ Custom → have user set their own

Require MFA:
  ☑ YES (most important!)

Attach Policies:
  → Don't attach yet, we'll use roles instead
```

**Attaching Policies to User:**

```
Three ways to grant permissions:
1. Direct: Attach policy directly to user
2. Groups: Add user to group (group has policies)
3. Roles: Have user assume role (best for cross-account)
```

**Least Privilege Example:**

```json
Developer needs to:
✅ Develop in AWS Console
✅ Deploy code via CI/CD
✅ View logs in CloudWatch
❌ Should NOT: Access databases, delete resources, modify IAM

Policy:
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeSecurityGroups",
        "ec2-messages:GetMessages",
        "ssm:StartSession",
        "ssm:GetConnectionStatus"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"  // Only dev region
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:us-east-1:005965605891:log-group:/aws/lambda/*"
    }
  ]
}
```

### 2. IAM Groups

**What:** Collection of users who need the same permissions

**Why:** Instead of attaching policy to 100 individual users, attach to 1 group

**Example:**

```
Group: Developers
  - Members: alice, bob, charlie
  - Policies: Developer-Access (S3, EC2, CloudWatch)

When alice joins dev team:
  → Add to group
  → Automatically gets all permissions
  → No need to attach policies individually

When alice leaves:
  → Remove from group
  → Loses all permissions
  → Clean, auditable
```

**Creating Group (Console):**

```
IAM Console → Groups → "Create Group"

Name: Developer-Team
Description: All software developers

Attach Policies:
  + AWSCodeBuildAdminAccess (build/deploy)
  + CloudWatchAgentServerPolicy (monitoring)
  + AmazonS3ReadOnlyAccess (read code repos)
  + Custom: DeveloperConsoleAccess (limited EC2, Lambda, etc.)

Add Members:
  → alice
  → bob
  → charlie
```

### 3. IAM Roles

**What:** Temporary identity that a principal can assume (like wearing a different hat)

**Why:** 
- Grant permissions without sharing credentials
- EC2/Lambda/Services can access other AWS services
- Cross-account access
- Federated users
- Emergency access (break-glass)

**How They Work:**

```
User: alice (has no permissions normally)
       ↓
  [Assumes role: SwitchRole-Admin]
       ↓
  [Gets temporary credentials: Access Key + Secret + Session Token]
       ↓
  [Can now perform admin actions]
       ↓
  [Temporary credentials expire in 1 hour]
       ↓
  [alice back to normal permissions]
```

**Common Use Cases:**

1. **EC2 Instance Access to S3:**
```
EC2 instance → Assume role → S3 access
No credentials stored on instance (safer!)
```

2. **Cross-Account Access:**
```
User in Account A → Assumes role in Account B → Access Account B resources
```

3. **Federation/SSO:**
```
User logs in with company directory (Okta)
  → Gets temporary AWS credentials
  → Can access AWS Console/CLI
  → No AWS password needed
```

4. **Emergency Access:**
```
Normal user (limited permissions)
  → Requires approval + MFA
  → Assumes BreakGlass-Admin role (30 min limit)
  → Can handle emergency
  → Actions fully logged
```

**Creating Role (Console):**

```
IAM Console → Roles → "Create Role"

Trust Entity: EC2 (for EC2 instances)
Or: Another AWS Account
Or: SAML for federation
Or: Custom trust policy

Name: EC2-Application-Role
Description: Role for app servers to access S3

Add Permissions:
  + s3:GetObject on arn:aws:s3:::app-data/*
  + logs:PutLogEvents on arn:aws:logs:*

Add Trust Policy (Who can assume this role):
  - EC2 service
  - Specific IAM principal
  - Cross-account user
```

---

## 📋 IAM Policies - The Detail

### Policy Structure

```json
{
  "Version": "2012-10-17",           // Policy language version
  "Statement": [                      // Array of permissions
    {
      "Sid": "DescribeEC2",          // Optional identifier
      "Effect": "Allow",             // Allow or Deny
      "Action": "ec2:Describe*",     // What actions
      "Resource": "*",               // On which resources
      "Condition": {}                // Under what conditions (optional)
    }
  ]
}
```

### Policy Evaluation Logic

When principal attempts action:

```
1. Check EXPLICIT DENY (from any policy)
   → If found: DENIED (no exceptions!)
   → If not found: Continue

2. Check ORGANIZATION SCP (Service Control Policy)
   → Blocks action? → DENIED
   → Allows action? → Continue

3. Check PERMISSION BOUNDARIES
   → Restricts action? → DENIED
   → Allows action? → Continue

4. Check IDENTITY POLICIES (attached to user/role/group)
   → Explicit Allow found? → ALLOWED
   → Only Deny found? → DENIED
   → Nothing found? → DENIED (default deny)

5. Check RESOURCE POLICIES (S3 bucket policy, etc.)
   → Allow or Deny
   → Applied to resource

6. Check SESSION POLICIES (if assuming role with additional restrictions)
   → Applied on top of role policies

Final Result: ALLOWED or DENIED
CloudTrail: Logged (for compliance/security)
```

**Decision Tree Example:**

```
Alice tries: s3:PutObject on mybucket/documents/*

Step 1: Organization has explicit deny on s3:PutObject
  → DENIED (stops here, no need to continue)

Bob tries: s3:GetObject on mybucket/public/*

Step 1: No explicit deny
Step 2: SCP allows S3 actions
Step 3: No permission boundary
Step 4: Bob's attached policy has Allow for s3:GetObject on mybucket/public/*
  → ALLOWED

Charlie tries: iam:CreateUser

Step 1: No explicit deny
Step 2: SCP allows IAM actions
Step 3: Permission boundary restricts to s3:* only
  → Conflicts with iam:CreateUser
  → DENIED
```

### Common Policy Actions

```
S3:
  s3:GetObject          → Read object
  s3:PutObject          → Write object
  s3:DeleteObject       → Delete object
  s3:ListBucket         → List objects
  s3:*                  → All S3 actions

EC2:
  ec2:DescribeInstances → List instances
  ec2:StartInstances    → Start instance
  ec2:StopInstances     → Stop instance
  ec2:TerminateInstances → Delete instance
  ec2:*                 → All EC2 actions

IAM:
  iam:CreateUser        → Create user
  iam:DeleteUser        → Delete user
  iam:AttachUserPolicy  → Add permission
  iam:*                 → All IAM actions

CloudWatch Logs:
  logs:CreateLogGroup   → Create log group
  logs:CreateLogStream  → Create log stream
  logs:PutLogEvents     → Write log events
```

### Wildcard Usage

```
s3:*                  → All S3 actions (too broad!)
s3:Get*              → GetObject, GetBucketVersioning, etc.
s3:*Bucket*          → All bucket-related actions
arn:aws:s3:::*       → All S3 buckets and objects

❌ AVOID: Using wildcards unless absolutely necessary
✅ PREFER: Specific actions and resources
```

---

## 🔐 IAM Best Practices Overview

### 1. Root Account Security

**Root Account = Owner of entire AWS account**

**Keep It Locked Down:**
```
✅ Enable MFA on root account (NOW!)
✅ Create IAM admin user instead (for daily use)
✅ Don't share root credentials
✅ Root credentials stored in secure location (encrypted, offline)
✅ Only use root for:
   - Setting up organization
   - Root account emergency access
   - Account recovery
   - Changing billing address

❌ DON'T use root for:
   - Daily work
   - Console login
   - API/CLI access
   - Sharing with team
```

**Enabling Root MFA:**

```
AWS Console (logged in as root)
→ Account → Security Credentials
→ MFA → Manage MFA device
→ Virtual MFA device (Google Authenticator, Authy)
→ Scan QR code
→ Enter 6-digit code twice
→ Done! (Test it)
```

### 2. Least Privilege Principle

**Give each principal ONLY the permissions they need, nothing more**

**Example: Developer Role**

```
❌ BAD: Attach AdministratorAccess to developer
❌ WORSE: S3 read/write to entire bucket (but they only need documents/)
✅ GOOD: S3 read/write to s3://my-bucket/documents/* only

❌ BAD: Attach ec2-messages:* (all actions)
✅ GOOD: ec2-messages:GetMessages, ec2-messages:AcknowledgeMessage (specific)

❌ BAD: No resource restriction
✅ GOOD: Action allowed only in dev region (Resource condition)
```

**Building Least-Privilege Policy:**

```
Step 1: Ask: What does this role NEED to do?
  → Developer needs to deploy code to EC2
  → Developer needs to read logs from CloudWatch
  → Developer needs to push images to ECR
  → Developer needs to assume deployment role

Step 2: List actions required:
  → ec2-messages:GetMessages (SSM)
  → ssm:StartSession (SSM)
  → logs:GetLogEvents (CloudWatch)
  → ecr:GetAuthorizationToken (ECR login)
  → ecr:PutImage (push images)
  → sts:AssumeRole (assume deployment role)

Step 3: Scope to specific resources:
  → ec2 instances tagged with Environment=dev
  → CloudWatch logs for dev applications
  → ECR repository for dev code
  → Deployment role named Deployer-Dev

Step 4: Add conditions:
  → Business hours only (optional)
  → MFA required (optional)
  → Specific regions only (optional)

Step 5: Write policy (see next section)
```

### 3. MFA (Multi-Factor Authentication)

**MFA = Something you know (password) + Something you have (phone)**

```
Attacker knows your password:
❌ Without MFA: Immediate access
✅ With MFA: Attacker needs your phone too (much harder!)

MFA methods:
1. Virtual MFA (Google Authenticator, Authy): ⭐ Recommended
2. Hardware MFA (YubiKey, Thales): ⭐ Most secure
3. SMS MFA: OK (SMS can be intercepted, not ideal)
```

**Requiring MFA in Policy:**

```json
{
  "Statement": [{
    "Effect": "Allow",
    "Action": "iam:*",
    "Resource": "*",
    "Condition": {
      "Bool": {
        "aws:MultiFactorAuthPresent": "true"
      }
    }
  }]
}
```

### 4. Access Keys Rotation

**Access keys = Username/password for CLI/API**

```
Change every 90 days:

Current Key (AKIA1234567890ABCDEF):
  Created: Jan 1
  Last rotated: Jan 1
  Age: 90 days (TIME TO ROTATE!)

Create New Key:
  New Key (AKIA0987654321ZYXWVU): Created
  
Update Applications:
  Update Lambda environment variables
  Update CI/CD secrets
  Update application config
  
Disable Old Key:
  Set status to Inactive (don't delete yet)
  
Test Old Key:
  Try using old key
  Should fail
  
Delete Old Key:
  30 days later (after confirming no issues)
  Remove from all systems
  Delete in IAM
```

---

## 📊 IAM Architecture for Organizations

### Multi-User Setup

```
Company: TechCorp (Account: 005965605891)

IAM Users:
  alice (senior engineer)
    → Policies: Developer, Reviewer
  
  bob (junior engineer)
    → Group: Developers
  
  charlie (DevOps)
    → Group: Operators
  
  diana (contractor)
    → Group: Contractors (limited access, 6 months)

IAM Groups:
  Developers (policies: dev access)
  Operators (policies: infrastructure)
  Contractors (policies: limited, time-bound)
  Auditors (read-only access)

IAM Roles:
  EC2-Application (for app servers)
  Lambda-Execution (for Lambda functions)
  Cross-Account-Role (for partner company)
  BreakGlass-Admin (emergency access, 30 min)

Root Account:
  ✅ MFA enabled
  ✅ Not used for daily work
  ✅ Password stored securely (offline)
```

### AWS SSO / Identity Center (Modern Approach)

**Instead of creating 100 IAM users, use AWS SSO:**

```
User logs in once:
  alice@techcorp.com + password + phone approval
  
AWS SSO provides:
  ✅ AWS Console access
  ✅ AWS CLI credentials
  ✅ Single sign-on
  ✅ Centralized user management
  ✅ Integration with existing directory (Okta, Azure AD)

User leaves company:
  Disable in directory
  Automatically loses AWS access
  No need to manually delete IAM user
```

---

## ✅ Key Takeaways

1. **IAM is AWS Security Foundation:** Get this right, everything else is easier
2. **Policy Evaluation:** Explicit deny > Organization SCP > Permission boundary > Identity policy
3. **Five Components:** Principal (who), Action (what), Resource (on what), Condition (when), Effect (allow/deny)
4. **Least Privilege:** Give minimum permissions needed
5. **MFA:** Always require for sensitive operations
6. **Root Account:** Lock down immediately
7. **Access Keys:** Rotate every 90 days
8. **Groups & Roles:** Use for managing permissions at scale
9. **CloudTrail:** Log everything for compliance
10. **Regular Audits:** Check for over-permissive access

---

## 🚀 Next Steps

1. **Read Next:** `02_Advanced_IAM_Policies.md` (custom policy creation)
2. **Do Lab:** Create IAM user with least-privilege S3 policy
3. **Secure:** Enable MFA on your own root account today!
4. **Understand:** How your current AWS access works (which policy gives you permission?)

---

**IAM is the foundation. Master this, and everything else becomes easier! 🔐**
