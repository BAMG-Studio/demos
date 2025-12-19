# OWASP Top 10: Web & Kubernetes Vulnerabilities with Cloud Context

> **Quick Reference:** OWASP publishes the most critical security risks. The Top 10 changes every few years. Current: 2021 list. Kubernetes Top 10 is separate for container environments.

---

## Part 1: What is OWASP?

**OWASP** = Open Web Application Security Project - nonprofit foundation publishing security risk lists

**Think of it as:** Consumer Reports for cybersecurity - the authoritative vulnerability list

**Why It Matters:**
- Referenced in PCI-DSS, HIPAA, SOX compliance frameworks
- Standard for security testing and code reviews
- Used in hiring security professionals
- Foundation for DevSecOps practices

---

## Part 2: OWASP Top 10 for Web Applications (2021)

### 1. Broken Access Control

**What:** Users access data/functions they shouldn't

**Layman's Example:**
- Change URL from `/user/123` to `/user/999` and see another person's data
- Bank customer viewing other customers' accounts
- Non-admin accessing admin panel

**Cloud Context (AWS):**
- S3 bucket publicly accessible when it shouldn't be
- IAM role with overly broad permissions (e.g., `*:*` instead of specific actions)
- Security group allowing SSH from 0.0.0.0/0
- Database accessible from internet when it should be private

**How to Prevent:**
- Authorization checks on every request
- Deny by default (unless explicitly allowed)
- Role-based access control (RBAC)
- Least-privilege IAM policies (specify exact actions, resources)
- Regular access reviews

**AWS Implementation:**
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "s3:GetObject",
      "s3:PutObject"
    ],
    "Resource": "arn:aws:s3:::my-bucket/user-data/*"
  }]
}
```

**Interview Point:** "I implement least-privilege by default. Every IAM role gets minimal permissions needed. I use AWS Access Analyzer to identify overly permissive access and create automation to remediate."

---

### 2. Cryptographic Failures

**What:** Sensitive data (passwords, credit cards, health records) not protected

**Layman's Example:**
- Hospital stores patient records in plain text files
- Web application sends passwords over HTTP (not HTTPS)
- Encryption using MD5 (broken algorithm) instead of AES-256
- Database backup stored without encryption

**Cloud Context:**
- S3 bucket without encryption (plain text data at rest)
- RDS database without encryption
- EBS volumes unencrypted
- CloudTrail logs not encrypted
- TLS 1.0/1.1 (outdated) instead of TLS 1.2+

**How to Prevent:**
- **Encryption at Rest:** AES-256 with customer-managed keys (KMS)
- **Encryption in Transit:** TLS 1.3 (minimum 1.2)
- **Key Management:** AWS KMS with key rotation
- **No Weak Algorithms:** Avoid MD5, SHA1 for security
- **Secure Deletion:** Cryptographic erasure, not just delete

**AWS Implementation:**
```bash
# Enable S3 encryption
aws s3api put-bucket-encryption \
  --bucket my-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "arn:aws:kms:region:account:key/id"
      },
      "BucketKeyEnabled": true
    }]
  }'

# Enable RDS encryption
aws rds create-db-instance \
  --db-instance-identifier prod-db \
  --storage-encrypted \
  --kms-key-id arn:aws:kms:...
```

**Interview Point:** "Encryption is not optional—it's mandatory. I enable by default for all storage services: S3 with KMS, RDS encrypted with customer-managed keys, EBS with encryption enabled by default. I use AWS KMS with key rotation for compliance."

---

### 3. Injection

**What:** Attacker sends malicious data interpreted as commands

**Types:** SQL injection, command injection, LDAP injection, XPath injection, NoSQL injection

**Layman's Example:**
```
Normal input: username = "john"
Malicious input: username = "admin' OR '1'='1"
Vulnerable query: SELECT * FROM users WHERE username = 'admin' OR '1'='1'
Result: Returns ALL users because '1'='1' is always true
```

**Cloud Context:**
- DynamoDB NoSQL injection (similar to SQL injection but for NoSQL)
- Lambda receiving untrusted input from API Gateway
- CloudTrail log analysis with injected values

**How to Prevent:**
- **Parameterized Queries:** Use placeholders instead of concatenation
- **Input Validation:** Whitelist allowed characters
- **ORM Frameworks:** SQLAlchemy, Hibernage handle escaping
- **Least Privilege:** Database accounts with minimal permissions
- **WAF (Web Application Firewall):** Block common injection patterns

**Vulnerable Code:**
```python
# VULNERABLE - DO NOT USE
@app.route('/user/<username>')
def get_user(username):
    query = f"SELECT * FROM users WHERE username = '{username}'"
    result = db.execute(query)
    return jsonify(result)
