# Module 10: Temporary Credentials & Sessions - STS Deep Dive

## 📚 STS Service Overview

### What is STS (Security Token Service)?

**STS = AWS service that issues temporary credentials**

```
Similar to:
  Passport office issues temporary travel visa
  Bank issues temporary debit card
  Hotel issues temporary key card to room
  
AWS STS:
  Issues temporary AWS credentials
  Valid for limited time (15 min - 12 hours)
  Can be limited to specific actions/resources
  Auto-revocable
```

### Why Temporary Credentials?

**With Long-Term Credentials (Access Keys):**
```
alice has: AKIA1234567890ABCDEF (access key)
           wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY (secret)

Problems:
❌ Valid forever (until rotated or disabled)
❌ If leaked, attacker has unlimited time
❌ Hard to rotate (update everywhere)
❌ No expiration date
❌ Scope: All actions (unless policy restricts)

Real incident:
  Developer committed access key to GitHub
  Attacker found it (5 minutes later)
  Attacker had 24 hours before key rotated
  Stole $50K in compute
```

**With Temporary Credentials (STS Tokens):**
```
alice assumes role → STS returns:
  AccessKey: ASIA1234567890ABCDEF
  SecretKey: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
  SessionToken: FwoGZXIvYXdzEL...8EIzqU= (proves temporary)
  Expiration: 2024-01-15 11:00:00 UTC (1 hour from now)

Advantages:
✅ Valid only 1 hour (not forever)
✅ If leaked, attacker has 1 hour
✅ SessionToken proves it's temporary
✅ Auto-expires (no rotation needed)
✅ Scope: Limited by role policy
✅ Real incident: Same scenario
   But credentials expire after 1 hour
   Attacker stole $200 (caught and revoked)
   Much less damage
```

---

## 🔑 Types of Temporary Credentials

### 1. AssumeRole - STS:AssumeRole

**Who uses it:** Users, services, cross-account roles

**When:** Normal operational access

```
Example: Developer needs S3 access

Process:
  1. alice calls: sts:AssumeRole
  2. RoleArn: arn:aws:iam::005965605891:role/Developer-S3
  3. RoleSessionName: alice-session
  4. DurationSeconds: 3600 (1 hour)
  
  5. AWS checks:
     - Does alice have sts:AssumeRole permission? YES
     - Does role trust alice? YES
     - Is duration valid? YES (3600 < max 12 hours)
  
  6. STS returns:
     {
       "AssumedRoleUser": {
         "AssumedRoleId": "AROA....:alice-session",
         "Arn": "arn:aws:sts::005965605891:assumed-role/Developer-S3/alice-session"
       },
       "Credentials": {
         "AccessKeyId": "ASIA....",
         "SecretAccessKey": "....",
         "SessionToken": "FwoGZXI....",
         "Expiration": "2024-01-15T11:00:00Z"
       }
    }
  
  7. alice uses credentials for 1 hour
  
  8. After 1 hour: Credentials expire
     alice must assume role again (re-authenticate)
```

**Code Example:**

```python
import boto3

# Create STS client
sts = boto3.client('sts')

# Assume role
response = sts.assume_role(
    RoleArn='arn:aws:iam::005965605891:role/Developer-S3',
    RoleSessionName='alice-work-session',
    DurationSeconds=3600
)

# Extract credentials
access_key = response['Credentials']['AccessKeyId']
secret_key = response['Credentials']['SecretAccessKey']
session_token = response['Credentials']['SessionToken']
expires = response['Credentials']['Expiration']

# Use temporary credentials
s3 = boto3.client('s3',
    aws_access_key_id=access_key,
    aws_secret_access_key=secret_key,
    aws_session_token=session_token
)

# Can now use S3
s3.list_buckets()

# After 1 hour: Must assume role again
```

### 2. AssumeRoleWithSAML

**Who uses it:** Federated users (enterprise SSO)

**When:** SAML federation from Okta, Azure AD, etc.

```
Example: alice@company.com via Okta

Flow:
  1. alice logs into Okta
  2. Okta generates SAML assertion
  3. Assertion includes:
     - alice@company.com
     - groups: [engineering, aws-users]
     - AuthenticationInstant: now
     - SessionNotOnOrAfter: 1 hour
  
  4. alice (via browser) sends SAML to AWS
  
  5. AWS calls: sts:AssumeRoleWithSAML
     Principal: Okta SAML provider
     SAML assertion: ...
     RoleArn: arn:aws:iam::005965605891:role/Developer-Role
  
  6. AWS checks:
     - Is SAML signature valid? YES
     - Is assertion not expired? YES
     - Does role trust Okta? YES
  
  7. STS returns: Temporary credentials
  
  8. alice uses AWS Console for 12 hours
  
  9. alice logs out: Session ends
     Credentials revoked
```

