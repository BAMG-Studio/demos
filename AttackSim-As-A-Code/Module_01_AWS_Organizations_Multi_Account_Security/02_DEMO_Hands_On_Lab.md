# Module 1: Hands-On Demo - Building Your AWS Multi-Account Organization

## 🎯 Demo Objective

By the end of this hands-on lab, you will have:
- ✅ Created an AWS Organization from scratch
- ✅ Designed and implemented a 4-OU hierarchy
- ✅ Created 5 member accounts and organized them
- ✅ Implemented Service Control Policies (SCPs)
- ✅ Tested SCP enforcement
- ✅ Configured centralized logging
- ✅ Documented your architecture
- ✅ Estimated real-world costs

**Estimated Duration:** 3-4 hours  
**AWS Account Required:** Management account (AWS CLI access, root credentials)  
**Cost Estimate:** $5-10 for this demo (mostly CloudTrail storage)

---

## 📋 Pre-Demo Checklist

### Prerequisites You Need:
- [ ] AWS Management Account access (NOT recommended: root, but we'll use SSO)
- [ ] AWS CLI v2 installed (`aws --version`)
- [ ] AWS credentials configured (`aws configure`)
- [ ] Permissions to create Organizations and IAM roles
- [ ] Text editor for notes (notepad, VS Code, etc.)
- [ ] Spreadsheet software (Excel, Google Sheets) for documentation

### What We're Building:
```
Management Account (005965605891)
├── Security OU
│   ├── Security-Logging-Account
│   └── Security-Tools-Account
├── Production OU
│   └── Production-Apps-Account
├── NonProduction OU
│   ├── Development-Account
│   └── Test-Account
└── Sandbox OU
    └── AttackSim-Lab-Account
```

---

## 🚀 Step 1: Enable AWS Organizations

### 1.1 Check Current State

**Using AWS Console:**
1. Open [AWS Console](https://console.aws.amazon.com)
2. Navigate to Organizations service
3. Note if organization already exists

**Using AWS CLI:**
```bash
aws organizations describe-organization
```

**Expected Output (if organization doesn't exist):**
```
An error occurred (AWSOrganizationsNotInUseException)
```

**Expected Output (if organization exists):**
```json
{
  "Organization": {
    "Arn": "arn:aws:organizations::005965605891:organization/o-xxxxxxxxxx",
    "Id": "o-xxxxxxxxxx",
    "MasterAccountArn": "arn:aws:iam::005965605891:root",
    "MasterAccountId": "005965605891",
    "MasterAccountEmail": "your-email@example.com",
    "RootId": "r-xxxx",
    "FeatureSet": "ALL"  # This means SCPs are enabled
  }
}
```

### 1.2 Create Organization (If Needed)

**Using AWS Console:**
1. Go to Organizations → Create Organization
2. Select "Enable all features" (includes SCPs)
3. Confirm via email
4. Wait 5-10 minutes for creation

**Using AWS CLI:**
```bash
# Create organization with all features enabled
aws organizations create-organization \
  --feature-set ALL

# This command requires root account access
```

**Important Notes:**
- This action cannot be undone immediately (takes 30 days to disable)
- All existing accounts will be unaffected
- If you have a root email, verify it

### 1.3 Document Your Organization

Create a tracking spreadsheet:

| Field | Value |
|-------|-------|
| Organization ID | o-xxxxxxxxxx |
| Management Account ID | 005965605891 |
| Management Account Email | your-email@example.com |
| Root ID | r-xxxx |
| Feature Set | ALL |
| Creation Date | YYYY-MM-DD |

---

## 🏗️ Step 2: Design Your OU Hierarchy

### 2.1 Create Root OUs

**Understanding the Root:**
Every organization has a "Root" - it's not a typical OU, but where SCPs apply first.

```
Root
├── Security
├── Production  
├── NonProduction
└── Sandbox
```

**Using AWS Console:**

1. Go to Organizations → AWS accounts
2. Click on "Root" (it will show "r-xxxx")
3. Click "Create new OU"
4. Enter name: "Security"
5. Click "Create"
6. Repeat for: "Production", "NonProduction", "Sandbox"

**Using AWS CLI:**

```bash
# First, get Root ID
ROOT_ID=$(aws organizations list-roots --query 'Roots[0].Id' --output text)

# Create OUs
aws organizations create-organizational-unit \
  --parent-id $ROOT_ID \
  --name "Security"

aws organizations create-organizational-unit \
  --parent-id $ROOT_ID \
  --name "Production"

aws organizations create-organizational-unit \
  --parent-id $ROOT_ID \
  --name "NonProduction"

aws organizations create-organizational-unit \
  --parent-id $ROOT_ID \
  --name "Sandbox"
```

**Verify Creation:**
```bash
aws organizations list-organizational-units-for-parent \
  --parent-id $ROOT_ID
```

**Expected Output:**
```json
{
  "OrganizationalUnits": [
    {
      "Id": "ou-xxxx-xxxxxxxx",
      "Arn": "arn:aws:organizations::005965605891:ou/o-xxxxxxxxxx/ou-xxxx-xxxxxxxx",
      "Name": "Security",
      "Status": "ACTIVE"
    },
    // ... other OUs
  ]
}
```

### 2.2 Create Sub-OUs for Security

Some organizations need sub-OUs. For our course, we'll keep it flat (no sub-OUs under Security).

**Update your OU tracking table:**

| OU Name | OU ID | Parent | Status |
|---------|-------|--------|--------|
| Root | r-xxxx | - | ACTIVE |
| Security | ou-xxxx-sec | Root | ACTIVE |
| Production | ou-xxxx-prod | Root | ACTIVE |
| NonProduction | ou-xxxx-nonprod | Root | ACTIVE |
| Sandbox | ou-xxxx-sand | Root | ACTIVE |

---

## 👥 Step 3: Create Member Accounts

### 3.1 Create First Account: Security-Logging

**Using AWS Console:**

1. Go to Organizations → AWS accounts → Add account
2. Select "Create AWS account"
3. Fill in:
   - **Account name:** Security-Logging
   - **Account email:** security-logging@example.com (MUST be unique)
   - **IAM role name:** (leave default - OrganizationAccountAccessRole)
4. Click "Create"
5. Wait 1-2 minutes for account creation

**Expected Notification:**
```
Account creation successful
New account ID: 123456789012
```

### 3.2 Create Additional Accounts

Repeat the process for each account:

| Account Name | Email | Purpose |
|--------------|-------|---------|
| Security-Logging | security-logging@example.com | Centralized audit logs |
| Security-Tools | security-tools@example.com | GuardDuty, Security Hub, Inspector |
| Production-Apps | production@example.com | Live applications |
| Development | development@example.com | Dev/test builds |
| Test | test@example.com | QA testing |
| AttackSim-Lab | attacksim@example.com | Attack simulations |

**Automated Creation with CLI:**

```bash
#!/bin/bash

# Create multiple accounts programmatically
ACCOUNTS=(
  "Security-Logging:security-logging@example.com:Security"
  "Security-Tools:security-tools@example.com:Security"
  "Production-Apps:production@example.com:Production"
  "Development:development@example.com:NonProduction"
  "Test:test@example.com:NonProduction"
  "AttackSim-Lab:attacksim@example.com:Sandbox"
)

for account in "${ACCOUNTS[@]}"; do
  IFS=':' read -r name email ou <<< "$account"
  
  # Create account
  ACCOUNT_ID=$(aws organizations create-account \
    --account-name "$name" \
    --email "$email" \
    --query 'CreateAccountStatus.AccountId' \
    --output text)
  
  echo "Created account: $name ($ACCOUNT_ID)"
done

# Give accounts time to be created
echo "Waiting 60 seconds for account creation..."
sleep 60
```

**Tracking Table (Update as you create):**

| Account Name | Account ID | Email | OU | Status |
|--------------|------------|-------|-----|--------|
| Security-Logging | 123456789012 | security-logging@example.com | Security | ACTIVE |
| Security-Tools | 123456789013 | security-tools@example.com | Security | ACTIVE |
| Production-Apps | 123456789014 | production@example.com | Production | ACTIVE |
| Development | 123456789015 | development@example.com | NonProduction | ACTIVE |
| Test | 123456789016 | test@example.com | NonProduction | ACTIVE |
| AttackSim-Lab | 123456789017 | attacksim@example.com | Sandbox | ACTIVE |

### 3.3 Move Accounts to OUs

**Using AWS Console:**

1. Go to Organizations → AWS accounts
2. Select account "Security-Logging"
3. Click "Move" 
4. Select parent: "Security" OU
5. Click "Confirm"
6. Repeat for all accounts

**Using AWS CLI:**

```bash
# Get OU IDs
SECURITY_OU=$(aws organizations list-organizational-units-for-parent \
  --parent-id $ROOT_ID \
  --filters Name=Name,Values=Security \
  --query 'OrganizationalUnits[0].Id' \
  --output text)

# Move account to Security OU
aws organizations move-account \
  --account-id 123456789012 \
  --source-parent-id $ROOT_ID \
  --destination-parent-id $SECURITY_OU
```

**Verify Structure:**
```bash
aws organizations list-accounts-for-parent \
  --parent-id $SECURITY_OU
```

---

## 🔐 Step 4: Implement Service Control Policies

### 4.1 Enable SCP Policy Type

**Check Current Status:**
```bash
aws organizations list-policies --filter SERVICE_CONTROL_POLICY
```

**If SCPs are not enabled:**
```bash
aws organizations enable-policy-type \
  --root-id $ROOT_ID \
  --policy-type SERVICE_CONTROL_POLICY
```

**Expected Output:**
```json
{
  "PolicyType": {
    "Type": "SERVICE_CONTROL_POLICY",
    "Status": "ENABLED"
  }
}
```

### 4.2 Create Baseline Security Protection Policy

This policy prevents disabling security services across the entire organization.

**Save as `scp_baseline_security.json`:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PreventCloudTrailDisable",
      "Effect": "Deny",
      "Action": [
        "cloudtrail:StopLogging",
        "cloudtrail:DeleteTrail",
        "cloudtrail:UpdateTrail"
      ],
      "Resource": "*"
    },
    {
      "Sid": "PreventGuardDutyDisable",
      "Effect": "Deny",
      "Action": [
        "guardduty:DeleteDetector",
        "guardduty:DeleteMembers",
        "guardduty:DisassociateFromMasterAccount",
        "guardduty:UpdateDetector"
      ],
      "Resource": "*"
    },
    {
      "Sid": "PreventSecurityHubDisable",
      "Effect": "Deny",
      "Action": [
        "securityhub:DeleteInvitations",
        "securityhub:DisableSecurityHub",
        "securityhub:DisassociateFromMasterAccount"
      ],
      "Resource": "*"
    },
    {
      "Sid": "PreventConfigDisable",
      "Effect": "Deny",
      "Action": [
        "config:DeleteConfigurationAggregator",
        "config:DeleteConfigurationRecorder",
        "config:StopConfigurationRecorder"
      ],
      "Resource": "*"
    }
  ]
}
```

**Create Policy via CLI:**

```bash
POLICY_ID=$(aws organizations create-policy \
  --name "Baseline-Security-Protection" \
  --description "Prevents disabling essential security services" \
  --type SERVICE_CONTROL_POLICY \
  --content file://scp_baseline_security.json \
  --query 'Policy.PolicySummary.Id' \
  --output text)

