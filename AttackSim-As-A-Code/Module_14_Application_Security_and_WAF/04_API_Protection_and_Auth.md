# 04 - API Protection & Auth

## API Gateway
- Enable JWT auth (Cognito/OIDC); require scopes.
- Set usage plans + API keys for partners if needed.
- Enable request validation (models) + throttle (burst/rate) per stage.

## ALB + App
- OIDC auth on ALB listener rules if feasible.
- Enforce HTTPS redirect; HSTS headers.

## Data Layer
- Principle of least privilege for app roles to data stores.

## Validation
- Invalid token → 401; over throttle → 429; schema mismatch → validation error.

Outcome: Authenticated, validated, and throttled APIs.