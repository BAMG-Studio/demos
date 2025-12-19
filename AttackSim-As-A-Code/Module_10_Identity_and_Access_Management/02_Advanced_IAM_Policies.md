# Module 10: Advanced IAM Policies - Hands-On Deep Dive

## 📚 Understanding Complex Policy Scenarios

### Real-World Challenge: E-Commerce Company

**Scenario:**
Company has 3 environments (dev, staging, prod) and multiple teams:
- **Developers:** Need to deploy to dev/staging, not prod
- **QA Testers:** Need read-only access to all environments
- **DevOps:** Need full control of infrastructure
- **Contractors:** 3-month contract, limited S3 and EC2 access
- **Auditors:** Read-only across entire company

**Without Policies:**
```
❌ Everyone gets admin access (insecure!)
❌ No way to restrict by environment
❌ Can't prevent contractors from accessing production
❌ Can't limit contractor access to 3 months
```

**With Advanced Policies:**
```
✅ Role: Developer-Role
   → Can deploy to dev/staging
   → Cannot even see prod environment
   → Limited to us-east-1 region
   
✅ Role: Contractor-Role
   → Limited to specific S3 bucket
   → Expires in 3 months
   → Cannot modify security groups
   → Cannot see IAM or billing
```

---

## 🔐 Advanced Condition Keys

### Resource-Based Conditions

#### 1. IP Address Restriction

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "AllowFromOfficeOnly",
    "Effect": "Allow",
    "Action": "s3:*",
    "Resource": "arn:aws:s3:::company-secrets/*",
    "Condition": {
      "IpAddress": {
        "aws:SourceIp": [
          "72.21.198.0/24",     // Office network
          "203.0.113.0/24"      // VPN network
        ]
      }
    }
  },
  {
    "Sid": "DenyFromPublicInternet",
    "Effect": "Deny",
    "Action": "s3:*",
    "Resource": "arn:aws:s3:::company-secrets/*",
    "Condition": {
      "IpAddress": {
        "aws:SourceIp": "0.0.0.0/0"
      }
    }
  }]
}
```

**Why both Allow AND Deny?**
- Allow: Permits office IPs (whitelist)
- Deny: Explicitly blocks public internet (blacklist)
- Best practice: Be explicit about what's allowed AND disallowed

#### 2. Time-Based Access

```json
{
  "Sid": "BusinessHoursOnly",
  "Effect": "Allow",
  "Action": "ec2:*Instances",
  "Resource": "*",
  "Condition": {
    "DateGreaterThanEquals": {
      "aws:CurrentTime": "2024-01-15T09:00:00Z"
    },
    "DateLessThan": {
      "aws:CurrentTime": "2024-01-15T17:00:00Z"
    }
  }
}
```

**Use Cases:**
- Limit contractor access to business hours only
- Prevent after-hours changes (change control)
- Time-limited emergency access (BreakGlass role)

#### 3. Region Restriction

```json
{
  "Sid": "UsEastOneOnly",
  "Effect": "Allow",
  "Action": "ec2:*",
  "Resource": "*",
  "Condition": {
    "StringEquals": {
      "aws:RequestedRegion": "us-east-1"
    }
  }
}
```

**Compliance Use Case:**
```
Regulation: Data must stay in EU (GDPR)

Policy:
- Allow: eu-west-1, eu-central-1
- Deny: us-east-1, us-west-2, ap-southeast-1

User in us-east-1 tries to launch EC2:
  Condition check: requested region = us-east-1
  Policy condition: allowed regions = eu-*
  Result: DENIED (compliance maintained!)
```

#### 4. MFA Requirement

```json
{
  "Sid": "AllowWithMFA",
  "Effect": "Allow",
  "Action": "iam:DeleteUser",
  "Resource": "arn:aws:iam::005965605891:user/*",
  "Condition": {
    "Bool": {
      "aws:MultiFactorAuthPresent": "true"
    }
  }
}
```

**Use Cases:**
- Sensitive operations (delete, modify security groups)
- Privileged roles
- High-risk actions
- Compliance requirement

#### 5. Resource Tagging

```json
{
  "Sid": "AllowTaggedResourcesOnly",
  "Effect": "Allow",
  "Action": "ec2:TerminateInstances",
  "Resource": "arn:aws:ec2:*:*:instance/*",
  "Condition": {
    "StringEquals": {
      "ec2:ResourceTag/Environment": "dev"
    }
  }
}
```

**Practical Example:**

```
Tag all dev instances:
  Name: my-dev-server
  Environment: dev
  Owner: alice

