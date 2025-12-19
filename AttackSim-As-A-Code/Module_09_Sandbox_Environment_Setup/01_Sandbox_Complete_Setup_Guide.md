# Module 9: Sandbox Environment Setup - Complete Guide

## 📚 What is a Sandbox Environment?

**Technical Definition:**
A sandbox is an isolated AWS account used for testing attacks, running security exercises, and practicing incident response without affecting production systems.

**Layman Analogy:**
A sandbox is like a **testing ground for explosives experts:**

- ❌ **Without sandbox:** "Let's test this bomb in downtown (production)" → BAD
- ✅ **With sandbox:** "Let's test it in an isolated desert (sandbox)" → SAFE

**Key Rules:**
- ✅ Can break things freely
- ✅ No real customers affected
- ✅ Low cost (can delete everything)
- ❌ NOT connected to production
- ❌ NOT contain real customer data
- ❌ NOT connected to other accounts

---

## 🏗️ Sandbox Account Architecture

```
Your AWS Organization:
├─ Management Account (Account 005965605891)
│  └─ For organization management only
│
├─ Production Account (Account ABC123DEF456)
│  └─ Running actual applications/services
│  └─ Customer data LIVE
│  └─ No red team attacks here!
│
├─ Development Account (Account XYZ789GHI012)
│  └─ For engineers to build/test features
│  └─ No red team attacks here!
│
└─ SANDBOX ACCOUNT ⭐ (Account NEW-SANDBOX-ID)
   └─ ISOLATED from all other accounts
   └─ Cross-account access DENIED
   └─ Red team attacks allowed!
   └─ Stratus simulations happen here
   └─ Incident response practiced here
   └─ Cost: ~$50-100/month
```

---

## 🔧 Step-by-Step Sandbox Setup

### Step 1: Create Sandbox AWS Account

**Option A: Via AWS Organizations (Recommended)**

```
AWS Console → AWS Organizations → Accounts → Create Account

Details:
├─ Account Name: "sandbox-security-testing"
├─ Account Email: security-sandbox@company.com (must be unique)
├─ IAM role name: OrganizationAccountAccessRole (default)
└─ Create

Wait: 15-20 minutes for account creation

Access:
├─ Go to Management Account console
├─ Assume OrganizationAccountAccessRole into sandbox account
├─ Or: Login as root (if you have password)
```

**Option B: Standalone Account**

```
If not using Organizations:
1. Go to AWS sign-up: https://aws.amazon.com
2. Create new account with:
   └─ Email: sandbox-testing@company.com
   └─ Password: (secure!)
   └─ Payment method: Corporate credit card
3. Login to new account
4. Setup IAM admin user (don't use root!)
```

### Step 2: Set Sandbox Account Limits

**Goal:** Prevent runaway costs (crypto-mining, attack, etc.)

```
AWS Console → Billing → Billing Preferences

Budget Alerts:
├─ Create Budget: Set $500/month limit
├─ Alert threshold: Notify when 80% ($400) reached
├─ Alert recipients: security-team@company.com
└─ Alert when: Forecast exceeds budget

Cost Controls:
├─ Consider: Reserve instances (commit to usage = save 30-40%)
├─ Consider: Savings plans (flexible, save 20-30%)
└─ Monitor: Cost Explorer dashboard

Purpose:
✅ Prevent $10K+ surprise bills
✅ Alert if malicious code launches mining
✅ Contain costs of testing
```

### Step 3: Enable Core Monitoring (Even in Sandbox!)

**Enable CloudTrail (Audit Log):**

```
Services → CloudTrail → Trails → Create Trail

Configuration:
├─ Trail name: sandbox-audit-trail
├─ S3 bucket: Create new "sandbox-audit-logs-[account-id]"
├─ Log file validation: ENABLED
├─ Enable log file encryption: YES
├─ CloudWatch Logs: ENABLED
├─ Include global service events: YES
└─ Create

Purpose:
✅ See what red team did during attacks
✅ Analyze detection effectiveness
✅ Train analyst on real attack patterns
```

**Enable GuardDuty (Threat Detection):**

```
Services → GuardDuty → Get Started → Enable GuardDuty

Configuration:
├─ Enable for this account: YES
├─ Organization members: Not needed (sandbox only)
├─ Finding export: Create SNS topic
└─ Findings to SNS email address

Purpose:
✅ Detect when red team does attacks
✅ Generate alerts for practice
✅ Test incident response playbooks
```

