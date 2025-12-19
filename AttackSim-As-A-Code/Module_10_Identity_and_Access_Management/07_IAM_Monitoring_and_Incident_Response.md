# Module 10: IAM Monitoring & Incident Response - Detection & Remediation

## 📚 Monitoring IAM Events with CloudTrail

### CloudTrail Fundamentals

**What:** AWS logging service that records all API calls

**Records:**
- Who made the API call (Principal)
- When (Timestamp)
- What action (Action)
- Which resource (ResourceName)
- From where (SourceIPAddress)
- Success or failure (ErrorCode)

**Why IAM Monitoring Matters:**

```
Without CloudTrail:
  Attacker steals credentials
  Attacker accesses your data
  You don't know it happened
  Data breached silently

With CloudTrail:
  Attacker steals credentials
  Attacker accesses your data
  CloudTrail logs every action
  You detect anomaly in 10 minutes
  You disable credentials
  You limit damage
```

### Setting Up CloudTrail for IAM

```
Step 1: Enable CloudTrail

AWS Console → CloudTrail
  Click: Create Trail
  
  Trail name: iam-monitoring-trail
  S3 bucket: cloudtrail-logs-005965605891 (create new)
  Log file validation: Enable (prevents tampering)
  Include global events: Enable (IAM is global)

Step 2: Configure S3 bucket (for logs)

  Bucket policy (CloudTrail writes logs):
  {
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::cloudtrail-logs-005965605891/*"
    }]
  }

Step 3: Enable monitoring on IAM services

  Events to log:
    ☑ Management Events (IAM changes)
    ☑ Insight Events (unusual patterns)
    ☑ Data Events (S3, Lambda code changes) - optional

  API selectors:
    ReadOnlyEvents: include
    WriteOnlyEvents: include
    (Or: Select specific events you care about)

Step 4: Start logging

  CloudTrail starts recording
  All IAM changes logged to S3
  Search logs in CloudTrail console (last 90 days)
```

### CloudTrail Log Example

```json
{
  "eventVersion": "1.05",
  "userIdentity": {
    "type": "IAMUser",
    "principalId": "AIDACKCEVSQ6C2EXAMPLE",
    "arn": "arn:aws:iam::005965605891:user/alice",
    "accountId": "005965605891",
    "userName": "alice"
  },
  "eventTime": "2024-01-15T10:30:45Z",
  "eventSource": "iam.amazonaws.com",
  "eventName": "CreateAccessKey",
  "awsRegion": "us-east-1",
  "sourceIPAddress": "72.21.198.45",
  "userAgent": "aws-cli/2.0.0",
  "requestParameters": {
    "userName": "bob"
  },
  "responseElements": {
    "accessKey": {
      "accessKeyId": "AKIA1234567890ABCDEF"
    }
  },
  "requestID": "12345678-1234-1234-1234-123456789012",
  "eventID": "abcdef01-2345-6789-abcd-ef0123456789",
  "eventType": "AwsApiCall",
  "recipientAccountId": "005965605891"
}
```

**What This Shows:**
```
Who: alice (IAM user)
What: CreateAccessKey
When: Jan 15, 2024 10:30:45 UTC
Where: Created access key for bob
From: 72.21.198.45 (office IP)
Tool: AWS CLI v2
Request ID: For AWS support reference
Status: Success (accessKey returned)
```

### CloudTrail Queries

```
Find all IAM changes:
  CloudTrail Console → Events
  Filter: Event source = iam.amazonaws.com
  Show: All changes to IAM
  
Find all failed login attempts:
  Filter: Event name = ConsoleLogin
  Filter: Error code = exists
  Show: Unsuccessful console logins

Find all access key creations:
  Filter: Event name = CreateAccessKey
  Show: When access keys created, by whom

Find all policy changes:
  Filter: Event name = PutUserPolicy, PutRolePolicy, etc.
  Show: When policies changed, what changed

Find all MFA disablements:
  Filter: Event name = DeactivateMFADevice
  Show: When MFA devices deactivated
```

---

## 🚨 GuardDuty for IAM Threat Detection

### What is GuardDuty?

