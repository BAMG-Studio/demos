# Compliance Control Implementation: Hands-On Code Examples

> **Quick Reference:** Don't just understand compliance frameworks—implement the actual controls. This guide shows concrete Python and Bash code for real compliance requirements.

---

## Part 1: Understanding the Compliance Landscape

### Major Compliance Frameworks

| Framework | Focus | Key Requirements | Cloud-Specific |
|-----------|-------|------------------|---|
| **NIST 800-53** | Federal government info security | 20 control families (AC, AU, CM, CP, etc.) | Very detailed |
| **PCI-DSS** | Payment Card Industry | 12 requirements for payment data | Moderate, mostly traditional |
| **HIPAA** | Healthcare data protection | 3 rules (Privacy, Security, Breach) | Heavily cloud-focused now |
| **SOX** | Financial reporting controls | IT general controls for financial data | Moderate |
| **ISO 27001** | General info security | 14 categories, 114 controls | Generic (not AWS-specific) |
| **CIS Benchmarks** | Security hardening standards | Configuration baselines | Very AWS-specific |

### The Control Implementation Lifecycle

```
1. Requirement: "Encrypt all data at rest"
         ↓
2. Design: "Use AES-256 with KMS"
         ↓
3. Implementation: Write code to enable KMS
         ↓
4. Verification: Prove it's enabled (script + screenshot)
         ↓
5. Testing: Actually encrypt/decrypt to verify
         ↓
6. Monitoring: Continuous checks for compliance drift
         ↓
7. Audit: Provide evidence to auditors
         ↓
8. Remediation: Fix any drift found
```

---

## Part 2: NIST 800-53 Implementations

### NIST SC-28: Protection of Information at Rest

**Requirement:** "Encrypt all sensitive information at rest"

#### Implementation: S3 Encryption

```python
import boto3
import json
from datetime import datetime

def implement_s3_encryption(bucket_name, kms_key_id):
    """
    Implement NIST SC-28: Encrypt S3 buckets
    """
    
    s3_client = boto3.client('s3')
    
    print(f"[{datetime.utcnow()}] Implementing S3 encryption for {bucket_name}")
    
    try:
        # Enable default encryption (all uploads encrypted automatically)
        s3_client.put_bucket_encryption(
            Bucket=bucket_name,
            ServerSideEncryptionConfiguration={
                'Rules': [{
                    'ApplyServerSideEncryptionByDefault': {
                        'SSEAlgorithm': 'aws:kms',
                        'KMSMasterKeyID': kms_key_id
                    },
                    'BucketKeyEnabled': True  # Reduces KMS API calls, faster
                }]
            }
        )
        print(f"[✓] S3 default encryption enabled (KMS)")
        
        # Enforce HTTPS only (encrypts in transit)
        bucket_policy = {
            'Version': '2012-10-17',
            'Statement': [{
                'Sid': 'EnforceHTTPS',
                'Effect': 'Deny',
                'Principal': '*',
                'Action': 's3:*',
                'Resource': [
                    f'arn:aws:s3:::{bucket_name}',
                    f'arn:aws:s3:::{bucket_name}/*'
                ],
                'Condition': {
                    'Bool': {'aws:SecureTransport': 'false'}
                }
            }]
        }
        
        s3_client.put_bucket_policy(
            Bucket=bucket_name,
            Policy=json.dumps(bucket_policy)
        )
        print(f"[✓] HTTPS enforcement enabled (in-transit encryption)")
        
        # Verify encryption is actually enabled
        encryption = s3_client.get_bucket_encryption(Bucket=bucket_name)
        
        print(f"""
[VERIFIED] S3 Encryption Configuration:
- Algorithm: {encryption['ServerSideEncryptionConfiguration']['Rules'][0]['ApplyServerSideEncryptionByDefault']['SSEAlgorithm']}
- KMS Key: {encryption['ServerSideEncryptionConfiguration']['Rules'][0]['ApplyServerSideEncryptionByDefault'].get('KMSMasterKeyID', 'AWS-managed')}
- Transport: HTTPS enforced
        """)
        
        return True
        
    except Exception as e:
        print(f"[ERROR] Implementation failed: {str(e)}")
        return False

# Usage
if __name__ == '__main__':
    kms_key = 'arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012'
    implement_s3_encryption('production-data-bucket', kms_key)
```

