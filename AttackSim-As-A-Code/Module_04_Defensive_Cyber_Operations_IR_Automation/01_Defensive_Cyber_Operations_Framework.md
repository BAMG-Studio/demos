# Module 4: Defensive Cyber Operations & Incident Response Automation

## 📚 What is Defensive Cyber Operations?

**Technical Definition:**
Defensive Cyber Operations (DCO) is the practice of detecting, investigating, and responding to security threats in real-time using automated and manual processes. It includes:
1. **Detection** - Find attacks as they happen
2. **Investigation** - Determine scope and impact
3. **Response** - Stop the attack and contain damage
4. **Recovery** - Restore normal operations
5. **Learning** - Improve for next time

**Layman Analogy:**
Defensive cyber operations is like a **hospital emergency response system:**

- **Detection** = Patient arrives with chest pain (911 call)
- **Investigation** = Doctors run tests to determine if it's a heart attack
- **Response** = Immediate surgery/medication to save life
- **Recovery** = Rehabilitation to restore health
- **Learning** = Autopsy/review to prevent future incidents

**Real Example Timeline:**

```
2:47 AM - ATTACK BEGINS
  └─ Attacker compromises EC2 instance
  
2:47:30 AM - DETECTION (30 seconds later)
  └─ GuardDuty detects suspicious activity
  └─ SIEM alert fires
  └─ SNS email sent to security team
  
2:48 AM - INVESTIGATION (1 minute)
  └─ On-call analyst checks SIEM
  └─ Determines: 1 instance compromised, 5 GB data accessed
  └─ Escalates to incident commander
  
2:48:30 AM - RESPONSE INITIATED (1.5 minutes)
  └─ Automated playbooks execute:
     • Isolate instance (remove network access)
     • Disable compromised credentials
     • Create forensic snapshots
     • Block attacker IP
  └─ Manual actions:
     • Notify management
     • Prepare legal/law enforcement notification
  
2:50 AM - CONTAINMENT COMPLETE (3 minutes)
  └─ Attacker no longer has access
  └─ Damage limited to 5 GB (vs. potential 1 TB)
  
Next day - RECOVERY
  └─ Restore from clean backup
  └─ Verify no further compromise
  
Next week - POST-INCIDENT REVIEW
  └─ Weak password enabled attack (policy change)
  └─ Create new detection rule (future prevention)
  └─ Train team on security best practices
```

---

## 🏗️ Incident Response Framework: NIST IR Lifecycle

All incident response follows the NIST 800-61 framework:

### Phase 1: PREPARATION
**Goal:** Get ready before incidents happen

**Activities:**
- Deploy monitoring (SIEM, GuardDuty, CloudWatch)
- Build incident response team
- Create runbooks (playbooks)
- Test playbooks regularly
- Train team
- Ensure backups exist

**Example:** "Before we have an incident, we have playbooks written, team trained, SIEM running, and backups tested."

### Phase 2: DETECTION & ANALYSIS
**Goal:** Find incident, determine if real, understand scope

**Activities:**
- Alert fires (brute force, malware, data exfiltration)
- Analyst investigates: Is this real or false positive?
- Determine: What system affected? What's the scope?
- Escalate if needed

**Example:**
```
Alert: 50 failed logins on user "peter"
Analyst investigates:
  - Check CloudTrail: Peter was on vacation (not him doing it)
  - Check SIEM: Attack from IP 203.0.113.1
  - Check geolocation: IP from Uzbekistan
  - Determination: REAL ATTACK - brute force attempt
  - Scope: One account, no successful logins yet
  - Severity: MEDIUM (attack detected before success)
```

### Phase 3: CONTAINMENT
**Goal:** Stop the attack and limit damage

**Short-Term Containment (stop active attack):**
- Block attacker IP
- Disable compromised credentials
- Isolate infected systems
- Revoke active sessions

**Long-Term Containment (prevent further damage):**
- Patch systems
- Change passwords
- Apply security updates
- Implement fixes for vulnerability