**Enable AWS Config (Configuration Tracking):**

```
Services → AWS Config → Get started → 1-click setup

This will:
├─ Record configuration changes
├─ Check compliance with 40+ rules
├─ Provide inventory of resources
├─ Track resource relationships

Purpose:
✅ Detect unauthorized changes (test detection)
✅ Audit compliance posture
✅ Track configuration drift
```

### Step 4: Set Up Sandbox Networking

**Create VPC (Isolated Network):**

```
Services → VPC → VPCs → Create VPC

Configuration:
├─ Name: sandbox-vpc
├─ IPv4 CIDR block: 10.0.0.0/16
│  └─ This means: 65,536 IP addresses available
│  └─ 10.0.1.0 - 10.0.255.255
└─ Create

Create Subnets:
├─ Subnet 1 (Public): 10.0.1.0/24
│  └─ 256 IPs available
│  └─ Allows internet access
│  └─ For: Load balancers, bastion hosts
│
├─ Subnet 2 (Private): 10.0.10.0/24
│  └─ 256 IPs available
│  └─ No direct internet access
│  └─ For: Databases, app servers, test instances

Create Internet Gateway:
├─ Attach to sandbox-vpc
├─ Purpose: Allow internet communication
└─ For: Testing outbound connections

Create Route Table:
├─ Name: Public-routes
├─ Routes:
│  └─ 0.0.0.0/0 → Internet Gateway
├─ Associate with Public Subnet
└─ Effect: Public subnet can reach internet

Create NAT Gateway (optional):
├─ Purpose: Private subnet internet access (out only)
├─ Cost: $32/month + data transfer costs
└─ Use for: Private instances reaching external services
```

**Network Diagram:**

```
sandbox-vpc (10.0.0.0/16)
│
├─ Public Subnet (10.0.1.0/24)
│  ├─ Internet Gateway
│  ├─ Load Balancer (if testing web apps)
│  └─ Bastion Host (to SSH into private)
│
├─ Private Subnet (10.0.10.0/24)
│  ├─ Test EC2 instances
│  ├─ Test databases
│  ├─ No direct internet
│  └─ NAT Gateway (optional, for outbound)
│
└─ Security Groups (Firewalls)
   ├─ public-sg: Allow 443 (HTTPS), 22 (SSH)
   ├─ private-sg: Allow 3306 (MySQL), 5432 (PostgreSQL)
   └─ Allow communication between subnets
```

### Step 5: Create Test Resources

**Create Test EC2 Instance:**

```
Services → EC2 → Instances → Launch Instance

Configuration:
├─ Name: sandbox-test-server-01
├─ AMI: Amazon Linux 2
├─ Instance type: t3.micro (free tier eligible)
├─ VPC: sandbox-vpc
├─ Subnet: Private (10.0.10.0/24)
├─ IAM role: Create new (will give permissions)
└─ Security group: private-sg (allow SSH from bastion)

IAM Role Setup:
├─ Role name: sandbox-instance-role
├─ Permissions:
│  ├─ AmazonSSMManagedInstanceCore (for Session Manager)
│  ├─ CloudWatchAgentServerPolicy (for monitoring)
│  └─ Custom: S3 read-only (for S3 access testing)
└─ Allow red team to assume role

Cost: $0.0116/hour = ~$8.50/month (t3.micro)
```

**Create Test RDS Database (Optional):**

```
Services → RDS → Databases → Create Database

Configuration:
├─ Database type: MySQL (free tier)
├─ DB instance identifier: sandbox-mysql-01
├─ Master username: admin
├─ Master password: (generate strong password, save in Secrets Manager)
├─ DB instance class: db.t3.micro (free tier)
├─ Storage: 20 GB (free tier)
├─ VPC: sandbox-vpc
├─ Subnet: Private
├─ Security group: private-sg (allow MySQL port 3306)
└─ Create

Cost: $0.017/hour = ~$12.50/month (db.t3.micro)
```

**Create Test S3 Bucket:**