#### Implementation: RDS Encryption

```python
def implement_rds_encryption(db_instance_id, kms_key_id):
    """
    Implement NIST SC-28: Encrypt RDS databases
    NOTE: Must be done at creation time, cannot be enabled on existing unencrypted DB
    """
    
    rds_client = boto3.client('rds')
    
    print(f"[{datetime.utcnow()}] Checking RDS encryption: {db_instance_id}")
    
    # Check if encrypted
    response = rds_client.describe_db_instances(
        DBInstanceIdentifier=db_instance_id
    )
    
    db = response['DBInstances'][0]
    is_encrypted = db['StorageEncrypted']
    
    if is_encrypted:
        print(f"[✓] RDS {db_instance_id} is encrypted")
        kms_key = db.get('KmsKeyId', 'AWS-managed key')
        print(f"    KMS Key: {kms_key}")
        return True
    
    else:
        print(f"[X] RDS {db_instance_id} is NOT encrypted")
        print(f"[ACTION REQUIRED] Create encrypted RDS snapshot and restore:")
        
        # Create snapshot
        snapshot_id = f"{db_instance_id}-encrypted-{datetime.utcnow().strftime('%Y%m%d')}"
        
        print(f"""
Steps to remediate:
1. Create snapshot: 
   aws rds create-db-snapshot --db-instance-identifier {db_instance_id} --db-snapshot-identifier {snapshot_id}

2. Restore from snapshot with encryption:
   aws rds restore-db-instance-from-db-snapshot \\
     --db-instance-identifier {db_instance_id}-encrypted \\
     --db-snapshot-identifier {snapshot_id} \\
     --storage-encrypted \\
     --kms-key-id {kms_key_id}

3. Verify encryption:
   aws rds describe-db-instances --db-instance-identifier {db_instance_id}-encrypted
        """)
        
        return False

# Usage
if __name__ == '__main__':
    kms_key = 'arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012'
    implement_rds_encryption('production-database', kms_key)
```

#### Implementation: EBS Encryption

```python
def implement_ebs_encryption_by_default():
    """
    Implement NIST SC-28: Enable EBS encryption by default
    All new EBS volumes will be encrypted automatically
    """
    
    ec2_client = boto3.client('ec2')
    
    print(f"[{datetime.utcnow()}] Implementing EBS encryption by default")
    
    try:
        # Enable encryption by default at account level
        ec2_client.enable_ebs_encryption_by_default()
        
        print(f"[✓] EBS encryption by default enabled")
        
        # Verify
        response = ec2_client.get_ebs_encryption_by_default()
        
        if response['EbsEncryptionByDefault']:
            print(f"[VERIFIED] All new EBS volumes will be encrypted")
            return True
        else:
            print(f"[ERROR] Verification failed")
            return False
            
    except Exception as e:
        print(f"[ERROR] {str(e)}")
        return False

# Usage
if __name__ == '__main__':
    implement_ebs_encryption_by_default()
```

---

### NIST AC-2: Account Management

**Requirement:** "Manage user accounts and enforce access controls"

