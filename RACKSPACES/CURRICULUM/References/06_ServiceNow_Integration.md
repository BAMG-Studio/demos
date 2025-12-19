# ServiceNow Integration: Ticketing, CMDB, and Workflow Automation

> **Quick Reference:** ServiceNow is the world's leading IT Service Management platform. Integrate it with AWS security findings to automatically track and remediate vulnerabilities.

---

## Part 1: Why ServiceNow Integration Matters

### The Problem Without Integration

**Without ServiceNow:**
- Orca finds 450 vulnerabilities
- Prisma finds 200 more findings
- GuardDuty detects threat
- Email goes to security team
- Some findings get lost
- No tracking, no accountability
- No deadline enforcement
- Compliance team can't verify remediation

### The Solution With Integration

**With ServiceNow:**
- Security tool finds issue
- Automatically creates incident/change request
- Assigns to correct team
- Sets priority based on risk
- Tracks remediation progress
- Compliance team verifies completion
- CMDB links to affected business services

---

## Part 2: ServiceNow Architecture

### ServiceNow Products for Cloud Security

| Product | Purpose | Integration Point |
|---------|---------|-------------------|
| **ITSM** | Service management, incident tracking | Auto-create incidents from findings |
| **CMDB** | Asset database, relationships | Link findings to business services |
| **ITOM** | IT operations, monitoring | Feed AWS metrics into monitoring |
| **GRC** | Governance, risk, compliance | Track compliance control evidence |
| **SecOps** | Security incident management | Escalate critical incidents |

### Integration Architecture

```
AWS Security Tools
├── GuardDuty (threat detection)
├── Inspector (vulnerability scanning)
├── Macie (data security)
├── Config (compliance violations)
├── Orca (cloud posture)
└── Prisma Cloud (cloud security)
    ↓ (EventBridge rules)
    ↓
AWS Lambda (Transformation)
    ├── Enrich finding with context
    ├── Map to CMDB asset
    ├── Calculate business impact
    ├── Determine assignment group
    └── Set priority
    ↓
ServiceNow API
    ├── Create/Update incident
    ├── Link to CMDB CI
    ├── Auto-assign to team
    ├── Set SLA
    └── Create task
    ↓
ServiceNow Incident Management
    ├── Notify assigned teams
    ├── Track remediation
    ├── Update status
    └── Provide compliance evidence
```

---

## Part 3: Lambda Function - GuardDuty to ServiceNow

### Pattern 1: Create Incident from GuardDuty Finding

