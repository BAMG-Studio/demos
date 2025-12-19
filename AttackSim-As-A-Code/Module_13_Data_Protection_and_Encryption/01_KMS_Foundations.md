# 01 - KMS Foundations

## Key Types
- Symmetric CMKs (default); asymmetric for sign/verify
- Single-region vs multi-Region keys

## Policies & Access
- Key policy should list: security account admins, key users (services/roles), CloudTrail logging.
- Use grants for applications (least-priv, revocable) vs broad policy edits.

## Defaults
- Enable automatic rotation (1 year) where supported.
- Alias naming: `alias/app-env-purpose` (e.g., `alias/s3-prod-data`).

## Validation
- `aws kms encrypt/decrypt` test with role.
- CloudTrail shows `Encrypt/Decrypt` events.

Outcome: Secure, governed KMS keys ready for service encryption.