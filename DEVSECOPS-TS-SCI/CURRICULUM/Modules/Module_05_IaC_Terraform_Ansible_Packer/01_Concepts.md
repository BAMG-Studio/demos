# Concepts (plain English) — IaC, CaC, and Packer

## The problem this solves
When infrastructure is built by clicking around:
- nobody can prove what changed
- environments drift (dev ≠ prod)
- recovery is slow

When infrastructure is built from code:
- changes are reviewed
- environments are repeatable
- evidence is easy to produce

## IaC vs CaC
- **IaC (Infrastructure as Code)**: builds the infrastructure (networks, compute, IAM, load balancers).
- **CaC (Configuration as Code)**: configures the OS/app layer consistently (packages, hardening, app config).

Plain English: Terraform builds the “house.” Ansible arranges the “furniture” the same way every time.

## Terraform (what to be able to explain)
- **Plan/apply**: preview changes, then execute them.
- **State**: Terraform tracks what it built; protect it like a critical system.
- **Modules**: reusable building blocks.
- **Drift**: if someone changes things manually, the code and reality diverge.
- **Workspaces/environments**: dev/test/prod separation.

## Ansible (what to be able to explain)
- **Idempotence**: running the playbook twice results in the same end state.
- **Inventory**: the list of hosts/targets.
- **Roles**: reusable configuration units.

## Packer (what to be able to explain)
**Packer** builds a pre-hardened “golden image” (AMI/VM image).

Why it matters:
- faster provisioning
- consistent baselines
- fewer “snowflake” servers

## Evidence mindset (enterprise + TS/SCI friendly)
What leaders/auditors care about:
- what version of the code ran
- who approved it
- what it changed
- how to roll back

Even when you can’t show sensitive details, you can show:
- the process
- the controls
- the evidence artifacts (plans, reports, approvals)
