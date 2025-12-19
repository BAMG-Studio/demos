# CloudTrail & VPC Flow Logs: Complete Forensics Guide

> **Quick Reference:** CloudTrail records WHO did WHAT, WHEN, WHERE. VPC Flow Logs records network traffic flows. Together they enable complete incident investigation.

---

## Part 1: CloudTrail - Complete Audit Trail

### What is CloudTrail?

**Definition:** AWS service recording every API call to your AWS account

**Analogy:** Security camera for AWS - every action recorded with timestamps and full details

### What CloudTrail Records

```
User/Entity → Takes Action → CloudTrail Records:
                            ├── WHO (user identity, IAM role)
                            ├── WHAT (API call, service)
                            ├── WHEN (timestamp, timezone)
                            ├── WHERE (source IP address)
                            ├── HOW (parameters, request details)
                            └── RESULT (success/failure, error code)
```

### CloudTrail Event Structure

```json
{
  "eventVersion": "1.05",
  "userIdentity": {
    "type": "IAMUser",
    "principalId": "AIDACKCEVSQ6C2EXAMPLE",
    "arn": "arn:aws:iam::123456789012:user/alice",
    "accountId": "123456789012",
    "userName": "alice"
  },
  "eventTime": "2025-12-16T10:23:45Z",
  "eventSource": "s3.amazonaws.com",
  "eventName": "PutObject",
  "awsRegion": "us-east-1",
  "sourceIPAddress": "203.0.113.45",
  "userAgent": "aws-cli/2.9.0",
  "requestParameters": {
    "bucketName": "production-data",
    "key": "sensitive-file.csv"
  },
  "responseElements": null,
  "s3": {
    "bucket": {
      "name": "production-data",
      "arn": "arn:aws:s3:::production-data"
    },
    "object": {
      "key": "sensitive-file.csv",
      "size": 2048000
    }
  },
  "requestID": "EXAMPLE123456789",
  "eventID": "1-example-uuid",
  "resources": [{
    "type": "AWS::S3::Object",
    "ARN": "arn:aws:s3:::production-data/sensitive-file.csv"
  }],
  "eventType": "AwsApiCall",
  "recipientAccountId": "123456789012",
  "sharedEventID": "example-shared-event-id",
  "tlsDetails": {
    "tlsVersion": "TLSv1.2",
    "cipherSuite": "ECDHE-RSA-AES128-GCM-SHA256",
    "clientProvidedHostHeader": "s3.us-east-1.amazonaws.com"
  }
}
```

### Key Event Fields for Forensics

| Field | Purpose | Forensic Use |
|-------|---------|--------------|
| **eventName** | Which AWS API was called | Identify suspicious actions |
| **userIdentity** | Who made the call | Attribute actions to users/roles |
| **sourceIPAddress** | Where the call came from | Identify if external/internal |
| **eventTime** | When the action occurred | Build timeline of incident |
| **requestParameters** | What was requested | Understand the action details |
| **responseElements** | What happened | Success/failure determination |
| **errorCode** | Why it failed (if error) | Identify blocked attacks |

### Types of CloudTrail Events

#### 1. Management Events (DEFAULT)
- Creating/modifying AWS resources
- IAM operations
- Configuration changes
- Examples: CreateDBInstance, PutBucketPolicy, AttachRolePolicy

#### 2. Data Events (OPTIONAL - higher cost)
- S3 object operations (GetObject, PutObject, DeleteObject)
- Lambda function invocations
- DynamoDB table operations
- Higher volume, more detailed

#### 3. Insights Events (SPECIAL)
- Unusual API call rates
- Unusual error rates
- ML-detected anomalies
- Auto-enabled; helps identify attacks

### CloudTrail Setup (Best Practices)

```bash
# Enable organization trail (logs all accounts)
aws cloudtrail create-trail \
  --name=organization-trail \
  --s3-bucket-name=cloudtrail-logs-prod \
  --is-organization-trail \
  --is-multi-region-trail \
  --include-global-service-events \
  --enable-log-file-validation

# Start logging
aws cloudtrail start-logging \
  --trail-name=organization-trail

# Enable Insights to detect anomalies
aws cloudtrail put-insight-selectors \
  --trail-name=organization-trail \
  --insight-selectors InsightType=ApiCallRateInsight
```

### Protecting CloudTrail Logs