Tag all prod instances:
  Name: my-prod-server
  Environment: prod
  Owner: alice

Policy:
  Developer-Role can terminate instances with tag Environment=dev
  Developer-Role CANNOT terminate instances with tag Environment=prod
  
Result: alice can terminate her own dev servers, but safely protected from prod
```

#### 6. Principal-Based Conditions

```json
{
  "Sid": "AllowSpecificUserOnly",
  "Effect": "Allow",
  "Action": "s3:DeleteObject",
  "Resource": "arn:aws:s3:::backups/*",
  "Condition": {
    "StringEquals": {
      "aws:username": "admin"
    }
  }
}
```

---

## 🎯 Resource-Based Policies

### S3 Bucket Policy

**Layman Analogy:**
```
Identity Policy: "Alice is allowed to open doors"
  (Permission lives with Alice)

Resource Policy: "This specific door can only be opened by Alice"
  (Permission lives with the door)
```

**S3 Bucket Policy Example:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicRead",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"  // Anyone
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-public-website/*",
      "Condition": {
        "StringEquals": {
          "aws:SourceVpc": "vpc-12345678"  // Only from specific VPC
        }
      }
    },
    {
      "Sid": "DenyUnencryptedUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::company-data/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    }
  ]
}
```

**Key Difference from Identity Policy:**

| Aspect | Identity Policy | Resource Policy |
|--------|-----------------|-----------------|
| Attached to | User/Role/Group | S3 Bucket, SQS Queue, etc. |
| Controls | What identity can do | What can be done to resource |
| Example | "alice can GetObject" | "GetObject allowed on bucket" |
| Use Case | Permission model | Cross-account, public access |

### Cross-Account Access (Resource Policy)

**Scenario:** Partner company needs to access your S3 bucket

```
Your AWS Account: 005965605891
Partner AWS Account: 123456789012

Partner user ARN: arn:aws:iam::123456789012:user/partner-user

S3 Bucket Policy (in your account):
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "AllowPartnerAccess",
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::123456789012:user/partner-user"
    },
    "Action": [
      "s3:GetObject",
      "s3:ListBucket"
    ],
    "Resource": [
      "arn:aws:s3:::partnership-data",
      "arn:aws:s3:::partnership-data/*"
    ]
  }]
}

Result:
✅ Partner user can read data from bucket
✅ No AWS credentials shared
✅ Access appears in CloudTrail (who accessed what, when)
✅ Can be revoked instantly
```

---

## 🚫 Explicit Deny - Most Powerful

### Why Explicit Deny?

```
Policy Evaluation:

Step 1: Found explicit DENY? → Stop, DENIED (always wins!)
Step 2: No explicit deny? → Continue checking other policies
Step 3: Found Allow? → ALLOWED
Step 4: No Allow found? → DENIED (default)

Key point: Explicit deny ALWAYS wins over Allow
```

**Example:**

```
Scenario: Protect sensitive bucket from accidental deletion

User has: PowerUser policy (can do almost everything)
  Includes: s3:DeleteObject, s3:DeleteBucket

But we want: Protect data in s3://sensitive-data/ from deletion

Solution: Add explicit Deny policy

{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "DenyDeleteSensitiveData",
    "Effect": "Deny",
    "Action": [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ],
    "Resource": "arn:aws:s3:::sensitive-data/*"
  }]
}

Result:
❌ Even though user has Allow from PowerUser
❌ Explicit Deny blocks s3:DeleteObject on this bucket
❌ User cannot delete sensitive data
✅ User can still delete objects in other buckets
```

### Break Glass Scenario

