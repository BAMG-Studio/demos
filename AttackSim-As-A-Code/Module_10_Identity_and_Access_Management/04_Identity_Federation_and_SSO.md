# Module 10: Identity Federation & SSO - Enterprise Integration

## 📚 Why Federation?

### The Problem: Credential Proliferation

**Before Federation:**
```
Employee: alice@company.com

Systems they access:
  1. Company email (Outlook) → username: alice, password: P@ssw0rd123
  2. Company Slack → username: alice, password: P@ssw0rd456
  3. AWS Console → username: alice, password: P@ssw0rd789
  4. Company website → username: alice, password: P@ssw0rd999
  5. VPN → username: alice, password: P@ssw0rd111
  6. GitHub Enterprise → username: alice, password: P@ssw0rd222

Problems:
❌ 6 different passwords to remember
❌ Passwords written on sticky notes
❌ Password reuse (insecure)
❌ When alice leaves: IT must delete 6 accounts
❌ When alice changes password: Must change in 6 places
❌ No central audit (who did what where)
❌ Each password breach could compromise all systems
```

**With Federation:**
```
Employee: alice@company.com
Master Directory: Okta (or Azure AD, or Ping, or custom)

Employee logs in once:
  alice@company.com + password + biometric/phone approval
  
Okta provides:
  ✅ AWS Console access (temporary credentials)
  ✅ Slack access (SAML token)
  ✅ GitHub access (OAuth token)
  ✅ Email access (SAML)
  
Benefits:
✅ One password
✅ Multi-factor authentication (MFA) in one place
✅ Manager approvals
✅ Automatic access revocation (employee leaves)
✅ Audit trail (central logging)
✅ No AWS credentials created
```

---

## 🔑 Federation Concepts

### Identity Provider (IdP)

**What:** System that authenticates users

**Examples:**
- Okta (most popular)
- Azure AD / Entra ID (Microsoft)
- Ping Identity
- Google Workspace
- Custom LDAP/Active Directory

**What It Does:**
1. User provides username/password
2. IdP verifies credentials
3. IdP checks if user authorized for application
4. IdP returns token/assertion (proves user is authenticated)
5. Application accepts token (trusts IdP)

### Service Provider (SP)

**What:** System that user wants to access (AWS, Slack, etc.)

**How It Works:**
```
User → Okta (IdP) → Okta says "user is alice"
                        ↓
                    AWS (SP) → Okta says "alice is authorized"
                                 ↓
                             AWS Console opened for alice
```

---

## 🔐 SAML 2.0 - Federation Protocol

### How SAML Works

**SAML = Security Assertion Markup Language (XML-based)**

```
Step-by-step flow:

1. alice opens browser → AWS Console
   
2. AWS detects: No AWS credentials
   Redirects to: Okta login page
   
3. alice enters: username + password
   Okta verifies ✅
   
4. Okta asks: Do you authorize AWS Console?
   alice clicks: Yes
   
5. Okta generates: SAML Assertion (XML)
   Content:
   {
     <Assertion>
       <Issuer>okta.com</Issuer>
       <Subject>alice@company.com</Subject>
       <AuthenticationStatement Instant="2024-01-15T10:00:00Z"/>
       <AttributeStatement>
         <Attribute Name="groups" Value="engineering,aws-developers"/>
       </AttributeStatement>
     </Assertion>
   }
   Signed with: Okta's private key
   
6. Okta sends: SAML Assertion back to AWS
   Via: Browser (user redirected)
   
7. AWS receives: SAML Assertion
   Verifies: Signature matches Okta's certificate ✅
   Checks: Assertion not expired ✅
   Reads: Groups = engineering, aws-developers
   
8. AWS grants: AWS session
   Action: sts:AssumeRole (internal, automatic)
   Role: Selected based on SAML groups
   Duration: 12 hours (typical)
   
9. alice has: AWS Console access
   No AWS password created
   No access key stored
   Session expires: 12 hours or when she logs out
   
10. alice logs out:
    SAML session ends
    AWS session ends
    Access revoked
```

### SAML Trust Setup

**In AWS:**

```
IAM Console → Identity Providers → SAML Provider

Name: okta
Upload XML metadata:
  (downloaded from Okta portal)

XML contains:
  - Okta's certificate (public key)
  - Okta's SAML endpoint
  - Allowed bindings (POST, Redirect)
```