```
Services → S3 → Buckets → Create Bucket

Configuration:
├─ Bucket name: sandbox-test-data-[account-id]
│  └─ Must be globally unique (AWS requirement)
├─ Region: us-east-1
├─ Block Public Access: ALL ENABLED (keep private!)
├─ Versioning: ENABLED (can restore deleted files)
├─ Encryption: ENABLED (default AES-256)
├─ Server access logging: ENABLED (log all access)
└─ Create

Upload Test Data:
├─ Create file: dummy-customer-data.csv
│  └─ Contains: Sample customer names, fake SSNs, etc.
│  └─ NOT real data! Not customer PII!
├─ Upload to bucket
└─ Use for: Testing data exfiltration

Cost: $0.023 per GB/month = ~$1/month (for small test file)
```

### Step 6: Create IAM Users for Red Team

**Create Red Team Attacker User:**

```
Services → IAM → Users → Create User

User 1: stratus-attacker
├─ Permissions: AdministratorAccess
│  └─ Can do ANYTHING in sandbox
│  └─ This is safe because it's sandbox only!
├─ Access key: Create & save CSV
├─ Purpose: Stratus Red Team tool
└─ No console access (only programmatic)

User 2: pentest-admin
├─ Permissions: AdministratorAccess
├─ Access key: Create
├─ Purpose: Manual penetration tester
├─ Multi-factor authentication: REQUIRED
└─ Password: Set strong password

Purpose of high permissions in sandbox:
✅ Red team can fully simulate attacker
✅ Test all detection/response capabilities
✅ Find vulnerabilities before production
✅ Safe because: Isolated sandbox account
```

### Step 7: Create Security Monitoring Dashboard

**CloudWatch Dashboard for Sandbox:**

```
Services → CloudWatch → Dashboards → Create Dashboard

Dashboard: "Sandbox Security Monitoring"

Widgets to add:
1. EC2 Instances
   └─ Running count, CPU, network

2. RDS Database
   └─ Connections, query performance

3. S3 Bucket
   └─ Object count, size, access frequency

4. CloudTrail Events
   └─ API call volume over time
   └─ Top API calls
   └─ Top users

5. GuardDuty Findings
   └─ Finding count by severity
   └─ Finding type distribution
   └─ Timeline

6. AWS Config Compliance
   └─ % compliant rules
   └─ Non-compliant resources

7. Billing
   └─ Current month costs
   └─ Forecast (will exceed budget?)

8. VPC Flow Logs
   └─ Network traffic volume
   └─ Accepted vs. rejected flows
   └─ Top source/destination IPs

Purpose:
✅ See sandbox health at a glance
✅ Detect red team activity
✅ Monitor costs
```

---

## ⚙️ Sandbox Operations

### Daily Checklist

```
Monday Morning:
[ ] Check CloudWatch dashboard
   └─ Any unexpected activity?
   └─ Any cost spikes?
[ ] Review CloudTrail
   └─ API activity normal?
   └─ Any unusual changes?
[ ] Check GuardDuty findings
   └─ Any findings from weekend?
[ ] Verify EC2 instances running
   └─ Expected instances only?
[ ] Check S3 buckets
   └─ Correct permissions?
   └─ Encryption enabled?
```

### Weekly Maintenance

```
Every Friday:
[ ] Cleanup test resources
   └─ Delete test instances created during week
   └─ Delete test databases
   └─ Delete test snapshots
[ ] Review costs
   └─ Track what resources cost
   └─ Identify optimization opportunities
[ ] Review security findings
   └─ Any compliance violations?
   └─ Any misconfigurations?
[ ] Backup test data
   └─ If using real test data, ensure it's backed up
```

### Monthly Tasks

```
End of Month:
[ ] Archive CloudTrail logs
   └─ Analyze for learning
   └─ Keep for compliance
[ ] Archive GuardDuty findings
   └─ Document findings
   └─ Lessons learned
[ ] Document lessons learned
   └─ What did we test?
   └─ What did we learn?
   └─ What should we do differently?
[ ] Plan next month exercises
   └─ Which techniques to test?
   └─ Which tools to validate?
[ ] Delete everything (optional)
   └─ If starting fresh next month
   └─ Reduces clutter
```

---

## 🚨 Sandbox Disaster Recovery

**What if Red Team Goes Rogue?**