```
Emergency access: Admin needs to fix production outage

Normal state: alice = Developer (limited access)

Emergency: alice assumes BreakGlass-Admin role (30-minute duration)
  Gets: Full admin permissions
  Requirements: 
    + Requires approval from on-call manager (SNS notification)
    + Requires MFA confirmation
    + Automatically revokes after 30 minutes
    + All actions logged to separate audit trail

After emergency fixed:
  - Manual deactivation of role
  - Post-incident review of all actions taken
  - Document what happened and why
```

---

## 📋 Permission Boundaries

**Layman Analogy:**
```
Scenario: Parent supervising teenager

Identity Policy: "Permission to go out after school"
  → Identity-level permission (what they're allowed to do)

Permission Boundary: "But must be back by 9 PM and stay within 5 miles"
  → Maximum permissions (can't do more than this, even if allowed)

Result:
  Teen allowed to: Leave after school, go to friend's house, go to movies
  Teen NOT allowed to: Leave after school (policy allows) BUT past 9 PM (boundary rejects)
  Teen NOT allowed to: Leave after school (policy allows) BUT go to different city (boundary rejects)

Key: Permission Boundary = Upper limit of permissions
```

**Technical Example:**

```
Scenario: Company wants admin who can manage EC2 and S3, but:
  - Cannot touch IAM (can't create other admins)
  - Cannot touch billing
  - Cannot touch KMS

Solution:

Identity Policy (on user):
{
  "Statement": [{
    "Effect": "Allow",
    "Action": "*",
    "Resource": "*"
  }]
}

Permission Boundary (policy):
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "cloudwatch:*",
        "logs:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": [
        "iam:*",
        "billing:*",
        "kms:*",
        "organizations:*"
      ],
      "Resource": "*"
    }
  ]
}

Result:
✅ User has admin access to EC2, S3, CloudWatch, Logs
❌ Cannot access IAM (boundary blocks)
❌ Cannot access billing (boundary blocks)
❌ Cannot access KMS (boundary blocks)
✅ Cannot exceed boundary permissions, even if they find another policy
```

---

## 🔍 Policy Simulator - Test Before Deploying

### How to Use Policy Simulator

**Scenario:** Before attaching policy to alice, test it

```
AWS Console:
  IAM → Policies → Policy Simulator (or separate tool)

Fill in:
  Principal: arn:aws:iam::005965605891:user/alice
  Actions: s3:GetObject, s3:PutObject, s3:DeleteObject
  Resources: arn:aws:s3:::my-bucket/*

Click: "Simulate Custom Policy"

Results:
  s3:GetObject → ALLOWED ✅
  s3:PutObject → ALLOWED ✅
  s3:DeleteObject → DENIED ❌ (boundary restricts)
  
Debug:
  Why denied? → Click "View Details"
  → "Denied by permission boundary"
  → "Maximum permission is s3:*Except=DeleteObject"
```

### Testing Cross-Account Policies

```
Test: Can partner in Account B access bucket in Account A?

Policy Simulator:
  Account: 005965605891 (your account)
  Principal: arn:aws:iam::123456789012:user/partner-user
  Action: s3:GetObject
  Resource: arn:aws:s3:::partnership-bucket/*

Results:
  → Checks your bucket policy
  → Checks partner's identity policy (requires cross-account role setup)
  → Gives accurate answer

Before deploying to production:
  Test that partner can actually access
  Test that they can't access other buckets
  Test that they can't delete objects
```

---

## 🛠️ Building Custom Policies - Best Practices

### Step-by-Step Policy Construction

**Task:** Create policy for Junior Developer

**Requirements:**
- Deploy code to EC2 instances (dev environment only)
- Read logs from CloudWatch
- View CloudFormation templates
- Cannot modify databases
- Cannot access production
- Cannot touch IAM
- Time limited (work hours only)

**Step 1: List Required Actions**

```
Deployment:
  + ec2-messages:GetMessages
  + ec2-messages:AcknowledgeMessage
  + ssm:StartSession
  + ssm:GetConnectionStatus

CloudWatch Logs:
  + logs:GetLogEvents
  + logs:DescribeLogStreams
  + logs:DescribeLogGroups

CloudFormation:
  + cloudformation:DescribeStacks
  + cloudformation:GetTemplate
  + cloudformation:DescribeStackResources

EC2 (read-only):
  + ec2:DescribeInstances
  + ec2:DescribeInstanceAttribute
  + ec2:DescribeSecurityGroups

Deny explicitly:
  + rds:* (no database access)
  + iam:* (no IAM access)
```