**Example:**
```
Incident: Database compromised, attacker has admin password
Short-term (minutes):
  - Force logout all sessions
  - Change admin password
  - Block attacker IP
  - Enable detailed logging
  
Long-term (hours/days):
  - Patch database vulnerability
  - Enable encryption at rest
  - Implement MFA
  - Deploy WAF to prevent web attacks
```

### Phase 4: ERADICATION
**Goal:** Remove attacker from system completely

**Activities:**
- Remove malware/backdoors
- Close vulnerabilities
- Identify and remove attacker tools
- Verify attacker cannot return

**Example:**
```
Found: Backdoor user account "maintenance" created by attacker
Eradication steps:
  1. Document account creation (CloudTrail)
  2. Check all actions taken by account (forensics)
  3. Check for other backdoors (SSH keys, scheduled tasks)
  4. Delete all attacker artifacts
  5. Scan for rootkits/malware
  6. Verify no alternate access methods exist
```

### Phase 5: RECOVERY
**Goal:** Restore systems to normal operation

**Activities:**
- Restore from clean backups
- Rebuild compromised systems
- Restore data
- Verify functionality
- Gradually return to production

**Example:**
```
Incident: Ransomware encrypted database
Recovery:
  1. Create new database instance (clean)
  2. Restore data from backup (pre-ransomware)
  3. Restore from point-in-time (8 hours before attack)
  4. Verify data integrity (spot checks)
  5. Gradually bring clients back (monitor for issues)
  6. Full restoration (24-48 hours total)
```

### Phase 6: POST-INCIDENT ACTIVITIES
**Goal:** Learn and improve

**Activities:**
- Document timeline and facts
- Identify root cause (how did attacker get in?)
- Create action items (fix root cause, improve detection)
- Update playbooks
- Train team
- Share lessons learned

**Example:**
```
Incident Summary:
  Attacker compromised EC2 instance via weak password
  
Root Cause Analysis:
  - Password: peter123 (dictionary word)
  - No password policy enforcement
  - No MFA enabled
  - No SSH key enforcement
  
Improvements:
  1. Enforce strong password policy (15+ chars, complexity)
  2. Require MFA for all users
  3. Enforce SSH keys (disable password auth)
  4. Add detection rule: "Root login via password"
  5. Create run book: "Compromised instance playbook"
  6. Train team on attack vectors
```

---

## 🤖 Automated Incident Response Playbooks

### What are Playbooks?

**Technical:** Playbooks are automated workflows triggered by alerts that perform standardized response actions without human intervention.

**Layman:** Playbooks are like **emergency procedures at an airport:**

- **Alarm sounds:** Fire detected in terminal
- **Automatic procedures trigger:**
  1. Sprinklers activate
  2. Doors lock (prevent spread)
  3. Alarm broadcasts evacuation
  4. Emergency lights activate
  5. Fire department auto-called
- **Result:** Immediate, coordinated response without firefighters thinking about what to do

**Key Benefits:**
- ✅ **Speed:** Seconds vs. hours/days
- ✅ **Consistency:** Same response every time
- ✅ **Scale:** Handle 100 incidents simultaneously
- ✅ **Accuracy:** No human error
- ✅ **Evidence:** Automated logging of response

### Playbook Example #1: Brute Force Attack Response

**Trigger:** Alert "Failed login attempts > 10 in 5 minutes"

**Automated Actions (execute in sequence):**

```python
1. GATHER INTELLIGENCE
   Get details from GuardDuty/CloudTrail:
   - Attacker IP address
   - Target user account
   - Number of attempts
   - Time window
   - Successful logins? (YES = worse!)

2. IMMEDIATE CONTAINMENT
   Disable user's temporary:
   - Force logout active sessions
   - Disable console access
   - Disable API access keys
   - Action: "Buying time while analyst investigates"

3. BLOCK ATTACKER
   Network-level defense:
   - Add attacker IP to WAF block list
   - Update security groups (deny from that IP)
   - Action: "Prevent any further connection attempts"

4. PRESERVE EVIDENCE
   Save everything for forensics:
   - Query CloudTrail for all events from attacker IP
   - Get VPC Flow Logs showing connection attempts
   - Create snapshot of any affected systems
   - Save to S3 forensics bucket
   - Action: "Keep the crime scene intact"

5. NOTIFY TEAM
   Send alert with all details:
   - To: security-team@acme.com
   - Message: "Brute force attack on user [X] from IP [Y]"
   - Attachment: List of 100+ failed login events
   - Action: "Get human analysts involved"

6. LOG INCIDENT
   Create incident record:
   - Timestamp
   - Type: Brute Force Attack
   - Affected user
   - Attacker IP
   - Actions taken
   - Action: "For compliance and post-incident review"
```

