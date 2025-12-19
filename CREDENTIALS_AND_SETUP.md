# Credentials & Environment Setup

## Prerequisites

### Required Tools
```bash
# Terraform >= 1.5
terraform version

# AWS CLI v2
aws --version

# Python 3.9+
python3 --version

# Docker (for container scanning)
docker --version

# jq (JSON processing)
jq --version

# Git
git --version
```

### Installation (macOS/Linux)
```bash
# Terraform
brew install terraform

# AWS CLI
brew install awscli

# Python 3.9+
brew install python@3.11

# Docker
brew install docker

# jq
brew install jq
```

---

## AWS Account Structure

### Recommended Multi-Account Setup

```
AWS Organization (Root)
├── Management Account (Billing, Organizations)
├── Security Account (Central logging, threat detection, compliance)
│   ├── CloudTrail (multi-region)
│   ├── AWS Config (aggregator)
│   ├── GuardDuty (delegated admin)
│   ├── SecurityHub (delegated admin)
│   ├── OpenSearch (SIEM)
│   └── Lambda (playbooks)
├── Production Account (Workloads)
│   ├── EC2, RDS, S3, etc.
│   └── CloudTrail → Security Account
├── Development Account (Workloads)
│   ├── EC2, RDS, S3, etc.
│   └── CloudTrail → Security Account
└── Sandbox Account (Testing)
    ├── Purple team exercises
    └── Attack simulation
```

### Account IDs (Replace with Your Values)

Create a `.env` file in the project root:

```bash
# AWS Account IDs
export AWS_MANAGEMENT_ACCOUNT_ID="111111111111"
export AWS_SECURITY_ACCOUNT_ID="222222222222"
export AWS_PROD_ACCOUNT_ID="333333333333"
export AWS_DEV_ACCOUNT_ID="444444444444"
export AWS_SANDBOX_ACCOUNT_ID="555555555555"

# AWS Region
export AWS_REGION="us-east-1"
export AWS_SECONDARY_REGION="us-west-2"

# Project naming
export PROJECT_NAME="rackspace-soc"
export ENVIRONMENT="prod"

# Security settings
export ENABLE_GUARDDUTY="true"
export ENABLE_SECURITYHUB="true"
export ENABLE_OPENSEARCH="true"
export ENABLE_LAMBDA_PLAYBOOKS="true"

# OpenSearch (SIEM)
export OPENSEARCH_DOMAIN_NAME="rackspace-soc-siem"
export OPENSEARCH_VERSION="2.11"
export OPENSEARCH_NODE_COUNT="3"
export OPENSEARCH_INSTANCE_TYPE="t3.medium.search"

# Notifications
export SNS_EMAIL="security-team@example.com"
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# ServiceNow (optional)
export SERVICENOW_INSTANCE="dev12345.service-now.com"
export SERVICENOW_API_USER="<api_user>"
export SERVICENOW_API_PASSWORD="<api_password>"

# Compliance settings
export ENABLE_CIS_BENCHMARK="true"
export ENABLE_PCI_DSS="true"
export ENABLE_HIPAA="false"

# Cost tracking
export COST_ALLOCATION_TAG="rackspace-soc"
```

---

## AWS IAM Setup

### 1. Enable AWS Organizations (Management Account)

```bash
aws organizations describe-organization

# If not enabled:
aws organizations create-organization --feature-set ALL
```

### 2. Create Security Account (if not exists)

```bash
# In Management Account
aws organizations create-account \
  --account-name "Security" \
  --email "security-account@example.com"

# Note the AccountId from response
```

### 3. Cross-Account IAM Roles

#### In Security Account: Create role for Terraform

```bash
# Create trust policy
cat > /tmp/trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${AWS_MANAGEMENT_ACCOUNT_ID}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create role
aws iam create-role \
  --role-name TerraformSecurityRole \
  --assume-role-policy-document file:///tmp/trust-policy.json

# Attach admin policy (for demo; use least privilege in production)
aws iam attach-role-policy \
  --role-name TerraformSecurityRole \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

#### In Management Account: Create role for cross-account access

```bash
# Create trust policy for Security Account
cat > /tmp/trust-policy-mgmt.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${AWS_SECURITY_ACCOUNT_ID}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create role
aws iam create-role \
  --role-name SecurityAccountAccessRole \
  --assume-role-policy-document file:///tmp/trust-policy-mgmt.json

# Attach policy for Organizations access
aws iam put-role-policy \
  --role-name SecurityAccountAccessRole \
  --policy-name OrganizationsAccess \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "organizations:Describe*",
          "organizations:List*"
        ],
        "Resource": "*"
      }
    ]
  }'
```

### 4. Configure AWS CLI Profiles

```bash
# Add to ~/.aws/config
[profile security]
role_arn = arn:aws:iam::222222222222:role/TerraformSecurityRole
source_profile = default
region = us-east-1

[profile prod]
role_arn = arn:aws:iam::333333333333:role/TerraformRole
source_profile = default
region = us-east-1

[profile dev]
role_arn = arn:aws:iam::444444444444:role/TerraformRole
source_profile = default
region = us-east-1

[profile sandbox]
role_arn = arn:aws:iam::555555555555:role/TerraformRole
source_profile = default
region = us-east-1
```

### 5. Test Cross-Account Access

```bash
# Test Security Account access
aws sts get-caller-identity --profile security