**GuardDuty = Threat detection service**

Analyzes:
- CloudTrail logs
- VPC Flow Logs
- DNS logs

Detects:
- Cryptocurrency mining
- Bot network activity
- Privilege escalation
- Unusual API calls
- Impossible travel
- Brute force attacks

### GuardDuty IAM Findings

#### Finding 1: UnauthorizedAPI

```
Alert: Attacker attempts action without permission

Example:
  alice has: s3:GetObject (read S3)
  alice tries: iam:CreateUser (not permitted)
  Result: UnauthorizedAPI finding
  
What it means:
  ✓ Access control is working (denied unauthorized action)
  ✗ But someone tried to exceed their permissions
  ? Was it accidental or malicious?

Response:
  1. Check CloudTrail: What was alice doing?
  2. Ask alice: Did you try to create a user?
  3. If intentional: Update alice's policy
  4. If not: Check if credentials compromised
```

#### Finding 2: EC2 Instance Credential Exfiltration

```
Alert: Credentials from EC2 instance being used elsewhere

Scenario:
  EC2 instance has IAM role (temporary credentials)
  Attacker steals credentials from instance
  Attacker uses them from external IP
  
GuardDuty detects:
  - Instance credentials used from non-AWS IP
  - Credentials used in different region
  - Credentials used for unusual API calls

Response:
  1. Revoke the instance role (force new credentials)
  2. Audit what attacker did with credentials
  3. Check for malware on instance
  4. Update instance profile policy
  5. Restrict credential access on instance
```

#### Finding 3: IAM Role Assumption Anomaly

```
Alert: Role assumed by unusual principal

Example:
  Lambda function typically assumes: s3-read-role
  But today: Lambda assumes admin-role
  
GuardDuty analyzes pattern:
  Normal: Lambda assumes s3-read-role
  Anomaly: Lambda suddenly assumes admin-role
  Alert: UnusualAssumeRoleActivity
  
Response:
  1. Check: Did code change? (redeploy)
  2. Check: Is this new functionality? (expected)
  3. Check: Is Lambda compromised? (audit logs)
  4. If unexpected: Update Lambda policy immediately
```

#### Finding 4: Policy Attached to User

```
Alert: Direct policy attached (not through group/role)

Example:
  Normally: alice in Developer group (has permissions)
  Scenario: admin attaches AdminPolicy directly to alice
  GuardDuty detects: Unusual privilege escalation
  
Why alert?
  - Users should get permissions through groups
  - Direct attachment = potential escalation
  - Might indicate compromise or error
  
Response:
  1. Check: Why was policy attached?
  2. If mistake: Remove and use group instead
  3. If intentional: Document and review quarterly
  4. If compromise: Follow incident response
```

### Enabling GuardDuty

```
AWS Console → GuardDuty
  Click: Enable

GuardDuty then:
  ✅ Analyzes CloudTrail logs (background)
  ✅ Analyzes VPC Flow Logs (background)
  ✅ Analyzes DNS logs (background)
  ✅ Generates findings (displayed in console)

Cost: ~$1-3/month per account (very cheap)

Findings appear in:
  - GuardDuty Console (dashboard)
  - CloudWatch Events (can trigger Lambda, SNS)
  - EventBridge (can route to other services)
```

---

## 📊 CloudWatch Monitoring & Alerts

### CloudWatch Metrics for IAM

**Available Metrics:**
- AccountAccessKeysPresent
- AccountMFAEnabled
- UserAccessKeysPresent
- UserMFAEnabled
- RoleAssumptionCount
- etc.

### Creating CloudWatch Alarms

**Alarm 1: Root Account Usage**

```
CloudWatch Console → Alarms → Create Alarm

Metric: Root Account Usage
Statistic: Sum
Period: 5 minutes
Threshold: >= 1 (any usage is suspicious)

When triggered:
  Action: Send SNS notification
  To: security-team@company.com
  Message: "Root account was used! Check immediately."
```

**Code/CloudFormation:**

