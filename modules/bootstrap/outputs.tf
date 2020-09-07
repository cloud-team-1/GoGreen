output "s3_bucket_arn" {
  value       = aws_s3_bucket.gogreen-3tier-tf-state.arn
  description = "The ARN of the S3 bucket"
}