**In Okta:**

```
Okta console → Applications → AWS

Configure:
  - AWS Account ID: 005965605891
  - IDP Metadata URL: https://okta.com/metadata.xml
  - Assertion Consumer Service (ACS) URL: https://signin.aws.amazon.com/saml
  
Group mapping:
  Okta group: "engineering" → AWS Role: "Developer-Role"
  Okta group: "devops" → AWS Role: "DevOps-Role"
  Okta group: "compliance" → AWS Role: "Auditor-Role"
```

### SAML Role Selection

```
Okta Assertion includes groups:
  <Attribute Name="groups" Value="engineering"/>

AWS receives assertion:
  Groups = [engineering]
  
AWS role trust policy:
{
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::005965605891:saml-provider/okta"
    },
    "Action": "sts:AssumeRoleWithSAML",
    "Condition": {
      "StringEquals": {
        "SAML:aud": "https://signin.aws.amazon.com/saml"
      }
    }
  }]
}

AWS role name: Developer-Role
Role policy: S3 read/write on dev bucket

Result:
✅ alice in engineering group
✅ SAML assertion says alice is in engineering
✅ Trust policy allows engineering group
✅ alice assumed Developer-Role
✅ Can access S3 dev bucket
```

---

## 🔑 OpenID Connect (OIDC) - Modern Federation

### OIDC vs SAML

| Aspect | SAML | OIDC |
|--------|------|------|
| Purpose | Enterprise federation | Consumer + Enterprise |
| Protocol | XML-based | OAuth 2.0 + JWT |
| Typical User | Corporate employee | Anyone (Okta, Google, GitHub) |
| Modern | Older (2005) | Newer (2014) |
| AWS Use | ✅ Fully supported | ✅ GitHub, Google, Okta |

### OIDC Flow

```
Developer using GitHub for authentication:

1. Developer: npm run deploy (in laptop)

2. CLI needs AWS credentials:
   Checks for credential provider
   
3. Checks: Do I have GitHub credentials?
   Yes, GitHub account logged in locally
   
4. CLI contacts: AWS STS
   Action: AssumeRoleWithWebIdentity
   ProviderId: github.com
   Token: GitHub access token
   RoleArn: arn:aws:iam::005965605891:role/CI-CD-Role
   
5. AWS verifies: Is token from github.com? ✅
   
6. AWS checks: Does role trust github.com? ✅

7. AWS checks: Is developer authorized?
   (Condition: repo owner = my-org/my-repo)
   ✅ YES
   
8. AWS returns: Temporary credentials
   AccessKey + Secret + Token
   Duration: 15 minutes
   
9. CLI uses: Temporary credentials
   Deploys application
   CloudTrail shows: AssumeRoleWithWebIdentity/CI-CD-Role
   
10. After 15 min: Credentials expire
    If more work needed: Request new credentials
    GitHub re-authenticates (fast, already logged in)
```

### GitHub Actions OIDC Example

```yaml
# .github/workflows/deploy.yml

name: Deploy to AWS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    permissions:
      id-token: write  # Request OIDC token from GitHub
      contents: read
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: arn:aws:iam::005965605891:role/GitHub-OIDC-Role
          aws-region: us-east-1
          token-format: aws4
          web-identity-token-file: /tmp/awscreds
      
      - name: Deploy
        run: |
          aws s3 sync . s3://my-app-bucket
          aws cloudfront create-invalidation --distribution-id E123ABC --paths "/*"

# Behind the scenes:
# 1. GitHub generates OIDC token (proves this is GitHub Actions, this repo, this commit)
# 2. GitHub Actions CLI exchanges OIDC token for AWS credentials
# 3. aws-cli uses temporary credentials
# 4. deploy succeeds
# 5. Credentials expire (no cleanup needed)
# 6. Next run: GitHub generates new token, repeats process
```

---

## 🎯 AWS SSO / Identity Center

### What It Is

**AWS SSO (now called AWS Identity Center):**
- AWS's managed service for identity federation
- Simplifies multi-account access
- Integrates with corporate directories
- Built into AWS Organizations

### Architecture

