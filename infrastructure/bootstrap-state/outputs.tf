output "state_bucket_name" {
  description = "Use this bucket name in infrastructure/backend.hcl."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "ARN of the Terraform state bucket."
  value       = aws_s3_bucket.terraform_state.arn
}

output "state_bucket_region" {
  description = "Region containing the Terraform state bucket."
  value       = var.aws_region
}
