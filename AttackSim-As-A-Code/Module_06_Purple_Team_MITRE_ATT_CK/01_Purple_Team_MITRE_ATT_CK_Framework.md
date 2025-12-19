# Module 6: Purple Team Methodology & MITRE ATT&CK Framework

## 📚 What is Purple Team?

**Technical Definition:**
"Purple Team" is the combination of Red Team (offensive/attack) and Blue Team (defensive). Purple teamers test an organization's defenses by simulating attacks (Red) while the defenders respond (Blue), creating a continuous feedback loop for improvement.

**Layman Analogy:**
Purple team is like **hiring a professional burglar to test your house's security:**

- **Without purple team:** You have locks, cameras, alarms, but you don't know if they actually work. Burglar gets in anyway.
- **With purple team:** Professional burglar tests every entrance, documents what works and what doesn't. You fix the gaps BEFORE a real criminal tries.

**The Three Teams:**

```
RED TEAM               PURPLE TEAM           BLUE TEAM
(Attackers)           (Both teams)           (Defenders)

Goal: Attack          Goal: Test & Improve  Goal: Defend
Role: Offensive       Role: Collaborative   Role: Defensive

How: Simulate         How: Red tests,       How: Detect,
     real attacks     Blue responds,        respond,
                      Both learn            recover

Example: Try to       Example: Attacker     Example: SOC
break in             tests, defender       monitors,
undetected           improves, both        analysts
                     share findings        respond
```

---

## 🎯 MITRE ATT&CK Framework

### What is MITRE ATT&CK?

**Technical:** MITRE ATT&CK (Adversarial Tactics, Techniques & Common Knowledge) is a globally-accessible knowledge base of adversary tactics and techniques based on real-world observations. It provides a common language for describing attacker behavior.

**Layman:** MITRE ATT&CK is like a **playbook documenting how criminals actually break in:**

Instead of imaginary attacks, MITRE documents:
- ✅ Real attacks that have happened
- ✅ Exactly which tools/techniques were used
- ✅ Which defenses would have prevented it
- ✅ Detection methods that would have caught it

### MITRE ATT&CK Tactic Categories

Attackers follow a logical progression (Kill Chain):

```
1. RECONNAISSANCE
   └─ What do you want to attack?
   └─ Techniques: OSINT, scanning, social engineering research
   └─ Example: "I want to attack Acme Corp. Let me research their employees..."

2. RESOURCE DEVELOPMENT
   └─ Get tools/infrastructure for attack
   └─ Techniques: Buy domains, set up C2 servers, acquire malware
   └─ Example: "I need a domain to send phishing emails from..."

3. INITIAL ACCESS
   └─ Get into the target's network
   └─ Techniques: Phishing, drive-by download, supply chain attack
   └─ Example: "Send phishing email to CEO to get her password..."

4. EXECUTION
   └─ Run code on target system
   └─ Techniques: PowerShell, command line, exploit
   └─ Example: "Download and run ransomware executable..."

5. PERSISTENCE
   └─ Stay in the system even if they restart
   └─ Techniques: Install backdoor, create admin user, modify startup
   └─ Example: "Create 'maintenance' admin account so I can get back in later..."

6. PRIVILEGE ESCALATION
   └─ Get higher access (user → admin)
   └─ Techniques: Exploit kernel vulnerability, sudo abuse, steal admin credentials
   └─ Example: "Run privilege escalation exploit to become root..."

7. DEFENSE EVASION
   └─ Avoid being detected
   └─ Techniques: Disable antivirus, clear logs, hide processes
   └─ Example: "Delete CloudTrail logs so no one knows what I did..."

8. CREDENTIAL ACCESS
   └─ Steal passwords/tokens
   └─ Techniques: Phishing, credential dumping, brute force
   └─ Example: "Use Mimikatz to dump passwords from memory..."

9. DISCOVERY
   └─ Learn what's in the network
   └─ Techniques: Network scanning, directory enumeration, environment variable enumeration
   └─ Example: "List all S3 buckets to find valuable data..."

10. LATERAL MOVEMENT
    └─ Move from one system to another
    └─ Techniques: SSH/RDP to other servers, pass-the-hash
    └─ Example: "Use stolen credentials to SSH into database server..."

11. COLLECTION
    └─ Steal the data
    └─ Techniques: Data exfiltration, screen capture, clipboard capture
    └─ Example: "Download all customer data from S3..."

12. COMMAND & CONTROL
    └─ Communicate with attacker's servers
    └─ Techniques: HTTPS to remote IP, DNS tunneling, encrypted channel
    └─ Example: "Send stolen data to attacker's server in Russia..."

13. EXFILTRATION
    └─ Get data out of network
    └─ Techniques: Transfer over C2 channel, compress and upload, cloud service
    └─ Example: "Compress customer database, upload to Dropbox..."

14. IMPACT
    └─ Cause damage
    └─ Techniques: Encrypt with ransomware, delete data, DDoS
    └─ Example: "Encrypt everything with AES-256 and demand ransom..."
```

