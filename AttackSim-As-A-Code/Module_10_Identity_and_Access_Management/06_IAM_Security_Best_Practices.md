# Module 10: IAM Security Best Practices - Hardening Your Access Control

## 📚 Root Account Security - First Priority

### Why Root Account Matters

**Root Account = Owner of entire AWS account**

```
Permissions:
  ✅ Full access to everything
  ✅ Cancel account
  ✅ Change payment method
  ✅ Close account
  ✅ No limits or restrictions

Comparison:
  Root Account: 🔓 Vault Master Key (open everything)
  Admin User: 🔑 Manager Key (very powerful, limited)
  Developer: 🗝️ Employee Key (specific rooms only)
  
If vault master key stolen:
  ❌ Attacker owns entire account
  ❌ Can delete all resources
  ❌ Can change payment
  ❌ Can close account
```

### Root Account Hardening - Step by Step

**Step 1: Create Root Account MFA (FIRST AND FOREMOST)**

```
AWS Console (logged in as root):
  → Account in top-right
  → Security Credentials
  → MFA
  → Manage MFA device
  → Virtual device (recommended)
  → Scan QR code with Google Authenticator/Authy
  → Enter 2 consecutive 6-digit codes
  → Done! Test it

Why MFA first?
  If someone gets root password later
  They still can't access root account
  They need your phone/authenticator app
```

**Step 2: Create IAM Admin User**

```
AWS Console (root account):
  → IAM
  → Users
  → Create User
  
Name: admin
  Description: AWS Account Administrator
  Tags: 
    - CreatedDate: 2024-01-15
    - Purpose: Daily Admin Access
  
Access type:
  ☑ Console access
  ☐ Programmatic access (NO - don't create access key yet)

Attach policy:
  AdministratorAccess (full permissions)
  
Done! Write down:
  - Username: admin
  - Password (temporary)
  - Console login URL
  - Do NOT share
```

**Step 3: Enable MFA on Admin User**

```
AWS Console (admin user):
  → My Security Credentials
  → MFA
  → Assign MFA device
  → Virtual device
  → Scan QR code
  → Done! Test it
```

**Step 4: Enable Root Account Billing Alerts**

```
AWS Console (root account):
  → Billing
  → Billing preferences
  → Alert preferences
  
☑ Receive Billing Alerts
☑ Receive AWS Free Tier Alerts

Email: admin@company.com

Why?
  If attacker compromises account
  They might incur charges
  You get instant alert
  Can stop instance before bill is huge
```

**Step 5: Lock Down Root Account**

```
✅ Enable MFA (done)
✅ Create IAM admin (done)
✅ Login to root account (test MFA works)

Now:
  → Sign out
  → Lock root credentials away
  
Where to store:
  ✅ Password manager (1Password, LastPass, Bitwarden)
  ✅ Encrypted USB drive (offline)
  ✅ Physical safe (printed password)
  
NOT:
  ❌ Sticky note on monitor
  ❌ Unencrypted text file
  ❌ Email
  ❌ Slack message
  ❌ GitHub repository

Recovery process (if needed):
  1. Request account recovery
  2. AWS sends code to registered email
  3. Verify code
  4. Can reset MFA device
  5. Can reset password
```

**Step 6: Use IAM Admin for Daily Work**

```
Never use root account except:
  ☑ Enable MFA (you did this)
  ☑ Create billing alerts (you did this)
  ☑ Update root password (once yearly)
  ☑ Change AWS support plan
  ☑ Close account
  ☑ Change associated AWS account email
  ☑ Create organization (if using AWS Organizations)
  
For everything else:
  → Login with admin user
  → If admin not enough: Create specific role
  → Assume role for specific task
  → Done! Switch back to admin
```

### Root Account Compromise Response

