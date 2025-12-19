# Concepts — CI/CD at scale (plain English)

## CI/CD = the automated assembly line
- **CI (Continuous Integration)**: every code change is automatically built and tested.
- **CD (Continuous Delivery/Deployment)**: passing changes are packaged and deployed with guardrails.

Plain English: you are replacing manual steps with repeatable automation.

## What changes when you have “hundreds of apps”
At small scale, teams handcraft pipelines.

At enterprise scale:
- handcrafted pipelines become inconsistent and risky
- security gates drift (some teams scan, others skip)
- releases become unpredictable

So you standardize.

## The enterprise pattern: “Golden pipeline”
A **golden pipeline** is a standard workflow template that every app inherits.

Teams only provide:
- how to build
- how to test
- what artifact to produce (container image, package)

The platform provides:
- security gates (SAST/SCA/image scanning)
- tagging/versioning
- evidence outputs (logs, reports)
- approvals for production

## Jenkins mapping
In Jenkins, you implement this with:
- **Jenkinsfiles** (Pipeline as Code)
- **Shared libraries** (reusable pipeline functions)

## Evidence mindset (TS/SCI)
Your pipeline should produce evidence you can show an auditor:
- what ran
- what versions were used
- what passed/failed
- who approved production