### Example Attack Using MITRE ATT&CK Language

**Real Attack: NotPetya Ransomware**

```
Attacker Goal: Spread ransomware, encrypt systems, extort ransom

MITRE Tactics Used:
1. RECONNAISSANCE
   - Researched software development company "Linkos"
   - Found they create popular accounting software
   - Identified thousands of enterprise customers

2. RESOURCE DEVELOPMENT
   - Set up infrastructure to host malware
   - Acquired legitimate code-signing certificates (stolen)
   - Staged malware in hidden repositories

3. INITIAL ACCESS (Supply Chain Attack)
   - Compromised Linkos development server
   - Injected malware into software update package
   - Customers auto-updated software (trusted source!)

4. EXECUTION
   - Malicious DLL runs during Windows update
   - Drops NotPetya ransomware payload
   - Executes encryption routine

5. PERSISTENCE
   - Registers Run keys in Windows registry
   - Ensures malware survives reboot
   - Creates multiple copies across system

6. PRIVILEGE ESCALATION
   - Exploits Windows EternalBlue vulnerability (CVE-2017-0144)
   - Escalates from user → SYSTEM (full control)

7. DEFENSE EVASION
   - Disables Windows Update
   - Stops antivirus processes
   - Clears event logs
   - Uses legitimate Windows tools (living off the land)

8. CREDENTIAL ACCESS
   - Harvests credentials from system memory
   - Cracks password hashes
   - Gains access to other systems

9. DISCOVERY
   - Enumerates network shares
   - Lists connected servers
   - Identifies valuable systems

10. LATERAL MOVEMENT
    - Uses stolen credentials to SSH/RDP to other servers
    - Spreads malware across entire network
    - Infects hundreds of systems

11. COLLECTION
    - Identifies important files (documents, databases)
    - Prepares high-value targets for encryption

12. COMMAND & CONTROL
    - Communicates back to attacker infrastructure
    - Reports progress
    - Receives encryption key

13. EXFILTRATION
    - Exfiltrates sensitive documents
    - Uploads to attacker's servers

14. IMPACT
    - Encrypts files with AES-256
    - Shows ransom note
    - Demands 300 Bitcoin (~$300K)
    - Cripples entire organization

Real-World Result:
- 200,000+ computers infected in 65 countries
- Estimated $10 billion in damage
- Companies like Maersk, hospitals, hospitals, banks affected
```

---

## 🔴 Red Team vs. 🔵 Blue Team vs. 🟣 Purple Team

| Aspect | Red Team | Blue Team | Purple Team |
|--------|----------|-----------|-------------|
| **Goal** | Attack/compromise | Defend/respond | Test & improve |
| **Mindset** | Offense | Defense | Both |
| **Tools** | Metasploit, Burp, Stratus | SIEM, IDS, Firewall | Both attack & defense |
| **Objective** | Find vulnerabilities | Find attackers | Find gaps in defense |
| **Collaboration** | Often separate | Often separate | **Collaborates!** |
| **Outcome** | "Here's what we found" | "We detected you" | "How do we fix this?" |

### Purple Team Activity Example

**Traditional (Red vs Blue):**
```
Red Team: "We found 10 vulnerabilities and compromised 5 systems!"
Blue Team: "Great, we'll patch those."
... 6 months later ...
Blue Team: (Still doesn't know how to detect the attacks)
Red Team: (Still not aware of defenses)
Gap: They never talk about detection!
```

