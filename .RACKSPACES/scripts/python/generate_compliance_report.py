#!/usr/bin/env python3
"""
Generate a simple compliance report mapping controls to cloud settings (demo).
"""
from datetime import datetime

def generate_report():
    return {
        "timestamp": datetime.now().isoformat(),
        "checks": [
            {"control": "NIST AC-2", "status": "PASS", "details": "IAM account lifecycle + least privilege"},
            {"control": "NIST CM", "status": "PASS", "details": "AWS Config recorder + drift rules"},
            {"control": "PCI Encrypt", "status": "PASS", "details": "KMS for S3/RDS/EBS; TLS enforced"},
            {"control": "SOX Logging", "status": "PASS", "details": "CloudTrail multi-region + integrity"},
        ],
    }

if __name__ == "__main__":
    rep = generate_report()
    for c in rep["checks"]:
        print(f"- {c['control']}: {c['status']} — {c['details']}")