```

**Secure Code:**
```python
# SAFE - Use parameterized queries
@app.route('/user/<username>')
def get_user(username):
    query = "SELECT * FROM users WHERE username = ?"
    result = db.execute(query, (username,))  # Parameter binding
    return jsonify(result)
```

**AWS WAF Rule:**
```json
{
  "Name": "AWSManagedRulesSQLiRuleSet",
  "Priority": 1,
  "Statement": {
    "ManagedRuleGroupStatement": {
      "VendorName": "AWS",
      "Name": "AWSManagedRulesSQLiRuleSet"
    }
  },
  "Action": {"Block": {}},
  "VisibilityConfig": {
    "SampledRequestsEnabled": true,
    "CloudWatchMetricsEnabled": true,
    "MetricName": "SQLiRuleSetMetric"
  }
}
```

**Interview Point:** "I build parameterized queries as standard. Every database query uses parameter binding. I enable AWS WAF for web applications with OWASP managed rule sets. This defense-in-depth approach prevents injection attacks."

---

### 4. Insecure Design

**What:** Security flaws in architecture/design, not implementation

**Layman's Example:**
- Building house with door lock on the OUTSIDE (defeats purpose)
- Bank system with no transaction audit trail (can't detect fraud)
- Password recovery that requires knowing security questions (predictable)

**Cloud Context:**
- No encryption key rotation strategy (if key compromised, all data exposed forever)
- Single region deployment (no disaster recovery)
- No rate limiting on APIs (vulnerable to brute force/DDoS)
- No audit logging (can't detect breaches)

**How to Prevent:**
- **Threat Modeling:** Identify risks during design, not after deployment
- **Secure Design Patterns:** Use proven security architectures
- **Defense in Depth:** Multiple security layers
- **Separation of Concerns:** Microservices reduce blast radius

**Threat Model Example:**
```
1. Who are attackers?
   - External: Internet users, competitors
   - Internal: Disgruntled employees, contractors

2. What assets are they after?
   - Customer PII
   - Payment data
   - Trade secrets

3. What attacks would they use?
   - Brute force credentials
   - Exploit unpatched servers
   - Social engineering

4. How do we prevent?
   - MFA (prevents brute force)
   - Patching strategy (no exploits)
   - Security awareness training
```

**Interview Point:** "I include security in architecture decisions. Before building, I ask: 'What could go wrong? How would an attacker exploit this? What's our defense?' This threat modeling approach prevents expensive rearchitecture later."

---

### 5. Security Misconfiguration

**What:** Default settings, unnecessary features, error messages revealing too much

**Examples:**
- Default admin passwords (admin/admin)
- Directory listing enabled (revealing file structure)
- Detailed error messages showing stack traces
- Unpatched software versions
- Unnecessary services running

**Cloud Context - Common Misconfigurations:**
- S3 bucket publicly accessible (1 setting wrong)
- Security group allowing 0.0.0.0/0 on all ports
- RDS with default password
- EC2 with open SSH to internet
- API Gateway without authentication
- CloudFront without WAF
- No encryption enabled by default

**How to Prevent:**
- **Automated Scanning:** AWS Config, Orca, Prisma Cloud
- **Infrastructure as Code:** Templates with secure defaults
- **Regular Reviews:** Monthly security assessment
- **Hardening Guides:** Follow CIS Benchmarks
- **Immutable Infrastructure:** Deploy from known-good templates

**AWS Config Rule (Automated Detection):**
```python
import boto3

def evaluate_compliance(configuration_item):
    """Check if S3 bucket has public access blocked"""
    if configuration_item['resourceType'] != 'AWS::S3::Bucket':
        return 'NOT_APPLICABLE'
    
    bucket_name = configuration_item['resourceName']
    
    s3 = boto3.client('s3')
    try:
        block_config = s3.get_public_access_block(
            Bucket=bucket_name
        )['PublicAccessBlockConfiguration']
        
        if all([
            block_config['BlockPublicAcls'],
            block_config['IgnorePublicAcls'],
            block_config['BlockPublicPolicy'],
            block_config['RestrictPublicBuckets']
        ]):
            return 'COMPLIANT'
    except:
        pass
    
    return 'NON_COMPLIANT'
