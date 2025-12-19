# SIEM Architecture & Design - Deep Dive

## 📚 What is SIEM Architecture?

**Technical Definition:**
SIEM architecture is the design of a centralized security monitoring system that:
1. **Ingests** logs from all security tools (hundreds of data sources)
2. **Normalizes** logs into common format (makes them comparable)
3. **Enriches** logs with context (who is this user? what's normal?)
4. **Analyzes** for patterns indicating attacks
5. **Alerts** security team automatically
6. **Stores** evidence for forensics and compliance

**Layman Analogy:**
Think of a SIEM like a **hospital patient monitoring system:**

- **Data Collection** = Heart monitor, blood pressure cuff, oxygen sensor, temperature probe (all monitoring different vital signs)
- **Normalization** = Doctor's dashboard showing all metrics in one place (pulse, BP, O2, temp)
- **Analysis** = Doctor's brain noticing "pulse 150 + BP 180 + shallow breathing = heart attack risk!"
- **Alerting** = Alarm that goes off and calls the cardiology team
- **Storage** = Medical records saved for future reference

Without a SIEM, you'd have:
- ❌ Heart monitor data on one machine
- ❌ Blood pressure data on another
- ❌ Oxygen sensor on a third
- ❌ Doctor running between rooms not seeing the full picture
- ❌ Missing patterns that would be obvious together

With a SIEM:
- ✅ All data on one dashboard
- ✅ Automatic analysis of combinations
- ✅ Alerts when patterns indicate problems
- ✅ Full medical history saved

---

## 🏗️ SIEM Architecture Components

### Component 1: Data Sources (What Gets Monitored)

**AWS Services Generating Security Data:**

```
CloudTrail               Kinesis Firehose     OpenSearch SIEM
   (API logs)               (buffering)          (analysis)
      ↓                         ↓                     ↓
   [Who did what?]    [Queue the data]    [Find suspicious patterns]
   
GuardDuty               Kinesis Firehose     OpenSearch SIEM
(threat findings)          (buffering)          (analysis)
      ↓                         ↓                     ↓
  [Threats detected]   [Queue the data]    [Correlate with other data]
  
VPC Flow Logs           Kinesis Firehose     OpenSearch SIEM
(network traffic)          (buffering)          (analysis)
      ↓                         ↓                     ↓
 [Who talks to whom?]  [Queue the data]    [Find data exfiltration]
```

**Key Data Sources:**

1. **CloudTrail (API Activity)**
   - Every API call to AWS services
   - Who, what, when, where, result
   - ~500 KB per day for small orgs, 50+ GB for large orgs

2. **GuardDuty (Threat Findings)**
   - AI-powered threat detection
   - ~10-100 findings per day (depends on activity)
   - High fidelity (usually real threats)

3. **VPC Flow Logs (Network Traffic)**
   - Every network connection (billions per day!)
   - Source IP, destination IP, port, bytes transferred
   - Huge volume but very valuable for detecting exfiltration

4. **AWS Config (Configuration Changes)**
   - When configurations change
   - Security group modifications, IAM policy changes, S3 ACL changes
   - Detects misconfigurations

5. **CloudWatch Logs (Application Logs)**
   - Logs from EC2 instances, Lambda functions, applications
   - Varies by application (web server, database, custom code)

6. **ALB/NLB Access Logs (Web Traffic)**
   - HTTP/HTTPS requests to load balancers
   - User agent, source IP, response codes
   - Useful for detecting web attacks

7. **WAF Logs (Web Application Firewall)**
   - Blocked and allowed requests
   - Attack patterns and payloads
   - Useful for detecting web exploits

8. **S3 Access Logs (Object Access)**
   - Who accessed which S3 objects
   - Read, write, delete operations
   - Useful for detecting data exfiltration

---

### Component 2: Log Ingestion Layer (Getting Data In)

**Architecture Pattern:**

```
AWS Services     Kinesis Firehose      Lambda          S3 (Backup)
    ↓                 ↓                  ↓                  ↓
CloudTrail ────→ Buffer/Queue ────→ Transform ────→ Archival
GuardDuty  ────→ (auto-scaling) ────→ (normalize) ────→ (7-year retention)
VPC Logs   ────→ (batch loading) ────→ (enrich) ────→
Config ────→                      ────→
```

**Layman Explanation:**
- **AWS Services:** These are the security cameras/sensors generating data
- **Kinesis Firehose:** This is a conveyor belt that buffers incoming data (so it doesn't overwhelm the system)
- **Lambda:** This is a worker that transforms data (converts different formats to a standard format)
- **S3 Backup:** This saves a copy for long-term archival and compliance

**Benefits:**
- ✅ Handles huge volumes (10,000+ events per second)
- ✅ Automatic scaling (no capacity planning needed)
- ✅ Low cost (~$0.90/month for 50GB data)
- ✅ Automatic retry on failures
- ✅ Built-in data backup to S3

**How It Works Step-by-Step:**

```
1:47 PM UTC: CloudTrail generates API log
  └─ "User peter@acme.com created EC2 instance i-0abc123"
  └─ ~1 KB of data
  
1:47:01 PM: Data sent to Kinesis Firehose
  └─ Firehose buffers (waits for more data to arrive)
  └─ Collects 500 KB or waits 60 seconds (whichever comes first)
  
1:47:45 PM: 60 second buffer expires
  └─ Firehose has collected 50 KB of data
  └─ Sends to Lambda function
  
1:47:46 PM: Lambda processes data
  └─ Transforms CloudTrail JSON → standard format
  └─ Adds enrichment (user department, IP location)
  └─ Sends to OpenSearch SIEM
  
1:47:50 PM: Data searchable in SIEM
  └─ Total latency: 3 minutes 50 seconds
  └─ Good enough for most scenarios
  
1:47:50 PM: Data also backed up to S3
  └─ Kept for 7 years for compliance
```

---

### Component 3: Data Normalization (Making Data Comparable)

**The Problem:**

Different systems log in different formats:

```
CloudTrail Format:
{
  "eventTime": "2025-10-28T13:47:15Z",
  "eventSource": "ec2.amazonaws.com",
  "eventName": "RunInstances",
  "userIdentity": {
    "principalId": "AIDACKCEVSQ6C2EXAMPLE",
    "arn": "arn:aws:iam::123456789012:user/peter",
    "userName": "peter"
  }
}

GuardDuty Format:
{
  "createAt": 1609459200000,
  "type": "UnauthorizedAccess:EC2/SSHBruteForce",
  "finding": {
    "resourceType": "Instance",
    "instanceDetails": {
      "instanceId": "i-0abc123def456ghi"
    }
  }
}

VPC Flow Logs Format:
version account-id interface-id srcaddr dstaddr srcport dstport protocol packets bytes windowstart windowend action

2 123456789012 eni-0abc123 10.0.1.10 192.168.1.1 22 32780 6 100 8200 1609459200 1609459260 ACCEPT
```

**Different fields, different names, different formats!**

**The Solution: Data Normalization**

Convert all formats to a standard schema:

```
NORMALIZED FORMAT (all data sources):
{
  "@timestamp": "2025-10-28T13:47:15Z",     # When did it happen?
  "event_type": "api_call",                  # What kind of event?
  "event_name": "RunInstances",              # What action?
  "event_source": "ec2",                     # Which AWS service?
  
  "user": {
    "id": "AIDACKCEVSQ6C2EXAMPLE",          # Who did it?
    "name": "peter",
    "arn": "arn:aws:iam::123456789012:user/peter"
  },
  
  "resource": {
    "type": "EC2:Instance",                 # What was affected?
    "id": "i-0abc123def456ghi",
    "account": "123456789012"
  },
  
  "result": "success",                       # Did it work?
  
  "source": {
    "ip": "192.168.1.1",                    # Where did it come from?
    "port": 22,
    "geo": {
      "country": "US",
      "city": "New York"
    }
  },
  
  "severity": "medium"                       # How bad is it?
}
```

**Benefits:**
- ✅ All data in one format → easy to search
- ✅ Consistent field names → simple alerting rules
- ✅ Easy comparison across sources → find correlations

**How Normalization Works:**

```
1. Lambda receives raw CloudTrail log
   └─ JSON with CloudTrail field names
   
2. Lambda checks source (CloudTrail)
   └─ Loads CloudTrail normalization rules
   
3. Lambda maps CloudTrail fields → standard fields
   └─ eventName → event_name
   └─ userIdentity.userName → user.name
   └─ resources[0].ARN → resource.arn
   
4. Lambda enriches with additional context
   └─ Looks up user in directory (department? group?)
   └─ Looks up IP in geolocation database
   └─ Compares to baseline (is this user's normal behavior?)
   
5. Lambda sends normalized log to SIEM
   └─ Now ready for analysis
```

---

### Component 4: SIEM Indexing (Making Data Searchable)

**What is an Index?**

An index is like a **book's index page** that lets you quickly find information:

❌ **Without Index:**
- Have a 1000-page book
- Need to find "CloudTrail logs from peter"
- Read entire book page by page
- Takes 30 minutes

✅ **With Index:**
- Book's index shows:
  - "CloudTrail: pages 234-456"
  - "peter: pages 100, 234, 567"
- Go directly to page 234
- Find what you need in 30 seconds

**SIEM Indexes Work the Same Way:**

```
Raw Logs in S3:          vs.    SIEM Indexes:
-                               
10 trillion events              Optimized for search:
(unorganized)              
                           Index "cloudtrail-2025-10":
Search needs to scan            - cloudtrail logs from October 2025
ALL 10 trillion                 - Optimized for event_timestamp
(slow! expensive!)              - Optimized for user.name
                           
                           Index "guardduty-2025-10":
                                - GuardDuty findings from October 2025
                                - Optimized for severity
                                - Optimized for finding_type
                           
                           Index "vpcflow-2025-10":
                                - Network traffic from October 2025
                                - Optimized for source_ip
                                - Optimized for destination_ip
```

**Index Lifecycle Management (ILM):**

As data ages, move it to cheaper storage:

```
Day 0-30: HOT Index
├─ SSD storage (fast/expensive)
├─ Data: 100 GB/day
├─ Use for: Daily analysis, dashboards
├─ Cost: $5/day

Day 31-90: WARM Index
├─ Standard storage (slower/cheaper)
├─ Data: 3 TB
├─ Use for: Weekly reports, compliance
├─ Cost: $0.50/day (90% cheaper!)

Day 91-730: COLD Index
├─ Archival storage (very slow/very cheap)
├─ Data: 20 TB
├─ Use for: Forensics, audits, legal
├─ Cost: $0.05/day (99% cheaper!)

Day 730+: DELETE or move to Glacier
├─ Delete old data to save costs
├─ Or move to Glacier for 7+ year retention
```

---

### Component 5: Detection & Alerting (Finding Threats)

**How Detection Works:**

```
Alert Rule: "Brute Force Attack"

Trigger Condition:
  IF (eventName == "ConsoleLogin" AND result == "failure")
  AND (same user has >10 failures in 5 minutes)
  THEN fire alert

Example Timeline:
  1:30:01 PM - ConsoleLogin failure (user peter)
  1:30:15 PM - ConsoleLogin failure (user peter) 
  1:30:28 PM - ConsoleLogin failure (user peter)
  1:30:42 PM - ConsoleLogin failure (user peter)
  1:30:55 PM - ConsoleLogin failure (user peter) 
  1:31:08 PM - ConsoleLogin failure (user peter)
  1:31:21 PM - ConsoleLogin failure (user peter)
  1:31:34 PM - ConsoleLogin failure (user peter)
  1:31:47 PM - ConsoleLogin failure (user peter)
  1:32:00 PM - ConsoleLogin failure (user peter)
  1:32:13 PM - ConsoleLogin failure (user peter)
  1:32:15 PM - ConsoleLogin failure (user peter) ← 11th failure in 5 minutes!
  
🚨 ALERT FIRES! → SNS email → "Brute Force Attack detected on peter!"
```

**Types of Detection Rules:**

1. **Signature-Based** (Pattern matching)
   - Look for known attack patterns
   - Example: "Disable CloudTrail" = eventName == "StopLogging"
   - Fast, accurate, but only catches known attacks

2. **Anomaly-Based** (Unusual behavior)
   - Compare to normal baseline
   - Example: "peter usually logs in at 9 AM from Office IP. Login at 3 AM from China = anomaly!"
   - Catches unknown attacks, but can have false positives

3. **Correlation** (Multiple events together)
   - Combine events that together indicate attack
   - Example: "Privilege escalation = GetRole + AttachRolePolicy + AssumeRole (all in 2 minutes)"
   - Most powerful, finds sophisticated attacks

---

### Component 6: Investigation & Response (What Analysts Do)

**Incident Investigation Workflow:**

```
1. ALERT FIRES
   ↓
   "🚨 High-severity GuardDuty finding: Compromised EC2 Instance"
   
2. ANALYST OPENS SIEM
   ↓
   Dashboard → Incident details
   
3. QUESTION 1: What happened?
   ↓
   Search CloudTrail for instance
   Find: "SSH from 58.32.100.201 (China) at 2:45 AM"
   Find: "Downloaded large file from S3"
   Find: "Modified security group to allow outbound to C2 server"
   
4. QUESTION 2: Who was affected?
   ↓
   Search for all instances by same user
   Find: 3 instances affected, user created backups
   
5. QUESTION 3: How bad is it?
   ↓
   Check GuardDuty for other findings
   Check VPC Flow Logs for data exfiltration
   Size of data: 50 GB (CRITICAL!)
   
6. QUESTION 4: What do we do?
   ↓
   Incident response playbook:
   - Isolate affected instances
   - Disable compromised credentials
   - Block attacker IP
   - Notify management
   - Prepare forensic evidence
   
7. EXECUTE RESPONSE
   ↓
   Automated playbooks execute (see Module 4)
   OR manual response by security team
   
8. DOCUMENT & IMPROVE
   ↓
   Root cause: Weak password (peter123)
   Improvement: Enforce strong password policy
   Update detection rules
```

---

## 🎯 SIEM Architecture Decision Matrix

**Choosing the Right SIEM:**

| Factor | OpenSearch | Splunk | AWS CloudWatch Logs | Datadog |
|--------|-----------|--------|-------------------|---------|
| **Cost/Month** | $26 | $2000+ | $50 | $500+ |
| **Learning Curve** | Low | Medium | Low | Medium |
| **Customization** | High | Very High | Low | Medium |
| **Scalability** | Medium | Very High | Very High | Very High |
| **Built for AWS** | Moderate | Low | High | Medium |
| **Data Retention** | Configurable | Configurable | Configurable | 15 months default |
| **Best For** | Learning/Startups | Enterprise | AWS-only | DevOps/Ops |

**Recommendation:**
- **Learning/Certification:** OpenSearch ($26/month - perfect for this course)
- **Small Business:** OpenSearch + AWS CloudWatch Logs (combined ~$75/month)
- **Medium Business:** Splunk (~$2,000/month for 10GB/day)
- **Enterprise:** Splunk or Datadog ($50,000+/year)

---

## 🏗️ Complete SIEM Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        AWS SECURITY ENVIRONMENT                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  MANAGEMENT ACCOUNT              PRODUCTION ACCOUNT                      │
│  ┌──────────────────┐             ┌──────────────────┐                   │
│  │ CloudTrail       │             │ CloudTrail       │                   │
│  │ (org-wide logs)  │             │ (prod logs)      │                   │
│  └────────┬─────────┘             └────────┬─────────┘                   │
│           │                                 │                             │
│  ┌──────────────────┐             ┌──────────────────┐                   │
│  │ GuardDuty        │             │ GuardDuty        │                   │
│  │ (findings)       │             │ (findings)       │                   │
│  └────────┬─────────┘             └────────┬─────────┘                   │
│           │                                 │                             │
│  ┌──────────────────┐             ┌──────────────────┐                   │
│  │ Config           │             │ VPC Flow Logs    │                   │
│  │ (config changes) │             │ (network traffic)│                   │
│  └────────┬─────────┘             └────────┬─────────┘                   │
│           └─────────────┬──────────────────┘                              │
│                         │                                                 │
│                    LOGS TO...                                             │
│                         ↓                                                 │
│                         │                                                 │
│      ┌──────────────────────────────────────┐                            │
│      │    SECURITY LOGGING ACCOUNT          │                            │
│      ├──────────────────────────────────────┤                            │
│      │                                      │                            │
│      │  S3 Bucket (centralized logs)        │                            │
│      │  └─ org-centralized-logs/            │                            │
│      │     ├─ cloudtrail/                   │                            │
│      │     ├─ guardduty/                    │                            │
│      │     ├─ config/                       │                            │
│      │     └─ vpcflowlogs/                  │                            │
│      │                                      │                            │
│      │  ↓                                    │                            │
│      │                                      │                            │
│      │  Kinesis Data Firehose               │                            │
│      │  (real-time ingestion)               │                            │
│      │  └─ Name: security-logs-firehose     │                            │
│      │     Destination: OpenSearch          │                            │
│      │     Backup: S3                       │                            │
│      │     Transformation: Lambda           │                            │
│      │                                      │                            │
│      │  ↓                                    │                            │
│      │                                      │                            │
│      │  Lambda Function (transform data)    │                            │
│      │  └─ Normalize logs to standard format│                            │
│      │     Add enrichment (geo, baseline)   │                            │
│      │     Send to OpenSearch               │                            │
│      │                                      │                            │
│      │  ↓                                    │                            │
│      │                                      │                            │
│      │  CloudWatch Logs Insights            │                            │
│      │  └─ Monitor pipeline health          │                            │
│      │     Alert on ingestion delays        │                            │
│      │                                      │                            │
│      └──────────────────────────────────────┘                            │
│                         │                                                 │
│                         ↓                                                 │
│      ┌──────────────────────────────────────┐                            │
│      │    OPENSEARCH SIEM CLUSTER           │                            │
│      ├──────────────────────────────────────┤                            │
│      │                                      │                            │
│      │  Indexes:                            │                            │
│      │  ├─ cloudtrail-2025-10               │                            │
│      │  ├─ guardduty-2025-10                │                            │
│      │  ├─ vpcflow-2025-10                  │                            │
│      │  └─ config-2025-10                   │                            │
│      │                                      │                            │
│      │  Index Lifecycle Management:         │                            │
│      │  ├─ HOT (0-30 days) - SSD            │                            │
│      │  ├─ WARM (30-90 days) - HDD          │                            │
│      │  └─ COLD (90+ days) - Archival       │                            │
│      │                                      │                            │
│      └──────────────────────────────────────┘                            │
│            │                            │                                 │
│            ├──────────────┬─────────────┤                                 │
│            ↓              ↓             ↓                                 │
│                                                                           │
│      ┌──────────────┐  ┌──────────────┐  ┌──────────────┐               │
│      │ DASHBOARDS   │  │ ALERTS       │  │ THREAT       │               │
│      │ (visibility) │  │ (detection)  │  │ HUNTING      │               │
│      ├──────────────┤  ├──────────────┤  │ (investigation)              │
│      │• Security    │  │• Brute force │  │              │               │
│      │  overview    │  │• Data exfil. │  │OpenSearch   │               │
│      │• Threat      │  │• Priv. esc.  │  │Dev Tools    │               │
│      │  intel       │  │• CloudTrail  │  │(custom     │               │
│      │• Network     │  │  deletion    │  │ queries)    │               │
│      │  forensics   │  │              │  │             │               │
│      │• Compliance  │  │SNS → Email   │  │Manual       │               │
│      │              │  │    → Slack   │  │Investigation               │
│      │              │  │    → PagerD. │  │             │               │
│      └──────────────┘  └──────────────┘  └──────────────┘               │
│            │                                    │                         │
│            └────────────────┬───────────────────┘                         │
│                             │                                             │
│                             ↓                                             │
│            ┌────────────────────────────┐                                │
│            │  SOC ANALYST WORKSTATIONS  │                               │
│            ├────────────────────────────┤                               │
│            │ • Incident investigation   │                               │
│            │ • Threat hunting           │                               │
│            │ • Forensic analysis        │                               │
│            │ • Report generation        │                               │
│            │ • Compliance verification  │                               │
│            └────────────────────────────┘                               │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 Data Flow Example: Attack Scenario

**Timeline: Ransomware Attack Detection**

```
2:45:47 AM
Attacker compromises EC2 instance (weak password)
└─ Connects via SSH from IP 203.0.113.50 (Uzbekistan)

2:45:50 AM (3 seconds later)
CloudTrail logs SSH API call
└─ Event: ConsoleLogin
   User: compromised-instance
   Source IP: 203.0.113.50
   Result: Success

2:45:51 AM
Kinesis Firehose receives CloudTrail log
└─ Buffers for batching

2:45:52 AM
Firehose sends batch to Lambda (has other events)
└─ Lambda receives 50 logs in batch

2:45:53 AM
Lambda normalizes logs
└─ Maps CloudTrail → standard format
   Enriches with IP geolocation (Uzbekistan)
   Adds severity assessment (medium-high)

2:45:54 AM
Lambda sends normalized logs to OpenSearch
└─ OpenSearch indexes in real-time

2:45:55 AM (TOTAL: 8 seconds from attack to searchable)
OpenSearch alerting monitor triggers
Condition met: ConsoleLogin from non-corporate IP
└─ Severity: HIGH
   Detection Rule: "Login from Unusual Location"
   Action: Send SNS email alert

2:45:56 AM
SNS sends email to security team
└─ Email arrives in inbox

2:46:15 AM (SOC analyst reads email, ~30 seconds after attack)
Analyst clicks link to SIEM
└─ Opens incident dashboard
   Sees: User: compromised-instance
         Source: Uzbekistan
         Time: 2:45:47 AM
         
2:46:20 AM
Analyst runs threat hunting query in OpenSearch
GET cloudtrail-*/_search
{
  "query": {
    "match": {
      "source.ip": "203.0.113.50"
    }
  }
}

Result: 15 API calls from attacker in last 30 minutes!
- CreateAccessKey (created backdoor credentials)
- ModifySecurityGroup (opened port 443)
- DescribeInstances (looking for other targets)
- DescribeS3Buckets (preparing to delete data)
- ...

2:46:35 AM
Analyst escalates: "CRITICAL - Active intrusion in progress!"
└─ Incident response playbook activates
   Automated actions (Module 4):
   - Instance isolated
   - Credentials disabled
   - Forensic snapshot created
   - Management notified

2:46:50 AM (Total: ~3 minutes from attack to containment)
Instance is completely isolated
└─ Attacker no longer has access
   Attack stopped before data exfiltration
```

**Without SIEM:**
- No visibility into attack
- Attacker would have been active for HOURS
- Would have deleted/stolen massive amounts of data
- Incident discovered by customer complaint days later

**With SIEM:**
- 30 seconds from attack to analyst awareness
- 3 minutes to complete containment
- Attack stopped before significant damage

**That's the power of a properly-designed SIEM!**

---

## 🎯 Key Takeaways

1. **SIEM = Visibility:** Without a SIEM, you're flying blind. You have no idea what's happening in your environment.

2. **Architecture Matters:** How you ingest, normalize, and analyze logs determines your effectiveness.

3. **Real-Time is Critical:** The faster you detect attacks, the faster you stop them. Every second matters.

4. **Automation > Manual:** Alerts automatically firing is much better than hoping someone is watching.

5. **Correlation is Powerful:** Finding patterns across multiple data sources catches sophisticated attacks that single-tool alerts would miss.

---

**Ready to build your SIEM? Move to the next sub-module! 🚀**
