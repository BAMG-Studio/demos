# Module 2: SIEM Architecture & Security Operations Center (SOC) Workflows

## 📚 Overview

**What You'll Learn:** How to design, deploy, and operate a Security Information and Event Management (SIEM) system that ingests security data from across your AWS environment and enables a Security Operations Center (SOC) team to detect, investigate, and respond to threats in real-time.

**File Map (hands-on path):**
- `01_SIEM_Architecture_Design.md` (existing)
- `02_Log_Ingestion_Pipelines.md`
- `03_Data_Model_and_Fields.md`
- `04_Dashboards_and_Use_Cases.md`
- `05_Alerting_and_Runbooks.md`
- `06_Cost_and_Sizing.md`
- `07_Portfolio_Resume.md`

**Success Criteria (lab):** One source (CloudTrail) onboarded end-to-end; three dashboards live; five alerts mapped to runbooks; cost/retention plan documented.

**Learning Time:** 16-20 hours  
**Difficulty:** Intermediate → Advanced  
**Prerequisites:** Module 1 (AWS Organizations) completed  
**Real-World Context:** Every enterprise with >500 employees has a SOC team managing a SIEM. This is a core skill for defensive security roles.

---

## 🎯 What is a SIEM? (Layman Explanation)

**Technical Definition:**
A SIEM (Security Information and Event Management) is a centralized platform that:
1. **Collects** security data from all sources (firewalls, servers, cloud services, applications)
2. **Normalizes** data into a common format (different systems speak different languages)
3. **Analyzes** patterns to detect suspicious behavior (what looks weird?)
4. **Alerts** security team to potential incidents (ring the bell!)
5. **Stores** evidence for forensics and compliance (keep the receipts!)

**Layman Analogy:**

Imagine a bank with 500 security cameras, 100 alarm sensors, and 50 security guards:

❌ **Without SIEM:** Each guard watches their own monitor. One sees a guy checking door locks. Another sees tailgating. Another sees unusual ATM usage. But nobody talks to each other. Attacker slips through because no one sees the full picture.

✅ **With SIEM:** All camera feeds go to a central control room with a security analyst. The analyst sees:
- Guy checking doors (suspicious)
- Same guy tailgating (more suspicious)
- Same guy's badge using multiple ATMs in 5 minutes (definitely suspicious!)
- Analyst calls police before theft happens

**That's a SIEM: connecting the dots to see the full attack picture!**

---

## 📋 Sub-Modules in This Section

### Sub-Module 1: SIEM Architecture & Design
- **What:** How to design a SIEM system architecture for enterprise environments
- **Time:** 2 hours
- **Outcome:** Architecture diagram + design document

### Sub-Module 2: Log Ingestion Pipelines
- **What:** Getting data from 50+ AWS sources into your SIEM (CloudTrail, VPC Flow Logs, GuardDuty, etc.)
- **Time:** 3 hours
- **Outcome:** Functional ingestion pipeline with Kinesis Firehose + Lambda

### Sub-Module 3: Data Normalization & Indexing
- **What:** Converting different log formats into searchable indexes
- **Time:** 2 hours
- **Outcome:** Index templates for CloudTrail, GuardDuty, VPC Flow Logs, AWS Config

### Sub-Module 4: SIEM Dashboards & Visualizations
- **What:** Building dashboards that SOC analysts use to monitor security
- **Time:** 3 hours
- **Outcome:** 10+ operational dashboards (security overview, threat intelligence, etc.)

### Sub-Module 5: Alerting & Detection Rules
- **What:** Creating rules that automatically detect threats (brute force, data exfiltration, etc.)
- **Time:** 3 hours
- **Outcome:** 20+ production-ready detection rules

### Sub-Module 6: SOC Workflows & Procedures
- **What:** How SOC analysts actually use the SIEM (incident investigation, threat hunting, reporting)
- **Time:** 3 hours
- **Outcome:** SOC runbooks + analyst workflows

