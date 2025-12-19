# Concepts (plain English) — AWS cloud architecture

## The enterprise AWS mental model
In enterprise, AWS is not “one big account.” It is usually:
- many accounts (separate blast radius)
- standard networking patterns
- centralized logging and security
- strong identity boundaries

## Core building blocks to explain
- **Account**: a billing and security boundary.
- **Region/AZ**: where things run.
- **VPC**: your private network.
- **Subnets**: slices of the VPC (public/private).
- **Route tables/NAT/IGW**: how traffic moves.
- **Security groups/NACLs**: network access controls.

## Identity and access (IAM)
What interviewers want to hear:
- least privilege by default
- roles over long-lived keys
- separation of duties (build vs deploy vs operate)

## Multi-account strategy (simple but strong)
Common pattern:
- **Shared services** (CI runners, artifact stores)
- **Log archive** (central retention)
- **Security tooling** (detections, guardrails)
- **Dev/Test/Prod** separated

## Observability and audit readiness
Enterprise AWS expects:
- central logs (CloudTrail + service logs)
- immutable-ish storage for evidence
- easy-to-prove change history

## TS/SCI-friendly framing
Keep it generic and process-based:
- strict network boundaries
- controlled egress
- deterministic builds
- evidence and approvals tied to deployments
