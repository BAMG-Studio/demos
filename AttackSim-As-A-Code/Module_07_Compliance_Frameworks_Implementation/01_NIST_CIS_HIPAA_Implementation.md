# Module 7: Compliance Frameworks Implementation
## NIST 800-53, CIS AWS Benchmark, HIPAA Security Rule

## 📚 What Are Compliance Frameworks?

**Technical Definition:**
Compliance frameworks are standardized guidelines specifying security controls an organization must implement to protect sensitive data and meet legal/regulatory requirements.

**Layman Analogy:**
Compliance frameworks are like **building codes for security:**

- **Without codes:** Builders construct however they want, buildings might collapse, people die
- **With codes:** Standards specify: foundation depth, material strength, electrical safety, earthquake resistance
- **Result:** Safe buildings that won't collapse

**Compliance = Security Framework with legal/regulatory teeth**

Examples:
- Don't have HIPAA compliance? Fine: $1.5M+ per violation
- Don't have GDPR compliance? Fine: 4% of revenue (up to €20M)
- Don't have PCI-DSS compliance? No credit cards allowed (lose revenue)

---

## 🎯 Three Major Frameworks for AWS

### Framework 1: NIST 800-53 (National Institute of Standards & Technology)

**What it is:**
NIST SP 800-53 is the US government's security control catalog. It defines 900+ controls across 14 families.

**Who uses it:**
- US federal agencies (required)
- Contractors working with government
- Healthcare (recommended)
- Financial services (recommended)
- Any organization wanting security best practices

**14 Control Families:**

```
1. ACCESS CONTROL (AC)
   └─ Who can access what?
   └─ Example controls:
      • AC-2: Account Management
      • AC-3: Access Enforcement
      • AC-5: Separation of Duties
      • AC-6: Least Privilege
   └─ AWS Implementation:
      • IAM users/roles (AC-2)
      • IAM policies (AC-3)
      • Resource-based policies (AC-5)
      • Minimum necessary permissions (AC-6)

2. AUDIT & ACCOUNTABILITY (AU)
   └─ What happened? Who did it?
   └─ Example controls:
      • AU-2: Audit Events
      • AU-3: Content of Audit Records
      • AU-12: Audit Generation & Review
   └─ AWS Implementation:
      • CloudTrail (logs all API calls)
      • Config (logs configuration changes)
      • VPC Flow Logs (logs network traffic)

3. SECURITY ASSESSMENT & AUTHORIZATION (CA)
   └─ Did we do it right? Is it approved?
   └─ Example controls:
      • CA-2: Security Assessments
      • CA-6: Security Authorization
   └─ AWS Implementation:
      • AWS Config rules (automated checks)
      • AWS Security Hub (security assessments)
      • Third-party security assessments

4. CONFIGURATION MANAGEMENT (CM)
   └─ What's installed? What changed?
   └─ Example controls:
      • CM-2: Baseline Configuration
      • CM-3: Configuration Change Control
   └─ AWS Implementation:
      • AWS Config (track configuration changes)
      • Systems Manager (patch management)
      • Infrastructure as Code (CloudFormation)

5. IDENTIFICATION & AUTHENTICATION (IA)
   └─ Who are you? Prove it!
   └─ Example controls:
      • IA-2: Authentication
      • IA-4: Identifier Management
   └─ AWS Implementation:
      • IAM users (IA-4)
      • MFA (IA-2)
      • Temporary credentials (IA-4)

6. INCIDENT RESPONSE (IR)
   └─ Bad thing happened. What now?
   └─ Example controls:
      • IR-1: Incident Response Policy
      • IR-4: Incident Handling
      • IR-6: Incident Reporting
   └─ AWS Implementation:
      • Incident response playbooks
      • GuardDuty findings (detection)
      • SNS notifications (alerting)

7. MAINTENANCE (MA)
   └─ Keep systems running and secure
   └─ Example controls:
      • MA-1: System Maintenance Policy
      • MA-2: Controlled Maintenance
   └─ AWS Implementation:
      • Systems Manager Session Manager (secure login)
      • Managed updates
      • Patching schedule

8. MEDIA PROTECTION (MP)
   └─ Protect data on storage media
   └─ Example controls:
      • MP-2: Media Access
      • MP-4: Media Storage
   └─ AWS Implementation:
      • EBS encryption (encryption at rest)
      • S3 encryption
      • Secure deletion (shred data)

9. PHYSICAL & ENVIRONMENTAL PROTECTION (PE)
   └─ Protect physical infrastructure
   └─ Example controls:
      • PE-2: Physical Entry
      • PE-6: Monitoring Physical Access
   └─ AWS Implementation:
      • AWS manages (data center security)
      • Your responsibility: On-premises equipment

10. PLANNING (PL)
    └─ What's your security strategy?
    └─ Example controls:
       • PL-1: Security Planning
       • PL-2: System Security Plan
    └─ AWS Implementation:
       • Architecture documentation
       • Security design documents
       • Risk assessments

11. PERSONNEL SECURITY (PS)
    └─ Hire and manage secure people
    └─ Example controls:
       • PS-1: Personnel Security Policy
       • PS-6: Access Termination
    └─ AWS Implementation:
       • IAM user management
       • Disable users when they leave
       • Regular access reviews

12. RISK ASSESSMENT (RA)
    └─ What could go wrong?
    └─ Example controls:
       • RA-3: Risk Assessment
    └─ AWS Implementation:
       • Threat modeling
       • Vulnerability scanning
       • Risk scoring

13. SYSTEM & COMMUNICATIONS PROTECTION (SC)
    └─ Protect data in transit
    └─ Example controls:
       • SC-7: Boundary Protection
       • SC-23: Session Authenticity
    └─ AWS Implementation:
       • VPCs (network boundaries)
       • Security groups (firewall)
       • HTTPS encryption (data in transit)
       • TLS 1.2+ enforcement

14. SYSTEM & INFORMATION INTEGRITY (SI)
    └─ Ensure data isn't corrupted/altered
    └─ Example controls:
       • SI-2: Flaw Remediation
       • SI-7: Information System Monitoring
    └─ AWS Implementation:
       • Patch management
       • Malware scanning
       • File integrity monitoring
```

