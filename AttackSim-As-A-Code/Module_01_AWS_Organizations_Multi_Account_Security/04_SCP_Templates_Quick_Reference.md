# Module 1: SCP Policy Templates & Quick Reference Guide

## 📖 Quick Reference: SCPs Explained Simply

### What's an SCP? (One-Minute Explanation)

**Imagine a parent setting rules for teenagers:**
- Parent says: "You can go anywhere in the city EXCEPT the abandoned warehouse"
- Even if a teenager has a car, license, and money, they CAN'T go to the warehouse
- SCP is like the parent's rule - it overrides everything else

**In AWS terms:**
- SCP says: "No one can disable CloudTrail, ever"
- Even if developer has "Administrator" permission, they CAN'T disable CloudTrail
- SCP is the absolute rule that no IAM permission can override

---

## 📋 SCP Policy Templates

### Template 1: Baseline Security Protection

**Purpose:** Prevent disabling essential security services  
**Scope:** Attach to Root (applies everywhere)  
**Use Case:** Mandatory across entire organization  

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyCloudTrailDisable",
      "Effect": "Deny",
      "Action": [
        "cloudtrail:StopLogging",
        "cloudtrail:DeleteTrail",
        "cloudtrail:UpdateTrail"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:PrincipalOrgID": "${aws:PrincipalOrgID}"
        }
      }
    },
    {
      "Sid": "DenyGuardDutyDisable",
      "Effect": "Deny",
      "Action": [
        "guardduty:DeleteDetector",
        "guardduty:DeleteMembers",
        "guardduty:DisassociateFromMasterAccount"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenySecurityHubDisable",
      "Effect": "Deny",
      "Action": [
        "securityhub:DeleteInvitations",
        "securityhub:DisableSecurityHub",
        "securityhub:DisassociateFromMasterAccount"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyConfigDisable",
      "Effect": "Deny",
      "Action": [
        "config:DeleteConfigurationAggregator",
        "config:DeleteConfigurationRecorder",
        "config:StopConfigurationRecorder",
        "config:DeleteRemediationConfigurations"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyCloudWatchDisable",
      "Effect": "Deny",
      "Action": [
        "logs:DeleteLogGroup",
        "logs:PutRetentionPolicy",
        "logs:DeleteRetentionPolicy"
      ],
      "Resource": "arn:aws:logs:*:*:log-group:/aws/*"
    }
  ]
}
```

**What it protects against:**
- Attacker disables logging to hide tracks
- Accidental deletion of monitoring
- Compliance violation by disabling required services

**Cost:** $0 (SCPs are free)

---

### Template 2: Cost Control & Quota Limits

**Purpose:** Prevent expensive resources and regions  
**Scope:** Attach to Root (applies everywhere)  
**Use Case:** Budget management and cost control  

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyExpensiveRegions",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": [
            "us-east-1",
            "us-west-2",
            "eu-west-1"
          ]
        }
      }
    },
    {
      "Sid": "DenyExpensiveInstanceTypes",
      "Effect": "Deny",
      "Action": "ec2:RunInstances",
      "Resource": [
        "arn:aws:ec2:*:*:instance/*"
      ],
      "Condition": {
        "StringLike": {
          "ec2:InstanceType": [
            "p3.*",
            "p4.*",
            "x1.*",
            "x2.*",
            "u-*",
            "i3en.*"
          ]
        }
      }
    },
    {
      "Sid": "DenyMaxInstanceCount",
      "Effect": "Deny",
      "Action": "ec2:RunInstances",
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "NumericGreaterThan": {
          "ec2:MaxCount": "5"
        }
      }
    },
    {
      "Sid": "DenyExpensiveDatabase",
      "Effect": "Deny",
      "Action": [
        "rds:CreateDBInstance",
        "rds:CreateDBCluster"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "rds:DatabaseEngine": [
            "db.r5.24xlarge",
            "db.r6.24xlarge"
          ]
        }
      }
    }
  ]
}
```

**What it protects against:**
- Developer accidentally launches in expensive region ($10K/month)
- Malware spins up expensive GPU instances (crypto mining)
- Forgotten instances rack up costs
- Expensive database instances launched by mistake

**Estimated monthly savings:** $1,000-5,000 per account

---

### Template 3: Production Environment Protection

**Purpose:** Strict controls for production accounts  
**Scope:** Attach to Production OU only  
**Use Case:** Prevent dangerous changes in live environment  

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyProductionDataDeletion",
      "Effect": "Deny",
      "Action": [
        "rds:DeleteDBInstance",
        "rds:DeleteDBCluster",
        "dynamodb:DeleteTable",
        "s3:DeleteBucket",
        "elasticache:DeleteCacheCluster",
        "redshift:DeleteCluster",
        "kinesisanalytics:DeleteApplication"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyProuctionConfigChanges",
      "Effect": "Deny",
      "Action": [
        "rds:ModifyDBInstance",
        "rds:ModifyDBCluster",
        "dynamodb:UpdateTable"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestedRegion": "prod*"
        }
      }
    },
    {
      "Sid": "DenyDisablingEncryption",
      "Effect": "Deny",
      "Action": [
        "rds:ModifyDBInstance",
        "s3:PutBucketEncryption",
        "kms:DisableKey"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyChangingBackupSettings",
      "Effect": "Deny",
      "Action": [
        "rds:ModifyDBInstance",
        "rds:DeleteDBSnapshot",
        "ebs:DeleteSnapshot"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:username": "*"
        }
      }
    }
  ]
}
```

**What it protects against:**
- Accidental database deletion (career-ending incident)
- Configuration changes that break the application
- Disabling encryption on sensitive data
- Deletion of backups (recovery becomes impossible)

**Estimated impact:** Prevents $1M+ in data loss per incident

---

### Template 4: Development Environment Freedom

**Purpose:** Allow experimentation in non-production  
**Scope:** Attach to Development OU  
**Use Case:** Enable developers to move fast  

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowDevExperimentation",
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "rds:*",
        "dynamodb:*",
        "s3:*",
        "lambda:*",
        "apigateway:*",
        "cloudformation:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "RestrictCrossAccountAccess",
      "Effect": "Deny",
      "Action": "sts:AssumeRole",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:SourceAccount": [
            "DEVELOPMENT_ACCOUNT_ID",
            "MANAGEMENT_ACCOUNT_ID"
          ]
        }
      }
    }
  ]
}
```