```yaml
RootAccountAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    MetricName: RootAccountUsage
    Namespace: AWS/IAM
    Statistic: Sum
    Period: 300
    EvaluationPeriods: 1
    Threshold: 1
    ComparisonOperator: GreaterThanOrEqualToThreshold
    AlarmActions:
      - !Ref SecurityTeamSNSTopic
```

**Alarm 2: Failed Login Attempts**

```
EventPattern (CloudWatch Events):
{
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": ["ConsoleLogin"],
    "errorCode": ["Client.UnauthorizedOperation"]
  }
}

When matched:
  Trigger: Lambda function
  Action: Increment counter
  If counter > 5 in 10 minutes:
    Action: Notify security team
    Action: Trigger forensics analysis
```

**Alarm 3: Privilege Escalation Detection**

```
Pattern: User assumes admin role (unusual for them)

CloudWatch Insights Query:
  fields @timestamp, userIdentity.principalId, requestParameters.roleArn
  | filter eventName = "AssumeRole"
  | filter requestParameters.roleArn like /admin/i
  | stats count() as attempts by userIdentity.principalId
  | filter attempts > 1
```

---

## 🚨 Incident Response Playbooks

### Playbook 1: Compromised IAM User Credentials

**Trigger:** CloudTrail shows unusual activity from user

```
Step 1: Isolate (0-5 minutes)
  1. Disable user login:
     aws iam delete-login-profile --user-name alice
  
  2. Deactivate access keys:
     aws iam update-access-key-status \
         --user-name alice \
         --access-key-id AKIA1234567890ABCDEF \
         --status Inactive
  
  3. Force logout:
     aws sts revoke-session-token \
         --session-token <token>

Step 2: Assess Damage (5-30 minutes)
  1. Query CloudTrail for actions by user:
     aws cloudtrail lookup-events \
         --attribute-key Username \
         --attribute-value alice \
         --start-time 2024-01-15T00:00:00Z
  
  2. Check what resources were accessed:
     - S3 buckets read (data exfiltration?)
     - EC2 instances accessed (lateral movement?)
     - IAM changes made (privilege escalation?)
     - Secrets accessed (API keys stolen?)
  
  3. Determine scope of compromise:
     - How long were credentials active?
     - What damage could have occurred?
     - Was data exfiltrated?

Step 3: Contain (30-60 minutes)
  1. Revoke any cross-account access:
     - If alice has assume-role on other accounts
     - Disable that role temporarily
  
  2. Audit related credentials:
     - If alice used API keys with other users
     - Check those users for compromise
  
  3. Review automation:
     - If alice's credentials in CI/CD pipeline
     - Disable and recreate pipeline credentials

Step 4: Eradicate (1-4 hours)
  1. Create new credentials for alice:
     aws iam create-access-key --user-name alice
  
  2. Reset password:
     aws iam update-login-profile \
         --user-name alice \
         --password <new-temporary-password>
  
  3. Force MFA re-enrollment:
     (User must set up new MFA device)

Step 5: Recovery (4-24 hours)
  1. Return access gradually:
     - First, console only
     - Test MFA works
     - Then, new access keys
  
  2. Monitor heavily:
     - More frequent CloudTrail checks
     - Alert on any unusual activity
  
  3. Conduct forensics:
     - When were credentials stolen?
     - How (code repo, email, laptop)?
     - Could attacker still have access?

Step 6: Post-Incident (1 week)
  1. Document incident:
     - Timeline
     - What happened
     - What was compromised
     - How it was detected
     - How it was contained
     - What was exposed
  
  2. Root cause analysis:
     - Why were credentials exposed?
     - Could this have been prevented?
  
  3. Implement improvements:
     - Better secret scanning
     - Shorter key rotation
     - Better monitoring
     - User training
```

### Playbook 2: Unauthorized IAM Policy Change

**Trigger:** CloudTrail shows policy attached by unexpected user