---

### Framework 2: CIS AWS Foundations Benchmark

**What it is:**
CIS (Center for Internet Security) AWS Foundations Benchmark is a practical checklist of specific AWS controls you should implement.

**Who uses it:**
- AWS-specific organizations (very common)
- Startups (CIS is free!)
- Companies migrating to AWS
- AWS certification exam prep

**CIS AWS Checklist (5 Key Areas):**

```
AREA 1: IDENTITY & ACCESS MANAGEMENT (10 controls)
└─ Implement:
   ✅ MFA on root account
   ✅ Individual IAM users (don't share root)
   ✅ Prevent public access to IAM private keys
   ✅ Don't use inline policies (use managed policies)
   ✅ Disable unused credentials
   ✅ Regular credential rotation
   ✅ Remove MFA-disabled users
   ✅ Enable MFA for console access
   ✅ Cross-account access (STS assumed roles)
   ✅ Monitor IAM policy changes

AWS Audit Tools:
   • AWS Config rules (check: mfa_enabled_for_iam_console_access)
   • IAM Access Analyzer (check: public IAM resources)
   • CloudTrail (audit: who changed IAM policy?)

AREA 2: LOGGING (12 controls)
└─ Implement:
   ✅ CloudTrail enabled & protected
   ✅ CloudTrail logs to S3 (immutable)
   ✅ S3 object lock enabled (can't delete logs)
   ✅ CloudTrail log validation (prevent tampering)
   ✅ CloudWatch alarms for specific events
   ✅ CloudTrail integrated with CloudWatch
   ✅ VPC Flow Logs enabled
   ✅ CloudTrail logs encrypted
   ✅ S3 server access logging
   ✅ Config enabled & integrated
   ✅ Config rules for compliance
   ✅ Config history protected

AWS Audit Tools:
   • AWS Config (check: cloudtrail_enabled_on_account)
   • CloudTrail (verify: logging to S3)
   • S3 (verify: object lock enabled, versioning)

AREA 3: MONITORING (14 controls)
└─ Implement:
   ✅ CloudWatch Log Groups created
   ✅ Unauthorized API calls detected
   ✅ Console authentication failures detected
   ✅ IAM policy changes detected
   ✅ CloudTrail disabled/deleted detected
   ✅ Console login without MFA detected
   ✅ Root account usage detected
   ✅ IAM policy changes monitored
   ✅ Network ACL changes detected
   ✅ Network gateway changes detected
   ✅ VPC changes detected
   ✅ EC2 changes detected
   ✅ S3 changes detected
   ✅ Security Group changes detected

Concrete Example: Root Account Usage Alert
   • Log source: CloudTrail
   • Trigger: eventName = "Login" AND userIdentity.principalId = "root"
   • Action: SNS alert to security team
   • Response: Investigate immediately (root should NEVER be used!)

AREA 4: NETWORKING (5 controls)
└─ Implement:
   ✅ VPCs used (not default VPC)
   ✅ Flow Logs enabled
   ✅ Security groups restricted (no 0.0.0.0/0)
   ✅ Network ACLs reviewed
   ✅ Ingress restricted on ports 3389 (RDP), 22 (SSH)

AWS Audit Tools:
   • AWS Config rules (check: vpc_default_network_acl_restricted_incoming)
   • VPC Flow Logs analysis
   • Security group reviews

AREA 5: ENCRYPTION & KEY MANAGEMENT (4 controls)
└─ Implement:
   ✅ S3 default encryption enabled
   ✅ S3 encryption enforced (via bucket policy)
   ✅ RDS encryption enabled
   ✅ KMS key rotation enabled

AWS Audit Tools:
   • AWS Config rules (check: s3_bucket_server_side_encryption_enabled)
   • S3 bucket policies (require encryption)
   • RDS snapshots (encryption enabled)
```