```python
def implement_account_management():
    """
    Implement NIST AC-2: Account Management
    - Strong password policy
    - MFA enforcement
    - Credential rotation
    """
    
    iam_client = boto3.client('iam')
    
    print(f"[{datetime.utcnow()}] Implementing account management controls")
    
    try:
        # Step 1: Enforce strong password policy
        iam_client.update_account_password_policy(
            MinimumPasswordLength=14,
            RequireSymbols=True,
            RequireNumbers=True,
            RequireUppercaseCharacters=True,
            RequireLowercaseCharacters=True,
            AllowUsersToChangePassword=True,
            ExpirePasswords=True,
            MaxPasswordAge=90,
            PasswordReusePrevention=12
        )
        print(f"[✓] Strong password policy enforced (14 chars, complexity, 90-day rotation)")
        
        # Step 2: Check for MFA on all console users
        users_without_mfa = []
        
        for user in iam_client.list_users()['Users']:
            username = user['UserName']
            
            # Skip service accounts
            if username.startswith('svc-'):
                continue
            
            # Check for virtual MFA device
            mfa_devices = iam_client.list_mfa_devices(UserName=username)['MFADevices']
            
            if not mfa_devices:
                users_without_mfa.append(username)
        
        if users_without_mfa:
            print(f"[!] {len(users_without_mfa)} users missing MFA: {users_without_mfa}")
            print(f"[ACTION] Enable MFA for these users:")
            
            for user in users_without_mfa:
                print(f"  aws iam enable-mfa-device --user-name {user}")
        else:
            print(f"[✓] All console users have MFA enabled")
        
        # Step 3: Check for old access keys
        old_keys = []
        
        for user in iam_client.list_users()['Users']:
            username = user['UserName']
            
            keys = iam_client.list_access_keys(UserName=username)['AccessKeyMetadata']
            
            for key in keys:
                # Check if key is older than 90 days
                key_age = datetime.utcnow() - key['CreateDate'].replace(tzinfo=None)
                
                if key_age.days > 90:
                    old_keys.append({
                        'username': username,
                        'key_id': key['AccessKeyId'],
                        'age_days': key_age.days
                    })
        
        if old_keys:
            print(f"[!] {len(old_keys)} access keys older than 90 days:")
            
            for old_key in old_keys:
                print(f"  User: {old_key['username']}, Key: {old_key['key_id']}, Age: {old_key['age_days']} days")
                print(f"  Action: aws iam update-access-key --access-key-id {old_key['key_id']} --user-name {old_key['username']} --status Inactive")
        else:
            print(f"[✓] All access keys are current (< 90 days old)")
        
        # Step 4: Check for unused accounts
        unused_users = []
        
        for user in iam_client.list_users()['Users']:
            username = user['UserName']
            
            try:
                # Get access key last used
                keys = iam_client.list_access_keys(UserName=username)['AccessKeyMetadata']
                
                for key in keys:
                    last_used = iam_client.get_access_key_last_used(
                        AccessKeyId=key['AccessKeyId']
                    )
                    
                    if 'LastUsedDate' in last_used['AccessKeyLastUsed']:
                        last_used_date = last_used['AccessKeyLastUsed']['LastUsedDate'].replace(tzinfo=None)
                        days_since_used = (datetime.utcnow() - last_used_date).days
                        
                        if days_since_used > 90:
                            unused_users.append({
                                'username': username,
                                'days_unused': days_since_used
                            })
            except:
                pass
        
        if unused_users:
            print(f"[!] {len(unused_users)} users unused for > 90 days:")
            
            for unused in unused_users:
                print(f"  {unused['username']}: {unused['days_unused']} days")
                print(f"  Action: Deactivate or delete user")
        else:
            print(f"[✓] All users are actively used")
        
        print(f"""
[SUMMARY] NIST AC-2 Account Management:
✓ Strong password policy
✓ MFA enforcement
✓ Credential rotation (90-day max age)
✓ Unused account detection

Actions Required:
- Enable MFA for {len(users_without_mfa)} users
- Rotate {len(old_keys)} old access keys
- Deactivate {len(unused_users)} unused accounts
        """)
        
        return True
        
    except Exception as e:
        print(f"[ERROR] {str(e)}")
        return False

# Usage
if __name__ == '__main__':
    implement_account_management()
```

