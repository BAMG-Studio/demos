# 06 - Custom Detections & Threat Intel

## Goal
Write focused rules for your environment and enrich with intel to reduce blind spots.

## Custom Detection Ideas
- **IAM Backdoor:** `CreateUser` or `CreateAccessKey` by non-admin role outside CI pipeline.
- **Privilege Escalation:** `AttachUserPolicy` with `AdministratorAccess` or `PassRole` to wildcard.
- **Logging Tamper:** `StopLogging`, `DeleteTrail`, `PutBucketPolicy` on log archive.
- **Network Egress:** Flow Logs showing large egress to new ASN/geo; DNS queries to newly-seen domains.
- **S3 Exposure:** `PutBucketAcl` granting `AllUsers` or `AuthenticatedUsers`; Security Hub S3.1 control fails.

## Where to Implement
- **EventBridge**: pattern match + SNS/Lambda.
- **OpenSearch Monitor**: query-based conditions.
- **Athena**: scheduled query → SNS on result count > 0.
- **Lambda**: custom logic (stateful), store last-seen in DynamoDB.

## Sample EventBridge Pattern (IAM Backdoor)
```json
{
  "source": ["aws.iam"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": ["CreateUser", "CreateAccessKey"],
    "userIdentity": {
      "sessionContext": {
        "sessionIssuer": {
          "userName": [{"anything-but": ["ci-role", "admin-automation"]}]
        }
      }
    }
  }
}
```

## Threat Intel Hooks
- **GuardDuty Lists:** add threat lists (S3 URL) for bad IPs/domains; add trusted lists to reduce noise.
- **OpenSearch Enrich:** upload intel CSV (IP, domain, category) to index; join in queries.
- **VPC DNS Firewall**: block known bad domains and log matches.

## Tuning & Noise Reduction
- Suppress rules with clear business justifications (documented expiration).
- Add `environment`/`owner` tags to resources; route alerts based on tag.
- Rate-limit repetitive alerts; batch similar events.

## Validation
- Simulate `CreateUser` with non-admin role → verify alert.
- Upload a threat-list with a known test IP, generate Flow Log entry to it → verify detection.

Outcome: Tailored detections that reflect your environment, with intel-driven context and reduced noise.