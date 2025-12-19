# 01 - Application Security Threat Model

## Steps
- Identify entry points: ALB/API GW/CloudFront → app → data stores.
- Assets: PII, tokens, secrets, business logic.
- Threats: OWASP Top 10, auth bypass, SSRF, brute force, bot scraping.
- Controls: WAF, authN/Z, input validation, rate limits, logging, least privilege.

Outcome: Agreed list of threats mapped to controls you’ll implement.