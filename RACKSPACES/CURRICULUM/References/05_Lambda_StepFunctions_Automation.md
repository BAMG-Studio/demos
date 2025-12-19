# Lambda & Step Functions Security Automation - Complete Patterns

> **Quick Reference:** Lambda = serverless compute for automation. Step Functions = orchestrate multiple Lambdas into workflows. Together they enable rapid incident response and security automation.

---

## Part 1: AWS Lambda for Security Automation

### What is Lambda?

**Definition:** Serverless compute service - write code, AWS handles servers/scaling

**Key Characteristics:**
- Pay only for execution time
- Automatic scaling
- Event-driven (triggered by events)
- No server management
- Fast execution (milliseconds to seconds)

### Why Lambda for Security?

**Traditional Incident Response:**
- Security team gets alert
- Manually SSH to server
- Run remediation commands
- Document actions
- **Total time: 30+ minutes**

**Lambda-Driven Incident Response:**
- Event triggers Lambda
- Lambda executes remediation steps in parallel
- Logs all actions automatically
- Sends notifications
- **Total time: < 1 minute**

### Lambda Permissions for Security

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:ModifyInstanceAttribute",
        "ec2:CreateSnapshot",
        "ec2:CreateSecurityGroup",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:PutRolePolicy",
        "iam:UpdateAssumeRolePolicy"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutBucketPolicy",
        "s3:PutPublicAccessBlock"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sns:Publish",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## Part 2: Lambda Auto-Remediation Patterns

### Pattern 1: Auto-Remediate Public S3 Bucket

**Trigger:** AWS Config detects S3 bucket is public

**Scenario:** Someone accidentally changes bucket policy, exposing customer data

```python
import boto3
import json
from datetime import datetime

def lambda_handler(event, context):
    """Auto-remediate public S3 buckets"""
    
    s3_client = boto3.client('s3')
    sns_client = boto3.client('sns')
    
    print(f"[{datetime.utcnow()}] Starting S3 public bucket remediation")
    
    try:
        # Parse AWS Config event
        config_item = json.loads(event['configurationItem'])
        bucket_name = config_item['resourceName']
        
        print(f"[REMEDIATE] Removing public access from bucket: {bucket_name}")
        
        # Step 1: Block public access
        s3_client.put_public_access_block(
            Bucket=bucket_name,
            PublicAccessBlockConfiguration={
                'BlockPublicAcls': True,
                'IgnorePublicAcls': True,
                'BlockPublicPolicy': True,
                'RestrictPublicBuckets': True
            }
        )
        print(f"[OK] Block Public Access enabled")
        
        # Step 2: Remove public bucket policy if exists
        try:
            s3_client.delete_bucket_policy(Bucket=bucket_name)
            print(f"[OK] Public bucket policy removed")
        except s3_client.exceptions.NoSuchBucketPolicy:
            print(f"[OK] No public bucket policy to remove")
        
        # Step 3: Ensure bucket encryption
        s3_client.put_bucket_encryption(
            Bucket=bucket_name,
            ServerSideEncryptionConfiguration={
                'Rules': [{
                    'ApplyServerSideEncryptionByDefault': {
                        'SSEAlgorithm': 'AES256'
                    }
                }]
            }
        )
        print(f"[OK] Bucket encryption enforced")
        
        # Step 4: Notify security team
        sns_client.publish(
            TopicArn='arn:aws:sns:us-east-1:123456789012:security-alerts',
            Subject=f'[REMEDIATED] Public S3 Bucket: {bucket_name}',
            Message=f'''
AWS Config detected public S3 bucket: {bucket_name}

Actions Taken by Lambda:
1. ✅ Block Public Access enabled
2. ✅ Public bucket policy removed
3. ✅ Encryption enforced
4. ✅ All remediation logged

Review Required:
- Verify bucket still works correctly
- Check if legitimate public access needed
- Review CloudTrail for who changed permissions

Bucket: {bucket_name}
Remediation Time: {datetime.utcnow().isoformat()}
            '''
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Remediation successful',
                'bucket': bucket_name
            })
        }
        
    except Exception as e:
        print(f"[ERROR] Remediation failed: {str(e)}")
        
        # Notify on failure
        sns_client.publish(
            TopicArn='arn:aws:sns:us-east-1:123456789012:security-alerts',
            Subject='[FAILED] S3 Auto-Remediation Error',
            Message=f'S3 public bucket remediation failed. Manual review required.\n\nError: {str(e)}'
        )
        
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
```

