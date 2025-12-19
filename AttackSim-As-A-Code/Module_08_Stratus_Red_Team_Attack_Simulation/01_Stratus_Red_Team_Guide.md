# Module 8: Stratus Red Team - Attack Simulation Framework

## 📚 What is Stratus Red Team?

**Technical Definition:**
Stratus Red Team is an open-source attack simulation framework designed for AWS/Azure/GCP that provides pre-built attack scenarios mapped to MITRE ATT&CK techniques. It allows security teams to safely test defenses by simulating real attacker behavior.

**Layman Analogy:**
Stratus Red Team is like a **professional burglar you hire to test your home security:**

- ❌ **Without testing:** You think your security is great, but don't know
- ✅ **With Stratus testing:** Professional tries every known burglary technique, documents what works, what doesn't

**Key Benefits:**
- ✅ Safe simulation (sandbox environment)
- ✅ MITRE ATT&CK mapped (industry standard)
- ✅ Repeatable (run same attack multiple times)
- ✅ Measurable (MTTD, MTTR metrics)
- ✅ Free/open-source (no licensing)

---

## 🎯 Stratus Red Team Installation & Setup

### Prerequisites

```
✅ AWS Account (separate sandbox recommended)
✅ AWS CLI configured
✅ Python 3.7+ installed
✅ Git installed
✅ Basic knowledge of AWS services
✅ IAM permissions: EC2, Lambda, IAM, S3 (admin role OK for sandbox)
```

### Installation Steps

**Step 1: Install Stratus Red Team**

Option A: macOS/Linux (Homebrew)
```bash
# Add Stratus repository
brew tap datadog/stratus-red-team https://github.com/DataDog/stratus-red-team

# Install
brew install stratus-red-team

# Verify
stratus --version
# Output: Stratus Red Team v2.X.X
```

Option B: Linux (Manual Download)
```bash
# Download latest release
wget https://github.com/DataDog/stratus-red-team/releases/download/v2.9.0/stratus-red-team-linux-amd64.tar.gz

# Extract
tar -xzf stratus-red-team-linux-amd64.tar.gz

# Move to PATH
sudo mv stratus /usr/local/bin/

# Verify
stratus --version
```

Option C: Windows (Git Bash or WSL2)
```bash
# In WSL2 terminal (Linux subsystem):
# Follow Linux installation above
```

**Step 2: Configure AWS Credentials**

Create IAM user for Stratus (in sandbox account):

```
AWS Console → IAM → Users → Create user "stratus-attacker"
├─ Permissions: AdministratorAccess (OK for sandbox!)
├─ Access key: Create
└─ Store: Save CSV securely
```

Configure credentials:
```bash
# Option A: AWS CLI config
aws configure --profile stratus-sandbox
# Paste:
# AWS Access Key ID: AKIA...
# AWS Secret Access Key: ...
# Default region: us-east-1
# Output format: json

# Option B: Environment variables
export AWS_ACCESS_KEY_ID=AKIA...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-east-1

# Test credentials
aws sts get-caller-identity
# Output: Should show "stratus-attacker" user
```

---

## 🚀 Stratus Attack Techniques

### Available Attack Categories

