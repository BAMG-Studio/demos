# Module 10: Cross-Account Access & Delegation - Multi-Account Architecture

## 📚 Why Cross-Account Access?

### Business Drivers

**Scenario 1: Multi-Team Organization**
```
Company Structure:
  - Frontend Team (owns frontend-prod account)
  - Backend Team (owns backend-prod account)
  - DevOps Team (owns shared-infra account)
  - Finance Team (owns billing-prod account)

Problem:
❌ Frontend team can't deploy to backend account
❌ DevOps can't troubleshoot in frontend account
❌ Finance can't audit AWS costs across teams
❌ No centralized management

Solution:
✅ Create cross-account roles
✅ Frontend team assumes role in backend account (when needed)
✅ DevOps assumes role in any team's account
✅ Finance role can read-only across all accounts
```

**Scenario 2: Contractor/Partner Access**
```
Your Company (Account: 005965605891)
Partner Company (Account: 123456789012)

Partner needs to:
  ✅ Access your S3 bucket with customer data
  ❌ But NOT access your production EC2 instances
  ❌ But NOT access your databases
  ❌ But NOT access your IAM settings

Solution:
  → Create role in your account
  → Partner assumes role from their account
  → Role only allows S3 read access
  → No AWS credentials shared
  → Can audit everything in CloudTrail
```

**Scenario 3: Development → Production Promotion**
```
Dev Account (005965605891): Development and testing
Prod Account (999988887777): Production deployment

Process:
  1. Developer commits code
  2. CI/CD runs in dev account (builds, tests)
  3. CI/CD assumes role in prod account
  4. CI/CD deploys to production
  5. All actions logged (CloudTrail)

Benefits:
  ✅ Developers can't accidentally break production
  ✅ Prod access through automated pipeline only
  ✅ Audit trail of who deployed what
  ✅ Easy rollback (don't have dev credentials)
```

---

## 🔑 AssumeRole Mechanics

### How AssumeRole Works

```
User in Account A:
arn:aws:iam::005965605891:user/alice

Alice wants to work in Account B:
arn:aws:iam::999988887777:role/Developer-Role

Process:

1. Alice calls: sts:AssumeRole API
   Input: 
     RoleArn: arn:aws:iam::999988887777:role/Developer-Role
     RoleSessionName: alice-session
     Duration: 3600 seconds (1 hour)

2. AWS checks:
   a) Does role in Account B trust account A? (Trust policy)
   b) Does alice in account A have permission to assume? (Identity policy)

3. If both yes:
   AWS returns: 
     AccessKeyId
     SecretAccessKey
     SessionToken (proves it's temporary)
     Expiration

4. Alice uses temporary credentials:
   All API calls use new credentials
   CloudTrail shows: Assumed-role/Developer-Role/alice-session
   (Can see who Alice is and that she assumed role)

5. After 1 hour:
   Credentials expire
   Alice must assume role again (re-authenticate)
```

### Detailed Flow Diagram

```
┌─────────────────────────────────┐
│ Account A (User's Account)      │
├─────────────────────────────────┤
│                                 │
│  User: alice                    │
│  Identity Policy: AssumeRole    │
│    sts:AssumeRole on roleB      │
│                                 │
│  1. Calls: AssumeRole           │
│     Target: arn:aws:iam::       │
│     999988887777:role/...       │
│                                 │
└────────────┬────────────────────┘
             │
             │ AssumeRole Request
             ↓
┌─────────────────────────────────┐
│ STS Service (Cross-Account)     │
├─────────────────────────────────┤
│                                 │
│  2. Check Trust Policy:         │
│     Does role B trust account A?│
│     ✅ YES                      │
│                                 │
│  3. Check Identity Policy:      │
│     Does alice have permission? │
│     ✅ YES                      │
│                                 │
│  4. Generate temporary creds:   │
│     AccessKey + Secret + Token  │
│     Duration: 1 hour            │
│     Session name: alice-session │
│                                 │
└────────────┬────────────────────┘
             │
             │ Return Credentials
             ↓
┌─────────────────────────────────┐
│ Account B (Target Account)      │
├─────────────────────────────────┤
│                                 │
│  Role: Developer-Role           │
│  Permissions: EC2 read-only     │
│  Trust: Account A only          │
│                                 │
│  5. Alice uses temporary creds  │
│     → Can access Account B      │
│     → Limited by role policy    │
│     → CloudTrail logs:          │
│        Principal: Assumed-Role/ │
│        Developer-Role/          │
│        alice-session            │
│                                 │
│  6. After 1 hour: Creds expire  │
│     Must assume role again      │
│                                 │
└─────────────────────────────────┘
```