```

**Interview Point:** "Misconfiguration is the #1 cause of cloud breaches. I use Infrastructure as Code with secure baselines. Every resource inherits encryption, logging, and access controls by default. AWS Config continuously checks for violations."

---

### 6. Vulnerable and Outdated Components

**What:** Using libraries/frameworks with known vulnerabilities

**Famous Case:** 2017 Equifax breach - used outdated Apache Struts with public exploit

**Cloud Context:**
- Python package with known vulnerability (SCA tools detect)
- Container image with outdated OS patches
- Lambda runtime on deprecated version
- Third-party SaaS with unpatched API

**How to Prevent:**
- **Software Bill of Materials (SBOM):** Know what you're using
- **SCA Tools:** Snyk, Dependabot monitor dependencies
- **Vulnerability Subscriptions:** NVD, security advisories
- **Automated Patching:** Regular updates
- **Container Scanning:** Trivy scans images for CVEs

**Example - Log4Shell (December 2021):**
```
Critical vulnerability in Log4j library
CVE-2021-44228 - Remote Code Execution
Severity: CRITICAL (CVSS 10.0)
Affected: log4j 2.0 through 2.14.1

SCA detection:
$ snyk test
✗ [High] Remote Code Injection (RCE)
  in log4j:2.14.1
  Introduced through: org.apache.logging.log4j
```

**Interview Point:** "Dependencies are 80% of modern applications. I use SCA tools scanning continuously for vulnerable packages. When Log4Shell was discovered, automated alerts identified all affected systems within hours. Manual process would have taken weeks."

---

### 7. Identification and Authentication Failures

**What:** Weak authentication mechanisms

**Examples:**
- Weak password policies (8 chars, no special chars)
- No MFA (one factor = one vulnerability away from compromise)
- Session tokens exposed in URLs
- Credential stuffing succeeds (attacker uses leaked passwords)
- Default credentials still active

**Cloud Context:**
- IAM user with long-lived access keys (no rotation)
- Root account credentials not protected
- No MFA on privileged accounts
- Session tokens in CloudTrail logs (if logged)

**How to Prevent:**
- **Strong Passwords:** 14+ characters, complexity requirements
- **MFA Required:** SMS is weak; use TOTP/security keys
- **No Default Credentials:** Change all defaults
- **Rotate Credentials:** Every 90 days
- **Rate Limiting:** Prevent brute force attacks

**AWS Implementation:**
```bash
# Enforce strong IAM password policy
aws iam update-account-password-policy \
  --minimum-password-length 14 \
  --require-symbols \
  --require-numbers \
  --require-uppercase-characters \
  --require-lowercase-characters \
  --allow-users-to-change-password \
  --password-reuse-prevention 12

# Require MFA for console access
aws iam create-virtual-mfa-device \
  --virtual-mfa-device-name myuser-mfa

# Rotate access keys
aws iam update-access-key \
  --access-key-id AKIAIOSFODNN7EXAMPLE \
  --status Inactive
```

**Interview Point:** "I enforce MFA company-wide. Every AWS console access requires MFA. Access keys are rotated quarterly. Root account is locked away with MFA enabled. This prevents credential-based breaches."

---

### 8. Software and Data Integrity Failures

**What:** Code/infrastructure don't verify integrity

**Examples:**
- Auto-update without digital signatures
- CI/CD pipeline without integrity checks
- Unsigned container images (attacker could modify)
- Compromised dependencies (SolarWinds 2020)

**Cloud Context:**
- ECR pushing unsigned images
- Lambda code updated without integrity verification
- CloudFormation templates from untrusted sources
- Container images without scanning

**How to Prevent:**
- **Code Signing:** Sign commits, sign container images
- **Verify Signatures:** Only run signed code
- **CI/CD Security Gates:** Integrity checks before deployment
- **Container Image Signing:** Cosign, Docker Content Trust
- **Trusted Repositories:** Only use verified sources

**Container Signing Example:**
```bash
# Install Cosign
curl https://github.com/sigstore/cosign/releases/download/.../cosign-linux-amd64

# Sign image
cosign sign --key cosign.key \
  us-east-1.dkr.ecr.amazonaws.com/myapp:latest

# Verify signature before deployment
cosign verify --key cosign.pub \
  us-east-1.dkr.ecr.amazonaws.com/myapp:latest