---

## Part 3: PCI-DSS Implementations

### PCI-DSS Requirement 3: Protect Stored Cardholder Data

**Requirement:** "Encrypt all stored payment card data"

```python
def implement_pci_dss_data_protection():
    """
    Implement PCI-DSS Requirement 3: Protect stored cardholder data
    - Encrypt card numbers
    - Use tokenization where possible
    - Restrict access
    """
    
    kms_client = boto3.client('kms')
    s3_client = boto3.client('s3')
    
    print(f"[{datetime.utcnow()}] Implementing PCI-DSS Requirement 3")
    
    # Create dedicated KMS key for PCI data (with strong controls)
    key_policy = {
        'Version': '2012-10-17',
        'Statement': [
            {
                'Sid': 'Enable IAM policies',
                'Effect': 'Allow',
                'Principal': {'AWS': f'arn:aws:iam::123456789012:root'},
                'Action': 'kms:*',
                'Resource': '*'
            },
            {
                'Sid': 'Allow use of the key for payment system',
                'Effect': 'Allow',
                'Principal': {
                    'AWS': 'arn:aws:iam::123456789012:role/payment-processing-role'
                },
                'Action': [
                    'kms:Decrypt',
                    'kms:DescribeKey'
                ],
                'Resource': '*'
            }
        ]
    }
    
    try:
        # Create CMK (Customer Master Key)
        key_response = kms_client.create_key(
            Description='PCI-DSS cardholder data encryption key',
            KeyUsage='ENCRYPT_DECRYPT',
            Origin='AWS_KMS',
            MultiRegion=False,
            Policy=json.dumps(key_policy)
        )
        
        key_id = key_response['KeyMetadata']['KeyId']
        print(f"[✓] Created KMS key for PCI data: {key_id}")
        
        # Enable key rotation
        kms_client.enable_key_rotation(KeyId=key_id)
        print(f"[✓] Key rotation enabled (annual)")
        
        # Create S3 bucket for encrypted card data (separate from other data)
        bucket_name = f'pci-encrypted-data-{datetime.utcnow().strftime("%Y%m%d%H%M%S")}'
        
        s3_client.create_bucket(Bucket=bucket_name)
        print(f"[✓] Created PCI data bucket: {bucket_name}")
        
        # Apply strict controls
        
        # 1. Enable encryption with KMS
        s3_client.put_bucket_encryption(
            Bucket=bucket_name,
            ServerSideEncryptionConfiguration={
                'Rules': [{
                    'ApplyServerSideEncryptionByDefault': {
                        'SSEAlgorithm': 'aws:kms',
                        'KMSMasterKeyID': key_id
                    }
                }]
            }
        )
        print(f"[✓] Bucket encryption enabled")
        
        # 2. Block public access
        s3_client.put_public_access_block(
            Bucket=bucket_name,
            PublicAccessBlockConfiguration={
                'BlockPublicAcls': True,
                'IgnorePublicAcls': True,
                'BlockPublicPolicy': True,
                'RestrictPublicBuckets': True
            }
        )
        print(f"[✓] Public access blocked")
        
        # 3. Enable versioning (audit trail)
        s3_client.put_bucket_versioning(
            Bucket=bucket_name,
            VersioningConfiguration={'Status': 'Enabled'}
        )
        print(f"[✓] Versioning enabled")
        
        # 4. Enable access logging
        s3_client.put_bucket_logging(
            Bucket=bucket_name,
            BucketLoggingStatus={
                'LoggingEnabled': {
                    'TargetBucket': f'{bucket_name}-logs',
                    'TargetPrefix': 'access-logs/'
                }
            }
        )
        print(f"[✓] Access logging enabled")
        
        # 5. Restrict access policy
        bucket_policy = {
            'Version': '2012-10-17',
            'Statement': [
                {
                    'Sid': 'Allow payment processing role only',
                    'Effect': 'Allow',
                    'Principal': {
                        'AWS': 'arn:aws:iam::123456789012:role/payment-processing-role'
                    },
                    'Action': [
                        's3:GetObject',
                        's3:PutObject'
                    ],
                    'Resource': f'arn:aws:s3:::{bucket_name}/*'
                },
                {
                    'Sid': 'Deny unencrypted uploads',
                    'Effect': 'Deny',
                    'Principal': '*',
                    'Action': 's3:PutObject',
                    'Resource': f'arn:aws:s3:::{bucket_name}/*',
                    'Condition': {
                        'StringNotEquals': {
                            's3:x-amz-server-side-encryption': 'aws:kms'
                        }
                    }
                }
            ]
        }
        
        s3_client.put_bucket_policy(
            Bucket=bucket_name,
            Policy=json.dumps(bucket_policy)
        )
        print(f"[✓] Restrictive bucket policy applied")
        
        print(f"""
[PCI-DSS REQUIREMENT 3 - IMPLEMENTED]
✓ Cardholder data encrypted with CMK
✓ Key rotation enabled
✓ Public access blocked
✓ Access logging enabled
✓ Versioning enabled
✓ Only authorized role can access
✓ Unencrypted uploads denied

Bucket: {bucket_name}
KMS Key: {key_id}
        """)
        
        return True
        
    except Exception as e:
        print(f"[ERROR] {str(e)}")
        return False

# Usage
if __name__ == '__main__':
    implement_pci_dss_data_protection()
```