---

### Framework 3: HIPAA Security Rule

**What it is:**
HIPAA (Health Insurance Portability & Accountability Act) Security Rule requires healthcare organizations to protect Protected Health Information (PHI).

**Who uses it:**
- Healthcare organizations
- Health insurance companies
- Medical device companies
- Cloud providers hosting healthcare data (Business Associates)

**Key HIPAA Controls for AWS:**

```
1. ADMINISTRATIVE SAFEGUARDS
   ├─ Workforce security
   │  └─ Unique user IDs (don't share accounts)
   │  └─ Implement: IAM users (one per person)
   │
   ├─ Information access management
   │  └─ Principle of least privilege
   │  └─ Implement: Minimal IAM permissions
   │
   ├─ Security awareness training
   │  └─ Regular training on HIPAA requirements
   │  └─ Implement: Training compliance tracking
   │
   └─ Security incident procedures
      └─ Incident response plan (required!)
      └─ Implement: Playbooks, documentation

2. PHYSICAL SAFEGUARDS
   ├─ Facility access controls
   │  └─ Data center security (AWS manages)
   │  └─ AWS compliance: AWS certifications
   │
   ├─ Workstation security
   │  └─ Secure access to workstations
   │  └─ Implement: Encrypted laptops, MFA
   │
   └─ Device & media controls
      └─ Control removable media
      └─ Implement: Block USB, Screen privacy filters

3. TECHNICAL SAFEGUARDS
   ├─ Access controls
   │  └─ Must be able to turn off access quickly
   │  └─ Implement: Immediate IAM user deletion
   │
   ├─ Encryption
   │  └─ Encryption at rest (recommended)
   │  └─ Encryption in transit (required!)
   │  └─ Implement: S3 encryption, RDS encryption, TLS
   │
   ├─ Audit & accountability
   │  └─ Audit logs of who accessed PHI
   │  └─ Implement: CloudTrail, S3 access logs
   │
   └─ Integrity
      └─ Ensure data not altered
      └─ Implement: Data validation, versioning

4. BREACH NOTIFICATION
   ├─ Notification timeline: 60 days
   │  └─ Notify affected individuals
   │  └─ Notify media (if >500 people)
   │  └─ Notify HHS (Department of Health & Human Services)
   │
   └─ HIPAA penalties for breaches: $100-$50,000 per person!
      └─ Example: 1,000 people = $100K-$50M fine
      └─ Implementation: Rapid breach detection & response
```

