# 02 - Scenario Catalog & MITRE Mapping

List scenarios with IDs, tool, MITRE technique, expected detection, expected response.

Example entries:
- `SIM-EC2-IMDS-EXFIL`: Stratus `aws.credential-access.ec2-steal-instance-credentials` → T1552.005 → Expect GuardDuty + Lambda isolate.
- `SIM-CLOUDTRAIL-STOP`: Stratus `aws.defense-evasion.cloudtrail-stop` → T1562.008 → Expect SCP deny.
- `SIM-IAM-BACKDOOR`: custom script create IAM user → T1136.003 → Expect alert + auto-delete (Module 16 extension).

Outcome: Clear mapping of tests to controls.