# Expected output:
# {
#     "UserId": "AIDAI...",
#     "Account": "222222222222",
#     "Arn": "arn:aws:iam::222222222222:role/TerraformSecurityRole"
# }
```

---

## Terraform Backend Setup

### 1. Create S3 Backend Bucket (Management Account)

```bash
# Create bucket for Terraform state
aws s3api create-bucket \
  --bucket rackspace-soc-terraform-state \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket rackspace-soc-terraform-state \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket rackspace-soc-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket rackspace-soc-terraform-state \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

### 2. Create DynamoDB Lock Table

```bash
aws dynamodb create-table \
  --table-name rackspace-soc-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### 3. Configure Terraform Backend

Create `backend.tf` in each phase directory:

```hcl
terraform {
  backend "s3" {
    bucket         = "rackspace-soc-terraform-state"
    key            = "phase-1/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "rackspace-soc-terraform-locks"
  }
}
```

---

## Python Environment Setup

### 1. Create Virtual Environment

```bash
cd /home/papaert/projects/lab/RACKSPACE_MANAGED_SECURITY_PROJECT

python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# or
venv\Scripts\activate  # Windows
```

### 2. Install Dependencies

```bash
pip install --upgrade pip

# Core dependencies
pip install boto3 botocore

# SIEM/Analytics
pip install opensearch-py opensearch-dsl

# Utilities
pip install python-dotenv requests pyyaml

# Testing
pip install pytest pytest-cov moto

# Development
pip install black flake8 mypy

# Create requirements.txt
pip freeze > requirements.txt
```

### 3. Create requirements.txt

```
boto3==1.28.85
botocore==1.31.85
opensearch-py==2.3.1
opensearch-dsl==2.1.0
python-dotenv==1.0.0
requests==2.31.0
pyyaml==6.0.1
pytest==7.4.3
pytest-cov==4.1.0
moto==4.2.9
black==23.12.0
flake8==6.1.0
mypy==1.7.1
```

---

## Environment Variables (.env)

### Create `.env` file in project root

```bash
# Copy template
cp .env.example .env

# Edit with your values
nano .env
```

### Required Variables

```bash
# AWS
AWS_REGION=us-east-1
AWS_SECURITY_ACCOUNT_ID=222222222222
AWS_PROD_ACCOUNT_ID=333333333333
AWS_DEV_ACCOUNT_ID=444444444444
AWS_SANDBOX_ACCOUNT_ID=555555555555

# Project
PROJECT_NAME=rackspace-soc
ENVIRONMENT=prod

# OpenSearch
OPENSEARCH_DOMAIN=rackspace-soc-siem
OPENSEARCH_ENDPOINT=https://rackspace-soc-siem.us-east-1.es.amazonaws.com
OPENSEARCH_USERNAME=admin
OPENSEARCH_PASSWORD=<generated_password>

# Notifications
SNS_TOPIC_ARN=arn:aws:sns:us-east-1:222222222222:rackspace-soc-alerts
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# ServiceNow (optional)
SERVICENOW_INSTANCE=dev12345.service-now.com
SERVICENOW_API_USER=api_user
SERVICENOW_API_PASSWORD=<api_password>

# Compliance
ENABLE_CIS=true
ENABLE_PCI=true
ENABLE_HIPAA=false

# Cost tracking
COST_TAG=rackspace-soc
```

---

## Validation Checklist

Before starting Phase 1, verify:

- [ ] AWS CLI configured with correct profiles
- [ ] Cross-account IAM roles created and tested
- [ ] S3 backend bucket created and encrypted
- [ ] DynamoDB lock table created
- [ ] Terraform installed (>= 1.5)
- [ ] Python 3.9+ with venv activated
- [ ] `.env` file created with all required variables
- [ ] AWS credentials have appropriate permissions
- [ ] Docker installed (for container scanning)
- [ ] Git configured for version control

### Quick Validation Script

```bash
#!/bin/bash
set -e

echo "=== AWS CLI ==="
aws --version
aws sts get-caller-identity

echo "=== Terraform ==="
terraform version

echo "=== Python ==="
python3 --version
pip list | grep boto3

echo "=== AWS Accounts ==="
echo "Security Account: $AWS_SECURITY_ACCOUNT_ID"
echo "Prod Account: $AWS_PROD_ACCOUNT_ID"
echo "Dev Account: $AWS_DEV_ACCOUNT_ID"

echo "=== S3 Backend ==="
aws s3 ls rackspace-soc-terraform-state

echo "=== DynamoDB Lock Table ==="
aws dynamodb describe-table --table-name rackspace-soc-terraform-locks

echo "✅ All prerequisites validated!"
```

Save as `validate_setup.sh` and run:

```bash
chmod +x validate_setup.sh
./validate_setup.sh
```

---

## Troubleshooting

### Issue: "Unable to assume role"
**Solution:** Verify trust policy in target account includes your principal ARN.

### Issue: "S3 bucket already exists"
**Solution:** Use globally unique bucket name (add timestamp or account ID).

### Issue: "Terraform state lock timeout"
**Solution:** Check DynamoDB table exists and is accessible.

### Issue: "Python boto3 import error"
**Solution:** Ensure venv is activated and boto3 installed: `pip install boto3`

### Issue: "AWS credentials not found"
**Solution:** Configure AWS CLI: `aws configure` or set `AWS_PROFILE` environment variable.

---

## Next Steps

1. Complete all validation checks above
2. Proceed to **Phase 1: Foundation** in `phase-1-foundation/`
3. Document setup in `DEVELOPER_JOURNAL.md`
4. Store evidence (screenshots, outputs) in `phase-1-foundation/evidence/`

---

**Last Updated:** 2025-01-XX  
**Status:** Ready for Implementation