echo "Created policy: $POLICY_ID"
```

### 4.3 Create Cost Control Policy

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
      "Sid": "DenyExpensiveInstanceTypes",
      "Effect": "Deny",
      "Action": "ec2:RunInstances",
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "StringLike": {
          "ec2:InstanceType": [
            "p3.*",
            "p4.*",
            "x1.*",
            "x2.*",
            "u-*"
          ]
        }
      }
    }
  ]
}
```

**Create Policy:**

```bash
COST_POLICY_ID=$(aws organizations create-policy \
  --name "Cost-Control-Policy" \
  --description "Restricts expensive AWS resources" \
  --type SERVICE_CONTROL_POLICY \
  --content file://scp_cost_control.json \
  --query 'Policy.PolicySummary.Id' \
  --output text)
```

### 4.4 Create Production Protection Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PreventProductionDataDeletion",
      "Effect": "Deny",
      "Action": [
        "rds:DeleteDBInstance",
        "rds:DeleteDBCluster",
        "dynamodb:DeleteTable",
        "s3:DeleteBucket",
        "elasticache:DeleteCacheCluster"
      ],
      "Resource": "*"
    },
    {
      "Sid": "PreventDisablingLogging",
      "Effect": "Deny",
      "Action": [
        "logs:DeleteLogGroup",
        "logs:PutRetentionPolicy"
      ],
      "Resource": "arn:aws:logs:*:*:log-group:/aws/*"
    }
  ]
}
```

**Create Policy:**

```bash
PROD_POLICY_ID=$(aws organizations create-policy \
  --name "Production-Protection-Policy" \
  --description "Restricts dangerous actions in production" \
  --type SERVICE_CONTROL_POLICY \
  --content file://scp_production_protection.json \
  --query 'Policy.PolicySummary.Id' \
  --output text)
