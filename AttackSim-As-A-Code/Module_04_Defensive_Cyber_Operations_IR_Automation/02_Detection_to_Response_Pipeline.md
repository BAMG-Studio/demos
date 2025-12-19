# 02 - Detection to Response Pipeline

Flow: Signal source → EventBridge rule → Target (Lambda/SSM/SNS) → Containment → Evidence → Notify → Ticket.

Key controls: DLQ, retries, idempotency, tagging incidents.

Outcome: Clear end-to-end path from detection to action.