```python
import boto3

def protect_cloudtrail_logs():
    s3 = boto3.client('s3')
    
    # Enable versioning (can't delete old logs)
    s3.put_bucket_versioning(
        Bucket='cloudtrail-logs-prod',
        VersioningConfiguration={'Status': 'Enabled'}
    )
    
    # Enable MFA Delete (must approve deletion)
    # NOTE: Requires root account MFA
    
    # Enable encryption with customer-managed KMS
    s3.put_bucket-encryption(
        Bucket='cloudtrail-logs-prod',
        ServerSideEncryptionConfiguration={
            'Rules': [{
                'ApplyServerSideEncryptionByDefault': {
                    'SSEAlgorithm': 'aws:kms',
                    'KMSMasterKeyID': 'arn:aws:kms:region:account:key/id'
                }
            }]
        }
    )
    
    # Block public access
    s3.put_public_access_block(
        Bucket='cloudtrail-logs-prod',
        PublicAccessBlockConfiguration={
            'BlockPublicAcls': True,
            'IgnorePublicAcls': True,
            'BlockPublicPolicy': True,
            'RestrictPublicBuckets': True
        }
    )
    
    # Set lifecycle policy (archive after 90 days)
    s3.put_bucket_lifecycle_configuration(
        Bucket='cloudtrail-logs-prod',
        LifecycleConfiguration={
            'Rules': [{
                'ID': 'archive-old-logs',
                'Status': 'Enabled',
                'Transitions': [{
                    'Days': 90,
                    'StorageClass': 'GLACIER'
                }]
            }]
        }
    )
```

---

## Part 2: VPC Flow Logs - Network Traffic Visibility

### What are VPC Flow Logs?

**Definition:** Captures network traffic flowing to/from network interfaces in your VPC

**Analogy:** Like router logs - shows every packet that passed through the network

### CloudTrail vs VPC Flow Logs

| Aspect | CloudTrail | VPC Flow Logs |
|--------|-----------|---------------|
| **Logs** | API calls | Network traffic |
| **Who** | User/role identity | Source/destination IP |
| **What** | API action (GetObject, StartEC2, etc.) | Network communication (port, protocol) |
| **Example** | User modified security group | Traffic attempted on port 22 |
| **Timeline** | Minutes retention (live) | Hours retention (near-live) |
| **Cost** | Low | Very low |
| **Forensic value** | Who did it? | How did network behave? |

### VPC Flow Log Format

```
version account-id interface-id srcaddr dstaddr srcport dstport 
protocol packets bytes start end action log-status

Example:
2 123456789010 eni-1a2b3c4d 10.0.1.201 198.0.2.1 42354 443 
6 13 3456 1612261370 1612261430 ACCEPT OK
```

### Field Meanings

| Field | Meaning | Example | Forensic Use |
|-------|---------|---------|--------------|
| srcaddr | Source IP | 10.0.1.201 | Which server initiated? |
| dstaddr | Destination IP | 198.0.2.1 | Where was traffic going? |
| srcport | Source port | 42354 | Which application/process? |
| dstport | Destination port | 443 | Which service (HTTPS=443, SSH=22)? |
| protocol | 6=TCP, 17=UDP | 6 | Connection type? |
| packets | Number of packets | 13 | How much data transferred? |
| bytes | Total bytes transferred | 3456 | Volume of exfiltration? |
| action | ACCEPT or REJECT | ACCEPT | Connection allowed/blocked? |
| start/end | Unix timestamps | 1612261370 | When did traffic occur? |

### VPC Flow Log Setup

```bash
# Enable VPC Flow Logs to CloudWatch
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids vpc-12345678 \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name /aws/vpc/flowlogs \
  --deliver-logs-permission-role-name flowlogsRole

# Enable VPC Flow Logs to S3
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids vpc-12345678 \
  --traffic-type ALL \
  --log-destination-type s3 \
  --log-destination arn:aws:s3:::flowlogs-bucket/prefix/
```

---

## Part 3: Investigation Scenarios

### Scenario 1: S3 Data Exfiltration Investigation

**Incident:** Unauthorized access to S3 bucket. 2.3 GB of data transferred to external IP in 1 hour.

**Investigation Steps:**

**Step 1: Identify CloudTrail Events**
```sql
SELECT 
    eventTime,
    userIdentity.principalId as user,
    eventName,
    sourceIPAddress,
    s3.object.key,
    s3.object.size,
    responseElements
FROM cloudtrail_logs
WHERE eventName IN ('GetObject', 'ListBucket')
    AND s3.bucket.name = 'production-data'
    AND eventTime > '2025-12-15T20:00:00Z'
ORDER BY eventTime DESC
LIMIT 100;
```

