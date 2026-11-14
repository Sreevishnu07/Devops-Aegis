variable "aws_region" {
  description = "AWS region in which to create the Terraform state bucket."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "sentinel"
}
