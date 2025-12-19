# 02 - Log Centralization (CloudTrail, Flow Logs, DNS)

## Goal
Centralize audit + network + DNS telemetry to the log archive bucket with integrity controls.

## Prereqs
- AWS Organizations with log archive account + bucket (from Module 1).
- IAM role with `organizations:EnableAWSServiceAccess` rights in management account.

## Steps (Console-first)
1) **Org CloudTrail (all regions)**
   - Go to CloudTrail → Trails → Create trail.
   - Name: `org-trail` (or reuse Module 1 name).
   - Apply to all accounts, all regions, management events = All, data events = S3: Write/Read, Lambda: Invoke.
   - Bucket: existing log archive (force SSE-S3 or KMS). Enable log file validation.
   - Insight events: on (API error rate, throttle).

2) **VPC Flow Logs (per VPC)**
   - VPC → Your VPCs → Flow Logs → Create.
   - Filter: `ALL` (lab) or `REJECT` (cost-save).
   - Destination: S3 (log archive) with prefix `flow-logs/<vpc-id>/`.
   - Format: include `pkt-srcaddr`, `pkt-dstaddr`, `action`, `tcp-flags`, `pkt-len`.

3) **Route 53 Resolver DNS Query Logs**
   - Route 53 → Query logging → Create.
   - Destination: S3 (log archive) prefix `dns-logs/`.
   - Choose VPCs to monitor.

4) **(Optional) ALB/WAF Logs**
   - ALB: Enable access logs to S3 (gzip).
   - WAF: Logging → Send to S3 via Kinesis Firehose (or CloudWatch Logs if easier).

## Hardening
- S3 bucket: block public access, MFA delete (if allowed), lifecycle to IA/Glacier, Object Lock (governance) if feasible.
- Enable **CloudTrail log file validation**; keep digest in separate bucket or same with Object Lock.
- Least-privilege access via Athena/OpenSearch roles; no write from analytics accounts.

## Validation
- Perform a console login and an S3 ListBucket; confirm events land in S3 within minutes.
- Run `nslookup example.com` in EC2; verify DNS query log entry.
- Generate allowed + denied traffic to see Flow Log entries.

## Cost Tips
- Use `REJECT` filter for noisy VPCs; enable only in target VPCs for lab.
- Shorter retention in CloudWatch Logs; keep long-term in S3 with lifecycle.

## Quick CLI (reference)
```bash
# Enable org CloudTrail (sample; adapt bucket names)
aws cloudtrail create-trail \
  --name org-trail \
  --s3-bucket-name <log-archive-bucket> \
  --is-multi-region-trail \
  --is-organization-trail
aws cloudtrail start-logging --name org-trail
```

Outcome: All foundational logs land centrally with integrity controls and lifecycle policies.