---

## 🤝 Trust Policy - Who Can Assume?

### Trust Policy Basics

**What:** Policy on the role that says "Who can assume me?"

**Where:** Attached to the role (not to the user)

**Example: Developer Role Trust Policy**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::005965605891:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "secret-code-12345"
        }
      }
    }
  ]
}
```

**Key Points:**
- `Principal`: Who is allowed to assume this role
- `sts:AssumeRole`: The action (always this for assuming role)
- `Condition`: Optional restrictions (ExternalId, MFA requirement, etc.)

### Types of Principals

#### 1. Specific User

```json
{
  "Principal": {
    "AWS": "arn:aws:iam::005965605891:user/alice"
  }
}
```
Only alice can assume the role

#### 2. Specific Role

```json
{
  "Principal": {
    "AWS": "arn:aws:iam::005965605891:role/CI-CD-Role"
  }
}
```
CI/CD pipeline (running in CI/CD role) can assume the role

#### 3. Entire Account (Root)

```json
{
  "Principal": {
    "AWS": "arn:aws:iam::005965605891:root"
  }
}
```
Anyone in account 005965605891 can assume (if they have sts:AssumeRole permission)

#### 4. AWS Service

```json
{
  "Principal": {
    "Service": "lambda.amazonaws.com"
  }
}
```
Lambda functions can assume the role (to access other services)

#### 5. External Principal (Cross-Account Partner)

```json
{
  "Principal": {
    "AWS": "arn:aws:iam::123456789012:root"
  },
  "Condition": {
    "StringEquals": {
      "sts:ExternalId": "unique-code-12345"
    }
  }
}
```
External account allowed, but with additional security (ExternalId)

---

## 🛡️ Cross-Account Security Best Practices

### External ID - Additional Security Layer

**Problem:**
```
You: Account 005965605891
Partner A: Account 123456789012
Partner B: Account 123456789013

You create role:
  Trust principal: arn:aws:iam::123456789012:root

Problem: What if Partner A's account gets compromised?
  Attacker can assume your role (role trusts their account)
  Attacker can access your resources
```

**Solution: External ID**

```
Trust policy:
{
  "Principal": {
    "AWS": "arn:aws:iam::123456789012:root"
  },
  "Condition": {
    "StringEquals": {
      "sts:ExternalId": "super-secret-code-xyz123"
    }
  }
}

Partner A wants to assume role:
  AssumeRole API call includes ExternalId
  If ExternalId matches: Role assumption succeeds
  If ExternalId missing or wrong: Role assumption fails

Scenario: Partner A's account compromised
  Attacker tries to assume role (without ExternalId)
  AWS checks: ExternalId provided? No
  AWS checks: ExternalId matches? No
  AWS denies (even though principal matches!)

Real-world impact:
  ✅ Even if partner account is compromised, your role is safe
  ✅ Extra password/code known only to partner
  ✅ If external ID leaked, you can rotate it
```

**How to Use ExternalId:**

```
Step 1: Generate random string (ExternalId)
  Example: UR7nK2pL9mQ5wX8jR4bS (20 random chars)
  
Step 2: You give ExternalId to partner
  Via: Email (encrypted), secure portal, phone
  NOT via: Slack, unencrypted email, GitHub
  
