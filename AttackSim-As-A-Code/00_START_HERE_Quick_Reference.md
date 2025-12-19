# 🎓 Complete Curriculum Quick Reference Guide

## Start Here! 📍

**New to this curriculum?** Read these files in order:

### Week 1: Foundation
1. Read: `COURSE_STRUCTURE_AND_ROADMAP.md` (Overview)
2. Read: `Module_01/README.md` (How organizations are structured)
3. Read: `Module_02/README.md` (What is SIEM)

### Week 2-3: SIEM Technology
4. Read: `Module_02/01_SIEM_Architecture_Design.md` (Core concepts)
5. Read: `Module_03/01_OpenSearch_Splunk_Comparison.md` (Which tool to use)
6. **DO:** Deploy sandbox (Module 9, steps 1-5)

### Week 4: Incident Response
7. Read: `Module_04/01_Defensive_Cyber_Operations_Framework.md` (IR lifecycle)
8. Read: `Module_05/01_High_Impact_Incident_Scenarios.md` (All 10 scenarios)
9. **PRACTICE:** Tabletop exercise with team (pick 1 scenario)

### Week 5: Testing & Validation
10. Read: `Module_06/01_Purple_Team_MITRE_ATT_CK_Framework.md` (Attack frameworks)
11. Read: `Module_08/01_Stratus_Red_Team_Guide.md` (How to attack safely)
12. **PRACTICE:** Run first Stratus attack in sandbox

