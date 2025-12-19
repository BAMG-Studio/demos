# Technical Q&A (tailored to the role)

## “Walk me through a CI/CD pipeline you built.”
Explain in order:
1. trigger (push/PR)
2. build
3. tests
4. security gates (SAST/SCA/IaC scan/container scan)
5. artifact publishing (image + tags)
6. deployment (staging → production)
7. monitoring and rollback

## “How do you integrate security into DevOps?”
- automate checks early (shift-left)
- treat infrastructure changes like code changes (reviewable, testable)
- use least-privilege credentials for pipelines
- store secrets outside git (vault/secrets manager)

## “How do you support hundreds of applications?”
- templates/shared libraries
- standard base images
- standardized Helm charts and Terraform modules
- policy-as-code guardrails