---

## 🔍 How to Audit for Compliance

### Method 1: AWS Config Rules (Automated)

```
Services → AWS Config → Rules → "Add rules"

Pre-built rules for CIS:
✅ cloudtrail_enabled_on_account
✅ mfa_enabled_for_iam_console_access
✅ s3_bucket_server_side_encryption_enabled
✅ ec2_security_group_restricted_incoming_tcp_udp
✅ root_account_mfa_enabled
✅ iam_root_access_key_check
✅ iam_policy_no_statements_with_admin_access
✅ restricted_ssh (no 0.0.0.0/0)
✅ encrypted_volumes (EBS encryption)
... and 50+ more!

How it works:
- Create rule → AWS Config checks it automatically
- Reports: COMPLIANT or NON_COMPLIANT
- Tracks: When it went compliant/non-compliant
- Alerts: SNS notification when violation detected
```

### Method 2: Security Hub (Comprehensive)

```
Services → Security Hub → Standards

Available standards:
✅ CIS AWS Foundations Benchmark
✅ NIST Special Publication 800-53 Revision 5
✅ PCI DSS 3.2.1
✅ HIPAA Security Rule
✅ FedRAMP Moderate
✅ SOC 2

How it works:
- Enable standard → Hub checks 100+ controls
- Generates findings for each control
- Shows: % compliant, top issues
- Integrates: All AWS services + third-party tools
```

### Method 3: Manual Audit Checklist

```
Download CIS AWS Benchmark checklist (free from CIS.org)

Sample checklist items:
[ ] 1.1 Avoid the use of "root" account
    ✓ Verify: Root account MFA enabled
    ✓ Verify: No root access keys exist
    
[ ] 1.2 Ensure MFA is enabled for all IAM users that have a console password
    ✓ Check: Each user has MFA device
    ✓ Verify: MFA is active (not disabled)
    
[ ] 2.1 Ensure CloudTrail is enabled in all regions
    ✓ Verify: Organization trail exists
    ✓ Verify: Logs to S3 bucket
    ✓ Verify: Log file validation enabled
    
... etc (20+ checklist items)

Tool: Manual spreadsheet or compliance automation tool
```

---

## 💰 Cost of Compliance

| Framework | Implementation Cost | Annual Maintenance | Tools Cost |
|-----------|-------------------|------------------|-----------|
| **CIS AWS** | $50K-$100K | $20K/year | $0 (AWS tools free) |
| **NIST 800-53** | $200K-$500K | $100K/year | $50K/year |
| **HIPAA** | $500K-$1M+ | $250K+/year | $100K+/year |

**ROI Calculation:**
- Cost: $100K (CIS implementation) + $20K/year (maintenance)
- Prevents: Regulatory fines ($1M+), data breaches ($10M+)
- Insurance reduction: Cyber insurance 20-30% cheaper
- Expected value: $500K+ annually

**Cost-Benefit: ALWAYS positive!**

---

## 📋 Compliance Roadmap

```
MONTH 1: Assessment
- Identify which frameworks apply to your org
- Use Security Hub to get baseline
- Document current state
- Identify gaps

MONTH 2-3: Quick Wins
- Implement easy controls first (CIS 1.0-1.5)
- Enable MFA on root
- Enable CloudTrail
- Create CloudWatch alarms

MONTH 4-6: Core Implementation
- Implement all access controls (IAM structure)
- Implement all logging controls
- Implement monitoring/alerting
- Documentation

MONTH 7-12: Hardening
- Network controls
- Encryption controls
- Incident response capability
- Regular audits

Ongoing: Compliance Maintenance
- Monthly Security Hub check
- Quarterly manual audits
- Annual assessments
- Continuous improvement
```

---

**Ready to implement? Move to Module 9 (Sandbox Environment)! 🚀**