**Purple Team Approach:**
```
Day 1: Planning
- Red Team: "We want to test credential access techniques"
- Blue Team: "Good, we want to know if we can detect theft"
- Purple Team: "Let's work together"

Day 2-5: Red attacks
- Red Team simulates credential theft (phishing, brute force, etc.)
- Blue Team actively monitors for attacks
- Both teams observe each other's actions

Day 6: Debrief
- Red Team: "Here's what we did, how you should have detected it"
- Blue Team: "Here's what we detected, here's what we missed"
- Purple Team: "Here's how we can improve both offense AND defense"

Outcome:
✅ Red understands how Blue detects attacks
✅ Blue understands how Red bypasses defenses
✅ Team improves exponentially
```

---

## 🎯 Building a Purple Team Program

### Step 1: Establish Team Structure

```
Red Team (Attack)
├─ Penetration testers
├─ Security researchers
├─ Ethical hackers
└─ Goal: Find vulnerabilities

Blue Team (Defense)
├─ SOC analysts
├─ Incident responders
├─ Security engineers
└─ Goal: Detect and respond to attacks

Purple Team (Bridge)
├─ Incident commander (leads coordination)
├─ Red team representative
├─ Blue team representative
└─ Goal: Collaborate and improve
```

### Step 2: Define Scope & Rules

```
What systems can Red Team attack?
✅ Sandbox AWS account
✅ Test databases
✅ Non-production servers

❌ Production systems (unless approved)
❌ Customer data (unless encrypted test data)
❌ Physical attacks (unless authorized)

Rules of Engagement:
- Communication protocols (when to stop, escalation procedures)
- Business hours vs. off-hours testing
- Data handling (what can be captured?)
- Reporting (what gets documented?)
```

### Step 3: Plan Attack Scenarios

Using MITRE ATT&CK:

```
Scenario 1: Initial Access & Reconnaissance
- Red Team: Send phishing email
- Technique: T1566 (Phishing)
- Blue Team: Try to detect email
- Defenses: Email filtering, user training, MFA
- Learning: Did we catch it? If not, why?

Scenario 2: Lateral Movement
- Red Team: Use stolen credentials to SSH to DB server
- Technique: T1021.004 (Remote Services: SSH)
- Blue Team: Try to detect suspicious login
- Defenses: Unusual location detection, failed login alerts
- Learning: How do we distinguish normal vs. abnormal?

Scenario 3: Data Exfiltration
- Red Team: Copy sensitive data to cloud storage
- Technique: T1567 (Exfiltration Over Web Service)
- Blue Team: Try to detect unusual data movement
- Defenses: DLP rules, network monitoring
- Learning: What's our baseline? Can we detect anomalies?
```

### Step 4: Execute and Observe

```
Red Team executes attack:
- 9:00 AM: Send phishing email
- 9:15 AM: User clicks (catches credentials)
- 9:16 AM: Log in to AWS console
- 9:17 AM: List S3 buckets
- 9:18 AM: Start downloading customer data

Blue Team monitors:
- 9:00 AM: Email arrives (let's monitor for clicks)
- 9:15 AM: See email opened (not flagged)
- 9:16 AM: ⚠️ ALERT: Unusual login location
- 9:17 AM: ⚠️ ALERT: API call from unusual IP
- 9:18 AM: ⚠️ ALERT: Large S3 data access

Purple Team observes both:
- Red: "Attack executed successfully"
- Blue: "Detected in 2 minutes"
- Purple learns: Detection works, but could be faster
```

### Step 5: Debrief & Improve

```
Questions for the team:

Red Team:
- What techniques worked?
- What techniques were blocked?
- How could you have been more stealthy?
- What detection gaps did you exploit?

Blue Team:
- What did you detect?
- What did you miss?
- How fast did you respond?
- What could improve detection?

Together:
- How can Red be more effective?
- How can Blue be more defensive?
- What process improvements needed?
- What tooling improvements needed?

Action Items:
- Red: "Next time try living-off-the-land techniques"
- Blue: "Need better anomaly detection"
- Purple: "Implement: Baseline user behavior profiles"
```