```

### 4.5 Attach Policies to OUs

**Attach Baseline Security to Root (applies everywhere):**

```bash
aws organizations attach-policy \
  --policy-id $POLICY_ID \
  --target-id $ROOT_ID
```

**Attach Cost Control to Root:**

```bash
aws organizations attach-policy \
  --policy-id $COST_POLICY_ID \
  --target-id $ROOT_ID
```

**Attach Production Protection to Production OU:**

```bash
PROD_OU=$(aws organizations list-organizational-units-for-parent \
  --parent-id $ROOT_ID \
  --filters Name=Name,Values=Production \
  --query 'OrganizationalUnits[0].Id' \
  --output text)

aws organizations attach-policy \
  --policy-id $PROD_POLICY_ID \
  --target-id $PROD_OU
```

**Verify Attachments:**

```bash
# Check policies attached to Root
aws organizations list-policies-for-target \
  --target-id $ROOT_ID \
  --filter SERVICE_CONTROL_POLICY

# Check policies attached to Production OU
aws organizations list-policies-for-target \
  --target-id $PROD_OU \
  --filter SERVICE_CONTROL_POLICY
```

---

## 🧪 Step 5: Test SCP Enforcement

### 5.1 Test: Prevent CloudTrail Deletion

**Scenario:** Try to delete CloudTrail in Production account

**First, ensure CloudTrail exists:**

```bash
# Assume role in Production account
aws sts assume-role \
  --role-arn "arn:aws:iam::123456789014:role/OrganizationAccountAccessRole" \
  --role-session-name "test-session"