### Week 6: Compliance
13. Read: `Module_07/01_NIST_CIS_HIPAA_Implementation.md` (Regulatory requirements)
14. **DO:** Configure AWS Config rules in sandbox
15. **REVIEW:** SESSION_SUMMARY.md (What you've learned)

---

## 📚 Module-by-Module Guide

### Module 1: AWS Organizations & Multi-Account Security
**Time:** 2-3 weeks | **Level:** Beginner | **Prerequisite:** AWS account access

**What you'll learn:**
- How large companies organize multiple AWS accounts
- SCPs (Service Control Policies) to prevent mistakes
- Cross-account access and permissions

**Files:**
- `Module_01/AWS_Organizations_Management_and_Setup.md` - Step-by-step setup
- `Module_01/Service_Control_Policies_Practical_Implementation.md` - Prevent bad actions
- `Module_01/Cross_Account_Access_and_Governance.md` - Share resources safely
- `Module_01/Audit_Logging_and_Monitoring_Multi_Account_Setup.md` - Track everything
- `Module_01/Cost_Analysis_and_Optimization.md` - Save money
- `Module_01/Case_Study_Real_World_Multi_Account_Architecture.md` - Real example
- `Module_01/PORTFOLIO_Interview_Resume_LinkedIn.md` - Job search materials

**Hands-on:**
- Create AWS Organization from scratch
- Deploy 3-5 test accounts
- Configure SCPs to deny dangerous actions
- Monitor with CloudTrail

**Expected Outcome:**
- Interview-ready multi-account architecture knowledge
- Can explain to non-technical people
- Can implement in real AWS

---

### Module 2: SIEM Architecture & SOC Operations
**Time:** 1-2 weeks | **Level:** Intermediate | **Prerequisite:** Module 1

**What you'll learn:**
- What SIEM systems are (log collection + analysis)
- How to design a SIEM infrastructure
- Real attack timeline and detection

**Files:**
- `Module_02/README.md` - Module overview
- `Module_02/01_SIEM_Architecture_Design.md` - Complete architecture

**Hands-on:**
- Deploy OpenSearch cluster
- Ingest CloudTrail logs
- Create sample detection rule
- Build basic dashboard

**Expected Outcome:**
- Understand log processing pipeline
- Can architect SIEM infrastructure
- Know how to detect attacks

---

### Module 3: OpenSearch & Splunk SIEM Tools
**Time:** 1 week | **Level:** Intermediate | **Prerequisite:** Module 2

**What you'll learn:**
- How to use OpenSearch (AWS native, $28/month)
- How to use Splunk (enterprise, $2,000+/month)
- Which tool to choose when

**Files:**
- `Module_03/01_OpenSearch_Splunk_Comparison.md` - Comparison + labs

**Hands-on:**
- Create OpenSearch domain
- Index sample data
- Write search queries
- Create dashboard
- Compare with Splunk free trial

**Expected Outcome:**
- Hands-on experience with both tools
- Can make cost-effective choice for organization
- Know strengths/weaknesses of each

---

### Module 4: Defensive Cyber Operations & IR Automation
**Time:** 1-2 weeks | **Level:** Intermediate | **Prerequisite:** Modules 2-3

**What you'll learn:**
- NIST incident response lifecycle (6 phases)
- How to automate response (playbooks)
- Metrics: MTTD (detection speed), MTTR (fix speed)

**Files:**
- `Module_04/01_Defensive_Cyber_Operations_Framework.md` - Complete framework

**Hands-on:**
- Create Lambda function for playbook
- Deploy EventBridge rule to trigger
- Test automated response
- Measure time to execute

**Expected Outcome:**
- Can design incident response process
- Know how to automate with Lambda
- Understand business metrics

---

### Module 5: Incident Response Simulations
**Time:** 2-3 weeks | **Level:** Intermediate to Advanced | **Prerequisite:** Module 4

**What you'll learn:**
- 10 realistic high-impact incident scenarios
- How to investigate
- How to respond
- Business impact of each

**Files:**
- `Module_05/01_High_Impact_Incident_Scenarios.md` - All 10 detailed

**Scenarios:**
1. Brute Force Attack (30 min)
2. Ransomware (1 hour)
3. Insider Threat (2 hours)
4. Supply Chain Attack (2-3 hours)
5. API-Based Attack (1 hour)
6. DDoS (1 hour)
7. Cloud Misconfiguration (30 min)
8. Compliance Violation (2 hours)
9. Multi-Stage Kill Chain (3+ hours)
10. Failure Analysis (2 hours)

**Hands-on:**
- Tabletop exercise with team (30-60 min per scenario)
- Solo practice writing response plans
- Hands-on labs in sandbox (running actual attacks)

**Expected Outcome:**
- Team trained on realistic scenarios
- Documented response procedures
- MTTD/MTTR metrics established

---

### Module 6: Purple Team & MITRE ATT&CK Framework
**Time:** 1-2 weeks | **Level:** Advanced | **Prerequisite:** Module 5

**What you'll learn:**
- MITRE ATT&CK framework (14 tactic categories)
- How red team attacks work
- How to validate blue team (defense) is working
- How to build purple team program

**Files:**
- `Module_06/01_Purple_Team_MITRE_ATT_CK_Framework.md` - Complete guide

**Hands-on:**
- Map real attack to MITRE tactics
- Plan purple team exercise
- Document which tactics your defenses can detect

**Expected Outcome:**
- Can speak MITRE language
- Know how to build purple team program
- Can explain attack methodology

---

### Module 7: Compliance Frameworks
**Time:** 2 weeks | **Level:** Intermediate | **Prerequisite:** Modules 2-4

**What you'll learn:**
- NIST 800-53 (14 control families)
- CIS AWS Foundations (5 areas)
- HIPAA Security Rule (4 safeguards)
- How to audit and maintain compliance

**Files:**
- `Module_07/01_NIST_CIS_HIPAA_Implementation.md` - All 3 frameworks

**Hands-on:**
- Configure AWS Config rules
- Set up Security Hub dashboard
- Check compliance posture
- Create remediation plan

**Expected Outcome:**
- Understand regulatory requirements
- Can map controls to technical solutions
- Know how to validate compliance

---

### Module 8: Stratus Red Team Attack Simulation
**Time:** 1-2 weeks | **Level:** Advanced | **Prerequisite:** Modules 5-6

**What you'll learn:**
- How to safely simulate attacks
- 50+ AWS attack techniques
- How to measure detection effectiveness
- Purple team exercise methodology

**Files:**
- `Module_08/01_Stratus_Red_Team_Guide.md` - Complete guide

**Hands-on:**
- Install Stratus Red Team tool
- Run first attack (credential theft)
- Measure MTTD (time to detect)
- Test if detection rules fire
- Document findings

**Expected Outcome:**
- Can run safe attack simulations
- Know 50+ AWS attack techniques
- Can measure defense effectiveness
- Can run purple team exercises

---

### Module 9: Sandbox Environment Setup
**Time:** 1 week | **Level:** Beginner to Intermediate | **Prerequisite:** Module 1

**What you'll learn:**
- How to create isolated AWS sandbox account
- What monitoring to deploy
- How to create test resources
- Safe testing environment

**Files:**
- `Module_09/01_Sandbox_Complete_Setup_Guide.md` - Complete setup

**Hands-on:**
- Create sandbox AWS account
- Deploy monitoring (CloudTrail, GuardDuty, Config)
- Create test EC2, RDS, S3
- Set up CloudWatch dashboard

**Expected Outcome:**
- Safe environment for testing
- Monitoring in place
- Ready to run all other modules

---

## 🎯 Quick Navigation by Role

### If you're a SOC Analyst (Detecting threats):
**Read in this order:**
1. Module 2: SIEM Architecture
2. Module 3: OpenSearch & Splunk
3. Module 5: Incident Response Scenarios
4. Module 4: IR Framework
→ **Practice:** Run scenarios in sandbox

### If you're a Security Engineer (Building defenses):
**Read in this order:**
1. Module 1: Organizations (understand structure)
2. Module 2: SIEM Architecture
3. Module 7: Compliance Frameworks
4. Module 4: Automation & Playbooks
5. Module 6: Purple Team (test your work)
→ **Practice:** Deploy sandbox, run Stratus

### If you're a CISO (Managing security program):
**Read in this order:**
1. Module 1: Organizations
2. Module 4: IR Lifecycle
3. Module 5: Incident Scenarios
4. Module 6: Purple Team Program
5. Module 7: Compliance
→ **Practice:** Run IR drills, establish metrics

### If you're a Penetration Tester:
**Read in this order:**
1. Module 6: MITRE ATT&CK
2. Module 8: Stratus Red Team
3. Module 5: Scenarios (understand detection)
4. Module 2: SIEM (what's detecting you?)
→ **Practice:** Run Stratus attacks, document

---

## 📊 Time Commitment Summary

| Role | Modules | Time | Outcome |
|------|---------|------|---------|
| Analyst | 2,3,4,5 | 6-8 weeks | Can detect & respond to incidents |
| Engineer | 1,2,4,6,7 | 8-10 weeks | Can architect security solutions |
| CISO | 1,4,5,6,7 | 6-8 weeks | Can manage security program |
| Penetration Tester | 6,8,5,2 | 4-6 weeks | Can run safe red team exercises |
| Complete Curriculum | All 9 | 12-16 weeks | Enterprise security expert |

---

## ✅ Completion Checklist

Track your progress:

**Month 1: Foundation**
- [ ] Read Module 1 (AWS Organizations)
- [ ] Read Module 2 (SIEM Architecture)
- [ ] Deploy sandbox account
- [ ] Enable monitoring (CloudTrail, GuardDuty)

**Month 2: Core Skills**
- [ ] Read Module 3 (OpenSearch & Splunk)
- [ ] Read Module 4 (IR Framework)
- [ ] Deploy OpenSearch cluster in sandbox
- [ ] Create first detection rule

**Month 3: Practice**
- [ ] Read Module 5 (10 Scenarios)
- [ ] Run tabletop exercise (pick 2 scenarios)
- [ ] Create incident response playbook
- [ ] Document MTTD/MTTR metrics

**Month 4: Advanced**
- [ ] Read Module 6 (Purple Team)
- [ ] Read Module 8 (Stratus Red Team)
- [ ] Run first Stratus attack
- [ ] Measure detection effectiveness

**Month 5: Validation**
- [ ] Read Module 7 (Compliance)
- [ ] Configure AWS Config rules
- [ ] Set up Security Hub
- [ ] Check compliance posture

**Month 6+: Expertise**
- [ ] Run monthly purple team exercises
- [ ] Conduct incident response drills
- [ ] Update incident playbooks
- [ ] Document lessons learned

---

## 🚀 Getting Started NOW

**Right Now (5 minutes):**
1. Go to: `Module_01/README.md`
2. Read what you'll learn
3. Decide if you have 2-3 weeks

**This Week:**
1. Read: `Module_02/01_SIEM_Architecture_Design.md`
2. Watch related AWS tutorials (search "OpenSearch SIEM")
3. Start sandbox deployment (Module 9)

**Next Week:**
1. Deploy sandbox AWS account
2. Enable monitoring
3. Read Module 3 (OpenSearch & Splunk)
4. Deploy OpenSearch in sandbox

**Follow-up:**
1. Read Modules 4-5 (Incident Response)
2. Run tabletop exercise with team
3. Create incident playbooks
4. Document what you learned

---

**🎓 Welcome to the curriculum! You're about to become an enterprise security expert. Let's go! 🚀**