```
If you suspect root account compromised:

Immediate (5 minutes):
  1. Change root password (get into account ASAP)
  2. Replace MFA device (old one might be compromised)
  3. Review CloudTrail (what did attacker do?)
  4. Check billing (any unusual charges?)

Short-term (1 hour):
  1. Disable all IAM user access keys > 90 days old
  2. Review IAM user permissions (did attacker create user?)
  3. Force password reset for all users
  4. Review EC2 instances (did attacker launch instances?)
  5. Review S3 buckets (did attacker modify bucket policy?)

Medium-term (1 day):
  1. Review all CloudTrail logs (full event history)
  2. Create forensics report (what happened and how?)
  3. Audit role assumptions (who accessed what?)
  4. Update IAM policies (did attacker escalate permissions?)
  5. Notify AWS support (especially if not your fault)

Long-term (1 week):
  1. Implement additional controls
  2. Review and harden all IAM policies
  3. Implement access analyzer
  4. Consider changing AWS account (if fully compromised)
```

---

## 🔐 Least Privilege Principle - Deep Implementation

### Least Privilege at Different Layers

```
Layer 1: Identity
  Give alice: Developer role
  Don't give: Admin role

Layer 2: Action
  Give alice: s3:GetObject, s3:PutObject
  Don't give: s3:DeleteObject, s3:*

Layer 3: Resource
  Give alice: arn:aws:s3:::dev-bucket/*
  Don't give: arn:aws:s3:::prod-bucket/*

Layer 4: Condition
  Give alice: Access during business hours
  Don't give: Access at 3 AM

Layer 5: Duration
  Give alice: 15-minute session
  Don't give: 12-hour session
```

### Permission Boundary Implementation

```
CEO role (without boundary):
  Policy: AdministratorAccess (can do anything)
  Risk: 
    ✅ Powerful (can do their job)
    ❌ Too powerful (can break things)

CEO role (with permission boundary):
  Identity Policy: AdministratorAccess
  Permission Boundary:
    - Allow: s3:*, ec2:*, rds:*, cloudformation:*
    - Deny: iam:*, organizations:*, billing:*
  
  Effective: Can do admin on data services, but not identity/org/billing

Implementation:
  1. Create boundary policy:
     {
       "Statement": [
         {"Effect": "Allow", "Action": ["s3:*", "ec2:*"]},
         {"Effect": "Deny", "Action": ["iam:*", "billing:*"]}
       ]
     }
  
  2. Attach boundary to role:
     Role: CEO
     Permissions Boundary: DataOwnerBoundary
  
  3. Add identity policy:
     (Can attach any policy within boundary)
  
  4. Result:
     CEO can do anything in S3/EC2 (within boundary)
     CEO cannot touch IAM or billing (blocked by boundary)
```

### Access Analyzer - Find Over-Permissive Access

```
What: AWS service that analyzes IAM policies

Why: Find permissions you didn't know you granted

Example:
  S3 bucket policy:
    Principal: "*" (anyone)
    Action: s3:GetObject
    Resource: arn:aws:s3:::public-website/*
  
  Is this intentional? (website is public) → OK
  Or accidental? (forgot to restrict to employees) → Alert!

How to use:

  AWS Console → IAM Access Analyzer
  
  Click: Analyze with Access Analyzer
  
  Results show:
    ✅ Resources with external access (intentional?)
    ⚠️ Resources with overly permissive access
    ✅ Resources with no external access
  
  Example findings:
    - S3 bucket allows public upload (✅ maybe intentional)
    - S3 bucket allows any AWS principal (❌ should be specific)
    - KMS key allows decrypt to anyone (❌ should restrict)
    - Lambda role allows iam:* (❌ should limit actions)

Workflow:
  1. Run analyzer (analyzes all policies)
  2. Review findings
  3. Decide: Intentional or accidental?
  4. Fix: Update policy if not intentional
  5. Archive: Mark as reviewed if intentional
```

---

## 📋 IAM Policy Audit & Review

### Quarterly Access Review

