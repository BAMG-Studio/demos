# Module 14: Application Security & WAF – Master Guide

## What & Why
Secure web/mobile APIs with layered controls: WAF rules, auth, input validation, API protections, and SDLC hardening. You’ll deploy AWS WAF managed rules, custom rules, bot control patterns, and secure CI/CD.

## Outcomes
- Threat modeling for apps/APIs
- AWS WAF on ALB/API Gateway/CloudFront with managed + custom rules
- Rate limiting, geo/IP allow/deny, bot mitigation basics
- App-layer logging/monitoring (WAF logs, ALB logs, CloudWatch metrics)
- SDLC controls: code scanning, secrets scanning, SBOM, deploy gates

## Path
1) `01_AppSec_Threat_Model.md`
2) `02_WAF_Basics_and_Managed_Rules.md`
3) `03_Custom_Rules_Rate_Limits_BotControl.md`
4) `04_API_Protection_and_Auth.md`
5) `05_SDLC_Scanning_and_Release_Gates.md`
6) `06_Logging_Observability.md`
7) `07_Portfolio_Resume.md`

## Success Criteria
- WAF web ACL attached to entry point with managed rules + custom rate rule.
- Logging enabled to S3/Kinesis; dashboards for WAF blocks/allow.
- API protected with auth (Cognito/OIDC) + throttling + schema validation.
- CI/CD pipeline with static analysis + secrets scan + dependency scan gate.

## Cost Snapshot (lab)
- WAF: ~$5 per ACL + $1/rule + request charges (small in lab)
- Code scanning (CodeGuru/Snyk/etc.): use free tiers/trials

Validate by sending OWASP-style test requests and observing WAF blocks + alerts.