**Trigger Configuration:**
```bash
# AWS Config Rule triggers Lambda when S3 is public
aws config put-config-rule \
  --config-rule '{
    "ConfigRuleName": "s3-bucket-public-read-prohibited",
    "Source": {
      "Owner": "CUSTOM_LAMBDA",
      "SourceIdentifier": "arn:aws:lambda:us-east-1:123456789012:function:CheckS3Public",
      "SourceDetails": [{
        "EventSource": "aws.config",
        "MessageType": "ConfigurationItemChangeNotification"
      }]
    }
  }'
```

**Result:** Within 30 seconds of misconfiguration, Lambda automatically blocks public access. Zero manual work.

---

### Pattern 2: Auto-Remediate Overly Permissive Security Group

**Trigger:** Security group rule allows 0.0.0.0/0 on database port (3306, 5432)

```python
import boto3
import json
from datetime import datetime

def lambda_handler(event, context):
    """Auto-remediate overly permissive security groups"""
    
    ec2_client = boto3.client('ec2')
    sns_client = boto3.client('sns')
    
    print(f"[{datetime.utcnow()}] Starting security group remediation")
    
    try:
        # Dangerous ports that should never be open to internet
        DANGEROUS_PORTS = {
            3306: 'MySQL',
            5432: 'PostgreSQL',
            27017: 'MongoDB',
            1433: 'SQL Server',
            22: 'SSH',
            3389: 'RDP'
        }
        
        # Parse event
        sg_id = event['detail']['requestParameters']['groupId']
        
        # Get current security group
        response = ec2_client.describe_security_groups(GroupIds=[sg_id])
        sg = response['SecurityGroups'][0]
        
        print(f"[REMEDIATE] Checking security group: {sg_id}")
        
        # Find dangerous rules
        dangerous_rules = []
        for rule in sg['IpPermissions']:
            from_port = rule.get('FromPort', 0)
            
            if from_port in DANGEROUS_PORTS:
                # Check if open to internet
                for ip_range in rule.get('IpRanges', []):
                    if ip_range['CidrIp'] == '0.0.0.0/0':
                        dangerous_rules.append({
                            'port': from_port,
                            'service': DANGEROUS_PORTS[from_port],
                            'protocol': rule['IpProtocol']
                        })
        
        # Revoke dangerous rules
        for rule in dangerous_rules:
            ec2_client.revoke_security_group_ingress(
                GroupId=sg_id,
                IpPermissions=[{
                    'IpProtocol': rule['protocol'],
                    'FromPort': rule['port'],
                    'ToPort': rule['port'],
                    'IpRanges': [{'CidrIp': '0.0.0.0/0'}]
                }]
            )
            print(f"[OK] Revoked {rule['service']} ({rule['port']}) from 0.0.0.0/0")
        
        # Notify team
        if dangerous_rules:
            sns_client.publish(
                TopicArn='arn:aws:sns:us-east-1:123456789012:security-alerts',
                Subject=f'[REMEDIATED] Overly Permissive Security Group: {sg_id}',
                Message=f'''
Lambda detected dangerous security group rules and auto-remediated.

Security Group: {sg_id}
Rules Revoked: {len(dangerous_rules)}

Revoked Rules:
{json.dumps(dangerous_rules, indent=2)}

Next Steps:
- Verify services still work
- If ports need to be open, restrict to specific IPs
- Review CloudTrail for who changed the security group

Time: {datetime.utcnow().isoformat()}
                '''
            )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Remediation successful',
                'rules_revoked': len(dangerous_rules)
            })
        }
        
    except Exception as e:
        print(f"[ERROR] {str(e)}")
        sns_client.publish(
            TopicArn='arn:aws:sns:us-east-1:123456789012:security-alerts',
            Subject='[FAILED] Security Group Remediation Error',
            Message=f'Auto-remediation failed. Manual review required.\n\nError: {str(e)}'
        )
        return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}
```

---

## Part 3: AWS Step Functions for Orchestration

### What is Step Functions?

**Definition:** Service for coordinating multiple Lambda functions and other AWS services into visual workflows

**Why Step Functions?**
- ❌ **Without:** Multiple Lambdas calling each other = complex, hard to debug
- ✅ **With:** Workflow diagram shows exactly what happens = clear, maintainable

### Step Functions Advantages

