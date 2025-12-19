# Playbook — Isolate Compromised EC2

## Trigger
- GuardDuty finding: UnauthorizedAccess or CryptoCurrency:EC2/BitcoinTool.B

## Steps
1. Tag instance as `SecurityStatus=Compromised`.
2. Snapshot attached volumes for forensics.
3. Attach isolation security group (no ingress/egress).
4. Notify IR channel; open ticket.

## Automation
- Lambda or Step Functions orchestrates steps; see `.RACKSPACES/scripts/python/incident_isolate_instance.py` (simulation).