```
Step 1: Immediate (0-2 minutes)
  1. Verify incident:
     aws iam list-user-policies --user-name alice
     aws iam list-attached-user-policies --user-name alice
     (Check for unexpected policies)
  
  2. If real: Revert the change:
     aws iam delete-user-policy \
         --user-name alice \
         --policy-name UnauthorizedPolicy

Step 2: Investigate (2-15 minutes)
  1. Who made change?
     aws cloudtrail lookup-events \
         --attribute-key EventName \
         --attribute-value PutUserPolicy \
         --start-time 2024-01-15T10:00:00Z
  
  2. When was it made?
     (Get exact timestamp)
  
  3. Was it legitimate?
     (Contact the person who made the change)

Step 3: Determine Impact
  1. Did alice actually use the new permissions?
     aws cloudtrail lookup-events \
         --attribute-key Username \
         --attribute-value alice \
         --start-time <after-policy-added>
     (Check what alice did after policy was added)
  
  2. If alice used unauthorized permissions:
     - Review actions taken
     - Assess damage
     - Determine if credentials compromised
  
  3. If alice didn't use permissions:
     (It was caught early, minimal damage)

Step 4: Prevent Recurrence
  1. Review IAM policies:
     Who can attach/modify policies?
     Should we restrict to fewer people?
  
  2. Implement access controls:
     Require MFA for policy changes
     Require approval workflow
     Restrict iam:PutUserPolicy (only admins)
  
  3. Set up monitoring:
     Alert on all policy changes
     Require documentation
     Review quarterly
```

### Playbook 3: Excessive Permission Usage

**Trigger:** User with read-only role accessing sensitive operations

```
Step 1: Confirm Anomaly (0-5 minutes)
  
  User alice (role: Analyst, read-only)
  Detected: alice called s3:DeleteObject
  Expected: alice should only call s3:GetObject
  
  Possibilities:
    ✓ Credentials compromised
    ✓ Role policy changed (unauthorized)
    ✓ User assumed different role
    ✓ Alert is false positive

Step 2: Investigate (5-20 minutes)
  
  1. Check alice's current policies:
     aws iam list-attached-user-policies --user-name alice
     (Confirm she still has read-only role)
  
  2. Check CloudTrail for s3:DeleteObject:
     Was it by alice (user credentials)?
     Or by assumed role (service)?
  
  3. Check for role assumption:
     Did alice assume a different role?
     When and why?
  
  4. Interview alice:
     Did you try to delete S3 objects?
     Is this new responsibility?
     Did someone ask you to do this?

Step 3: Respond
  
  If accidental:
    - Update alice's policy to include s3:DeleteObject
    - Document new responsibility
    - Continue monitoring
  
  If compromised:
    - Follow "Compromised Credentials" playbook
    - Disable and recreate credentials
    - Audit what was deleted
  
  If unauthorized:
    - Investigate who requested the change
    - Revert policy to read-only
    - File security incident
    - Notify management
```

---

## ✅ Monitoring & Response Checklist

**CloudTrail Setup:**
- [ ] CloudTrail enabled in all regions
- [ ] Logs stored in S3 with bucket policy
- [ ] Log file validation enabled
- [ ] Global events enabled (IAM, organizations)
- [ ] CloudTrail logs stored for > 1 year
- [ ] IAM changes logged specifically

**GuardDuty:**
- [ ] GuardDuty enabled
- [ ] Findings reviewed weekly
- [ ] CloudWatch Events configured for GuardDuty findings
- [ ] Lambda or SNS triggers implemented
- [ ] Findings exported to SIEM

**CloudWatch Monitoring:**
- [ ] Root account usage alarm
- [ ] Failed login attempts alarm
- [ ] Policy change alarm
- [ ] Access key creation alarm
- [ ] Unusual role assumption alarm
- [ ] Alarms tested (send test alert)

**Incident Response:**
- [ ] Incident response plan documented
- [ ] Playbooks created for common scenarios
- [ ] Response team trained
- [ ] Escalation path defined
- [ ] Communication plan established
- [ ] Post-incident review process defined

**Forensics:**
- [ ] CloudTrail available for investigation
- [ ] CloudTrail logs immutable (S3 object lock)
- [ ] Tools available to query logs
- [ ] Forensics documentation templates
- [ ] Retention policy (keep logs > 2 years)

---

**Capstone:** `PORTFOLIO_Interview_Resume.md` - Portfolio projects and interview prep