---

## Part 4: HIPAA Implementations

### HIPAA Security Rule: Access Controls

```python
def implement_hipaa_access_controls():
    """
    Implement HIPAA Security Rule: Access Controls
    - User access management
    - Emergency access procedures
    - Termination procedures
    """
    
    iam_client = boto3.client('iam')
    
    print(f"[{datetime.utcnow()}] Implementing HIPAA Access Controls")
    
    # 1. User access approval process (document, don't code)
    # 2. Role-based access (technical implementation)
    
    try:
        # Create HIPAA-specific roles
        roles_config = {
            'hipaa-clinician': {
                'description': 'Clinical staff - access to patient records',
                'allowed_actions': [
                    's3:GetObject',  # Read patient data
                    'dynamodb:GetItem',
                    'dynamodb:Query'
                ],
                'restricted_resources': [
                    'arn:aws:s3:::phi-data-bucket/clinical/*',
                    'arn:aws:dynamodb:*:123456789012:table/PatientRecords'
                ]
            },
            'hipaa-billing': {
                'description': 'Billing staff - access to billing records',
                'allowed_actions': [
                    's3:GetObject',
                    'dynamodb:GetItem',
                    'dynamodb:Query'
                ],
                'restricted_resources': [
                    'arn:aws:s3:::phi-data-bucket/billing/*',
                    'arn:aws:dynamodb:*:123456789012:table/BillingRecords'
                ]
            },
            'hipaa-admin': {
                'description': 'IT admin - full access for maintenance',
                'allowed_actions': ['*'],
                'restricted_resources': ['*'],
                'require_mfa': True,
                'require_approval': True
            }
        }
        
        for role_name, role_config in roles_config.items():
            # Create role
            trust_policy = {
                'Version': '2012-10-17',
                'Statement': [{
                    'Effect': 'Allow',
                    'Principal': {'AWS': 'arn:aws:iam::123456789012:root'},
                    'Action': 'sts:AssumeRole'
                }]
            }
            
            try:
                iam_client.create_role(
                    RoleName=role_name,
                    AssumeRolePolicyDocument=json.dumps(trust_policy),
                    Description=role_config['description']
                )
                print(f"[✓] Created role: {role_name}")
            except iam_client.exceptions.EntityAlreadyExistsException:
                print(f"[!] Role already exists: {role_name}")
            
            # Attach inline policy
            policy = {
                'Version': '2012-10-17',
                'Statement': [{
                    'Effect': 'Allow',
                    'Action': role_config['allowed_actions'],
                    'Resource': role_config['restricted_resources']
                }]
            }
            
            iam_client.put_role_policy(
                RoleName=role_name,
                PolicyName=f'{role_name}-policy',
                PolicyDocument=json.dumps(policy)
            )
            print(f"[✓] Attached policy to: {role_name}")
        
        print(f"""
[HIPAA ACCESS CONTROLS - IMPLEMENTED]
✓ Role-based access control (RBAC)
✓ Separation of duties (clinical, billing, admin)
✓ Least privilege access
✓ Restriction to specific resources

Roles Created:
- hipaa-clinician: Read clinical records only
- hipaa-billing: Read billing records only
- hipaa-admin: Full access (requires MFA + approval)
        """)
        
        return True
        
    except Exception as e:
        print(f"[ERROR] {str(e)}")
        return False

# Usage
if __name__ == '__main__':
    implement_hipaa_access_controls()
```

