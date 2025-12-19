# 05 - Search & Analytics Playbook

## Common Queries
- Root login timeline; IAM change trail; mass S3 deletes; deny spikes.
- Flow logs: top talkers; rejects by port; egress to rare ASN.
- GuardDuty: counts by severity/type/account.

## Hunting Flow
- Question → filter by account/region/time → pivot to identity/resource → save search.

Outcome: Repeatable searches for analysts and hunters.