```
Every 90 days, review:

1. IAM Users:
   Who still needs access?
   Who hasn't logged in for 90 days?
   → Disable or delete?

2. Access Keys:
   All keys rotated < 90 days?
   All keys in use?
   → Delete unused keys
   → Rotate old keys

3. Cross-Account Access:
   Still needed?
   Still appropriate?
   → Update trust policies
   → Remove unnecessary access

4. Privileged Roles:
   Who has admin access?
   Who actually needs it?
   → Remove from unnecessary users
   → Use role assumption instead

5. Federated Users:
   Users in directory still employed?
   Contractors still under contract?
   → Sync with directory
   → Revoke if needed

CLI command to find old access keys:

  aws iam get-credential-report | jq '..'
  
  Fields of interest:
    access_key_1_active (boolean)
    access_key_1_last_rotated (date)
    access_key_2_active (boolean)
    access_key_2_last_rotated (date)
  
  Check:
    ✅ All old keys are inactive
    ✅ Active keys rotated < 90 days
    ✅ No users with unused keys
```

### Detecting Suspicious Access

```
CloudTrail alerts for:

🔴 CRITICAL: Root account usage
   Alert if: root account does anything
   Response: Check if intentional
   Possible: Someone has root password!

🔴 CRITICAL: Privilege escalation
   Alert if: User assumes admin role (who normally has dev role)
   Response: Contact user immediately
   Possible: Unauthorized escalation or emergency access

🟠 WARNING: Unusual action
   Alert if: User uploads to S3 (who normally doesn't)
   Response: Check with user
   Possible: Compromised credentials or new responsibility

🟠 WARNING: Unusual location
   Alert if: User logs in from new country
   Response: Check with user
   Possible: Traveling or compromise

🔵 INFO: Access from unusual IP
   Alert if: User accesses from IP range (check VPN or travel)
   Response: Verify with user
   Possible: Normal travel or compromise

Automation example:
  CloudWatch Event Rule:
    Event: console.amazonaws.com "AssumeRole"
    Filter: RoleArn contains "Admin"
    Action: SNS notification to security team
    
  Result: Instant alert when admin role assumed
```

---

## 🔍 Password & Key Rotation

### IAM User Password Rotation

```
Requirement: Change password every 90 days

Automated approach:
  
  1. IAM Console → Password Policy
     ☑ Minimum length: 14 characters
     ☑ Require numbers: Yes
     ☑ Require symbols: Yes
     ☑ Require uppercase: Yes
     ☑ Require lowercase: Yes
     ☑ Require MFA: Optional but recommended
     ☑ Password expiration: 90 days
  
  2. User receives: Email reminder at 90 days
  
  3. User must: Change password before expiration
  
  4. After expiration:
     User cannot: Login (password expired)
     User can: Request password reset
     IT must: Reset password (temporary)

CLI to force password change:

  aws iam delete-login-profile --user-name alice
  # Forces password reset on next login
```

### Access Key Rotation

```
Requirement: Rotate access keys every 90 days

Scenario: alice has 2 access keys (allowed maximum)

Key 1: AKIA1234567890ABCDEF
  Created: Jan 1
  Age: 90 days (TIME TO ROTATE!)
  Status: Active

Key 2: (none yet)

Process:

Step 1: Create new key (in IAM)
  IAM Console → Users → alice
  Security Credentials → Create Access Key
  
  Key 2: AKIA9876543210ZYXWVU
  Created: Apr 1
  Status: Active

Step 2: Update all applications
  Lambda env vars: Update to Key 2
  CI/CD secrets: Update to Key 2
  SDK code: Update to Key 2
  Local development: Update to Key 2
  
  Test: All applications work with Key 2

Step 3: Deactivate old key
  IAM Console → Users → alice
  Make Key 1 Inactive (don't delete yet!)
  
  Wait: 7 days (ensure no application uses old key)
  
  Monitor: CloudTrail logs (confirm Key 1 not used)

Step 4: Delete old key
  After 7 days
  Delete Key 1 permanently
  
  Confirm: Key 1 no longer in system

Step 5: Next rotation (90 days later)
  Create Key 3
  Update all applications
  Deactivate Key 2
  Delete Key 2 after 7 days
```

---

## 🛡️ Incident Response - Compromised Credentials

### Immediate Response (< 5 minutes)

