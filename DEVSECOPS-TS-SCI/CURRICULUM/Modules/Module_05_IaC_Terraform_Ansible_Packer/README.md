# Module 05 — IaC (Terraform), CaC (Ansible), and Packer

## Outcome
You can explain how environments are built from code, why that improves reliability, and how it supports audits.

## Deliverables (what you will produce)
- `Developer_Journal.md`
- `Implementation_Summary.md`
- `03_Interview_Talk_Track.md`

## Core idea
Instead of clicking around a cloud console, you describe the environment in version-controlled files.

## Files
- `01_Concepts.md`
- `02_HandsOn.md`
- `03_Interview_Talk_Track.md`
- `Developer_Journal.md`
- `Implementation_Summary.md`

## Prereqs
- None required to read `01_Concepts.md`
- Optional for the hands-on: `terraform`, `ansible`, and `packer` (or use this module as a design/interview lab)

## How to run (quick start)
Even without cloud credentials, you can practice the evidence mindset by running the local “CI gates” and capturing the outputs.

```bash
cd /home/papaert/projects/lab/DEVSECOPS-TS-SCI
./scripts/ci_local.sh
```

## What you will build next
A small Terraform stack + an Ansible hardening playbook + a Packer image recipe (planned).