```
Stratus supports 50+ AWS attack techniques:

1. INITIAL ACCESS
   └─ T1199: Trusted Relationship (cross-account access)
   └─ T1566: Phishing (via email - simulated)
   └─ T1190: Exploit Public-Facing Application

2. EXECUTION
   └─ T1651: Cloud Administration Command (AWS CLI commands)
   └─ T1204: User Execution (execute code as user)
   └─ T1204.003: User Execution - Malicious Script

3. PERSISTENCE
   └─ T1136: Create Account (IAM user creation)
   └─ T1136.003: Create Account - Cloud Account (AWS IAM)
   └─ T1098: Account Manipulation (backdoor access)
   └─ T1574: Hijack Execution Flow (EC2 metadata)

4. PRIVILEGE ESCALATION
   └─ T1134: Access Token Manipulation
   └─ T1548: Abuse Elevation Control Mechanism
   └─ T1547: Boot or Logon Autostart Execution

5. DEFENSE EVASION
   └─ T1562: Impair Defenses (disable GuardDuty, CloudTrail)
   └─ T1562.008: Impair Defenses: Disable Cloud Logs
   └─ T1207: Rogue Domain Controller

6. CREDENTIAL ACCESS
   └─ T1110: Brute Force (credential guessing)
   └─ T1110.004: Brute Force: Credential Stuffing
   └─ T1552: Unsecured Credentials (steal from environment)
   └─ T1552.005: Cloud Instance Metadata API (EC2 instance role)

7. DISCOVERY
   └─ T1526: Cloud Service Discovery (list resources)
   └─ T1580: Cloud Infrastructure Discovery (describe instances)
   └─ T1538: Cloud Service Dashboard (AWS console access)

8. LATERAL MOVEMENT
   └─ T1021: Remote Services (SSH/RDP to other instances)
   └─ T1534: Internal Spearphishing (send email within org)
   └─ T1570: Lateral Tool Transfer (copy tools to other systems)

9. COLLECTION
   └─ T1530: Data from Cloud Storage Object (S3 download)
   └─ T1213: Data from Information Repositories (RDS access)
   └─ T1123: Audio Capture (if systems have audio)

10. COMMAND & CONTROL
    └─ T1071: Application Layer Protocol (HTTPS to C2)
    └─ T1001: Data Obfuscation (encrypt exfiltrated data)

11. EXFILTRATION
    └─ T1020: Automated Exfiltration (send data out)
    └─ T1567: Exfiltration Over Web Service (S3 upload)

12. IMPACT
    └─ T1485: Data Destruction (delete data)
    └─ T1486: Data Encrypted for Impact (ransomware)
    └─ T1561: Disk Wipe (format drives)
```

---

## 🔴 Running Stratus Attacks

### Attack Execution Workflow

```
Every Stratus attack follows this pattern:

1. WARMUP (Setup)
   └─ Create test resources (EC2, Lambda, S3)
   └─ Takes: 2-5 minutes
   └─ Cost: Minimal (small instances)
   └─ Command: stratus warmup aws.tactic.technique

2. DETONATE (Execute Attack)
   └─ Simulate the actual attack
   └─ Duration: Seconds to minutes
   └─ Outcome: Demonstrate technique
   └─ Command: stratus detonate aws.tactic.technique

3. OBSERVE (Monitor)
   └─ Check SIEM/logs while attack runs
   └─ Look for detection
   └─ Measure: MTTD (mean time to detect)

4. CLEANUP (Teardown)
   └─ Delete test resources
   └─ Remove evidence
   └─ Avoid costs
   └─ Command: stratus cleanup aws.tactic.technique
```

### Example Attack #1: EC2 Instance Credential Theft

**The Scenario:**
```
Attacker Goal: Steal credentials from running EC2 instance
MITRE Technique: T1552.005 (Cloud Instance Metadata API)
What happens: Script on attacker's laptop gets instance credentials
Detection: GuardDuty should alert (credential exfiltration)
```

**Execution:**

```bash
# Step 1: Warmup (create test EC2)
$ stratus warmup aws.credential-access.ec2-steal-instance-credentials
Output:
  Creating test EC2 instance...
  Instance: i-0a1b2c3d4e5f6g7h8
  Status: Running
  Warmup complete

# Step 2: Watch your SIEM now! (In another terminal)
# Open: OpenSearch or CloudWatch Logs
# Filter: GuardDuty findings
# Look for: UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration

# Step 3: Detonate (execute attack)
$ stratus detonate aws.credential-access.ec2-steal-instance-credentials
Output:
  Retrieving instance metadata credentials...
  Credentials stolen: ASIAZ...YAXXX
  Using stolen credentials from attacker IP: 203.0.113.50
  Making API call: sts:GetCallerIdentity
  SUCCESS - Credentials exfiltrated!

# Step 4: Check SIEM for detection
# Expected alert: "Credentials used from external IP"
# GuardDuty Finding: "UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration"
# Severity: HIGH (8.0+)

# Step 5: Cleanup (delete test instance)
$ stratus cleanup aws.credential-access.ec2-steal-instance-credentials
Output:
  Terminating test instance...
  Instance i-0a1b2c3d4e5f6g7h8 terminated
  Cleanup complete
```

