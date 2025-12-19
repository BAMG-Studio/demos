# 02 - Storage Encryption Controls

## S3
- Default encryption SSE-KMS (customer CMK) on buckets.
- Bucket policy: deny `s3:PutObject` without `aws:SecureTransport` and without `x-amz-server-side-encryption`.
- Block public access; enable versioning; optional Object Lock (governance).

## EBS
- Enable EBS encryption by default in each region.
- Use CMK per workload sensitivity; snapshot copy with re-encrypt.

## RDS/EFS
- Encrypt at rest; require TLS for clients (parameter group for RDS).

## VPC Endpoints
- Use S3 and KMS interface endpoints to keep traffic private.

## Validation
- Attempt unencrypted upload → should fail due to bucket policy.
- Check EBS default encryption flag.

Outcome: Storage services enforce encryption and transport controls.