### 3. AssumeRoleWithWebIdentity

**Who uses it:** External identity (GitHub, Google, Cognito)

**When:** CI/CD, mobile apps, web apps

```
Example: GitHub Actions deploying to AWS

Flow:
  1. GitHub Actions workflow starts
  
  2. GitHub generates OpenID Connect (OIDC) token
     Content:
     {
       "iss": "https://token.actions.githubusercontent.com",
       "sub": "repo:my-org/my-app:ref:refs/heads/main",
       "aud": "sts.amazonaws.com",
       "iat": 1705324800,
       "exp": 1705325400,  // 10 min validity
       "repository": "my-org/my-app",
       "repository_owner": "my-org"
     }
  
  3. CI/CD calls: sts:AssumeRoleWithWebIdentity
     WebIdentityToken: <OIDC token>
     RoleArn: arn:aws:iam::005965605891:role/GitHub-Deploy-Role
  
  4. AWS verifies:
     - Is token from github.com? YES
     - Is token not expired? YES (10 min old)
     - Does role trust github.com? YES
     - Are conditions met? (repo owner = my-org?) YES
  
  5. STS returns: Temporary credentials (15 min)
  
  6. CI/CD deploys to S3
  
  7. After 15 min: Credentials expire
     Next deployment: GitHub generates new token
     Process repeats
```

**Code (GitHub Actions):**

```yaml
name: Deploy

on: [push]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: arn:aws:iam::005965605891:role/GitHub-Deploy
          aws-region: us-east-1
      
      - run: aws s3 sync . s3://my-app-bucket/
```

### 4. GetSessionToken

**Who uses it:** Users requiring temporary credentials

**When:** MFA enforcement, temporary access elevation

```
Example: admin wants root account session with MFA

Flow:
  1. admin calls: sts:GetSessionToken
     SerialNumber: arn:aws:iam::005965605891:mfa/admin-mfa-device
     TokenCode: 123456 (from MFA device)
     DurationSeconds: 3600
  
  2. AWS checks:
     - Is MFA device active? YES
     - Is token code correct? YES
     - Is token not expired? YES
  
  3. STS returns: Temporary credentials with MFA proof
     Credentials valid only with MFA confirmation
  
  4. admin can now:
     sts:AssumeRole (without re-MFA if within session)
     
  5. CloudTrail shows:
     Principal: root account
     Action: GetSessionToken (with MFA)
     Status: Success
```

---

## ⏱️ Credential Lifetime & Duration

### Duration Limits

```
Role Maximum Duration (set during role creation):
  Default: 1 hour
  Maximum: 12 hours (43,200 seconds)
  Minimum: 15 minutes

When assume role:
  Can request duration UP TO maximum
  But not beyond

Example:
  Role max duration: 1 hour
  
  Request 30 min:
    OK ✅
  
  Request 2 hours:
    DENIED ❌ (exceeds max)
  
  Request 1 hour:
    OK ✅

Reason:
  Short-lived credentials = more secure
  If credentials leaked, damage limited
```

### Session vs Token Expiration

```
Temporary Credentials expire in two ways:

1. Session Expiration:
   - Set when credentials created
   - Example: "Expires in 1 hour"
   - After expiration: Credentials invalid
   - Must assume role again to get new creds

2. Token Revocation:
   - Immediate, before expiration
   - Triggered by: Policy change, breach response, etc.
   - Example: Compromised credentials detected
   - Old credentials: Immediately invalid
   - User must assume role again

Timeline Example:
  10:00 AM - alice assumes role (1 hour duration)
  Credentials valid until: 11:00 AM
  
  10:30 AM - alice's role policy changed
  New policy: Can only access S3 (not EC2)
  CloudTrail: New permissions (S3-only) apply
  
  alice uses EC2 at 10:35 AM:
    Old credentials still valid (expire at 11:00)
    BUT policy changed at 10:30
    New policy doesn't allow EC2
    EC2 action: DENIED
  
  alice uses S3 at 10:35 AM:
    Old credentials valid
    New policy allows S3
    S3 action: ALLOWED
  
  11:00 AM - Credentials expire
  alice needs: New credentials
  alice assumes role again
  Gets: New credentials with new policy
```

---

## 🔐 Session Policies - Additional Restrictions

**What:** Policy applied ON TOP of role policy (further restriction)

**Why:** Prevent privilege escalation

```
Scenario:
  alice has role: PowerUser
  PowerUser policy: s3:*, ec2:*, iam:*
  
  alice needs: Temporary access to only S3
  
  Solution: Session policy
  
AssumeRole call with SessionPolicy:
  {
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }]
  }

Result:
  Role policy: s3:*, ec2:*, iam:*
  Session policy: s3:*
  Effective: s3:* (intersection)
  
  alice CAN: s3:GetObject, s3:PutObject
  alice CANNOT: ec2:DescribeInstances (blocked by session policy)
  alice CANNOT: iam:CreateUser (blocked by session policy)
```