---

## 📊 Mapping Attacks to Detection/Response

Using MITRE ATT&CK for incident response planning:

```
ATTACK TECHNIQUE: T1098 (Account Manipulation)
Description: Attacker creates backdoor admin account

MITRE Details:
- Sub-technique: T1098.001 (Additional Cloud Credentials)
- Platforms: AWS, Azure, GCP
- Data sources: CloudTrail, IAM audit logs
- Mitigations:
  • MFA on privileged accounts
  • Monitor account creation
  • Regular access reviews
  • Principle of least privilege

YOUR RESPONSE PLAN:
1. Detection:
   - Alert: "New IAM user created by unknown principal"
   - Data source: CloudTrail (CreateUser event)
   - Threshold: Any new user is suspicious
   - Action: Alert to security team

2. Investigation:
   - Query: "Who created this account?"
   - Query: "Has this account been used?"
   - Query: "What permissions did account get?"
   - Check: Is creator legitimate?

3. Response (if real attack):
   - Immediate: Delete account
   - Cleanup: Revoke any access keys created
   - Check: Did attacker use account to do anything?
   - Long-term: Review all accounts, remove suspicious ones

4. Prevention:
   - Enforce: Only authorized tools can create users
   - Monitor: Multi-person approval for admin accounts
   - Track: Regular access reviews (monthly)
   - Alert: Immediately notify on admin account creation
```

---

## 🚀 Building Your Purple Team Program

**Maturity Levels:**

```
Level 1: RED ONLY
- One team performs penetration tests
- Blue team doesn't know about it
- Results: "Here's what we found"
- Gap: Blue team doesn't learn to detect

Level 2: SEQUENTIAL
- Red performs attack
- Blue gets report after completion
- Blue implements fixes
- Gap: Still not collaborative, learning delayed

Level 3: CONCURRENT (PURPLE TEAM!)
- Red attacks in real-time
- Blue monitors and responds simultaneously
- Both teams share observations
- Outcome: Immediate learning and improvement

Level 4: CONTINUOUS
- Purple team runs constant simulations
- Automated red team tools (Stratus Red Team)
- Continuous monitoring improvement
- Outcome: Security posture improves rapidly
```

---

## 📋 Purple Team Monthly Schedule

```
Week 1: Planning
- Identify tactics to test (based on MITRE ATT&CK)
- Define scenarios
- Brief teams on rules of engagement
- Set success criteria

Week 2: Preparation
- Red team: Prepare tools and attack scripts
- Blue team: Ensure monitoring is active
- Purple team: Final coordination

Week 3-4: Execution
- Monday: Test Scenario 1 (e.g., Initial Access)
- Tuesday: Debrief, document findings
- Wednesday: Test Scenario 2 (e.g., Persistence)
- Thursday: Debrief, document findings
- Friday: Overall debrief with leadership

Post-Exercise:
- Document findings
- Create action items
- Implement improvements
- Update detection rules
- Report to security leadership
```

---

## 💰 Purple Team Program Costs

```
Personnel (Largest cost):
- Red team lead: $150K/year
- 2 penetration testers: $300K/year
- Blue team coordinator: $120K/year
- Tools support staff: $100K/year
Total Personnel: ~$670K/year

Tools & Infrastructure:
- Sandbox AWS environment: $5K/month = $60K/year
- Red team tools (Metasploit, Burp, etc.): $10K/year
- Blue team tools (SIEM, etc.): Already budgeted
Total Tools: ~$70K/year

TOTAL PURPLE TEAM COST: ~$740K/year

ROI Calculation:
- Cost: $740K/year
- Prevents: Average breach costs $4.4 million
- Probability: Reduces breach probability by 50% (estimated)
- Expected value prevented: $4.4M × 50% = $2.2M
- ROI: $2.2M / $740K = 3:1

Plus soft benefits:
- Faster incident response
- Better security culture
- Improved team coordination
- Regulatory compliance
```

---

**Ready for purple team exercises? Move to Module 8 (Stratus Red Team Attack Simulation)!**

**Next: Module 7 (Compliance Frameworks) then Module 8 (Stratus Red Team) 🚀**