# Set credentials from output
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."

# Create a CloudTrail (if needed)
aws cloudtrail create-trail \
  --name test-trail \
  --s3-bucket-name my-cloudtrail-bucket

# Now try to delete it
aws cloudtrail delete-trail --name test-trail
```

**Expected Result:**
```
An error occurred (AccessDenied) when calling the DeleteTrail operation: 
User: arn:aws:iam::123456789014:user/test is not authorized to perform: 
cloudtrail:DeleteTrail with an explicit deny in an SCO policy
```

**Success!** The SCP blocked the deletion.

### 5.2 Test: Prevent Launching in Expensive Region

**Scenario:** Try to launch EC2 in expensive region

```bash
# Try to launch in eu-west-1 (prohibited by SCP)
aws ec2 run-instances \
  --image-id ami-12345678 \
  --count 1 \
  --instance-type t3.micro \
  --region eu-west-1
```

**Expected Result:**
```
An error occurred (UnauthorizedOperation) when calling the RunInstances operation: 
You are not authorized to perform this operation. 
Encoded authorization failure message: ...
```

**Success!** The SCP prevented the expensive region usage.

### 5.3 Test: Allowed Action (Verify SCP Doesn't Block Everything)

**Scenario:** Launch EC2 in allowed region

```bash
# This SHOULD work (allowed region)
aws ec2 run-instances \
  --image-id ami-12345678 \
  --count 1 \
  --instance-type t3.micro \
  --region us-east-1