### Sub-Module 7: Threat Hunting & Forensics
- **What:** Advanced investigation techniques (finding attacker activity, timeline reconstruction)
- **Time:** 2 hours
- **Outcome:** Threat hunting playbook + forensic analysis techniques

### Sub-Module 8: SIEM Operations & Maintenance
- **What:** Keeping the SIEM running (scaling, tuning, backups, disaster recovery)
- **Time:** 2 hours
- **Outcome:** Operations procedures + cost optimization guide

---

## 🎓 Learning Paths

### Path 1: SIEM Operator (8 hours) - For SOC Analysts
Best if you want to: Use a SIEM to find and investigate threats

**Sequence:**
1. Sub-Module 1: SIEM Architecture (understand the big picture)
2. Sub-Module 4: Dashboards & Visualizations (learn to use it)
3. Sub-Module 5: Alerting & Rules (understand what triggers alerts)
4. Sub-Module 6: SOC Workflows (learn analyst procedures)
5. Sub-Module 7: Threat Hunting (advanced investigation)

### Path 2: SIEM Engineer (12 hours) - For Cloud/Security Engineers
Best if you want to: Build and maintain a SIEM

**Sequence:**
1. Sub-Module 1: Architecture (design principles)
2. Sub-Module 2: Log Ingestion (get data in)
3. Sub-Module 3: Normalization & Indexing (make it searchable)
4. Sub-Module 4: Dashboards (make it visible)
5. Sub-Module 5: Alerting (automate detection)
6. Sub-Module 8: Operations (run it smoothly)

### Path 3: SOC Manager (10 hours) - For Leadership/Hiring
Best if you want to: Build and manage a SOC team

**Sequence:**
1. Sub-Module 1: Architecture (understand capabilities)
2. Sub-Module 6: SOC Workflows (understand team structure)
3. Sub-Module 4: Dashboards (what leadership sees)
4. Sub-Module 7: Threat Hunting (advanced analyst work)
5. Sub-Module 8: Operations (team management)

---

## 🛠️ Hands-On Labs

### Lab 1: Deploy OpenSearch SIEM Cluster
**Time:** 2 hours  
**Outcome:** Running SIEM system processing real AWS logs

### Lab 2: Ingest CloudTrail Logs via Kinesis Firehose
**Time:** 1.5 hours  
**Outcome:** CloudTrail data flowing into SIEM in real-time

### Lab 3: Create SIEM Detection Rule
**Time:** 1 hour  
**Outcome:** Alert that fires when brute force attack detected

### Lab 4: Investigate Sample Security Incident
**Time:** 1.5 hours  
**Outcome:** Complete incident investigation from detection to resolution

### Lab 5: Build SIEM Dashboard
**Time:** 1 hour  
**Outcome:** Interactive dashboard showing security posture

---

## 💰 Cost Estimates

| Service | Usage | Monthly | Annual | Notes |
|---------|-------|---------|--------|-------|
| **OpenSearch Domain** | 1 node (t3.small.search) | $26 | $315 | SIEM cluster |
| **EBS Storage** | 20 GB | $1.60 | $19 | Log storage |
| **Kinesis Firehose** | 50 GB/month | $0.90 | $11 | Log ingestion |
| **Lambda** | Log transformation | $0.20 | $2 | Data processing |
| **CloudWatch** | Log ingestion | $1.00 | $12 | Log monitoring |
| **SNS** | Alert notifications | $0.10 | $1 | Incident alerts |
| **S3 Backup** | Forensic archival | $0.12 | $1.44 | Long-term storage |
| **TOTAL** | **Per Month** | **~$30** | **~$361** | Full SIEM stack |

**Cost Optimization:**
- Use t3.small.search for learning ($26/month) → scale to r6g.large.search for production ($300+/month)
- Enable ILM (Index Lifecycle Management) to move old logs to cheaper storage
- Compress data in Kinesis Firehose (20% cost reduction)
- Delete old test indexes regularly

---

## 🎯 Success Metrics