**Timeline:**
- 2:47 PM - Attack starts (10 failed logins in 5 min)
- 2:52 PM - Alert fires
- 2:52:15 PM - Playbook executes all 6 steps
- 2:52:45 PM - Analyst notified
- 2:53 PM - Analyst investigates (user was on vacation, so definitely attacker!)
- 2:54 PM - Manual verification (credentials = real attack)
- 2:55 PM - Decision: Reset password, require MFA going forward
- 2:56 PM - Total time from attack to containment: ~9 minutes

---

### Playbook Example #2: Compromised EC2 Instance

**Trigger:** GuardDuty finding "Compromised EC2 instance"

**Automated Actions:**

```python
1. ISOLATE INSTANCE
   Network-level isolation:
   - Get instance ID and VPC
   - Create new security group: "QUARANTINE" (all traffic denied)
   - Replace instance's security groups with QUARANTINE
   - Effect: Instance cannot send or receive any network traffic
   - Action: "Prevent attacker from communicating with C2 or stealing data"

2. CREATE FORENSIC SNAPSHOT
   Preserve evidence:
   - Get all EBS volumes attached to instance
   - Create snapshot of each volume
   - Tag snapshots with incident metadata:
     • Incident date/time
     • GuardDuty finding ID
     • Original instance ID
   - Store snapshots in forensics account
   - Action: "Preserve system state for investigation"

3. TAG INSTANCE WITH METADATA
   Mark compromised system:
   - Add tags:
     • Status: COMPROMISED
     • IncidentID: INC-20251028-001
     • GuardDutyFinding: [finding ID]
     • ContainmentTime: [timestamp]
   - Action: "Label for manual investigation"

4. QUERY CLOUDTRAIL
   Find all attacker activity:
   - Get all API calls from instance in last 24 hours
   - Parse results to find suspicious actions:
     • Data exfiltration attempts
     • Privilege escalation
     • Lateral movement
   - Save results to S3
   - Action: "Understand what attacker did"

5. CREATE INCIDENT TICKET
   Automated incident management:
   - Tool: Jira/ServiceNow
   - Title: "CRITICAL: Compromised EC2 Instance [i-xxx]"
   - Description: Instance ID, GuardDuty finding, actions taken
   - Assign to: On-call security engineer
   - Priority: CRITICAL
   - Action: "Ensure human review"

6. NOTIFY SECURITY TEAM
   Send alert with full context:
   - Channels: Email, Slack, SMS (if critical)
   - Message template:
     ```
     🚨 CRITICAL SECURITY INCIDENT 🚨
     
     Type: Compromised EC2 Instance
     Instance: i-0abc123def456
     Instance Name: production-web-server-03
     Region: us-east-1
     
     GuardDuty Finding Type: [type]
     Severity: HIGH/CRITICAL
     
     ACTIONS TAKEN AUTOMATICALLY:
     ✅ Instance isolated (all network traffic blocked)
     ✅ Forensic snapshots created
     ✅ Instance tagged with incident metadata
     ✅ CloudTrail activity queried and saved
     ✅ Jira ticket created: JIRA-12345
     
     NEXT STEPS FOR ANALYST:
     1. Access forensic snapshots: s3://forensics/.../snapshots
     2. Review CloudTrail activity: s3://forensics/.../activity
     3. Determine blast radius (was data stolen?)
     4. Decide: Restore from backup OR deep investigation
     5. Identify root cause (how was instance compromised?)
     6. Implement fix (patch? stronger credentials? WAF rule?)
     
     Time: 2025-10-28T13:47:15Z
     ```
   - Action: "Get immediate human attention"
```