```

**Expected Result:**
```json
{
  "Instances": [
    {
      "InstanceId": "i-12345678",
      "State": { "Name": "pending" },
      ...
    }
  ]
}
```

**Success!** The SCP allows permitted actions.

**Documentation Template - Fill out your test results:**

| Test # | Action | Expected Result | Actual Result | Pass/Fail | Notes |
|--------|--------|-----------------|---------------|-----------|-------|
| 1 | Delete CloudTrail | Denied by SCP | [Your result] | [ ] | |
| 2 | Launch in eu-west-1 | Denied by SCP | [Your result] | [ ] | |
| 3 | Launch in us-east-1 | Allowed | [Your result] | [ ] | |

---

## 📊 Step 6: Enable Centralized Logging

### 6.1 Create S3 Bucket for CloudTrail

```bash
# Create bucket in Security-Logging account
aws s3api create-bucket \
  --bucket cloudtrail-logs-005965605891 \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket cloudtrail-logs-005965605891 \
  --versioning-configuration Status=Enabled

# Block public access
aws s3api put-public-access-block \
  --bucket cloudtrail-logs-005965605891 \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

### 6.2 Create Organization Trail

**Using AWS Console:**

1. Go to CloudTrail service
2. Click "Create trail"
3. Configure:
   - Name: "organization-trail"
   - S3 bucket: "cloudtrail-logs-005965605891"
   - Enable: "Log file validation"
   - Enable: "Multi-account logging" (organization trail)
4. Click "Create trail"
5. Click "Start logging"

**Using AWS CLI:**

```bash
aws cloudtrail create-trail \
  --name organization-trail \
  --s3-bucket-name cloudtrail-logs-005965605891 \
  --is-organization-trail \
  --enable-log-file-validation \
  --is-multi-region-trail

aws cloudtrail start-logging --trail-name organization-trail
```

**Verification:**

```bash
aws cloudtrail describe-trails \
  --trail-name-list organization-trail
```

---

## 📈 Step 7: Document Your Architecture

### 7.1 Create Architecture Diagram (Text-based)

Save as `architecture.txt`:

```
┌─────────────────────────────────────────────────────────────┐
│         AWS Organization (Management: 005965605891)         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  SECURITY OU (Policies: Baseline, Cost, Logging)   │    │
│  │  ┌──────────────────┐  ┌────────────────────────┐   │    │
│  │  │ Logging Account  │  │ Tools Account          │   │    │
│  │  │ (123456789012)   │  │ (123456789013)         │   │    │
│  │  │ • CloudTrail     │  │ • GuardDuty            │   │    │
│  │  │ • S3 Audit Logs  │  │ • Security Hub         │   │    │
│  │  │ • No apps        │  │ • Inspector            │   │    │
│  │  └──────────────────┘  └────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  PRODUCTION OU (Policies: Baseline, Cost, Prod)    │    │
│  │  ┌──────────────────────────────────────────────┐   │    │
│  │  │ Production-Apps Account (123456789014)       │   │    │
│  │  │ • EC2 (1x t3.micro in us-east-1)             │   │    │
│  │  │ • RDS (small db.t3.micro)                     │   │    │
│  │  │ • Highly restricted                           │   │    │
│  │  └──────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  NON-PRODUCTION OU (Policies: Baseline, Cost)      │    │
│  │  ┌─────────────────┐  ┌──────────────────────────┐ │    │
│  │  │ Dev Account     │  │ Test Account             │ │    │
│  │  │ (123456789015)  │  │ (123456789016)           │ │    │
│  │  │ • EC2 (dev)     │  │ • EC2 (test)             │ │    │
│  │  │ • Moderate      │  │ • Limited data           │ │    │
│  │  └─────────────────┘  └──────────────────────────┘ │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  SANDBOX OU (Policies: Baseline, Cost)             │    │
│  │  ┌──────────────────────────────────────────────┐   │    │
│  │  │ AttackSim-Lab Account (123456789017)         │   │    │
│  │  │ • Minimal restrictions                        │   │    │
│  │  │ • Attack simulation environment               │   │    │
│  │  │ • Isolated from others                        │   │    │
│  │  └──────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  SCP Policies Attached:                                      │
│  • Baseline-Security-Protection (Root - all accounts)       │
│  • Cost-Control-Policy (Root - all accounts)                │
│  • Production-Protection-Policy (Production OU)             │
│                                                              │
└─────────────────────────────────────────────────────────────┘

Centralized Logging:
  All accounts → CloudTrail → S3 (cloudtrail-logs-xxx)
                └→ CloudWatch Logs → Monitoring
```

### 7.2 Create Implementation Checklist

Create `implementation_checklist.md`:

```markdown
# AWS Organizations Implementation Checklist

## Phase 1: Organization Setup
- [x] Created AWS Organization
- [x] Enabled "All Features" (SCP support)
- [x] Documented Organization ID: o-xxxxxxxxxx

## Phase 2: OU Structure
- [x] Created Security OU
- [x] Created Production OU
- [x] Created NonProduction OU
- [x] Created Sandbox OU

## Phase 3: Member Accounts
- [x] Created Security-Logging Account (123456789012)
- [x] Created Security-Tools Account (123456789013)
- [x] Created Production-Apps Account (123456789014)
- [x] Created Development Account (123456789015)
- [x] Created Test Account (123456789016)
- [x] Created AttackSim-Lab Account (123456789017)
- [x] Moved all accounts to appropriate OUs

## Phase 4: Service Control Policies
- [x] Enabled SCP policy type
- [x] Created Baseline-Security-Protection policy
- [x] Created Cost-Control-Policy
- [x] Created Production-Protection-Policy
- [x] Attached Baseline-Security-Protection to Root
- [x] Attached Cost-Control-Policy to Root
- [x] Attached Production-Protection-Policy to Production OU

## Phase 5: Centralized Logging
- [x] Created S3 bucket for CloudTrail
- [x] Created organization trail
- [x] Enabled multi-account logging
- [x] Started logging

## Phase 6: Testing
- [x] Tested CloudTrail deletion prevention
- [x] Tested expensive region prevention
- [x] Verified allowed actions still work

## Phase 7: Documentation
- [x] Documented all account IDs and OUs
- [x] Created architecture diagram
- [x] Documented all SCPs and policies
- [x] Created cost estimation

## Ready for Next Module? YES - Go to Module 2!
```

### 7.3 Create Cost Tracking Spreadsheet

Create `cost_tracking.csv`:

```csv
Service,Monthly Cost,Account(s),Notes
AWS Organizations,0,All,"No charge for Organizations itself"
CloudTrail,5,Logging,"$2/100K events"
S3 Storage,10,Logging,"CloudTrail logs storage"
AWS Config,15,Logging,"$3/rule/month"
GuardDuty,10,Security-Tools,"$0.02 per million events, free trial"
Security Hub,5,Security-Tools,"$5/account/month"
Inspector,5,Security-Tools,"Vulnerability scanning"
EC2 Prod,15,Production,"t3.micro instance"
RDS Prod,20,Production,"db.t3.micro database"
EC2 Dev,15,Development,"t3.micro instance"
Miscellaneous,5,All,"Misc services"
TOTAL,105,All,"Estimated monthly cost"
```

---

## 🎯 Step 8: Real-World Scenarios

### Scenario 1: Threat Detection - Unauthorized API Call

**Situation:**
A developer's AWS access key was leaked on GitHub. An attacker uses it to try to disable GuardDuty.

**Command the attacker runs:**
```bash
aws guardduty delete-detector --detector-id 12345678
```

**What happens:**
```
An error occurred (AccessDenied) when calling the DeleteDetector operation:
User: arn:aws:iam::123456789015:root is not authorized to perform: 
guardduty:DeleteDetector with an explicit deny in a service control policy
```

**What you see in CloudTrail:**
```json
{
  "eventName": "DeleteDetector",
  "eventSource": "guardduty.amazonaws.com",
  "requestParameters": {
    "detectorId": "12345678"
  },
  "errorCode": "AccessDenied",
  "errorMessage": "User: arn:aws:iam::123456789015:root is not authorized to perform: guardduty:DeleteDetector with an explicit deny"
}
```

**Defense success:** SCP blocked the attack and logged it. You can now:
1. Rotate the compromised access key
2. Review CloudTrail for other malicious actions
3. Know GuardDuty is still active and protecting you

### Scenario 2: Cost Anomaly - Developer Mistake

**Situation:**
A junior developer accidentally launches 10 p3.8xlarge GPU instances (cost: $24/hour each!) in eu-west-1.

**Command developer runs:**
```bash
aws ec2 run-instances \
  --image-id ami-12345678 \
  --count 10 \
  --instance-type p3.8xlarge \
  --region eu-west-1
```