By the end of this module, you should be able to:

- ✅ Design a SIEM architecture for enterprise environments
- ✅ Ingest logs from 50+ AWS sources in real-time
- ✅ Create detection rules that find actual threats
- ✅ Build dashboards for SOC teams
- ✅ Investigate security incidents using SIEM data
- ✅ Conduct threat hunting (find hidden attackers)
- ✅ Manage SIEM operations at scale

---

## 📊 Resume Bullet Points

After completing this module, you can add to your resume:

```
• Architected and deployed AWS OpenSearch SIEM cluster ingesting 50GB/day of 
  security telemetry from CloudTrail, GuardDuty, VPC Flow Logs, and Config 
  supporting real-time threat detection and forensic investigation

• Implemented automated log ingestion pipeline using Kinesis Firehose with Lambda 
  transformation functions achieving <60 second latency from log generation to 
  searchability with 99.9% data delivery success rate

• Designed 20+ detection rules and automated alerting for critical security events 
  including brute force attempts, data exfiltration, and compliance violations 
  reducing mean time to detect (MTTD) by 70%

• Built interactive SIEM dashboards and visualizations enabling SOC analysts to 
  monitor security posture, conduct threat hunting, and perform forensic analysis 
  across 1M+ daily security events

• Established index lifecycle management policies optimizing storage costs through 
  hot/warm/cold tiering achieving 60% cost reduction while maintaining 2-year 
  log retention for compliance requirements
```

---

## 🎓 Prerequisites Check

Before starting this module, ensure:
- ✅ AWS account with Organizations set up (Module 1)
- ✅ CloudTrail enabled in all accounts
- ✅ GuardDuty enabled in Security Hub account
- ✅ VPC Flow Logs enabled (at least one VPC)
- ✅ AWS Config enabled
- ✅ IAM permissions to launch OpenSearch, Kinesis, Lambda
- ✅ Basic understanding of JSON and AWS CLI

---

## 📝 Files in This Module

1. **01_SIEM_Architecture_Design.md** - Architecture patterns and design principles
2. **02_Log_Ingestion_Pipeline.md** - How to get data from AWS into SIEM
3. **03_Data_Normalization_Indexing.md** - Making logs searchable
4. **04_SIEM_Dashboards_Visualizations.md** - Building operational dashboards
5. **05_Detection_Rules_Alerting.md** - Creating detection rules
6. **06_SOC_Workflows_Procedures.md** - How analysts use the SIEM
7. **07_Threat_Hunting_Forensics.md** - Advanced investigation techniques
8. **08_SIEM_Operations_Maintenance.md** - Running the SIEM at scale
9. **LAB_Complete_SIEM_Deployment.md** - Step-by-step lab guide
10. **PORTFOLIO_SIEM_Project.md** - Portfolio documentation for job search

---

## 🚀 Getting Started

**Recommended First Step:**
1. Read "01_SIEM_Architecture_Design.md" (30 minutes) to understand concepts
2. Jump to "LAB_Complete_SIEM_Deployment.md" (2 hours) to get hands-on
3. Then deep-dive into specific sub-modules based on your learning path

---

## 🤝 Need Help?

- **Q: What's the difference between SIEM and SOAR?**
  - **SIEM** = detect and report threats (passive analysis)
  - **SOAR** = automate response actions (active response)
  - This module covers SIEM. Module 4 covers SOAR automation.

- **Q: Should I use OpenSearch or Splunk?**
  - **OpenSearch:** Open-source, cheap ($26/month), good for learning
  - **Splunk:** Enterprise, expensive ($100K+/year), used in Fortune 500
  - This module covers both. Labs use OpenSearch (cheaper), but concepts apply to Splunk.

- **Q: How many rules do I need?**
  - Start with 20-30 rules covering top threats
  - Mature SIEM has 200+ rules
  - More rules = more alerts = analyst fatigue
  - Balance: Detection capability vs. alert noise

---

**Ready to build your SIEM? Let's go! 🚀**
