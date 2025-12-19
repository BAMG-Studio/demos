terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" { type = string }
variable "project" { type = string }

# KMS CMK for envelope encryption
resource "aws_kms_key" "cmk" {
  description             = "${var.project} CMK"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

# S3 bucket for CloudTrail logs with default encryption
resource "aws_s3_bucket" "trail_logs" {
  bucket = "${var.project}-cloudtrail-logs"
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "trail_logs" {
  bucket = aws_s3_bucket.trail_logs.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "trail_logs" {
  bucket = aws_s3_bucket.trail_logs.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cmk.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# CloudTrail
resource "aws_cloudtrail" "org_trail" {
  name                          = "${var.project}-trail"
  s3_bucket_name                = aws_s3_bucket.trail_logs.id
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  include_global_service_events = true
}

# AWS Config
resource "aws_config_configuration_recorder" "rec" {
  name     = "${var.project}-recorder"
  role_arn = aws_iam_role.config_role.arn
  recording_group {
    all_supported = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "chan" {
  name           = "${var.project}-channel"
  s3_bucket_name = aws_s3_bucket.trail_logs.id
  depends_on     = [aws_config_configuration_recorder.rec]
}

resource "aws_config_configuration_recorder_status" "status" {
  name       = aws_config_configuration_recorder.rec.name
  is_enabled = true
}

# IAM role for Config
resource "aws_iam_role" "config_role" {
  name = "${var.project}-config-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "config.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "config_attach" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

# Example Config rule: S3 buckets should not be public
resource "aws_config_config_rule" "s3_public_read_prohibited" {
  name = "s3-bucket-public-read-prohibited"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
}