**Finding:**
```
eventTime: 2025-12-15T20:15:30Z
user: arn:aws:iam::123456789012:role/app-ec2-role
eventName: GetObject
sourceIPAddress: 10.0.1.100
objects accessed: 50,000+ in 1 hour
```

**Step 2: Investigate User/Role**
```bash
# Check role permissions
aws iam get-role-policy \
  --role-name app-ec2-role \
  --policy-name s3-access

# Check role trust relationship
aws iam get-role \
  --role-name app-ec2-role
```

**Step 3: Check VPC Flow Logs for Network Activity**
```sql
SELECT 
    srcaddr,
    dstaddr,
    dstport,
    SUM(bytes) as total_bytes,
    COUNT(*) as num_packets,
    from_unixtime(start) as start_time,
    from_unixtime(end) as end_time
FROM vpc_flow_logs
WHERE srcaddr = '10.0.1.100'
    AND dstport NOT IN (80, 443, 53)  -- Exclude normal traffic
    AND action = 'ACCEPT'
    AND from_unixtime(start) > '2025-12-15 20:00:00'
GROUP BY srcaddr, dstaddr, dstport
ORDER BY total_bytes DESC;
```

**Finding:**
```
srcaddr: 10.0.1.100 (compromised EC2)
dstaddr: 203.0.113.99 (external IP, geo-location: unknown country)
dstport: 443 (HTTPS)
total_bytes: 2.3 GB
packets: 50,000+
time: 20:15 - 21:15 UTC
```

**Step 4: Scope Impact**
```sql
-- Which EC2 instance is compromised?
aws ec2 describe-network-interfaces \
  --filters Name=private-ip-address,Values=10.0.1.100

-- Which S3 objects were accessed?
SELECT 
    COUNT(DISTINCT s3.object.key) as unique_objects,
    SUM(s3.object.size) as total_size,
    MIN(eventTime) as first_access,
    MAX(eventTime) as last_access
FROM cloudtrail_logs
WHERE eventName = 'GetObject'
    AND s3.bucket.name = 'production-data'
    AND eventTime > '2025-12-15T20:00:00Z';

-- Result:
-- unique_objects: 50,045
-- total_size: 2.3 GB
-- All customer PII files
```

**Step 5: Remediation**

```python
import boto3
from datetime import datetime

def remediate_compromise():
    ec2 = boto3.client('ec2')
    iam = boto3.client('iam')
    
    # 1. Isolate EC2 instance
    print("[1] Isolating compromised EC2 instance...")
    ec2.modify_instance_attribute(
        InstanceId='i-0a1b2c3d4e5f6g7h8',
        Groups=['sg-forensic-isolation']  # No outbound access
    )
    
    # 2. Create forensic snapshot
    print("[2] Creating forensic snapshot...")
    snapshot = ec2.create_snapshot(
        VolumeId='vol-0a1b2c3d4e5f6g7h8',
        Description='Forensic snapshot - exfiltration incident'
    )
    
    # 3. Revoke IAM credentials
    print("[3] Revoking compromised credentials...")
    iam.put_role_policy(
        RoleName='app-ec2-role',
        PolicyName='s3-access-REVOKED',
        PolicyDocument='{"Version":"2012-10-17","Statement":[{"Effect":"Deny","Action":"*","Resource":"*"}]}'
    )
    
    # 4. Create ServiceNow incident
    print("[4] Creating incident ticket...")
    # (Would integrate with ServiceNow API here)
    
    # 5. Notification
    print("[5] Notifying security team...")
    sns = boto3.client('sns')
    sns.publish(
        TopicArn='arn:aws:sns:us-east-1:123456789012:security-alerts',
        Subject='CRITICAL: Data Exfiltration Incident - Remediated',
        Message='''
Compromised EC2 Instance: i-0a1b2c3d4e5f6g7h8
Data Exfiltrated: 2.3 GB customer PII
Time: 2025-12-15 20:15-21:15 UTC
Actions Taken:
- Instance isolated (no network access)
- Forensic snapshot created
- IAM credentials revoked
- Incident ticket created
Next: Forensic analysis of snapshot
        '''
    )
```