**Code Example:**

```python
sts = boto3.client('sts')

response = sts.assume_role(
    RoleArn='arn:aws:iam::005965605891:role/PowerUser',
    RoleSessionName='alice-limited-session',
    DurationSeconds=3600,
    Policy=json.dumps({  # Session policy (restriction)
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }]
    })
)

# alice now has credentials
# Limited to S3 only
```

---

## 🛡️ Credential Management Best Practices

### 1. Request Minimum Duration

```
❌ BAD:
   assume_role(
       RoleArn='...',
       DurationSeconds=43200  // 12 hours
   )
   
   Credentials valid for 12 hours
   If leaked, attacker has 12 hours

✅ GOOD:
   assume_role(
       RoleArn='...',
       DurationSeconds=900  // 15 minutes
   )
   
   Credentials valid for 15 minutes
   If leaked, attacker has 15 minutes
   
   When credentials expire:
     Request new ones (automatic re-auth)
```

### 2. Use Session Policies

```
❌ BAD:
   Assume PowerUser role
   Perform limited task
   
   What if role policy changes?
   What if attacker gets credentials?
   Attacker has PowerUser access

✅ GOOD:
   Assume PowerUser role
   Add session policy: s3:* only
   Perform limited task
   
   Even if attacker gets credentials:
   Attacker limited to S3 (by session policy)
   Cannot access EC2, RDS, IAM, etc.
```

### 3. Audit All Credential Creation

```
CloudTrail Events:
  - AssumeRole
  - AssumeRoleWithSAML
  - AssumeRoleWithWebIdentity
  - GetSessionToken

Monitor for:
  ✅ Unusual source IPs
  ✅ Unusual times (2 AM credentials assumed)
  ✅ Unusual roles (admin role assumed by automated user)
  ✅ Unusual duration (max duration every time)

Alert on:
  🔴 AssumeRole from 10 different IPs in 1 minute
  🔴 GetSessionToken followed immediately by AdminAccess action
  🔴 AssumeRole to privileged role at unusual time
```

### 4. Credential Rotation for Applications

```
Lambda function using STS:

Good approach:
  1. Lambda starts
  2. Lambda calls: sts:AssumeRole
  3. Gets temporary credentials
  4. Uses credentials for function duration
  5. Lambda ends
  6. Credentials expire
  7. Next invocation: Fresh credentials

Bad approach:
  1. Lambda starts
  2. Lambda hardcodes AWS access key
  3. Uses key for all invocations
  4. Key valid forever (until rotated manually)
  5. If key leaked, attacker has unlimited access

Better for long-running processes:
  1. Process calls: sts:AssumeRole (every 30 min)
  2. Gets fresh credentials (valid 1 hour)
  3. Uses credentials (30 min before they expire)
  4. Repeats process
  5. Old credentials never used after 1 hour
```

---

## 📊 Credential Scope & Limitations

### STS Credential Restrictions

```
Temporary credentials (from STS) cannot:
❌ Call iam:CreateUser (create new users)
❌ Call iam:CreateAccessKey (create access keys)
❌ Call organizations:* (modify organizations)
❌ Call account:* (change account settings)

Why? To prevent privilege escalation:
  If attacker gets temporary credentials
  Attacker cannot create new permanent user
  Attacker cannot create new access key
  Attacker cannot take over account

If you need to create users:
✅ Use long-term credentials (access key)
✅ Store in secure location (password manager)
✅ Rotate every 90 days
✅ Audit who creates users (CloudTrail)
```

### Region-Specific Tokens

```
Some tokens are region-specific:
  AssumeRole credentials: Global (work in any region)
  GetSessionToken credentials: Global

But role policies can restrict:
  "Condition": {
    "StringEquals": {
      "aws:RequestedRegion": "us-east-1"
    }
  }

Result:
  Credentials work in any region (technically)
  But role policy blocks access outside us-east-1
  User cannot access eu-west-1 resources
```

---

## ✅ Credential & Session Checklist

- [ ] Understand difference: Access keys vs STS tokens
- [ ] Always use temporary credentials (STS)
- [ ] Request minimum duration needed
- [ ] Use session policies for further restriction
- [ ] Audit all credential creation (CloudTrail)
- [ ] Monitor for anomalies
- [ ] Rotate long-term credentials (90 day cycle)
- [ ] Test credential expiration handling
- [ ] Implement automatic credential refresh
- [ ] Document credential requirements per service
- [ ] Plan for credential breach response

---

**Next:** `06_IAM_Security_Best_Practices.md` - Root account, least privilege, access analyzer