```python
import boto3
import requests
import json
from datetime import datetime
import base64

def lambda_handler(event, context):
    """
    Convert GuardDuty finding to ServiceNow incident
    """
    
    print(f"[{datetime.utcnow()}] Processing GuardDuty finding")
    
    try:
        # Parse GuardDuty finding
        finding = event['detail']
        finding_id = finding['id']
        severity = finding['severity']
        resource_type = finding['resource']['resourceType']
        
        print(f"[FINDING] ID: {finding_id}, Severity: {severity}, Type: {resource_type}")
        
        # Map GuardDuty severity to ServiceNow urgency
        severity_map = {
            7.0: '1',  # CRITICAL → Urgency 1 (highest)
            5.0: '2',  # HIGH → Urgency 2
            3.0: '3',  # MEDIUM → Urgency 3
            1.0: '4'   # LOW → Urgency 4
        }
        
        urgency = severity_map.get(severity, '4')
        
        # Get resource details
        resource = finding['resource']
        
        # Build comprehensive incident description
        description = f"""
{finding.get('title', 'GuardDuty Finding')}

**Severity:** {severity}
**Finding ID:** {finding_id}
**Finding Type:** {finding.get('type', 'Unknown')}
**Resource Type:** {resource_type}

**Details:**
{json.dumps(finding, indent=2, default=str)}

**Next Steps:**
1. Investigate the finding details above
2. Determine if this is a legitimate activity
3. Take remediation actions if required
4. Update incident status when complete

**Timeline:**
Created: {datetime.utcnow().isoformat()}
        """
        
        # Build incident payload for ServiceNow
        incident_payload = {
            'short_description': finding.get('title', 'AWS GuardDuty Finding'),
            'description': description,
            'urgency': urgency,
            'impact': '2',  # Medium impact
            'assignment_group': get_assignment_group(resource_type),
            'category': 'Security',
            'subcategory': 'Cloud Security',
            'state': '1',  # New
            'correlation_id': finding_id,
            'u_aws_region': finding.get('region', 'unknown'),
            'u_aws_account_id': finding.get('accountId', 'unknown'),
            'u_aws_resource_type': resource_type,
            'u_finding_id': finding_id,
            'u_finding_severity': severity
        }
        
        # Enrich with CMDB information if possible
        cmdb_info = get_cmdb_info(resource)
        if cmdb_info:
            incident_payload['cmdb_ci'] = cmdb_info['sys_id']
            incident_payload['u_affected_service'] = cmdb_info['name']
            incident_payload['u_business_impact'] = cmdb_info['criticality']
        
        # Create ServiceNow incident via REST API
        incident_response = create_servicenow_incident(incident_payload)
        
        incident_number = incident_response.get('number')
        incident_sys_id = incident_response.get('sys_id')
        
        print(f"[SUCCESS] Created ServiceNow incident: {incident_number}")
        
        # Send notification
        send_notification(incident_number, finding)
        
        return {
            'statusCode': 201,
            'body': json.dumps({
                'message': 'Incident created',
                'servicenow_incident': incident_number,
                'finding_id': finding_id
            })
        }
        
    except Exception as e:
        print(f"[ERROR] {str(e)}")
        
        # Still notify on failure
        send_failure_notification(str(e))
        
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def get_assignment_group(resource_type):
    """Map AWS resource type to ServiceNow assignment group"""
    
    assignment_map = {
        'Instance': 'Infrastructure Security Team',
        'S3': 'Data Security Team',
        'Database': 'Database Security Team',
        'IAM': 'Identity & Access Team',
        'Network': 'Network Security Team',
        'Lambda': 'Application Security Team'
    }
    
    return assignment_map.get(resource_type, 'Cloud Security Team')

def get_cmdb_info(resource):
    """
    Query ServiceNow CMDB to find affected CI (Configuration Item)
    and get business criticality
    """
    
    try:
        # Map AWS resource to CMDB
        resource_type = resource.get('resourceType', '')
        instance_id = resource.get('instanceDetails', {}).get('instanceId')
        
        if not instance_id:
            return None
        
        # Query CMDB for this instance
        servicenow_url = "https://yourinstance.service-now.com/api/now/table/cmdb_ci_compute"
        
        response = requests.get(
            f"{servicenow_url}?sysparm_query=name={instance_id}",
            auth=get_servicenow_auth(),
            headers={'Accept': 'application/json'}
        )
        
        if response.status_code == 200:
            results = response.json().get('result', [])
            if results:
                ci = results[0]
                return {
                    'sys_id': ci['sys_id'],
                    'name': ci['name'],
                    'criticality': ci.get('criticality', '3')
                }
        
        return None
        
    except Exception as e:
        print(f"[WARNING] CMDB lookup failed: {str(e)}")
        return None

def create_servicenow_incident(incident_payload):
    """Create incident in ServiceNow"""
    
    servicenow_url = "https://yourinstance.service-now.com/api/now/table/incident"
    
    response = requests.post(
        servicenow_url,
        auth=get_servicenow_auth(),
        headers={
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        },
        json=incident_payload
    )
    
    if response.status_code != 201:
        raise Exception(f"ServiceNow API error: {response.text}")
    
    result = response.json().get('result', {})
    
    return {
        'number': result.get('number'),
        'sys_id': result.get('sys_id')
    }

def get_servicenow_auth():
    """Get ServiceNow credentials from AWS Secrets Manager"""
    
    import boto3
    
    secrets_client = boto3.client('secretsmanager')
    
    secret = secrets_client.get_secret_value(SecretId='servicenow-api-credentials')
    credentials = json.loads(secret['SecretString'])
    
    return (credentials['username'], credentials['password'])

def send_notification(incident_number, finding):
    """Send Slack notification about new incident"""
    
    import boto3
    
    sns = boto3.client('sns')
    
    sns.publish(
        TopicArn='arn:aws:sns:us-east-1:123456789012:security-alerts',
        Subject=f'New ServiceNow Incident: {incident_number}',
        Message=f'''
GuardDuty Finding → ServiceNow Incident Created

Incident: {incident_number}
Finding: {finding.get('title')}
Severity: {finding.get('severity')}
Type: {finding.get('type')}

View in ServiceNow: https://yourinstance.service-now.com/nav_to.do?uri=incident.do?sys_id=...
        '''
    )

def send_failure_notification(error):
    """Notify on failure"""
    
    import boto3
    
    sns = boto3.client('sns')
    
    sns.publish(
        TopicArn='arn:aws:sns:us-east-1:123456789012:security-alerts',
        Subject='[FAILED] GuardDuty → ServiceNow Sync Failed',
        Message=f'Error creating ServiceNow incident from GuardDuty finding.\n\nError: {error}'
    )
```