**Step 2: Scope to Resources**

```
EC2 instances tagged with:
  Environment: dev
  Team: backend

Log groups matching:
  /aws/lambda/dev*
  /aws/ecs/dev*

CloudFormation stacks:
  Named: dev-*
  Not: prod-*
```

**Step 3: Add Conditions**

```
Region: us-east-1 only
Time: 09:00 - 17:00 UTC weekdays
```

**Step 4: Write Policy**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyProduction",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestedRegion": "prod*",
          "ec2:ResourceTag/Environment": "prod"
        }
      }
    },
    {
      "Sid": "AllowSSMAccess",
      "Effect": "Allow",
      "Action": [
        "ec2-messages:GetMessages",
        "ec2-messages:AcknowledgeMessage",
        "ssm:StartSession",
        "ssm:GetConnectionStatus"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Environment": "dev"
        }
      }
    },
    {
      "Sid": "AllowCloudWatchLogs",
      "Effect": "Allow",
      "Action": [
        "logs:GetLogEvents",
        "logs:DescribeLogStreams",
        "logs:DescribeLogGroups"
      ],
      "Resource": "arn:aws:logs:us-east-1:005965605891:log-group:/aws/lambda/dev*"
    },
    {
      "Sid": "AllowCloudFormationRead",
      "Effect": "Allow",
      "Action": [
        "cloudformation:DescribeStacks",
        "cloudformation:GetTemplate",
        "cloudformation:DescribeStackResources"
      ],
      "Resource": "arn:aws:cloudformation:us-east-1:005965605891:stack/dev-*/*"
    },
    {
      "Sid": "DenyDatabases",
      "Effect": "Deny",
      "Action": "rds:*",
      "Resource": "*"
    },
    {
      "Sid": "DenyIAM",
      "Effect": "Deny",
      "Action": "iam:*",
      "Resource": "*"
    }
  ]
}
```

**Step 5: Test in Policy Simulator**

```
Test cases:
✅ ec2-messages:GetMessages on dev instance → Allowed
✅ logs:GetLogEvents on dev logs → Allowed
❌ ec2-messages:GetMessages on prod instance → Denied (tag condition)
❌ rds:ModifyDBInstance → Denied (explicit deny)
❌ iam:CreateUser → Denied (explicit deny)
```

---

## 📊 Common Policies Reference

### Read-Only Access

```json
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*",
        "ec2:Describe*",
        "cloudformation:Describe*",
        "cloudformation:GetTemplate",
        "logs:Get*",
        "logs:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
```

### S3 Administrator (Single Bucket)

```json
{
  "Statement": [{
    "Effect": "Allow",
    "Action": "s3:*",
    "Resource": [
      "arn:aws:s3:::my-bucket",
      "arn:aws:s3:::my-bucket/*"
    ]
  }]
}
```

### CI/CD Deployment

```json
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:PutImage"
      ],
      "Resource": "arn:aws:ecr:us-east-1:005965605891:repository/myapp"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:UpdateService",
        "ecs:DescribeServices"
      ],
      "Resource": "arn:aws:ecs:us-east-1:005965605891:service/myservice"
    }
  ]
}
```

---

## ✅ Advanced Policy Checklist

- [ ] Use explicit Allow + explicit Deny (not just Allow)
- [ ] Test all policies in Policy Simulator before deployment
- [ ] Document WHY each permission is needed
- [ ] Review policies quarterly (access creep)
- [ ] Use resource tags for easy policy scoping
- [ ] Implement permission boundaries on privileged roles
- [ ] Require MFA for sensitive operations
- [ ] Monitor policy changes with CloudTrail
- [ ] Use Condition keys (IP, region, time, MFA)
- [ ] Never use wildcards (*) unless absolutely necessary

---

**Next:** `03_Cross_Account_Access_and_Delegation.md` - Multi-account strategies and federation