```

**Interview Point:** "Every container image is signed and verified. Lambda functions are deployed from code-signed artifacts. CloudFormation templates are scanned before execution. This supply chain security prevents compromised code from reaching production."

---

### 9. Security Logging and Monitoring Failures

**What:** Insufficient logging prevents incident detection

**Consequences:**
- Breaches detected months later
- No forensics audit trail
- Can't meet compliance requirements
- Attackers operate undetected

**Cloud Context:**
- No CloudTrail enabled (no audit of who did what)
- CloudTrail logs not retained
- No GuardDuty (no threat detection)
- No CloudWatch alarms (no real-time alerts)

**What to Log:**
- Authentication success/failures
- Access control failures
- Input validation failures
- API calls (CloudTrail)
- Data access (S3, RDS)
- Configuration changes
- Privileged actions

**How to Prevent:**
- **Centralized Logging:** CloudWatch, ELK, Splunk
- **Real-Time Alerting:** Immediate notification of issues
- **Log Retention:** 90 days hot, 7 years archive
- **Regular Review:** Weekly security event analysis
- **Event Correlation:** Connect related events

**CloudWatch Metric Filter Example:**
```bash
# Create alarm for unauthorized API calls
aws logs put-metric-filter \
  --log-group-name /aws/cloudtrail/events \
  --filter-name UnauthorizedApiCalls \
  --filter-pattern "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }" \
  --metric-transformations metricName=UnauthorizedAPICallsMetric,metricValue=1

# Create alarm to notify on suspicious activity
aws cloudwatch put-metric-alarm \
  --alarm-name UnauthorizedAPICallsAlarm \
  --metric-name UnauthorizedAPICallsMetric \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --alarm-actions arn:aws:sns:region:account:topic
```

**Interview Point:** "CloudTrail is mandatory—every API call logged. I set up metric filters for suspicious patterns. GuardDuty provides ML-based threat detection. Alerts go to Slack immediately. This real-time visibility means we detect incidents in minutes, not months."

---

### 10. Server-Side Request Forgery (SSRF)

**What:** Attacker tricks server into making requests to unintended locations

**Layman's Example:**
- Attacker: "Please fetch image from http://secret-admin-panel/"
- Server: Fetches it (with server's permissions)
- Attacker: Sees admin panel content
- Result: Access to restricted areas

**Cloud Context - AWS Metadata Attack:**
```
Attacker: "Fetch image from http://169.254.169.254/latest/meta-data/"
Server: Accesses metadata endpoint WITH IAM credentials
Result: Attacker gets AWS credentials with full permissions!
```

**How to Prevent:**
- **Whitelist Domains:** Only allow specific URLs
- **Disable Schemes:** Block file://, gopher://, etc.
- **Network Segmentation:** Restrict egress
- **IMDSv2:** Requires token (prevents simple exploits)
- **WAF Rules:** Block common SSRF patterns

**IMDSv2 Protection:**
```bash
# Enable IMDSv2 (requires token for metadata access)
aws ec2 modify-instance-metadata-options \
  --instance-id i-1234567890abcdef0 \
  --http-tokens required \
  --http-put-response-hop-limit 1
```

**Secure Code:**
```python
from urllib.parse import urlparse
import requests

ALLOWED_DOMAINS = ['api.trusted.com', 'cdn.trusted.com']

@app.route('/fetch-image')
def fetch_image():
    url = request.args.get('url')
    
    # Whitelist check
    parsed = urlparse(url)
    if parsed.netloc not in ALLOWED_DOMAINS:
        return "Invalid domain", 400
    
    # Block dangerous schemes
    if parsed.scheme not in ['http', 'https']:
        return "Invalid scheme", 400
    
    response = requests.get(url)
    return response.content