1. **Visual Workflows** - See entire process in diagram
2. **Error Handling** - Different paths for failures
3. **Parallel Execution** - Run multiple steps simultaneously
4. **Human Approval** - Pause for manual review
5. **Retries** - Automatic retry with backoff
6. **Audit Trail** - Complete log of execution history

---

## Part 4: Incident Response Workflow

### Complete Security Incident Response State Machine

```json
{
  "Comment": "Automated Security Incident Response Workflow",
  "StartAt": "AssessSeverity",
  "States": {
    "AssessSeverity": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:AssessIncidentSeverity",
      "Next": "EvaluateSeverity",
      "Catch": [{
        "ErrorEquals": ["States.ALL"],
        "Next": "NotifyCriticalError"
      }]
    },
    
    "EvaluateSeverity": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.severity",
          "StringEquals": "CRITICAL",
          "Next": "CriticalIncidentParallel"
        },
        {
          "Variable": "$.severity",
          "StringEquals": "HIGH",
          "Next": "HighIncidentActions"
        }
      ],
      "Default": "CreateLowPriorityTicket"
    },
    
    "CriticalIncidentParallel": {
      "Type": "Parallel",
      "Branches": [
        {
          "StartAt": "IsolateCompromisedResource",
          "States": {
            "IsolateCompromisedResource": {
              "Type": "Task",
              "Resource": "arn:aws:lambda:us-east-1:123456789012:function:IsolateEC2Instance",
              "End": true
            }
          }
        },
        {
          "StartAt": "CreateForensicSnapshot",
          "States": {
            "CreateForensicSnapshot": {
              "Type": "Task",
              "Resource": "arn:aws:lambda:us-east-1:123456789012:function:CreateForensicSnapshot",
              "End": true
            }
          }
        },
        {
          "StartAt": "RevokeCompromisedCredentials",
          "States": {
            "RevokeCompromisedCredentials": {
              "Type": "Task",
              "Resource": "arn:aws:lambda:us-east-1:123456789012:function:RevokeIAMCredentials",
              "End": true
            }
          }
        },
        {
          "StartAt": "QueryForensics",
          "States": {
            "QueryForensics": {
              "Type": "Task",
              "Resource": "arn:aws:lambda:us-east-1:123456789012:function:QueryCloudTrail",
              "End": true
            }
          }
        }
      ],
      "Next": "WaitForApproval"
    },
    
    "WaitForApproval": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sqs:sendMessage.waitForTaskToken",
      "Parameters": {
        "QueueUrl": "https://sqs.us-east-1.amazonaws.com/123456789012/approval-queue",
        "MessageBody": {
          "incident.$": "$.incidentDetails",
          "taskToken.$": "$$.Task.Token"
        }
      },
      "Next": "NotifyTeam"
    },
    
    "NotifyTeam": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:SendSlackAlert",
      "Parameters": {
        "severity": "CRITICAL",
        "message.$": "$.incidentDetails"
      },
      "Next": "CreateIncidentTicket"
    },
    
    "CreateIncidentTicket": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:CreateServiceNowIncident",
      "Parameters": {
        "severity": "CRITICAL",
        "shortDescription.$": "$.incidentTitle",
        "description.$": "$.incidentDetails"
      },
      "Next": "DocumentIncident"
    },
    
    "DocumentIncident": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:DocumentIncident",
      "End": true
    },
    
    "HighIncidentActions": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:HighIncidentHandler",
      "Next": "CreateIncidentTicket"
    },
    
    "CreateLowPriorityTicket": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:CreateLowPriorityTicket",
      "End": true
    },
    
    "NotifyCriticalError": {
      "Type": "Task",
      "Resource": "arn:aws:sns:us-east-1:123456789012:critical-alerts",
      "End": true
    }
  }
}
```

### Step Function Execution Flow

```
GuardDuty Detects Threat
         ↓
EventBridge triggers Step Function
         ↓
AssessSeverity Lambda: Determine criticality
         ↓
Choice: Is it CRITICAL?
         ├─ YES → Parallel execution:
         │        ├─ Isolate resource
         │        ├─ Create snapshot
         │        ├─ Revoke credentials
         │        └─ Query forensics
         │        Then wait for approval
         │
         └─ NO → Create ticket
                 (lower severity)
```

### Step Function Lambda: Isolation Function

