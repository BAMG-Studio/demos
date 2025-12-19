# Concepts — Containers and supply chain (plain English)

## Containers
A container is a standardized “software box” that includes:
- your app
- its dependencies
- its runtime configuration

It reduces surprises: the app runs the same way on laptop, test, and production.

## Images and layers
A container image is built in layers.
Smaller images generally mean:
- faster downloads
- fewer moving parts
- smaller attack surface

## Supply chain security (what it means)
Your software is built from many ingredients:
- your code
- open-source libraries
- base images

Supply chain security is the discipline of knowing what you shipped and reducing risk:
- dependency scanning (SCA — Software Composition Analysis)
- code scanning (SAST — Static Application Security Testing)
- image scanning
- SBOM (Software Bill of Materials)
- signing artifacts