**Timeline (What happens):**
```
T+0:00 - Stratus warmup creates EC2 instance with IAM role
T+0:02 - Instance running, metadata service available
T+0:03 - Stratus detonate starts attack
T+0:04 - Attack retrieves instance credentials from metadata
         └─ Instance credentials: ASIA...temporary (valid for 6 hours)
T+0:05 - Attack uses credentials from external IP (your laptop)
         └─ Makes: sts:GetCallerIdentity API call
         └─ External IP: Your public IP
T+0:06 - CloudTrail logs the API call:
         └─ PrincipalId: AIDAJ... (instance role)
         └─ SourceIP Address: 203.0.113.50 (your laptop IP)
         └─ User Agent: aws-cli
         └─ Action: GetCallerIdentity
T+0:07 - GuardDuty detection trigger:
         └─ "Credentials used from external IP"
         └─ Severity: HIGH
         └─ Finding: UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration.OutsideAWS
T+0:08 - Alert fires in SIEM (if you have detection rule)
T+0:09 - Stratus cleanup deletes test instance
         └─ Instance i-0a1b2c3d4e5f6g7h8 terminated

Total time: ~9 minutes
```

**Analyst Perspective:**
```
Time: T+0:08 (alert fires)

Alert Details:
  Type: GuardDuty Finding
  Title: Credentials used from external IP
  Severity: 8.0 (HIGH)
  Instance: i-0a1b2c3d4e5f6g7h8
  External IP: 203.0.113.50 (YOUR laptop IP during test!)
  
Analyst Actions:
  1. Check context: Is this expected? (No! Instance IP is internal)
  2. Check instance: What does it do? (Test EC2)
  3. Check timeline: When did this start? (Just now)
  4. Check for damage: What was accessed? (Just sts:GetCallerIdentity)
  5. Escalate: Is this real? (YES - but it's our red team test!)
```

---

### Example Attack #2: Disable CloudTrail (Should Fail!)

**The Scenario:**
```
Attacker Goal: Disable CloudTrail to hide attacks
MITRE Technique: T1562.008 (Impair Defenses: Disable Cloud Logs)
Expected Result: SHOULD FAIL (due to your SCP from Module 1)
```

**Execution:**

```bash
# Warmup (not needed - just need CloudTrail running)
$ stratus warmup aws.defense-evasion.cloudtrail-stop
Output: Skipped (resource already exists)

# Detonate
$ stratus detonate aws.defense-evasion.cloudtrail-stop
Output:
  Attempting to stop CloudTrail logging...
  API: StopLogging
  ❌ ERROR: Access Denied
  Service: CloudTrail
  Error Code: AccessDenied
  Reason: User is not authorized to perform: cloudtrail:StopLogging

  Attack FAILED (which is good!)
```

**What Happened:**
```
1. Stratus attacker tries: aws cloudtrail stop-logging
2. AWS API check: Is this principal allowed to stop CloudTrail?
3. Checks applied:
   ├─ IAM Policy: AdministratorAccess (allows everything)
   ├─ SCP (Service Control Policy): DENIES cloudtrail:StopLogging
   └─ Result: SCP takes precedence, action DENIED
4. Action blocked BEFORE it happens
5. CloudTrail logs the attempt: "StopLogging" with result "AccessDenied"

This is **Preventive Control** in action!
Without SCP: CloudTrail would be disabled (bad!)
With SCP: Attack fails, CloudTrail intact (good!)
```

---

## 📊 Documenting Stratus Test Results

### Test Result Template