```
Company: TechCorp

AWS Organizations:
├─ Management Account (005965605891)
├─ Dev Account (111111111111)
├─ Prod Account (222222222222)
└─ Audit Account (333333333333)

AWS Identity Center:
└─ Directory: AWS managed (default)
   Or: External directory (Okta, Azure AD, etc.)

Users:
├─ alice@techcorp.com
├─ bob@techcorp.com
├─ charlie@techcorp.com
└─ diana@techcorp.com

Groups:
├─ Engineering (alice, bob)
├─ DevOps (charlie)
└─ Compliance (diana)

Permission Sets (= IAM Policies):
├─ Developer (read dev account, write dev bucket)
├─ Operator (full dev/staging, limited prod)
├─ Auditor (read-only all accounts)
└─ Admin (full access all accounts)

Assignments:
├─ alice: Engineering group → Developer permission set → All accounts
├─ bob: Engineering group → Developer permission set → Dev account only
├─ charlie: DevOps group → Operator permission set → All accounts
└─ diana: Compliance group → Auditor permission set → All accounts

Result:
✅ alice logs in once
✅ Can access Dev, Prod, Audit accounts
✅ Limited to developer permissions
✅ Other teams can't access her accounts
✅ alice leaves: Disable in Identity Center → all access revoked
```

### Hands-On Setup

```
AWS Management Console:
  AWS Identity Center → Enable

Choose user source:
  Option 1: AWS Identity Center Directory (simple, managed by AWS)
  Option 2: External Identity Provider (Okta, Azure AD, etc.)

Step 1: Create users (or sync from Azure AD)

  IAM Identity Center → Users
  Create user:
    Email: alice@company.com
    First name: Alice
    Last name: Smith
    
  Repeat for: bob, charlie, diana

Step 2: Create groups

  IAM Identity Center → Groups
  Create group: Engineering
    Add members: alice, bob
    
  Create group: DevOps
    Add members: charlie

Step 3: Create permission sets (IAM policies)

  IAM Identity Center → Permission Sets
  Create permission set: Developer
    Inline policy:
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "s3:*",
          "Resource": "arn:aws:s3:::dev-*"
        }
      ]
    }

Step 4: Assign permissions

  AWS Accounts → Dev Account
  Assign users/groups:
    Group: Engineering
    Permission Set: Developer
    
  AWS Accounts → Prod Account
  Assign users/groups:
    Group: DevOps
    Permission Set: Operator

Step 5: Users access console

  User goes to: https://techcorp.awsapps.com/start
  Logs in: alice@company.com + password + MFA
  Sees: Dev account (and any others assigned)
  Clicks: Dev account
  Lands in: AWS Console
  Limited to: Developer permission set
  After 12 hours: Session expires, must log in again
```

### Comparison: IAM Users vs SSO

| Aspect | IAM Users | SSO |
|--------|-----------|-----|
| User Source | AWS-only | Corporate directory |
| Scaling | 1-10 users OK | 100+ users better |
| Central Mgmt | No (manage per account) | Yes (single console) |
| Group Sync | Manual | Automatic (Azure AD, Okta) |
| Account Access | One account per user | Multiple accounts easily |
| MFA | Per account | Centralized |
| Revocation | Manual (delete user) | Instant (disable in directory) |
| Cost | $1/user/month | $0 (free with Organizations) |
| Security | Good | Better (central control) |

---

## 🔄 External Identity Providers

### Okta Integration

```
Company already uses Okta for identity:

Step 1: Okta Admin sets up AWS integration

  Okta Admin Panel → Applications
  Search: AWS
  Click: Add
  
  Configure:
    - AWS Account ID: 005965605891
    - IDP certificate: Download Okta metadata
    - Assertion Consumer Service URL: https://signin.aws.amazon.com/saml
    
  Set up group mappings:
    okta-engineering → AWS-Developer-Role
    okta-devops → AWS-DevOps-Role
    okta-compliance → AWS-Auditor-Role

Step 2: AWS receives Okta metadata

  AWS Console → IAM → Identity Providers
  Create SAML Provider:
    Upload Okta metadata XML
    
  Create roles with SAML trust:
    Trust entity: okta.com
    Role name: AWS-Developer-Role
    Policy: Developer access

Step 3: Users access AWS

  alice logs in to Okta (laptop)
  alice.com + password + phone approval
  
  Alice sees in Okta:
    AWS (icon) → AWS Console
  
  Alice clicks: AWS Console
  
  Redirected to: AWS Console (already logged in!)
  alice sees: Only Dev account (her group permission)

Benefits:
✅ alice doesn't know AWS password
✅ Okta is source of truth
✅ alice leaves Okta → AWS access revoked
✅ One MFA setup (Okta)
✅ Full audit trail in Okta
```

