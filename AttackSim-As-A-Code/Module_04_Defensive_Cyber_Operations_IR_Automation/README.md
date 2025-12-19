# Module 4: Defensive Cyber Operations & IR Automation – Master Guide

## What & Why
Bridge detections to automated response. Design operational playbooks, event patterns, routing, and Lambda/SSM actions.

## Path
1) `01_Defensive_Cyber_Operations_Framework.md` (existing)
2) `02_Detection_to_Response_Pipeline.md`
3) `03_Event_Types_and_Patterns.md`
4) `04_Automation_Build.md`
5) `05_Runbook_Mapping.md`
6) `06_Validation_and_Drills.md`
7) `07_Portfolio_Resume.md`

## Success Criteria
- Documented pipeline (event → rule → target → action → evidence)
- Event patterns for top threats implemented
- At least 2 Lambda/SSM playbooks wired to EventBridge with DLQ
- Drill results captured with MTTD/MTTR

Cost: Mostly free (SNS/EventBridge/Lambda small; snapshots extra when used).