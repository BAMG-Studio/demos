output "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  value       = aws_s3_bucket.trail_logs.id
}

output "cloudtrail_bucket_arn" {
  description = "S3 bucket ARN for CloudTrail logs"
  value       = aws_s3_bucket.trail_logs.arn
}

output "cloudtrail_name" {
  description = "CloudTrail name"
  value       = aws_cloudtrail.org_trail.name
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = aws_cloudtrail.org_trail.arn
}

output "kms_key_id" {
  description = "KMS key ID for encryption"
  value       = aws_kms_key.cmk.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN for encryption"
  value       = aws_kms_key.cmk.arn
}

output "config_recorder_name" {
  description = "AWS Config recorder name"
  value       = aws_config_configuration_recorder.rec.name
}

output "config_recorder_arn" {
  description = "AWS Config recorder ARN"
  value       = aws_config_configuration_recorder.rec.arn
}

output "config_role_arn" {
  description = "AWS Config IAM role ARN"
  value       = aws_iam_role.config_role.arn
}