### Azure AD / Entra ID Integration

```
Enterprise: Uses Microsoft 365, all employees in Azure AD

Scenario: Enable AWS access without creating 500 IAM users

Step 1: Microsoft admin sets up federation

  Azure Portal → Enterprise Applications
  Create new app: AWS (template)
  
  Configure SAML:
    Identifier: arn:aws:iam::005965605891:saml-provider/aad
    Reply URL: https://signin.aws.amazon.com/saml

Step 2: Map groups to roles

  user.assignedroles = [azure-ad-group-engineer]
  
  Rule: If in engineering group
        Then email contains 'engineer'
        Then map to AWS Developer role

Step 3: Users access AWS

  alice.smith@company.com logs into: azure.microsoft.com
  alice sees: AWS (in My Apps)
  alice clicks: AWS
  Redirected to: AWS Console
  alice can: Access Dev account
  alice cannot: See Prod account (group permission)

Benefits:
✅ Uses existing Azure AD infrastructure
✅ No additional IdP tool cost
✅ Conditional access (IP-based, device-based)
✅ Centralized identity and access management
```

---

## 🔒 Federation Security Best Practices

### 1. Require MFA

```
SAML Assertion Condition:
  aws:MultiFactorAuthPresent: true
  
Result:
✅ User must complete MFA in IdP
✅ Even if user password stolen, can't access AWS
✅ MFA state proven in SAML assertion
```

### 2. Implement Conditional Access

```
Okta Policy:
  If location = offsite AND time = after-hours
  Then: Require additional MFA / block
  
Azure AD Conditional Access:
  If IP not in office range
  Then: Require Trusted Device + MFA
```

### 3. Audit Federation Events

```
CloudTrail logs:
  AssumeRoleWithSAML
    Time: 2024-01-15 10:30:00
    Principal: alice@company.com
    Role: Developer-Role
    Result: Success
    Source IP: 72.21.198.45
    User Agent: Mozilla/5.0 Safari

IdP logs (Okta):
  alice@company.com logged in
    Time: 2024-01-15 10:29:00
    MFA: Phone approval
    Location: San Francisco, CA
    Device: Alice's MacBook
    
  alice accessed AWS
    Time: 2024-01-15 10:30:00
    Status: Success
```

### 4. Session Management

```
SAML Session: 12 hours (typical)
AWS Session: 12 hours
Idle timeout: 15 minutes

If alice closes laptop:
  SAML session stays active (Okta)
  AWS session stays active (but idle)
  After 15 min idle: Session terminates
  
Next login: alice must re-authenticate Okta
```

### 5. Just-In-Time (JIT) Provisioning

```
Without JIT:
  Employee joins company
  IT admin creates IAM user in AWS
  Takes 1-2 days
  Employee can't access AWS

With JIT (automatic provisioning):
  Employee joins company
  Employee assigned group in Azure AD
  Employee logs in (SAML federation)
  AWS automatically:
    Creates temporary identity
    Assigns role based on group
    Grants access
  Instant!

When employee leaves:
  Removed from Azure AD
  Next login attempt: Fails
  Access revoked immediately
```

---

## ✅ Federation Implementation Checklist

- [ ] Choose IdP (Okta, Azure AD, or on-premises)
- [ ] Download IdP metadata (certificate, endpoints)
- [ ] Create SAML provider in AWS IAM
- [ ] Create federated roles (with SAML trust)
- [ ] Set up group-to-role mapping
- [ ] Test with pilot users
- [ ] Deploy to all users
- [ ] Implement conditional access rules
- [ ] Enable MFA in IdP
- [ ] Set up CloudTrail logging
- [ ] Document federation topology
- [ ] Plan for disaster recovery (IdP outage)

---

**Next:** `05_Temporary_Credentials_and_Sessions.md` - STS, tokens, and credential lifecycle