---

## Part 5: Audit Logging for Compliance

### CloudTrail Configuration for Compliance

```bash
#!/bin/bash

# Implement comprehensive CloudTrail logging for compliance

echo "[$(date)] Implementing CloudTrail for compliance"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=us-east-1
S3_BUCKET="cloudtrail-logs-${ACCOUNT_ID}"
KMS_KEY_ID="arn:aws:kms:${REGION}:${ACCOUNT_ID}:key/your-key-id"

# Create S3 bucket for CloudTrail logs
echo "[*] Creating S3 bucket for CloudTrail logs"
aws s3 mb "s3://${S3_BUCKET}" --region ${REGION}

# Enable versioning (keep all versions)
aws s3api put-bucket-versioning \
  --bucket ${S3_BUCKET} \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket ${S3_BUCKET} \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "'${KMS_KEY_ID}'"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket ${S3_BUCKET} \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Create CloudTrail
echo "[*] Creating CloudTrail"
aws cloudtrail create-trail \
  --name organization-trail \
  --s3-bucket-name ${S3_BUCKET} \
  --is-organization-trail \
  --is-multi-region-trail \
  --include-global-service-events \
  --enable-log-file-validation \
  --region ${REGION}

# Enable logging
aws cloudtrail start-logging \
  --trail-name organization-trail \
  --region ${REGION}

# Enable data events (more detailed, higher cost)
aws cloudtrail put-event-selectors \
  --trail-name organization-trail \
  --event-selectors ReadWriteType=All,IncludeManagementEvents=true,DataResources='[{Type=AWS::S3::Object,Values=[arn:aws:s3:::*]},{Type=AWS::Lambda::Function,Values=[arn:aws:lambda:*:*:function/*]}]' \
  --region ${REGION}

echo "[✓] CloudTrail configured for compliance"
echo "     - Multi-region enabled"
echo "     - Log file validation enabled"
echo "     - Encryption enabled"
echo "     - Data events enabled"
echo "     - Logs retained indefinitely"
```

---

## Part 6: Compliance Verification Script