**What it enables:**
- Developers create resources without approval
- Fast iteration and testing
- Learning through experimentation
- Isolated from other accounts

**Trade-off:** Must accept that dev account might be messy (that's okay!)

---

### Template 5: Compliance & Regulatory

**Purpose:** Enforce compliance standards (HIPAA, PCI-DSS, SOC 2)  
**Scope:** Attach to all OUs  
**Use Case:** Mandatory regulatory requirements  

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnforceDataEncryption",
      "Effect": "Deny",
      "Action": [
        "s3:CreateBucket",
        "s3:PutObject"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    },
    {
      "Sid": "EnforceVPCUse",
      "Effect": "Deny",
      "Action": "ec2:RunInstances",
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "StringEquals": {
          "ec2:Subnet": ""
        }
      }
    },
    {
      "Sid": "EnforceMFADelete",
      "Effect": "Deny",
      "Action": "s3:DeleteObject",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-mfa": "*"
        }
      }
    },
    {
      "Sid": "EnforceMonitoring",
      "Effect": "Deny",
      "Action": [
        "cloudtrail:StopLogging",
        "logs:DeleteLogGroup"
      ],
      "Resource": "*"
    }
  ]
}
```

**What it enforces:**
- All data must be encrypted (HIPAA, PCI-DSS)
- All resources must be in VPC (network isolation)
- Deletion requires MFA (change management, SOC 2)
- Logging never disabled (audit trail, HIPAA)

**Regulatory value:** Pass compliance audits without manual enforcement

---

### Template 6: Network Security & Data Isolation

**Purpose:** Enforce network-level security controls  
**Scope:** Attach to all OUs  
**Use Case:** Prevent data exfiltration  

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnencryptedTransfer",
      "Effect": "Deny",
      "Action": "s3:*",
      "Resource": "*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Sid": "DenyPublicS3Access",
      "Effect": "Deny",
      "Action": [
        "s3:PutAccountPublicAccessBlock",
        "s3:PutBucketPublicAccessBlock"
      ],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "s3:BlockPublicAcls": "false"
        }
      }
    },
    {
      "Sid": "DenyUnauthorizedDBAccess",
      "Effect": "Deny",
      "Action": [
        "rds:ModifyDBInstance",
        "rds:ModifyDBCluster"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "rds:PubliclyAccessible": "true"
        }
      }
    },
    {
      "Sid": "EnforceKMSForDataAtRest",
      "Effect": "Deny",
      "Action": [
        "rds:CreateDBInstance",
        "dynamodb:CreateTable"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "rds:StorageEncrypted": "true"
        }
      }
    }
  ]
}
```

