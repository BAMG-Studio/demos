# Module 3: OpenSearch & Splunk - SIEM Tools Deep Dive

## 📚 What is a SIEM Tool?

**Technical Definition:**
A SIEM tool is software that:
1. **Stores** logs in searchable indexes (databases optimized for search)
2. **Searches** billions of events in milliseconds
3. **Visualizes** data on interactive dashboards
4. **Alerts** automatically when patterns match rules
5. **Reports** on security posture for compliance

**Layman Analogy:**
A SIEM tool is like a **library:**

- **Without SIEM:** Billions of logs stored in random boxes in a warehouse (unsearchable, slow, useless)
- **With SIEM:** Librarian organizes books by topic, index tells you which shelf, you can find any book instantly

**Two Main SIEM Products in This Course:**

1. **OpenSearch** - Open-source, cheap, we'll use for learning
2. **Splunk** - Enterprise-grade, expensive, used in Fortune 500

---

## 🔴 OpenSearch (AWS's Alternative to Elasticsearch)

### What is OpenSearch?

**Technical:** OpenSearch is an open-source, distributed search and analytics engine based on Elasticsearch. It stores documents in "indexes" (similar to database tables) and provides powerful full-text search, real-time analytics, and visualizations.

**Layman:** OpenSearch is like Google for your logs. You type a query, it searches billions of events, returns results in milliseconds.

### OpenSearch Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    OpenSearch Domain                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Master Nodes              Data Nodes          Client Nodes │
│  (brain - make decisions)  (storage)      (API endpoints)  │
│  ┌───────────────┐         ┌──────────┐     ┌───────────┐ │
│  │ Node 1        │         │ Node 1   │     │ Node 1    │ │
│  │ Decides splits│    ┌────│ Index: c │     │ HTTP API  │ │
│  │ Decides health│    │    │ Trail    │     │ For apps  │ │
│  │ Manages meta  │    │    └──────────┘     └───────────┘ │
│  └───────────────┘    │    ┌──────────┐                    │
│                       │    │ Node 2   │                    │
│  ┌───────────────┐    │    │ Index: G │                    │
│  │ Node 2        │    └────│ uardDuty │                    │
│  │ Backup master │         └──────────┘                    │
│  └───────────────┘         ┌──────────┐                    │
│                            │ Node 3   │                    │
│                            │ Index:   │                    │
│                            │ VPC Flow │                    │
│                            └──────────┘                    │
│                                                              │
│  Shard Management:                                          │
│  └─ Each index split into shards (partitions)              │
│     └─ Shards replicated across data nodes                 │
│        └─ Failure of 1 node = data still available          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### OpenSearch Hands-On Lab: Basic Setup

**Step 1: Create OpenSearch Domain (AWS Console)**

```
Services → OpenSearch Service → Domains → Create domain

Domain Configuration:
├─ Domain name: security-siem-cluster
├─ Domain type: Data node
├─ Deployment option: Development and testing
│
├─ Data nodes:
│  ├─ Instance type: t3.small.search (good for learning)
│  ├─ Number of nodes: 1 (add more for HA)
│  ├─ EBS storage: 20 GB (gp3)
│
├─ Network:
│  ├─ Network type: VPC
│  ├─ VPC: Choose your VPC
│  ├─ Subnets: Choose private subnets
│  ├─ Security groups: Allow HTTPS (443) from your IP
│
├─ Access policies:
│  └─ Domain access policy:
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Principal": {
             "AWS": "arn:aws:iam::123456789012:root"
           },
           "Action": "es:*",
           "Resource": "arn:aws:es:us-east-1:123456789012:domain/security-siem-cluster/*"
         }
       ]
     }
│
├─ Encryption:
│  ├─ Enable encryption at rest: YES
│  ├─ Enable encryption in transit: YES
│  ├─ Enable node-to-node encryption: YES
│
├─ Monitoring:
│  ├─ Enable CloudWatch metrics: YES
│  ├─ Enable logging: YES
│
└─ Tags:
   └─ Environment: Learning
      Purpose: SIEM
      CostCenter: Security
```

**Cost Estimate:**
- t3.small.search: $26/month
- 20 GB EBS: $1.60/month
- Data transfer: ~$0.09/month
- **Total: ~$28/month**

**Step 2: Connect to OpenSearch Domain**

Once domain is created (takes 15-20 minutes):

**Option A: AWS Console (easiest for learning)**
```
Services → OpenSearch Service → Domains → security-siem-cluster
→ Dev Tools → Open OpenSearch Dashboards
```

**Option B: AWS CLI (for automation)**
```bash
# Get domain endpoint
aws opensearch describe-domains \
  --domain-names security-siem-cluster \
  --query 'DomainStatusList[0].DomainEndpoint'

# Output: security-siem-cluster-abc123.us-east-1.es.amazonaws.com

# Make API call (requires AWS SigV4 authentication)
# This is complex, so use option A for now
```