```python
import boto3
from datetime import datetime, timedelta
import json

def audit_compliance_controls():
    """
    Comprehensive audit of compliance controls
    Suitable for presenting to auditors
    """
    
    s3_client = boto3.client('s3')
    kms_client = boto3.client('kms')
    ec2_client = boto3.client('ec2')
    rds_client = boto3.client('rds')
    
    audit_report = {
        'timestamp': datetime.utcnow().isoformat(),
        'controls': {}
    }
    
    print(f"\n{'='*60}")
    print("COMPLIANCE AUDIT REPORT")
    print(f"{'='*60}\n")
    
    # Control 1: S3 Encryption (SC-28)
    print("[NIST SC-28] S3 Data Protection at Rest")
    print("-" * 60)
    
    s3_buckets = s3_client.list_buckets()['Buckets']
    unencrypted_buckets = []
    
    for bucket in s3_buckets:
        bucket_name = bucket['Name']
        
        try:
            encryption = s3_client.get_bucket_encryption(Bucket=bucket_name)
            is_encrypted = True
        except s3_client.exceptions.ServerSideEncryptionConfigurationNotFoundError:
            is_encrypted = False
            unencrypted_buckets.append(bucket_name)
        
        status = "✓ ENCRYPTED" if is_encrypted else "✗ NOT ENCRYPTED"
        print(f"  {bucket_name}: {status}")
    
    audit_report['controls']['s3_encryption'] = {
        'status': 'PASS' if not unencrypted_buckets else 'FAIL',
        'encrypted_buckets': len(s3_buckets) - len(unencrypted_buckets),
        'unencrypted_buckets': unencrypted_buckets
    }
    
    # Control 2: EBS Encryption (SC-28)
    print("\n[NIST SC-28] EBS Data Protection at Rest")
    print("-" * 60)
    
    ebs_default_encrypted = ec2_client.get_ebs_encryption_by_default()['EbsEncryptionByDefault']
    
    if ebs_default_encrypted:
        print("  ✓ EBS encryption by default: ENABLED")
    else:
        print("  ✗ EBS encryption by default: DISABLED")
    
    # Check individual volumes
    volumes = ec2_client.describe_volumes()['Volumes']
    unencrypted_volumes = [v['VolumeId'] for v in volumes if not v['Encrypted']]
    
    audit_report['controls']['ebs_encryption'] = {
        'status': 'PASS' if ebs_default_encrypted and not unencrypted_volumes else 'FAIL',
        'default_encryption': ebs_default_encrypted,
        'unencrypted_volumes': unencrypted_volumes
    }
    
    # Control 3: RDS Encryption (SC-28)
    print("\n[NIST SC-28] RDS Data Protection at Rest")
    print("-" * 60)
    
    databases = rds_client.describe_db_instances()['DBInstances']
    unencrypted_dbs = []
    
    for db in databases:
        db_id = db['DBInstanceIdentifier']
        is_encrypted = db['StorageEncrypted']
        
        status = "✓ ENCRYPTED" if is_encrypted else "✗ NOT ENCRYPTED"
        print(f"  {db_id}: {status}")
        
        if not is_encrypted:
            unencrypted_dbs.append(db_id)
    
    audit_report['controls']['rds_encryption'] = {
        'status': 'PASS' if not unencrypted_dbs else 'FAIL',
        'unencrypted_databases': unencrypted_dbs
    }
    
    # Control 4: CloudTrail Enabled (AU-2)
    print("\n[NIST AU-2] Audit Logging and Accountability")
    print("-" * 60)
    
    import boto3
    cloudtrail = boto3.client('cloudtrail')
    
    trails = cloudtrail.describe_trails()['trailList']
    logging_trails = 0
    
    for trail in trails:
        is_logging = cloudtrail.get_trail_status(Name=trail['Name'])['IsLogging']
        
        status = "✓ LOGGING" if is_logging else "✗ NOT LOGGING"
        print(f"  {trail['Name']}: {status}")
        
        if is_logging:
            logging_trails += 1
    
    audit_report['controls']['cloudtrail'] = {
        'status': 'PASS' if logging_trails > 0 else 'FAIL',
        'logging_trails': logging_trails,
        'total_trails': len(trails)
    }
    
    # Summary
    print(f"\n{'='*60}")
    print("COMPLIANCE SUMMARY")
    print(f"{'='*60}\n")
    
    passed = sum(1 for control in audit_report['controls'].values() if control['status'] == 'PASS')
    total = len(audit_report['controls'])
    
    print(f"Controls Passed: {passed}/{total}")
    print(f"Overall Status: {'PASS ✓' if passed == total else 'FAIL ✗'}")
    
    # Save report
    report_file = f"compliance-audit-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}.json"
    with open(report_file, 'w') as f:
        json.dump(audit_report, f, indent=2, default=str)
    
    print(f"\nAudit report saved to: {report_file}")
    
    return audit_report

# Usage
if __name__ == '__main__':
    audit_compliance_controls()
```

