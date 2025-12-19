# 04 - Forensics & Evidence Pipeline

## Evidence Capture
- EC2: snapshots, instance metadata, flow logs window, console output.
- S3: object versioning + access logs.
- IAM: credential report, CloudTrail slices around incident time.

## Storage
- S3 evidence bucket with Object Lock (governance), KMS CMK, tight ACLs.
- Index manifests (JSON) with incident ID, resources, hashes.

Outcome: Consistent evidence preservation for each automated playbook.