**What happens:**
```
An error occurred (UnauthorizedOperation) when calling the RunInstances operation:
You are not authorized to perform this operation.
Encoded authorization failure message: ...
```

**Why:**
SCP blocks both:
1. Expensive instances (p3.*) - DENIED
2. Expensive regions (eu-west-1) - DENIED

**Defense success:** SCP prevented a $240/hour mistake. Cost saved: thousands per month.

### Scenario 3: Compliance - Audit Proof

**Situation:**
Auditor asks: "Prove that production data hasn't been deleted for the past month."

**Your response:**
You can provide:
1. CloudTrail logs showing all API calls in Production account
2. SCP policy showing DeleteTable and DeleteDBInstance are blocked
3. Logs showing no successful delete attempts

**This satisfies:**
- SOC 2 audit (immutability of production data)
- PCI-DSS audit (separation of duties)
- ISO 27001 audit (change management)

---

## ✅ Verification Checklist

Before claiming this demo is complete:

- [ ] Can access AWS Organizations console
- [ ] Can list all 4 OUs
- [ ] Can list all 6 member accounts
- [ ] Accounts are properly organized in OUs
- [ ] Can list all 3 SCPs
- [ ] SCPs are attached to correct targets
- [ ] Tested CloudTrail prevention - DENIED as expected
- [ ] Tested expensive region prevention - DENIED as expected
- [ ] Tested allowed action - ALLOWED as expected
- [ ] CloudTrail is logging from all accounts
- [ ] S3 bucket has CloudTrail logs
- [ ] Created architecture diagram
- [ ] Created cost tracking spreadsheet
- [ ] Created implementation checklist
- [ ] All accounts have OrganizationAccountAccessRole

---

## 🐛 Troubleshooting

### Problem: Can't create Organization

**Error:** `AWSOrganizationsNotInUseException`

**Solution:**
- Go to AWS Console → Organizations
- Click "Create Organization"
- Wait 5-10 minutes for setup
- Retry your CLI command

### Problem: SCP Not Blocking Action

**Error:** Action succeeded even though SCP should block it

**Possible causes:**
1. SCP not attached to correct OU
2. Action happening in Management Account (SCPs don't apply)
3. IAM policy is also denying it (IAM takes precedence)

**Solution:**
```bash
# Verify SCP is attached
aws organizations list-policies-for-target \
  --target-id <OU-ID> \
  --filter SERVICE_CONTROL_POLICY

# Verify policy content
aws organizations describe-policy --policy-id <POLICY-ID>
```

### Problem: Can't Access Member Account

**Error:** `AccessDenied` when assuming role

**Solution:**
1. Verify account exists and is in OU
2. Verify OrganizationAccountAccessRole exists
3. Check your IAM permissions to assume role
4. Wait 5 minutes for role to propagate

---

## 📚 Lab Summary

**What you've built:**
- Fully functional AWS Organization with 6 member accounts
- Proper OU hierarchy for security, production, non-production, and sandbox
- 3 SCPs preventing common security issues and cost overruns
- Centralized CloudTrail logging to detect threats
- Tested all SCPs and verified they work

**What you've learned:**
- How to structure AWS accounts for defense
- How SCPs provide organization-wide security
- How to test security policies
- How to log and audit multi-account environments

**Cost incurred:** $5-15 (mostly CloudTrail and storage)

**Time invested:** 3-4 hours

**Result:** You now have a production-ready multi-account AWS environment that's secure by default.

---

## 🚀 Next Steps

1. **Module 2:** Identity & Access Management (IAM)
   - How to manage users, roles, and permissions
   - Best practices for credential management
   - Attack scenarios and defenses

2. **Ongoing:** 
   - Monitor CloudTrail logs in your organization
   - Set up CloudWatch alarms for suspicious activity
   - Review SCP effectiveness monthly

3. **Portfolio Building:**
   - Screenshot your organization structure
   - Document your SCPs and their purpose
   - Save cost calculations
   - This is resume-worthy: "Designed and implemented multi-account AWS organization with 6 accounts, SCPs, and centralized logging"

---

**Demo Status:** ✅ COMPLETE  
**Estimated Study Time:** 3-4 hours  
**Next Module:** Module 2 - Identity & Access Management (IAM)  
**Module Status:** Ready for submission to portfolio