**Step 3: Create Index Template (How to Store Data)**

In OpenSearch Dashboards → Dev Tools → Console:

```json
PUT _index_template/cloudtrail-template
{
  "index_patterns": ["cloudtrail-*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0,  # Change to 1+ for HA
      "index.lifecycle.name": "logs-policy",
      "index.lifecycle.rollover_alias": "cloudtrail"
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "event_name": { "type": "keyword" },
        "event_source": { "type": "keyword" },
        "user_name": { "type": "keyword" },
        "source_ip": { "type": "ip" },
        "result": { "type": "keyword" },
        "severity": { "type": "keyword" },
        "raw_message": { "type": "text" }
      }
    }
  }
}
```

**Step 4: Create First Index (Manually for Testing)**

```json
PUT cloudtrail-2025-10
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}

# Response: {"acknowledged":true,"shards_acknowledged":true,"index":"cloudtrail-2025-10"}
```

**Step 5: Index a Sample Document**

```json
POST cloudtrail-2025-10/_doc
{
  "@timestamp": "2025-10-28T13:47:15Z",
  "event_name": "RunInstances",
  "event_source": "ec2",
  "user_name": "peter",
  "source_ip": "192.168.1.1",
  "result": "success",
  "severity": "low",
  "raw_message": "User peter created EC2 instance i-0abc123"
}

# Response: {"_index":"cloudtrail-2025-10","_id":"ABC123","_version":1,"result":"created"}
```

**Step 6: Search Your First Event**

```json
GET cloudtrail-2025-10/_search
{
  "query": {
    "match": {
      "user_name": "peter"
    }
  }
}

# Response:
# {
#   "hits": {
#     "total": {"value": 1, "relation": "eq"},
#     "hits": [
#       {
#         "_index": "cloudtrail-2025-10",
#         "_source": {
#           "@timestamp": "2025-10-28T13:47:15Z",
#           "event_name": "RunInstances",
#           "user_name": "peter",
#           ...
#         }
#       }
#     ]
#   }
# }
```

**Step 7: Create Your First Visualization**

In OpenSearch Dashboards:
```
Menu → Visualize → Create Visualization
├─ Visualization type: Bar chart
├─ Data source: cloudtrail-2025-10
├─ X-axis: event_name (aggregation: terms)
├─ Y-axis: Count
└─ Click "Save" → "API_Calls_by_Type"
```

---

## 🔷 Splunk (Enterprise SIEM)

### What is Splunk?

**Technical:** Splunk is an enterprise-grade SIEM platform that ingests, indexes, analyzes, and visualizes data from thousands of sources. It's the most widely-used SIEM in Fortune 500 companies.

**Layman:** Splunk is the "expensive, powerful" version of OpenSearch. Like comparing a Mercedes to a Hyundai - both get you there, but Mercedes has more features and better support.

### Why Learn Both OpenSearch & Splunk?

| Aspect | OpenSearch | Splunk |
|--------|-----------|--------|
| **Cost** | $26/month | $2,000+/month |
| **Learning** | Easier | Steeper learning curve |
| **Real job** | Startups/AWS-focused | Enterprise/Fortune 500 |
| **Job market** | Growing | Very high demand |
| **Exam topics** | Some AWS certs | Industry standard |

**Recommendation:** Learn both concepts, implement in OpenSearch (cheap), understand Splunk terminology (for job interviews).

### Splunk Architecture (Comparison with OpenSearch)

```
OPENSEARCH ARCHITECTURE:           SPLUNK ARCHITECTURE:
┌──────────────────────────┐       ┌──────────────────────────┐
│ Data Input Nodes         │       │ Universal Forwarders     │
│ (receive logs)           │       │ (collect logs from       │
│ - Kinesis Firehose       │       │  servers/apps/devices)   │
│ - Direct API call        │       │ - Deploy to every server │
│ - S3 event notification  │       │ - Lightweight agent      │
└────────────┬─────────────┘       └────────────┬─────────────┘
             │                                  │
             ↓                                  ↓
┌──────────────────────────┐       ┌──────────────────────────┐
│ Lambda Normalization     │       │ Heavy Forwarders/        │
│ (transform data)         │       │ Indexers                 │
│ - CloudTrail → standard  │       │ (parse & index logs)     │
│ - GuardDuty → standard   │       │ - Parse log format       │
└────────────┬─────────────┘       │ - Create fields          │
             │                      │ - Index documents        │
             ↓                      └────────────┬─────────────┘
┌──────────────────────────┐                    │
│ OpenSearch Cluster       │                    ↓
│ (storage & search)       │       ┌──────────────────────────┐
│ - Indexes (shards)       │       │ Splunk Indexers         │
│ - Search nodes           │       │ (distributed storage)    │
│ - Master nodes           │       │ - Clustered for HA       │
└────────────┬─────────────┘       │ - Replicated buckets     │
             │                      └────────────┬─────────────┘
             ↓                                   │
┌──────────────────────────┐                    ↓
│ Dashboards & Alerts      │       ┌──────────────────────────┐
│ (visualization layer)    │       │ Splunk Search Head       │
│ - OpenSearch Dashboards  │       │ (search & visualize)     │
│ - Alerting monitors      │       │ - Query language: SPL    │
└──────────────────────────┘       │ - Dashboards & reports   │
                                   │ - Alerting & actions     │
                                   └──────────────────────────┘
```