---

## Part 4: Bidirectional Sync

### Pattern: Verify Remediation in ServiceNow, Update AWS

```python
import boto3
import requests
import json
from datetime import datetime

def servicenow_webhook_handler(event, context):
    """
    ServiceNow sends webhook when incident is marked 'Resolved'
    Lambda verifies the issue is actually fixed in AWS
    """
    
    print(f"[{datetime.utcnow()}] Received ServiceNow webhook")
    
    try:
        # Parse webhook
        body = json.loads(event.get('body', '{}'))
        
        incident_number = body.get('number')
        state = body.get('state')  # 6 = Resolved
        finding_id = body.get('correlation_id')
        
        print(f"[INCIDENT] {incident_number}, State: {state}")
        
        if state != '6':  # Not resolved
            return {'statusCode': 200}
        
        # Query AWS to verify fix
        fixed = verify_remediation(finding_id)
        
        if fixed:
            print(f"[VERIFIED] Issue is actually fixed in AWS")
            
            # Update ServiceNow to confirm
            update_servicenow_incident(incident_number, {
                'state': '7',  # Closed
                'close_notes': 'Issue verified fixed in AWS. Automatically closed.',
                'correlation_display': 'VERIFIED_REMEDIATED'
            })
            
            return {'statusCode': 200, 'body': 'Verified and closed'}
        
        else:
            print(f"[UNVERIFIED] Issue still exists in AWS")
            
            # Reopen incident
            update_servicenow_incident(incident_number, {
                'state': '2',  # In Progress
                'work_notes': 'Verification failed. Issue still exists in AWS. Reopening for remediation.'
            })
            
            return {'statusCode': 200, 'body': 'Issue still exists, reopened'}
        
    except Exception as e:
        print(f"[ERROR] {str(e)}")
        return {'statusCode': 500, 'body': str(e)}

def verify_remediation(finding_id):
    """
    Query GuardDuty to see if issue is still present
    For S3 public bucket: Check if actually private now
    For open port: Check if security group closed
    """
    
    guardduty = boto3.client('guardduty')
    
    try:
        # Get current detector
        detectors = guardduty.list_detectors()['DetectorIds']
        
        if not detectors:
            return False
        
        # Look for this finding
        findings = guardduty.list_findings(
            DetectorId=detectors[0],
            FindingCriteria={'Criterion': {
                'id': {'Value': finding_id}
            }}
        )['FindingIds']
        
        # If no findings found, issue is fixed!
        return len(findings) == 0
        
    except Exception as e:
        print(f"[WARNING] Could not verify: {str(e)}")
        return None  # Unknown state

def update_servicenow_incident(incident_number, updates):
    """Update incident in ServiceNow"""
    
    servicenow_url = f"https://yourinstance.service-now.com/api/now/table/incident"
    
    # First get sys_id
    get_response = requests.get(
        f"{servicenow_url}?sysparm_query=number={incident_number}",
        auth=get_servicenow_auth(),
        headers={'Accept': 'application/json'}
    )
    
    if get_response.status_code != 200:
        raise Exception("Could not find incident")
    
    sys_id = get_response.json()['result'][0]['sys_id']
    
    # Update
    response = requests.patch(
        f"{servicenow_url}/{sys_id}",
        auth=get_servicenow_auth(),
        headers={'Content-Type': 'application/json'},
        json=updates
    )
    
    if response.status_code != 200:
        raise Exception(f"Update failed: {response.text}")
```

