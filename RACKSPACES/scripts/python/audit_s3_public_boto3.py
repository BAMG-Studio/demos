#!/usr/bin/env python3
"""
Audit S3 buckets for public access using boto3 (read-only).
Requires AWS credentials with a read-only/audit policy (see iam_policies.md).
"""
import json
import boto3

s3 = boto3.client("s3")

def is_public_acl(acl):
    for grant in acl.get("Grants", []):
        grantee = grant.get("Grantee", {})
        uri = grantee.get("URI", "")
        if "AllUsers" in uri or "AuthenticatedUsers" in uri:
            return True
    return False

def audit():
    findings = []
    buckets = s3.list_buckets().get("Buckets", [])
    for b in buckets:
        name = b["Name"]
        acl = s3.get_bucket_acl(Bucket=name)
        if is_public_acl(acl):
            findings.append({"bucket": name, "issue": "Public ACL"})
        try:
            pol = s3.get_bucket_policy(Bucket=name)
            policy_doc = json.loads(pol["Policy"])
            statements = policy_doc.get("Statement", [])
            for stmt in statements:
                principal = stmt.get("Principal")
                effect = stmt.get("Effect")
                if effect == "Allow" and principal == "*":
                    findings.append({"bucket": name, "issue": "Policy allows *"})
        except s3.exceptions.NoSuchBucketPolicy:
            pass
    return findings

if __name__ == "__main__":
    result = audit()
    print(json.dumps({"findings": result}, indent=2))