```markdown
# Stratus Red Team Test - [Technique Name]

**Date:** 2025-10-28
**Tester:** Peter Kolawole
**Technique:** T1552.005 (Cloud Instance Metadata API)
**MITRE Category:** Credential Access

## Attack Details
- **Description:** Steal EC2 instance credentials via metadata service
- **Warmup Time:** 2 minutes
- **Attack Duration:** 30 seconds
- **Cleanup Time:** 1 minute
- **Total Time:** 3.5 minutes

## Detection Results
- **Alert Fired:** YES ✅
- **Alert Type:** GuardDuty Finding
- **Alert Time:** T+8 seconds (after attack started)
- **Detection Method:** Credentials used from external IP
- **MTTD (Mean Time to Detect):** 8 seconds ⭐

## Response Assessment
- **Detection Tool:** GuardDuty
- **Manual Review Needed:** YES (analyst verified legitimate)
- **Automated Response:** None triggered (false positive prevention)
- **Recommended Action:** If real: Isolate instance, disable role

## Findings
✅ POSITIVE: GuardDuty detected credential exfiltration rapidly
⚠️  GAP: No automated response to this finding
⚠️  GAP: Alert severity HIGH, but manual review needed

## Recommendations
1. Create automated playbook for this finding
2. Implement cross-account credential usage detection
3. Block external IP access to instance metadata (security group)
4. Add to incident response runbook

## Metrics
- Successful Attack: YES
- Detected: YES (8 seconds)
- Response Capability: Partial (manual only)
- Risk Reduction: 70% (detected but no auto-response)
```

---

## 🎯 Creating Custom Attacks

Stratus provides template for custom attacks:

```yaml
# custom-attack.yaml
id: custom.credential-access.steal-password-hash
name: Steal Password Hashes
description: Extract password hashes from database
tactic: credential-access
technique:
  - id: T1110
    reference: https://attack.mitre.org/techniques/T1110/

platforms:
  - aws

steps:
  - name: warmup
    description: Create test RDS database
    action:
      - rds:CreateDBInstance
  
  - name: detonate
    description: Query database for password hashes
    action:
      - rds:DescribeDBInstances
      - mysql-client: "SELECT * FROM users"
  
  - name: cleanup
    description: Delete test database
    action:
      - rds:DeleteDBInstance

detection:
  - source: CloudTrail
    events:
      - CreateDBInstance
      - DescribeDBInstances
    rules:
      - Large SELECT query detected
      - Password field access detected
```

---

## 💰 Cost of Stratus Testing

| Component | Cost | Notes |
|-----------|------|-------|
| **Stratus Tool** | $0 | Free/open-source |
| **EC2 Instances (warmup)** | $0.05/attack | t2.micro (~5 min) |
| **RDS (if needed)** | $0.10/attack | db.t3.micro (~5 min) |
| **Data Transfer** | $0.00 | Within AWS |
| **Total per Attack** | **~$0.15** | Incredibly cheap! |

**Running 100 attacks/month: $15**

---

## 📋 Purple Team Exercise Using Stratus

```
Week 1: Planning
[ ] Identify tactics to test (using MITRE framework)
[ ] Select 5-10 Stratus techniques
[ ] Plan detection rules for each
[ ] Brief team on exercise

Week 2: Preparation
[ ] Set up sandbox AWS account
[ ] Install Stratus Red Team
[ ] Prepare SIEM dashboards
[ ] Dry-run attacks

Week 3: Execution
Each day, run 2 attacks:
  Day 1: T1552.005 (credential theft)
  Day 2: T1562.008 (disable CloudTrail)
  Day 3: T1136.003 (create IAM user)
  Day 4: T1530 (steal S3 data)
  Day 5: T1486 (data encryption)

For each attack:
- [ ] Run warmup
- [ ] Alert on SIEM (watch live)
- [ ] Run detonate
- [ ] Measure detection time
- [ ] Check incident response
- [ ] Run cleanup
- [ ] Document findings

Week 4: Debrief & Improvement
[ ] Compile results
[ ] Present to leadership
[ ] Create action items
[ ] Update detection rules
[ ] Plan next exercise
```

---

**Ready for Sandbox setup? Move to Module 9! 🚀**