---

## Part 5: CMDB Integration for Impact Analysis

### Linking AWS Resources to Business Services

```python
def enrich_incident_with_cmdb(resource_id):
    """
    Link AWS resource to business service
    Show impact: "This database serves 3 microservices used by payment system"
    """
    
    requests_lib = requests
    
    # Step 1: Find AWS resource in CMDB
    query = f"name={resource_id} OR hostname={resource_id}"
    
    cmdb_response = requests_lib.get(
        "https://yourinstance.service-now.com/api/now/table/cmdb_ci_compute",
        params={'sysparm_query': query},
        auth=get_servicenow_auth()
    )
    
    if cmdb_response.status_code != 200:
        return None
    
    ci = cmdb_response.json()['result'][0]
    ci_sys_id = ci['sys_id']
    
    # Step 2: Find services that depend on this resource
    depends_response = requests_lib.get(
        "https://yourinstance.service-now.com/api/now/table/cmdb_rel_ci",
        params={
            'sysparm_query': f'parent={ci_sys_id}^child=service',
            'sysparm_limit': 100
        },
        auth=get_servicenow_auth()
    )
    
    services = []
    
    for relation in depends_response.json().get('result', []):
        service_sys_id = relation['child']
        
        # Get service details
        service_response = requests_lib.get(
            f"https://yourinstance.service-now.com/api/now/table/cmdb_ci_service/{service_sys_id}",
            auth=get_servicenow_auth()
        )
        
        service = service_response.json()['result']
        services.append({
            'name': service['name'],
            'criticality': service.get('criticality', '3'),
            'business_service': service.get('business_service')
        })
    
    return {
        'resource_ci': ci['name'],
        'affected_services': services,
        'total_impact': len(services)
    }

# Example output:
# {
#   "resource_ci": "prod-db-001",
#   "affected_services": [
#     {"name": "Payment API", "criticality": "1", "business_service": "Finance"},
#     {"name": "User Service", "criticality": "1", "business_service": "HR"},
#     {"name": "Reporting API", "criticality": "3", "business_service": "Analytics"}
#   ],
#   "total_impact": 3
# }
```

---

## Part 6: Automated Routing & Priority

### Intelligent Assignment Based on Impact

```python
def determine_incident_priority(finding, cmdb_info):
    """
    Automatically set ServiceNow priority based on:
    1. AWS severity
    2. Business impact (via CMDB)
    3. Regulatory compliance
    """
    
    priority = 4  # Default: lowest priority
    
    # Factor 1: AWS Severity
    severity = finding.get('severity', 1.0)
    
    if severity >= 7.0:
        priority = min(priority, 1)  # Critical → Priority 1
    elif severity >= 5.0:
        priority = min(priority, 2)  # High → Priority 2
    elif severity >= 3.0:
        priority = min(priority, 3)  # Medium → Priority 3
    
    # Factor 2: Affected Services
    if cmdb_info and cmdb_info.get('affected_services'):
        services = cmdb_info['affected_services']
        
        # If affecting critical service, escalate
        for service in services:
            if service.get('criticality') == '1':  # Critical
                priority = min(priority, 1)
    
    # Factor 3: Regulatory Impact
    finding_type = finding.get('type', '')
    
    if 'PCI' in finding_type or 'CreditCard' in finding_type:
        priority = min(priority, 2)  # PCI violations are High
    
    if 'HIPAA' in finding_type or 'PHI' in finding_type:
        priority = min(priority, 1)  # HIPAA violations are Critical
    
    return priority
```

