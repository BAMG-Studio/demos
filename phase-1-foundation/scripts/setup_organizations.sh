#!/bin/bash
set -e

MANAGEMENT_ACCOUNT_ID="${AWS_MANAGEMENT_ACCOUNT_ID}"
SECURITY_ACCOUNT_ID="${AWS_SECURITY_ACCOUNT_ID}"
PROD_ACCOUNT_ID="${AWS_PROD_ACCOUNT_ID}"
DEV_ACCOUNT_ID="${AWS_DEV_ACCOUNT_ID}"
SANDBOX_ACCOUNT_ID="${AWS_SANDBOX_ACCOUNT_ID}"

echo "=========================================="
echo "AWS Organizations Setup"
echo "=========================================="
echo ""

if [ -z "$MANAGEMENT_ACCOUNT_ID" ]; then
  echo "ERROR: AWS_MANAGEMENT_ACCOUNT_ID not set"
  exit 1
fi

echo "Management Account ID: $MANAGEMENT_ACCOUNT_ID"
echo "Security Account ID: $SECURITY_ACCOUNT_ID"
echo "Prod Account ID: $PROD_ACCOUNT_ID"
echo "Dev Account ID: $DEV_ACCOUNT_ID"
echo "Sandbox Account ID: $SANDBOX_ACCOUNT_ID"
echo ""

# Check if Organizations is enabled
echo "Checking AWS Organizations status..."
ORG_STATUS=$(aws organizations describe-organization --query 'Organization.Arn' --output text 2>/dev/null || echo "NOT_ENABLED")

if [ "$ORG_STATUS" = "NOT_ENABLED" ]; then
  echo "Enabling AWS Organizations..."
  aws organizations create-organization --feature-set ALL
  echo "✓ AWS Organizations enabled"
else
  echo "✓ AWS Organizations already enabled"
fi

echo ""
echo "Organizations setup complete!"
echo ""
echo "Next steps:"
echo "1. Create Security Account (if not exists)"
echo "2. Create Prod Account (if not exists)"
echo "3. Create Dev Account (if not exists)"
echo "4. Create Sandbox Account (if not exists)"
echo "5. Enable CloudTrail organization trail"
echo "6. Enable AWS Config aggregator"