Step 3: Partner uses ExternalId when assuming role
  AssumeRole call:
    RoleArn: arn:aws:iam::005965605891:role/PartnerAccess
    ExternalId: UR7nK2pL9mQ5wX8jR4bS
    
Step 4: If ExternalId compromised
  Generate new one: D3fG6hI9jK2lM5nO8pQ
  Update trust policy
  Old ExternalId no longer works
  Partner uses new ExternalId
```

### MFA Requirement for Sensitive Roles

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::005965605891:root"
    },
    "Action": "sts:AssumeRole",
    "Condition": {
      "Bool": {
        "aws:MultiFactorAuthPresent": "true"
      }
    }
  }]
}
```

**Effect:**
```
User tries to assume role without MFA:
  ❌ DENIED (condition fails)

User authenticates MFA, then assumes role:
  ✅ ALLOWED (condition passes)
```

### Session Duration Limits

```json
{
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "AWS": "arn:aws:iam::005965605891:user/alice" },
    "Action": "sts:AssumeRole",
    "Condition": {
      "NumericLessThan": {
        "sts:DurationSeconds": "3600"  // Max 1 hour
      }
    }
  }]
}
```

**Effect:**
```
Alice assumes role with DurationSeconds=7200 (2 hours):
  ❌ DENIED (condition fails, 7200 > 3600)

Alice assumes role with DurationSeconds=1800 (30 min):
  ✅ ALLOWED (condition passes, 1800 < 3600)
```

---

## 👥 Common Cross-Account Patterns

### Pattern 1: Multi-Account Organization (AWS Organizations)

```
Root Account (005965605891):
  - Organization master
  - Billing management
  - Cannot directly access other accounts

Dev Account (111111111111):
  - Developer team
  - Sandbox environment
  - Role: Developer-Role

Prod Account (222222222222):
  - Production systems
  - Limited access (deployment only)
  - Role: Deployer-Role

DevOps Account (333333333333):
  - Shared tools (Jenkins, Terraform, logging)
  - Assumes roles in Dev/Prod for deployments
  - Role: DevOps-Role

Deployment Flow:
1. Developer commits code
2. Jenkins (in DevOps account) detected
3. Jenkins assumes Deployer-Role in Prod
4. Jenkins deploys code
5. CloudTrail shows all actions
```

### Pattern 2: Third-Party Integration

```
Your Account (005965605891):
  - Customer data
  - S3 bucket with reports
  - Role: ThirdPartyAccess

Third-Party Company (123456789012):
  - Your customer
  - Needs to analyze your data
  - User: third-party-analyst@company.com
  - Has sts:AssumeRole permission

Third-Party Analyst Flow:
1. Analyst logs into their AWS account
2. Calls: AssumeRole
   - RoleArn: arn:aws:iam::005965605891:role/ThirdPartyAccess
   - ExternalId: shared-secret-xyz
3. Gets temporary credentials (5 hour session)
4. Accesses S3 bucket (read-only)
5. Downloads reports
6. Credentials expire
7. If analyst leaves company: Revoke trust policy

Benefits:
✅ No AWS credentials created in your account
✅ Analyst uses their own account
✅ Full audit trail (CloudTrail)
✅ Easy to revoke (just update trust policy)
✅ Temporary access (credentials auto-expire)
```

### Pattern 3: Least Privilege Role Assumption

```
Scenario: Developer needs temporary admin access (30 min emergency)

Normal: alice = Developer role (limited)
Emergency: alice can assume BreakGlass-Admin role (30 min)

BreakGlass-Admin Trust Policy:
{
  "Statement": [{
    "Principal": {
      "AWS": "arn:aws:iam::005965605891:user/alice"
    },
    "Action": "sts:AssumeRole",
    "Condition": {
      "Bool": {
        "aws:MultiFactorAuthPresent": "true"
      },
      "NumericLessThan": {
        "sts:DurationSeconds": "1800"  // 30 min max
      }
    }
  }]
}

BreakGlass-Admin Role Policy:
{
  "Statement": [{
    "Effect": "Allow",
    "Action": "*",
    "Resource": "*"
  }]
}

Process:
1. Production down (incident)
2. Alice requests emergency access (manager approval)
3. Alice assumes BreakGlass-Admin role (MFA required, 30 min)
4. Alice fixes issue
5. Emergency access expires (auto-revoke)
6. Post-incident review of CloudTrail logs
7. Document what happened and why
```