**Timeline:**
- 2:45 AM - Attacker compromises instance
- 2:47 AM - GuardDuty detects (2 minute detection)
- 2:47:30 AM - Playbook executes (30 seconds total):
  - 2:47:05 - Instance isolated
  - 2:47:10 - Snapshots started
  - 2:47:15 - CloudTrail queried
  - 2:47:25 - Jira ticket created
  - 2:47:30 - Email sent
- 2:48 AM - Analyst reads email
- 2:50 AM - Analyst reviews forensics
- 2:52 AM - Decision made (restore from backup)
- **Total: 7 minutes from breach to full containment**

**Without Playbook:**
- Would have taken 2-3 HOURS for manual response
- Attacker would have stolen data, installed backdoors, spread to other systems
- Damage: 1000x worse

---

## 🎯 Key Incident Response Metrics

**Mean Time to Detect (MTTD):** How long from attack to detection
- ❌ Without SIEM: 24-48 hours (customer reports issue)
- ✅ With SIEM: 5-30 minutes
- ✅ With GuardDuty: 1-5 minutes
- 🏆 Best practice: <5 minutes

**Mean Time to Respond (MTTR):** How long from detection to containment
- ❌ Without automation: 2-24 hours (analyst manually taking actions)
- ✅ With automation: 1-5 minutes (playbooks executing)
- 🏆 Best practice: <15 minutes

**Mean Time to Recover (MTRC):** How long from containment to normal operation
- ❌ For complex systems: Hours to days
- ✅ With backups: Minutes to hours
- 🏆 Best practice: <1 hour

**Key Calculation: Business Impact**

```
Attack Vector: Ransomware
System: Database with $1M/hour business value
Scenario A (No automation):
  Detection: 24 hours
  Response: 12 hours
  Recovery: 36 hours
  TOTAL DOWNTIME: 72 hours
  Cost: 72 × $1M = $72 MILLION

Scenario B (With automation):
  Detection: 5 minutes
  Response: 15 minutes
  Recovery: 30 minutes
  TOTAL DOWNTIME: 50 minutes
  Cost: 50 min × $1M/hour = ~$833K

SAVINGS: $72M - $833K = $71.1 MILLION!
```

That's why automated incident response is critical!

---

## 📝 Building Your Own Playbooks

**Framework for any playbook:**

```
1. TRIGGER
   When does this playbook execute?
   - Alert: "Brute force attack"
   - Finding: "Compromised credentials"
   - Event: "Public S3 bucket detected"

2. PRE-EXECUTION CHECKS
   Is this real or false positive?
   - Check SIEM context
   - Verify alert confidence
   - Check if attacker is already contained

3. INVESTIGATION PHASE
   Gather information:
   - What system affected?
   - What user involved?
   - How did attacker get in?
   - What did they do?

4. CONTAINMENT PHASE
   Stop the attack:
   - Block access (IP, credentials, account)
   - Isolate systems (network isolation)
   - Disable compromised resources

5. ERADICATION PHASE
   Remove all traces:
   - Delete backdoors
   - Remove malware
   - Change passwords
   - Patch vulnerabilities

6. RECOVERY PHASE
   Restore normal operations:
   - Restore from clean backup
   - Re-enable access for legitimate users
   - Monitor for re-infection

7. NOTIFICATION & LOGGING
   Alert team & preserve evidence:
   - Send incident notification
   - Log all automated actions
   - Create incident record
   - Prepare for post-incident review

8. POST-INCIDENT
   Learn and improve:
   - Identify root cause
   - Create action items
   - Update this playbook if needed
   - Share lessons learned
```

---

## 💰 Cost of Incident Response Automation

| Component | Monthly Cost | Notes |
|-----------|-------------|-------|
| **EventBridge Rules** | $0 | First 14 free |
| **Lambda Functions** | $0.20 | Log transformation |
| **SNS Notifications** | $0.10 | Email/SMS alerts |
| **S3 Forensics** | $1.00 | Evidence storage |
| **CloudWatch Logs** | $0.50 | Audit trail |
| **Total** | **~$2/month** | Incredibly cheap! |

**ROI:** $2/month cost vs. $1M+ prevented per incident = **500,000:1 return on investment!**

---

**Ready to automate incident response? Move to Module 5 for hands-on implementation! 🚀**
