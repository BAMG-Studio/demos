#!/bin/bash
set -e

PROJECT_NAME="${PROJECT_NAME:-rackspace-soc}"
AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_PROFILE="${AWS_PROFILE:-security}"

echo "=========================================="
echo "Phase 1: Foundation Validation"
echo "=========================================="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_result() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}: $1"
  else
    echo -e "${RED}✗ FAIL${NC}: $1"
    exit 1
  fi
}

echo "1. Checking AWS CLI access..."
aws sts get-caller-identity --profile $AWS_PROFILE > /dev/null
check_result "AWS CLI access"

echo ""
echo "2. Checking CloudTrail..."
TRAIL_NAME="${PROJECT_NAME}-trail"
aws cloudtrail describe-trails --trail-name-list $TRAIL_NAME --profile $AWS_PROFILE > /dev/null 2>&1
check_result "CloudTrail trail exists"

echo ""
echo "3. Checking CloudTrail S3 bucket..."
BUCKET_NAME="${PROJECT_NAME}-cloudtrail-logs-$(aws sts get-caller-identity --profile $AWS_PROFILE --query Account --output text)"
aws s3 ls s3://$BUCKET_NAME --profile $AWS_PROFILE > /dev/null
check_result "CloudTrail S3 bucket accessible"

echo ""
echo "4. Checking CloudTrail log file validation..."
TRAIL_STATUS=$(aws cloudtrail describe-trails --trail-name-list $TRAIL_NAME --profile $AWS_PROFILE --query 'trailList[0].LogFileValidationEnabled' --output text)
if [ "$TRAIL_STATUS" = "True" ]; then
  echo -e "${GREEN}✓ PASS${NC}: CloudTrail log file validation enabled"
else
  echo -e "${RED}✗ FAIL${NC}: CloudTrail log file validation not enabled"
  exit 1
fi

echo ""
echo "5. Checking AWS Config..."
RECORDER_NAME="${PROJECT_NAME}-recorder"
aws configservice describe-configuration-recorder-status --configuration-recorder-names $RECORDER_NAME --profile $AWS_PROFILE > /dev/null 2>&1
check_result "AWS Config recorder exists"

echo ""
echo "6. Checking AWS Config recorder status..."
RECORDER_STATUS=$(aws configservice describe-configuration-recorder-status --configuration-recorder-names $RECORDER_NAME --profile $AWS_PROFILE --query 'ConfigurationRecordersStatus[0].recording' --output text)
if [ "$RECORDER_STATUS" = "True" ]; then
  echo -e "${GREEN}✓ PASS${NC}: AWS Config recorder is recording"
else
  echo -e "${RED}✗ FAIL${NC}: AWS Config recorder is not recording"
  exit 1
fi

echo ""
echo "7. Checking KMS key..."
KMS_KEY_ID=$(aws kms list-aliases --profile $AWS_PROFILE --query "Aliases[?AliasName=='alias/${PROJECT_NAME}-cmk'].TargetKeyId" --output text)
if [ -n "$KMS_KEY_ID" ]; then
  echo -e "${GREEN}✓ PASS${NC}: KMS key exists"
else
  echo -e "${RED}✗ FAIL${NC}: KMS key not found"
  exit 1
fi

echo ""
echo "8. Checking KMS key rotation..."
KEY_ROTATION=$(aws kms get-key-rotation-status --key-id $KMS_KEY_ID --profile $AWS_PROFILE --query 'KeyRotationEnabled' --output text)
if [ "$KEY_ROTATION" = "True" ]; then
  echo -e "${GREEN}✓ PASS${NC}: KMS key rotation enabled"
else
  echo -e "${RED}✗ FAIL${NC}: KMS key rotation not enabled"
  exit 1
fi

echo ""
echo "9. Checking Config rules..."
RULES=$(aws configservice describe-config-rules --profile $AWS_PROFILE --query 'ConfigRules[*].ConfigRuleName' --output text)
if echo "$RULES" | grep -q "s3-bucket-public-read-prohibited"; then
  echo -e "${GREEN}✓ PASS${NC}: S3 public read prohibition rule exists"
else
  echo -e "${RED}✗ FAIL${NC}: S3 public read prohibition rule not found"
  exit 1
fi

echo ""
echo "=========================================="
echo -e "${GREEN}All Phase 1 validations passed!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Review CloudTrail logs in S3: s3://$BUCKET_NAME"
echo "2. Check Config compliance dashboard"
echo "3. Proceed to Phase 2: Detection & Monitoring"