---

## Part 7: Interview Talking Points

### Question: "How do you ensure compliance with security frameworks like NIST 800-53?"

**Answer:**

"Compliance isn't just about documentation—it's about implementation and verification. My approach has three layers:

**Layer 1: Implementation**
I implement actual controls in code, not just document them. For NIST SC-28 (encryption at rest), I have Python code that:
- Enables S3 encryption with customer-managed KMS keys
- Configures RDS with encrypted storage
- Sets EBS encryption by default
- Verifies encryption is actually enabled

For NIST AC-2 (account management), I automate:
- Strong password policy enforcement
- MFA requirement for console access
- Credential rotation (90-day max age)
- Unused account detection

**Layer 2: Continuous Verification**
I don't assume controls stay in place. I built audit scripts that:
- Scan all S3 buckets for encryption status
- Check RDS databases for encryption
- Verify CloudTrail is logging in all regions
- Identify drift from desired state
- Alert when controls are disabled

**Layer 3: Compliance Evidence**
When auditors come, I don't scramble for evidence. I have:
- Audit reports showing all controls verified
- CloudTrail logs (multiple years archived)
- Configuration screenshots with timestamps
- Compliance mapping document linking controls to implementation

**Example:** For PCI-DSS Requirement 3 (protect stored cardholder data), I:
1. Created dedicated KMS key with access restrictions
2. Enabled automatic encryption on S3 bucket storing card data
3. Blocked public access with multiple layers
4. Enabled access logging
5. Documented that only payment processing role can access
6. Set up CloudWatch alarm if encryption is disabled
7. Every month, run audit script verifying encryption still enabled

**Results:**
- Last audit: Zero findings (passed all controls)
- Continuous monitoring means controls never drift
- Compliance becomes automated, not manual process

**Key principle:** Compliance is like testing—if you wait to verify at the end, you've built wrong. Verify continuously as you build."

---

## Implementation Checklist

**Phase 1: Foundation (Week 1)**
- [ ] Create KMS keys for encryption
- [ ] Enable S3 encryption by default
- [ ] Enable CloudTrail in all regions
- [ ] Document baseline controls

**Phase 2: Data Protection (Week 2)**
- [ ] Implement S3 encryption
- [ ] Implement RDS encryption
- [ ] Implement EBS encryption by default
- [ ] Verify with audit script

**Phase 3: Access Controls (Week 3)**
- [ ] Implement strong password policy
- [ ] Enable MFA for all users
- [ ] Create RBAC roles
- [ ] Document access approval process

**Phase 4: Audit & Monitoring (Week 4)**
- [ ] Configure CloudTrail with data events
- [ ] Set up CloudWatch metric filters
- [ ] Create audit compliance script
- [ ] Schedule monthly verification

**Phase 5: Preparation (Ongoing)**
- [ ] Maintain compliance audit reports
- [ ] Document all changes with dates
- [ ] Test controls quarterly
- [ ] Update controls as requirements change

---

## Key Takeaways

> **Compliance is not optional—it's the price of operating in regulated industries. Automate it and verify continuously.**

1. **Implement actual controls** - Not just documents
2. **Automate verification** - Don't trust manual checks
3. **Continuous monitoring** - Catch drift immediately
4. **Audit trail** - CloudTrail is non-negotiable
5. **Evidence ready** - Auditors should be easy, not hard
6. **Separate encryption keys** - Sensitive data gets own key
7. **Access logging** - Know who accessed what
8. **Retention policies** - Keep logs long enough
9. **Regular testing** - Verify controls work
10. **Documentation** - Clear mapping of controls to implementation