### Splunk Hands-On (Free Trial Version)

**Step 1: Download Splunk Enterprise Free Trial**

```
1. Go to: https://www.splunk.com/en_us/download/splunk-enterprise.html
2. Create account (free trial = $0/month for 60 days)
3. Download Splunk for your OS (Windows, Mac, Linux)
4. Install locally
```

**Step 2: Start Splunk**

```bash
# macOS/Linux:
./splunk/bin/splunk start --accept-license

# Windows:
# Double-click splunkd.exe or use PowerShell:
& "C:\Program Files\Splunk\bin\splunk.exe" start --accept-license

# Wait for startup (2-3 minutes)
# Go to: https://localhost:8000
# Username: admin
# Password: (set during installation)
```

**Step 3: Add Data Source**

```
1. Click "Add Data" (home screen)
2. Select "Monitor"
3. Choose log file or application
4. For learning: Use sample log file
   - Settings → Sample data → click "Load"
5. Splunk automatically indexes data
```

**Step 4: Learn Splunk Query Language (SPL)**

Splunk's query language is different from OpenSearch:

```
OpenSearch (Elasticsearch Query DSL):
GET logs-*/_search
{
  "query": {
    "bool": {
      "must": [
        {"match": {"user_name": "peter"}},
        {"range": {"@timestamp": {"gte": "now-1h"}}}
      ]
    }
  }
}

Splunk (SPL - Splunk Processing Language):
index=main user_name=peter earliest=-1h latest=now
| stats count by event_name
```

**SPL Basics:**

```
Basic search:
sourcetype=syslog error

Filtering:
sourcetype=syslog error | search level=CRITICAL

Stats/aggregation:
sourcetype=syslog | stats count by host

Top values:
sourcetype=syslog | top limit=10 user

Time-based:
sourcetype=syslog earliest=-24h@h latest=now
(last 24 hours)

Multiple fields:
sourcetype=syslog | table host, user, event, result
```

**Step 5: Create a Dashboard in Splunk**

```
1. Search → save as → Dashboard
2. Name: "Security Overview"
3. Add panels (visualizations)
   - Panel 1: Events over time
     search: index=main
     visualization: Line chart
   
   - Panel 2: Top users
     search: index=main | stats count by user
     visualization: Bar chart
   
   - Panel 3: Errors by hour
     search: index=main error
     visualization: Heatmap
```

---

## 🆚 OpenSearch vs Splunk Comparison

| Capability | OpenSearch | Splunk |
|-----------|-----------|--------|
| **Ingestion rate** | ~1K events/sec | ~10K+ events/sec |
| **Query speed** | 1-10 seconds | <1 second (cached) |
| **Dashboard complexity** | Simple-Medium | Simple-Complex |
| **Alert types** | Basic | Advanced (correlation, etc) |
| **ML capabilities** | Limited | Strong (anomaly detection) |
| **Support** | Community | 24/7 Enterprise |
| **Cost at 10GB/day** | $28 | $2,000+ |
| **Scaling** | Medium | Enterprise |

---

## 📊 Cost Comparison Table

| Volume | OpenSearch | Splunk | Datadog |
|--------|-----------|--------|---------|
| **1 GB/day** | $28 | $2,000 | $500 |
| **10 GB/day** | $280 | $20,000 | $5,000 |
| **100 GB/day** | $2,800 | $200,000+ | $50,000+ |
| **Best for** | Learning | Enterprise | DevOps |

---

## 🎯 Which Tool to Use When?

**Use OpenSearch if:**
- ✅ Learning SIEM concepts
- ✅ Startup with small log volume (<10 GB/day)
- ✅ AWS-focused environment
- ✅ Limited budget (<$1,000/month)
- ✅ Need full control & customization

**Use Splunk if:**
- ✅ Fortune 500 company
- ✅ High log volume (100+ GB/day)
- ✅ Need advanced features (ML, correlation)
- ✅ Require 24/7 support
- ✅ Have budget for enterprise SIEM
- ✅ Industry standard requirement

---

**Next: Move to Module 4 (Defensive Cyber Operations) or Module 5 (Incident Response Simulations)**
