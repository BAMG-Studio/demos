#!/usr/bin/env python3
"""
Incident Response: isolate compromised instance (conceptual).
Usage: python incident_isolate_instance.py i-0123456789abcdef0
"""
import sys

def isolate_instance(instance_id: str):
    steps = [
        {"step": "tag_compromised", "status": "SIMULATED"},
        {"step": "snapshot_volumes", "status": "SIMULATED"},
        {"step": "apply_isolation_sg", "status": "SIMULATED"},
        {"step": "notify_team", "status": "SIMULATED"},
    ]
    return {"instance_id": instance_id, "actions": steps}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python incident_isolate_instance.py <instance_id>")
        sys.exit(1)
    instance_id = sys.argv[1]
    res = isolate_instance(instance_id)
    print(res)