```
Scenario: Attacker accidentally deleted database backups!

Step 1: Assess Damage (seconds)
[ ] What was deleted?
[ ] Can it be recovered?
[ ] From backups? From Recycle bin?

Step 2: Halt Damage (within minutes)
[ ] Revoke all red team credentials
   $ aws iam delete-access-key --access-key-id AKIA...
[ ] Deny all actions (emergency SCP)
   └─ SCP Policy: Deny * on all resources
[ ] Kill all running instances
   └─ Terminate everything (it's just sandbox)

Step 3: Assess Cleanup (within hours)
[ ] Delete all compromised resources
[ ] Recreate from templates
[ ] Restore from backups (if available)
[ ] Rebuild sandbox from scratch

Step 4: Prevent Recurrence
[ ] Review what went wrong
[ ] Update sandbox policies
[ ] Add preventive controls
[ ] Retrain red team

This is why sandbox is separate!
If this happened in production = MILLION DOLLAR DISASTER
In sandbox = Lesson learned, recreate in 1 hour
```

---

## 💰 Sandbox Cost Breakdown

```
Monthly Costs:

EC2 Instances:
├─ t3.micro (test server): $8.50
├─ t3.small (app server): $17/month
└─ Total EC2: $25/month

RDS Database:
├─ db.t3.micro (MySQL): $12.50
└─ Storage: 20 GB × $0.023 = $0.50
└─ Total RDS: $13/month

S3:
├─ Storage: 1 GB × $0.023 = $0.023
├─ Requests: ~$1/month
└─ Total S3: $1.50/month

Data Transfer:
├─ Out of region: ~$0.01/GB
├─ If transferring data out: $0-20/month
└─ Total data transfer: $0-20/month

Monitoring:
├─ CloudTrail: $2
├─ GuardDuty: $0 (included in Security Hub)
├─ AWS Config: $0.30 per rule per region
└─ Total monitoring: $5-10/month

Storage (EBS):
├─ 20 GB × $0.10 = $2/month
└─ snapshots: $0.50 per snapshot

TOTAL MONTHLY: $45-60/month

Cost Optimization:
- Use t3.micro instances (cheaper)
- Stop instances when not using (not delete!)
- Use RDS multi-AZ? No (sandbox doesn't need HA)
- Cleanup test resources immediately
- Use 1-year reserved instances (saves 30%)

Budget: $100/month should be plenty!
```

---

## 🎓 Sandbox Exercise Schedule

```
Month 1: Setup & Foundations
Week 1: Create sandbox account
Week 2: Deploy monitoring (CloudTrail, GuardDuty)
Week 3: Create test resources (EC2, RDS, S3)
Week 4: Practice basic tasks (create user, modify SG, etc)

Month 2: Detection Exercises
Week 1: Test CloudTrail detection (API changes)
Week 2: Test GuardDuty detection (simulated threats)
Week 3: Test Config detection (compliance rules)
Week 4: Test incident response (playbooks)

Month 3: Attack Simulations (Stratus)
Week 1: T1552.005 (Credential access)
Week 2: T1136.003 (Create account)
Week 3: T1562.008 (Disable CloudTrail)
Week 4: T1530 (Data theft from S3)

Month 4: Advanced Scenarios
Week 1: Supply chain attack simulation
Week 2: Insider threat simulation
Week 3: Ransomware attack response
Week 4: Multi-stage attack (kill chain)
```

---

## ✅ Sandbox Readiness Checklist

Before running attack simulations:

```
[ ] Sandbox account created
[ ] Budget alert set ($500/month)
[ ] CloudTrail enabled & logging to S3
[ ] GuardDuty enabled & alerting via SNS
[ ] AWS Config enabled with 40+ rules
[ ] VPC created with public/private subnets
[ ] Test EC2 instance created
[ ] Test RDS instance created
[ ] Test S3 bucket created
[ ] IAM users created (stratus-attacker, pentest-admin)
[ ] Security groups configured
[ ] CloudWatch dashboard created
[ ] SNS topics created for alerts
[ ] Email subscription to SNS (verify)
[ ] Stratus Red Team installed locally
[ ] AWS CLI configured for sandbox account
[ ] Initial baseline gathered (resource inventory)
[ ] Team trained on sandbox usage
[ ] Incident response runbooks updated
[ ] Ready to attack!
```

---

**Congratulations! Your sandbox is ready for attack simulations!**

**Next Steps:**
1. Run your first Stratus attack (Module 8)
2. Practice incident response (Module 5)
3. Run purple team exercises (Module 6)
4. Test compliance controls (Module 7)
5. Document lessons learned

**You're now ready for real-world defensive security work! 🚀**
