# 05 - SDLC Scanning & Release Gates

## Pipeline Controls
- Static analysis (CodeGuru/Sonar), dependency scan (Dependabot/Snyk), secrets scan (git-secrets/trufflehog), IaC scan (cfn-nag/Checkov).
- Break-glass rules: block on High/Critical findings unless exception approved.
- SBOM generation (CycloneDX) and store with artifacts.

## Signing & Integrity
- Sign container images (ECR with KMS), enforce via ECR scanning and OPA/Conftest in pipeline.

Outcome: Releases blocked on security gates; artifacts tracked with SBOM/signing.