---

## 🔄 Service Roles - Services Assuming Roles

### EC2 Instance Profile

**Scenario:** EC2 server needs to access S3

**Without Role (BAD):**
```
❌ Store AWS credentials on EC2 instance
❌ Credentials in /root/.aws/credentials file
❌ If instance compromised, credentials compromised
❌ Can't rotate credentials per instance
❌ Credentials visible in CloudTrail as from instance
```

**With Role (GOOD):**
```
✅ EC2 assumes role (no credentials stored on instance)
✅ Temporary credentials injected by AWS
✅ Temporary credentials expire (default 1 hour)
✅ If instance compromised, credentials only valid for 1 hour
✅ Credentials rotated automatically by AWS
✅ Can replace credentials without logging into instance
✅ CloudTrail shows: Assumed-role/EC2-Role/instance-id
```

**Setting Up:**

```
Step 1: Create role

IAM Console → Roles → Create Role
  Trust entity: EC2
  
  Trust policy:
  {
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  }

Step 2: Attach policies to role

  Add policy: S3ReadOnly (for production)
  Resource: arn:aws:s3:::app-data/*

Step 3: Create instance profile

  Instance profile wraps role (required for EC2)
  Associate profile with role

Step 4: Launch EC2 with instance profile

  EC2 Console → Launch Instance
  → IAM instance profile: EC2-AppRole
  → Instance starts
  → Instance profile attached

Step 5: EC2 uses role credentials

  Within EC2:
    aws s3 ls s3://app-data/
    
  AWS automatically:
    1. EC2 runtime requests credentials from metadata service
    2. EC2 calls: sts:AssumeRole (internally, not visible to user)
    3. Temporary credentials returned
    4. AWS SDK uses credentials for S3 access
    5. CloudTrail logs: Assumed-role/EC2-AppRole/instance-id
```

### Lambda Execution Role

```
Lambda function needs to:
  ✅ Write logs to CloudWatch
  ✅ Read items from DynamoDB
  ❌ Access S3 (not needed, don't include)

Solution:

1. Create role: Lambda-Execution-Role

2. Trust policy:
{
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "lambda.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}

3. Attach policies:
  - logs:CreateLogGroup
  - logs:CreateLogStream
  - logs:PutLogEvents
  - dynamodb:GetItem
  - dynamodb:Query

4. Deploy Lambda with execution role

5. Lambda code:
   import boto3
   
   dynamodb = boto3.resource('dynamodb')
   table = dynamodb.Table('users')
   item = table.get_item(Key={'id': '123'})
   # AWS automatically handles credentials
   # No AWS_SECRET_ACCESS_KEY in code

6. CloudTrail shows:
   Principal: Lambda execution role
   Action: dynamodb:GetItem
   Success!
```

---

## ✅ Cross-Account Checklist

- [ ] Understand trust policy vs. role policy
- [ ] Always use external ID for partner access
- [ ] Require MFA for sensitive roles
- [ ] Limit session duration (not 12 hour max)
- [ ] Audit role assumptions in CloudTrail
- [ ] Document trust relationships (who trusts who)
- [ ] Implement least privilege (minimal required actions)
- [ ] Regular review of cross-account roles (quarterly)
- [ ] Test role assumption before production use
- [ ] Implement break-glass access (emergency procedures)

---

**Next:** `04_Identity_Federation_and_SSO.md` - SAML, OIDC, and enterprise integration
