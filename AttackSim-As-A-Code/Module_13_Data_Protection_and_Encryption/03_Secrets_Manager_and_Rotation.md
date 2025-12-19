# 03 - Secrets Manager & Rotation

## Setup
- Create secret for RDS/user with JSON structure.
- Attach rotation Lambda (template) or built-in for RDS.
- Permissions: app role gets `secretsmanager:GetSecretValue` only; rotation role separate.

## Parameter Store
- Use for non-rotating config; mark SecureString with KMS CMK.

## Auditing
- Enable CloudTrail data events for `secretsmanager`.
- Set rotation interval (30–90 days) and alarm on rotation failure.

## Validation
- Rotate secret; confirm new password works and old revoked.

Outcome: Centralized secret storage with automated rotation and audit trail.