```

**Interview Point:** "I restrict egress from applications. EC2 instances can't reach metadata endpoints unless specifically allowed. Web servers can only access whitelisted external APIs. Lambda functions use VPC endpoints for AWS services. This defense prevents SSRF attacks."

---

## Part 3: OWASP Top 10 for Kubernetes (Cloud-Native)

Since Kubernetes is cloud-native, it has its own Top 10 risks:

| Risk | What It Is | Prevention |
|------|-----------|-----------|
| **K01: Insecure Workload Config** | Containers as root, no resource limits | Pod Security Standards, non-root users, resource limits |
| **K02: Supply Chain Vulns** | Vulnerable images, unverified containers | Image scanning, signing, SBOM verification |
| **K03: Overly Permissive RBAC** | Service accounts with excess permissions | Least privilege, regular audits, role-based access |
| **K04: Lack of Policy Enforcement** | No centralized policies | OPA Gatekeeper, Kyverno admission controllers |
| **K05: Inadequate Logging & Monitoring** | Can't detect incidents | Centralized logging, audit logs, threat detection |
| **K06: Broken Authentication** | Weak/missing auth | mTLS, service mesh, short-lived tokens, API tokens |
| **K07: Missing Network Segmentation** | All pods talk to all pods | Network policies, service mesh, zero-trust |
| **K08: Secrets Management Failures** | Secrets in code/env vars | External secrets manager (AWS Secrets Manager, Vault) |
| **K09: Misconfigured Cluster** | Insecure kubelet, API server | CIS benchmarks, regular audits, secure defaults |
| **K10: Outdated Components** | Old K8s versions | Regular updates, vulnerability scanning |

**Kubernetes Network Policy Example (prevents K07 - Network Segmentation):**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  # Deny all ingress/egress by default
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-api
spec:
  podSelector:
    matchLabels:
      tier: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 8080
```

---

## Part 4: Interview Talking Points

### Question: "Walk us through OWASP Top 10 and which ones you've encountered."

**Answer Template:**

"I consider OWASP Top 10 essential knowledge. It represents the most critical risks we encounter:

**Injection (Top 3 risk):** I've found SQL injection vulnerabilities in code reviews. The fix is simple—parameterized queries instead of string concatenation. I enforce this in code review and SAST scanning.

**Broken Access Control (most common):** More than half of breaches involve access control flaws. I implement least-privilege IAM policies. Every user/role gets minimal permissions needed. AWS Access Analyzer helps identify overly permissive access.

**Cryptographic Failures:** Data must be encrypted. I enable encryption on every storage service: S3 with KMS, RDS encrypted, EBS encryption by default. No exceptions.

**Security Misconfiguration:** The #1 cause of cloud breaches. I use Infrastructure as Code with secure baselines. Every resource inherits encryption and logging.

**Vulnerable Components:** I use SCA tools (Snyk) scanning dependencies continuously. When Log4Shell was discovered, we identified affected systems in hours due to automated monitoring.

**Insufficient Logging:** CloudTrail and GuardDuty are non-negotiable. I set metric filters for suspicious patterns, creating alerts that trigger immediately.

**Example incident:** We detected a brute force attack via CloudWatch alarms monitoring failed login attempts. Within 5 minutes, we saw the pattern and blocked the IP. Without comprehensive logging, this would have gone undetected."

---

## Implementation Checklist

### For Web Applications
- [ ] SAST/DAST in CI/CD for all code changes
- [ ] SCA monitoring all dependencies
- [ ] Parameterized queries for all database access
- [ ] AWS WAF protecting all public APIs
- [ ] MFA enforced for all user accounts
- [ ] Encryption enabled for all data (at rest and transit)
- [ ] AWS Config checking for misconfigurations
- [ ] CloudTrail enabled with encryption
- [ ] GuardDuty detecting threats
- [ ] Regular penetration testing

### For Kubernetes Environments
- [ ] Pod Security Standards enforced
- [ ] Network policies for segmentation
- [ ] RBAC with least privilege
- [ ] OPA/Kyverno policy enforcement
- [ ] Image scanning and signing
- [ ] Centralized logging from all pods
- [ ] Secrets stored in external manager
- [ ] CIS benchmark compliance
- [ ] Regular updates to Kubernetes version
- [ ] Service mesh for mTLS

---

## Key Takeaways

> **OWASP Top 10 represents the most critical risks. Addressing these 10 areas eliminates majority of common vulnerabilities.**

1. Broken Access Control is most common (implement least privilege)
2. Injection requires parameterized queries (no string concatenation)
3. Cryptographic Failures = always encrypt (no exceptions)
4. Misconfiguration is #1 cloud breach cause (use IaC defaults)
5. Vulnerable Components require continuous monitoring (SCA tools)
6. Insufficient Logging hides breaches (CloudTrail mandatory)
7. OWASP Top 10 applies to both web and Kubernetes
8. Prevention requires defense-in-depth (multiple layers)
9. Regular testing validates controls (SAST/DAST/penetration testing)
10. Compliance frameworks (PCI-DSS, HIPAA, SOX) require OWASP coverage