---

## Part 7: Interview Talking Points

### Question: "How would you integrate AWS security findings with ServiceNow?"

**Answer:**

"Complete integration requires three layers:

**Layer 1: Automated Creation**
When Orca detects a misconfiguration or GuardDuty finds a threat, Lambda automatically creates a ServiceNow incident with:
- Clear description and context
- Proper urgency (critical vulnerabilities set high priority)
- Assignment to correct team (database issues → DBA team, IAM issues → Identity team)
- Correlation ID linking back to AWS finding

**Layer 2: Business Impact Enrichment**
Lambda queries CMDB to understand impact:
- 'This S3 bucket serves the Payment API which is critical'
- 'This EC2 instance supports HR payroll system (PCI-regulated)'
- This context automatically escalates priority

**Layer 3: Verification & Closure**
When DevOps marks incident resolved in ServiceNow, Lambda:
1. Queries AWS to verify issue is actually fixed
2. If fixed: Auto-closes incident with evidence
3. If NOT fixed: Reopens with note that issue still exists
4. Prevents false closures

**Real example:**
GuardDuty → Orca finds public S3 bucket with customer PII
↓
EventBridge triggers Lambda
↓
Lambda queries CMDB: 'production-data' bucket
Finds it serves:
- Payment API (CRITICAL, PCI-regulated)
- Customer Portal (CRITICAL)
- Reporting System (Medium)
↓
Creates ServiceNow incident with:
- Title: 'CRITICAL: Public S3 bucket contains PII'
- Urgency: 1 (highest)
- Impact: 3 critical services
- Assignment: Data Security Team Lead
↓
DevOps teams see incident, remediate immediately
↓
Incident marked resolved
↓
Lambda verifies bucket is now private
↓
Incident auto-closed with compliance evidence

**Key benefits:**
- No findings slip through
- Right people get right priority
- Business impact clear
- Compliance evidence tracked
- MTTR from finding to remediation: 15 min average

This integration is essential for scale—without it, security team becomes bottleneck."

---

## Implementation Checklist

- [ ] Create ServiceNow account and set up API user
- [ ] Store credentials in AWS Secrets Manager
- [ ] Build Lambda function for GuardDuty → ServiceNow sync
- [ ] Create EventBridge rule to trigger Lambda
- [ ] Map AWS resource types to ServiceNow assignment groups
- [ ] Query CMDB to enrich incidents with business context
- [ ] Set up ServiceNow webhook for incident status updates
- [ ] Build verification Lambda to check if issues actually fixed
- [ ] Create Slack integration for notifications
- [ ] Test complete workflow (end-to-end)
- [ ] Document assignment group mappings
- [ ] Train teams on new incident flow

---

## Key Takeaways

> **ServiceNow integration closes the gap between security tools and IT operations. Findings that would get lost now automatically become tracked, assigned incidents.**

1. **Automatic creation** - Security tools → ServiceNow incidents (no manual entry)
2. **Business context** - CMDB links findings to affected services
3. **Smart assignment** - Incidents route to correct teams automatically
4. **Priority escalation** - Critical findings get highest priority
5. **Verification** - Automated checks confirm fixes actually work
6. **Compliance evidence** - Incident tickets provide audit trail
7. **Reduces MTTR** - Structured process speeds response
8. **Prevents alert fatigue** - Filtering in Lambda reduces noise
9. **Accountability** - Assignments ensure follow-through
10. **Scalability** - Same integration handles 10 findings or 10,000