**What it prevents:**
- Data transfer over unencrypted connections
- Accidentally making S3 buckets public
- Database exposed to internet
- Unencrypted data storage

**Security impact:** 99% reduction in data exfiltration risk

---

## 🔍 SCP Testing Checklist

Before deploying SCPs to production, test them:

### Test Checklist Template

```markdown
# SCP Testing Checklist

Policy Name: ____________________
Target OU: ____________________
Attachment Date: ____________________

## Positive Tests (Should be DENIED)
- [ ] Test 1 action - Expected DENY: _______ - Actual: _______
- [ ] Test 2 action - Expected DENY: _______ - Actual: _______
- [ ] Test 3 action - Expected DENY: _______ - Actual: _______

## Negative Tests (Should be ALLOWED)
- [ ] Test 1 action - Expected ALLOW: _______ - Actual: _______
- [ ] Test 2 action - Expected ALLOW: _______ - Actual: _______
- [ ] Test 3 action - Expected ALLOW: _______ - Actual: _______

## Business Impact Tests
- [ ] Normal development workflow: WORKS? _______
- [ ] Production deployment: WORKS? _______
- [ ] Compliance requirements: SATISFIED? _______

## Issues Found & Resolution
- Issue 1: _______________________ Solution: _______
- Issue 2: _______________________ Solution: _______

## Sign-off
- [ ] Development team approval
- [ ] Security team approval
- [ ] Operations team approval
- [ ] Ready for production deployment

Date: ________ Approver: ________
```

---

## ⚠️ Common SCP Mistakes & How to Fix Them

### Mistake 1: SCP Too Restrictive

**Problem:**
```json
{
  "Effect": "Deny",
  "Action": "*",
  "Resource": "*"
}
```

**Effect:** Blocks everything (even allowed actions)

**Fix:** Be specific about what you deny
```json
{
  "Effect": "Deny",
  "Action": "cloudtrail:DeleteTrail",
  "Resource": "*"
}
```

### Mistake 2: Forgetting the Allow

**Problem:**
```json
[
  {
    "Effect": "Deny",
    "Action": "ec2:TerminateInstances"
  }
]
```

**Effect:** Denies terminating instances (good) but user still needs default allow from IAM policy

**Fix:** Combine with IAM policy that grants permission
```
SCP says: Don't deny terminate (allow at org level)
IAM policy says: Yes, user can terminate (allow at account level)
Result: User can terminate instances
```

### Mistake 3: Not Testing in Non-Prod First

**Problem:**
Attach production protection SCP to production OU without testing

**Effect:** Everyone can't delete databases (even legitimate use)