```python
import boto3
import json
from datetime import datetime

def lambda_handler(event, context):
    """Isolate EC2 instance from network"""
    
    ec2_client = boto3.client('ec2')
    
    print(f"[{datetime.utcnow()}] Isolating EC2 instance")
    
    instance_id = event['detail']['resource']['instanceDetails']['instanceId']
    
    try:
        # Create forensic security group (no ingress/egress)
        sg_response = ec2_client.create_security_group(
            GroupName=f'forensic-isolation-{instance_id}',
            Description=f'Forensic isolation for {instance_id}',
            VpcId='vpc-12345678'
        )
        forensic_sg_id = sg_response['GroupId']
        print(f"[OK] Created forensic security group: {forensic_sg_id}")
        
        # Apply to instance (removes all network access)
        ec2_client.modify_instance_attribute(
            InstanceId=instance_id,
            Groups=[forensic_sg_id]
        )
        print(f"[OK] Instance isolated: {instance_id}")
        
        return {
            'statusCode': 200,
            'instance_id': instance_id,
            'isolation_sg': forensic_sg_id,
            'timestamp': datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        print(f"[ERROR] Isolation failed: {str(e)}")
        raise
```

---

## Part 5: Interview Talking Points

### Question: "Tell us about an automation project that reduced manual work."

**Answer:**

"I built a complete incident response workflow using Lambda and Step Functions. Before this, when GuardDuty detected threats, security team would:

1. Get alert
2. Manually query CloudTrail
3. SSH to servers
4. Create snapshots
5. Revoke credentials
6. Create ServiceNow ticket
7. Total time: 30+ minutes

**Now with automation:**

1. GuardDuty finds threat
2. EventBridge triggers Step Function
3. Four Lambdas execute **in parallel**:
   - IsolateEC2: Remove network access
   - SnapshotVolumes: Create forensic copies
   - RevokeCredentials: Revoke IAM access
   - QueryCloudTrail: Find suspicious activity
4. Step Function waits for approval
5. Security lead approves in Slack
6. Lambda creates ServiceNow ticket
7. Total time: < 2 minutes

**Results:**
- MTTR (Mean Time to Respond): 30 min → 2 min
- Response consistency: Manual → Automated
- Evidence preservation: Ad-hoc → Systematic
- No manual steps missed

**Key design decisions:**
- Parallel execution for speed (isolation + snapshot + credential revoke all at once)
- Human approval gate (Lambda doesn't delete data without approval)
- Complete audit trail (logs every action)
- Scalability (handles 1 incident or 100 incidents the same way)

The Step Function diagram shows stakeholders exactly what happens at each stage. This transparency builds confidence in automation."

---

## Implementation Checklist

**Phase 1: Foundation**
- [ ] Create IAM role for Lambda with security permissions
- [ ] Build first Lambda function (S3 public bucket remediation)
- [ ] Test Lambda in non-production
- [ ] Deploy to production
- [ ] Create CloudWatch alarms for Lambda errors

**Phase 2: Orchestration**
- [ ] Design incident response state machine
- [ ] Build assessment Lambda
- [ ] Build isolation Lambda
- [ ] Build forensics Lambda
- [ ] Deploy Step Function
- [ ] Test with mock events

**Phase 3: Integration**
- [ ] Connect GuardDuty to EventBridge
- [ ] Create EventBridge rule triggering Step Function
- [ ] Integrate ServiceNow for ticketing
- [ ] Set up Slack notifications
- [ ] Configure human approval process

**Phase 4: Optimization**
- [ ] Monitor Lambda execution times
- [ ] Tune error handling
- [ ] Adjust approval SLA
- [ ] Document runbooks
- [ ] Train team on process

---

## Key Takeaways

> **Lambda + Step Functions enable security automation at scale. Incidents that took 30 minutes now take 2 minutes.**

1. **Lambda = speed** - Execution time: seconds (not hours)
2. **Step Functions = orchestration** - Visual workflows, parallel execution, approval gates
3. **Auto-remediation** - Fix simple issues automatically (public buckets, open ports)
4. **Incident response** - Structured workflow with parallel actions
5. **Consistency** - Same process every time (no human error)
6. **Audit trail** - Complete logging of all automated actions
7. **Scalability** - Same automation handles 1 incident or 1000
8. **Human in the loop** - Approval gates for sensitive actions
9. **Cost-effective** - Pay only for execution time
10. **Interview advantage** - Demonstrates modern DevSecOps thinking