```
1. Disable credentials
   aws iam update-access-key-status \
       --user-name alice \
       --access-key-id AKIA1234567890ABCDEF \
       --status Inactive

2. Force password reset
   aws iam delete-login-profile --user-name alice
   (User must set new password on next login)

3. Check CloudTrail
   aws cloudtrail lookup-events \
       --attribute-key ResourceName \
       --attribute-value alice
   (What did alice do with those credentials?)

4. Notify user
   "Your AWS credentials may be compromised"
   "Please change your password"
   "Contact security team"
```

### Short-term Response (1 hour)

```
1. Review all actions taken with compromised credentials
   aws cloudtrail lookup-events \
       --attribute-key PrincipalId \
       --attribute-value <alice-principal-id>
   
   Look for:
     - Resources created (EC2, S3 buckets)
     - Security group changes
     - IAM policy changes
     - Data downloads (S3, RDS)

2. Assess damage
   What could attacker do with alice's permissions?
   What did they actually do?
   
   Example assessment:
     Attacker accessed: S3 bucket with customer data
     Attacker actions: ListBucket (data exfiltration risk?)
     Attacker risk: Could have downloaded customer PII
     
3. Take containment action
   - Delete any unauthorized resources
   - Revert any unauthorized changes
   - Change credentials of users alice trusts
   - Audit cross-account access (if alice has assume role)

4. Create new credentials for alice
   aws iam create-access-key --user-name alice
   (Give alice new credentials)
```

### Long-term Response (1 day - 1 week)

```
1. Forensic analysis
   - How were credentials exposed?
   - Was code committed to GitHub?
   - Were credentials logged somewhere?
   - Did someone share them?
   
2. Prevent recurrence
   - If code: Enable secret scanning on GitHub
   - If email: Improve email security
   - If device: Check for malware
   - If carelessness: Provide training

3. Update security policies
   - Require shorter access key lifetime?
   - Require STS instead of long-term keys?
   - Require MFA for sensitive operations?
   - Increase monitoring?

4. Implement detection
   - CloudTrail alerts for unusual activity
   - GuardDuty for anomaly detection
   - Access Analyzer for policy changes
   - IAM audit for permission creep
```

---

## ✅ IAM Security Best Practices Checklist

**Root Account:**
- [ ] MFA enabled on root account
- [ ] Root password strong and stored securely
- [ ] IAM admin user created
- [ ] MFA enabled on admin user
- [ ] Billing alerts configured
- [ ] Root account not used for daily work

**Users & Access:**
- [ ] No shared users (one user per person)
- [ ] All passwords meet complexity requirements
- [ ] MFA enabled for all users
- [ ] Access keys rotated every 90 days
- [ ] Unused keys deleted promptly
- [ ] Permissions reviewed quarterly

**Policies & Roles:**
- [ ] Least privilege implemented (minimum permissions)
- [ ] Permission boundaries on privileged roles
- [ ] No wildcard (*) in actions (be specific)
- [ ] Resource-based policies reviewed
- [ ] Session policies used for temporary privilege
- [ ] Explicit denies used where appropriate

**Cross-Account & Federation:**
- [ ] Cross-account trust reviewed
- [ ] ExternalId used for partner access
- [ ] MFA required for sensitive role assumption
- [ ] Session duration limited appropriately
- [ ] Federation certificates valid and monitored

**Monitoring & Audit:**
- [ ] CloudTrail enabled (all regions, all APIs)
- [ ] CloudTrail logs stored in S3 (immutable)
- [ ] Access Analyzer run quarterly
- [ ] Suspicious activity alerts configured
- [ ] Unusual credential usage detected
- [ ] Privilege escalation attempts alerted

**Incident Response:**
- [ ] Incident response plan documented
- [ ] Breach notification process defined
- [ ] Credentials quickly disableable
- [ ] Forensics capability available
- [ ] Communication plan (who to notify)
- [ ] Lessons learned process in place

---

**Next:** `07_IAM_Monitoring_and_Incident_Response.md` - CloudTrail, GuardDuty, playbooks