**Timeline:**
```
20:15 UTC - First GetObject API call detected (CloudTrail)
20:15 UTC - Network traffic to external IP (VPC Flow Logs)
20:45 UTC - Alert triggered (50,000 GetObject calls)
20:50 UTC - Security team investigates
21:00 UTC - Root cause identified (compromised EC2)
21:05 UTC - Instance isolated, credentials revoked
21:10 UTC - Incident ticket created
21:15 UTC - Forensic snapshot completed
```

---

### Scenario 2: Brute Force SSH Attack

**Incident:** Multiple failed login attempts to EC2 instance

**Investigation:**

**Step 1: Identify VPC Flow Logs Evidence**
```sql
-- Find failed SSH connection attempts
SELECT 
    srcaddr as attacker_ip,
    COUNT(*) as num_attempts,
    MIN(from_unixtime(start)) as first_attempt,
    MAX(from_unixtime(start)) as last_attempt
FROM vpc_flow_logs
WHERE dstaddr = '10.0.1.50'        -- Target EC2
    AND dstport = 22                -- SSH port
    AND action = 'REJECT'           -- Connection blocked
    AND from_unixtime(start) > '2025-12-15 22:00:00'
GROUP BY srcaddr
HAVING COUNT(*) > 10
ORDER BY COUNT(*) DESC;

-- Results:
-- 203.0.113.45: 487 attempts
-- 203.0.113.46: 23 attempts
-- 203.0.113.47: 15 attempts
```

**Step 2: Check EC2 Security Group**
```bash
# What's the current SSH security group?
aws ec2 describe-security-groups \
  --group-ids sg-12345678

# Result: Allows SSH from 0.0.0.0/0 (internet accessible!)
```

**Step 3: Review CloudTrail for Successful Access**
```sql
SELECT 
    eventTime,
    userIdentity.principalId,
    eventName,
    sourceIPAddress
FROM cloudtrail_logs
WHERE eventName IN ('AuthorizeSecurityGroupIngress', 'ModifySecurityGroup')
    AND eventTime > '2025-12-15T00:00:00Z';

-- Check if someone modified security group to allow access
```

**Step 4: Take Action**
```bash
# Immediately restrict SSH access
aws ec2 revoke-security-group-ingress \
  --group-id sg-12345678 \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

# Allow only from corporate network
aws ec2 authorize-security-group-ingress \
  --group-id sg-12345678 \
  --protocol tcp \
  --port 22 \
  --cidr 203.0.113.128/25  # Corporate IP range
```

---

## Part 4: Forensic Tools & Queries

### CloudTrail Forensic Queries

**Find all actions by a specific user:**
```sql
SELECT eventTime, eventName, awsRegion, sourceIPAddress
FROM cloudtrail_logs
WHERE userIdentity.principalId = 'AIDACKCEVSQ6C2EXAMPLE'
ORDER BY eventTime DESC;
```

**Find all failed API calls:**
```sql
SELECT eventTime, eventName, sourceIPAddress, errorCode
FROM cloudtrail_logs
WHERE errorCode IS NOT NULL
    AND eventTime > date_sub(now(), interval 24 hour)
ORDER BY eventTime DESC;
```

**Find privilege escalation attempts:**
```sql
SELECT eventTime, userIdentity.arn, eventName, requestParameters
FROM cloudtrail_logs
WHERE eventName IN (
    'AttachUserPolicy',
    'PutUserPolicy',
    'AttachRolePolicy',
    'CreateAccessKey'
)
    AND eventTime > date_sub(now(), interval 7 day)
ORDER BY eventTime DESC;
```

**Find data access:**
```sql
SELECT eventTime, userIdentity.arn, eventName, s3.bucket.name, s3.object.key
FROM cloudtrail_logs
WHERE eventName IN ('GetObject', 'PutObject', 'DeleteObject')
    AND s3.bucket.name = 'sensitive-data'
    AND eventTime > date_sub(now(), interval 24 hour)
ORDER BY eventTime DESC;
```

### VPC Flow Logs Forensic Queries

**Find all traffic to/from a specific IP:**
```sql
SELECT srcaddr, dstaddr, dstport, protocol, SUM(bytes) as total_bytes
FROM vpc_flow_logs
WHERE srcaddr = '10.0.1.100' OR dstaddr = '10.0.1.100'
GROUP BY srcaddr, dstaddr, dstport, protocol
ORDER BY total_bytes DESC;
```