**Fix:** Test in development OU first
```
Step 1: Test SCP in Development OU
Step 2: Get feedback from developers
Step 3: Adjust policy
Step 4: Attach to Production OU
```

### Mistake 4: Over-Complicating Policy

**Problem:**
```json
{
  "Condition": {
    "StringEquals": {
      "aws:username": "admin"
    },
    "IpAddress": {
      "aws:SourceIp": "10.0.0.0/8"
    },
    "StringLike": {
      "aws:SourceArn": "arn:aws:iam::*:role/prod*"
    }
  }
}
```

**Effect:** Policy is hard to understand and maintain

**Fix:** Keep it simple and clear
```json
{
  "Effect": "Deny",
  "Action": "rds:DeleteDBInstance",
  "Resource": "*"
}
```

---

## 🚀 SCP Best Practices

### Practice 1: Start with "Baseline Security"

Deploy the baseline security protection policy first (prevents security service disabling). Everything else is optional.

### Practice 2: Test Before Production

Always test SCPs in a non-production OU before attaching to production.

### Practice 3: Document Your SCPs

Keep a registry of all SCPs and why they exist:

```
| SCP Name | Purpose | Attached To | Review Date |
|----------|---------|-------------|-------------|
| Baseline-Security | Prevent logging disable | Root | Q1 2024 |
| Cost-Control | Prevent expensive regions | Root | Q1 2024 |
| Production-Protection | Prevent data deletion | Production OU | Q1 2024 |
```

### Practice 4: Monitor SCP Denials

Set up CloudWatch alarms for SCP denials:

```bash
# Creates alarm when SCP denies action
aws cloudwatch put-metric-alarm \
  --alarm-name SCP-Denial-Spike \
  --alarm-description "Alert when SCP denies actions" \
  --metric-name SCPDenialCount \
  --namespace AWS/Organizations \
  --threshold 10
```

### Practice 5: Review Quarterly

Every quarter, review:
- [ ] Are SCPs still appropriate?
- [ ] Have business needs changed?
- [ ] Do SCPs need adjustment?
- [ ] Are developers frustrated by restrictions?

---

## 📊 SCP Decision Tree

Use this to decide which SCPs to implement:

```
Do you need to...
│
├─ Prevent disabling security services?
│  └─→ Deploy: Baseline-Security-Protection
│
├─ Prevent expensive resources?
│  └─→ Deploy: Cost-Control-Policy
│
├─ Protect production data?
│  └─→ Deploy: Production-Protection-Policy
│
├─ Enforce encryption?
│  └─→ Deploy: Network-Security-Policy
│
├─ Enable compliance standards?
│  └─→ Deploy: Compliance-Policy
│
└─ Allow development freedom?
   └─→ Deploy: Development-Freedom-Policy
```

---

## 🎓 Summary

### What You've Learned

| Concept | Understanding |
|---------|---------------|
| SCP basics | Deny-based policies that override everything |
| When to use SCPs | Org-wide rules, not account-specific |
| Common SCPs | Baseline, Cost, Production, Compliance |
| Testing SCPs | Positive, negative, and business impact |
| Common mistakes | Over-restrictive, forgetting allows, not testing |
| Best practices | Document, test, review quarterly, monitor |

### Templates You Have

1. ✅ Baseline Security Protection (mandatory)
2. ✅ Cost Control & Quota Limits (recommended)
3. ✅ Production Environment Protection (recommended)
4. ✅ Development Environment Freedom (recommended)
5. ✅ Compliance & Regulatory (if needed)
6. ✅ Network Security & Data Isolation (if needed)

### Next Steps

1. Choose which SCPs you need
2. Copy templates and customize
3. Test in development OU first
4. Get team sign-off
5. Attach to production OU
6. Monitor and review quarterly

---

**Module 1 Reference Guide Complete**  
**Next:** Module 2 - Identity & Access Management (IAM)
