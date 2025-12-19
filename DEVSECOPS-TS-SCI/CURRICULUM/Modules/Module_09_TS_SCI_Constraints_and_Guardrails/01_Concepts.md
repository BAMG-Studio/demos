# Concepts (plain English) — TS/SCI constraints and guardrails

## Safe framing
This module is about operating constraints and engineering patterns (not operational details).

## Common constraints (non-sensitive, generic)
- limited or controlled network access
- stricter change control and approvals
- tighter identity boundaries and logging requirements
- higher emphasis on deterministic builds and provenance

## What “guardrails” mean
Guardrails are controls that prevent unsafe actions by default.

Examples:
- pipeline gates (tests + security checks)
- policy enforcement (what’s allowed to deploy)
- least-privilege roles for CI vs humans
- artifact provenance and SBOMs

## The delivery-friendly mindset
The goal is not “slow.” The goal is **predictable and auditable**:
- automation replaces manual process
- standard templates reduce variance
- evidence is produced automatically