**Find unusual outbound traffic:**
```sql
SELECT srcaddr, dstaddr, dstport, SUM(bytes) as total_bytes
FROM vpc_flow_logs
WHERE srcaddr IN (SELECT private_ip FROM ec2_instances WHERE instance_type IN ('t3.micro', 't3.small'))
    AND dstport NOT IN (80, 443, 53)  -- Exclude normal traffic
    AND action = 'ACCEPT'
GROUP BY srcaddr, dstaddr, dstport
ORDER BY total_bytes DESC;
```

**Find rejected connections (attacks/misconfiguration):**
```sql
SELECT srcaddr, COUNT(*) as rejected_attempts
FROM vpc_flow_logs
WHERE action = 'REJECT'
    AND from_unixtime(start) > date_sub(now(), interval 1 hour)
GROUP BY srcaddr
ORDER BY COUNT(*) DESC;
```

---

## Part 5: Interview Talking Points

### Question: "Walk us through how you would investigate a suspected data breach."

**Answer:**

"I'd use a structured, methodical approach combining CloudTrail and VPC Flow Logs:

**Phase 1: Assessment (First 15 minutes)**
- What data was accessed? Which S3 buckets? Which database?
- When did it happen? Get timeline from CloudTrail timestamps
- Who accessed it? Check userIdentity.principalId and IAM role
- Check for ongoing access—is the compromise still active?

**Phase 2: Source Investigation (Next 30 minutes)**
- CloudTrail: Find all API calls from the compromised identity
- VPC Flow Logs: Track network connections from source IP
- Geo-locate attacker IP (is this internal or external?)
- Check if credentials were stolen or if system was compromised

**Phase 3: Scope Determination (1 hour)**
- How many objects accessed? How much data exfiltrated?
- Which customers affected? What information was exposed?
- Was data exported outside AWS? Check VPC Flow Logs for egress
- Are other systems compromised? Check for lateral movement in CloudTrail

**Phase 4: Containment (Immediately)**
- Revoke IAM credentials used in the attack
- Isolate affected EC2 instances (remove internet access)
- Block attacker's IP in WAF/NACL
- Create forensic snapshots before any changes

**Phase 5: Investigation & Evidence Collection**
- Export CloudTrail logs to S3 for forensic analysis
- Save VPC Flow Logs and relevant metrics
- Document all findings with timestamps and sources
- Preserve forensic snapshots for detailed analysis

**Example:** A previous incident showed suspicious S3 access. I queried CloudTrail for GetObject calls over last 24 hours on sensitive bucket. Found 50,000 API calls from an EC2 instance between 20:15-21:15 UTC. VPC Flow Logs showed 2.3 GB transferred to external IP (203.0.113.99). Combined evidence showed clear data exfiltration. I immediately isolated the EC2 instance, revoked its IAM role credentials, and created a forensic snapshot. The incident was contained within 10 minutes from detection to remediation.

**Critical tools:**
- CloudTrail: Who did what, when
- VPC Flow Logs: Network communication paths
- AWS Config: Configuration changes history
- GuardDuty: ML-detected threats
- CloudWatch: Real-time alerting

This multi-source approach provides complete forensic visibility and enables rapid, informed response."

---

## Implementation Checklist

- [ ] CloudTrail enabled in all regions
- [ ] Multi-region trail to catch global events
- [ ] Log file integrity validation enabled
- [ ] CloudTrail logs encrypted with KMS
- [ ] CloudTrail logs stored in protected S3 bucket (versioning, MFA Delete)
- [ ] VPC Flow Logs enabled for all VPCs
- [ ] Flow Logs sent to CloudWatch Logs
- [ ] Retention policy set (90 days hot, archive to Glacier)
- [ ] CloudWatch alarms configured for suspicious patterns
- [ ] Forensic analysis tools/queries documented
- [ ] Team trained on investigation procedures
- [ ] Regular simulations to test incident response

---

## Key Takeaways

> **CloudTrail and VPC Flow Logs are non-negotiable for cloud security. Together they provide complete visibility for forensic investigation.**

1. **CloudTrail = API audit trail** - Essential for understanding actions
2. **VPC Flow Logs = Network visibility** - Shows communication paths
3. **Multi-source investigation** - Combine both for complete picture
4. **Immediate containment** - Isolate while investigating
5. **Forensic preservation** - Create snapshots before changes
6. **Automated alerting** - CloudWatch enables real-time detection
7. **Retention policies** - Keep logs for compliance (typically 90 days hot, 7 years archived)
8. **Team training** - Investigators must know how to use these tools
9. **Regular drills** - Practice investigations before real incidents
10. **Compliance requirement** - Most frameworks mandate audit logging
