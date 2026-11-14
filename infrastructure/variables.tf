variable "aws_region" {
  description = "AWS region for the Sentinel infrastructure"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "project identifier"
  type        = string
  default     = "sentinel"
}

variable "environment" {
  description = "Environment label"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the Sentinel VPC."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "Two public subnet CIDRs, assigned to the first two available AZs in the selected region."
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]

  validation {
    condition = length(var.public_subnet_cidrs) == 2 && alltrue([
      for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "Provide exactly two valid IPv4 subnet CIDR blocks."
  }
}

variable "admin_cidr" {
  description = "My current public IPv4 CIDR for optional SSH and Nagios UI access"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.admin_cidr == null || can(cidrhost(var.admin_cidr, 0))
    error_message = "admin_cidr must be a valid CIDR block or null."
  }
}

variable "ec2_key_name" {
  description = "Existing EC2 key-pair name"
  type        = string
  default     = null
  nullable    = true
}

variable "ops_instance_type" {
  description = "EC2 instance type for the operations node."
  type        = string
  default     = "t3.small"
}

variable "app_instance_type" {
  description = "EC2 instance type for the Blue and Green application nodes."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Encrypted gp3 root volume size in GiB for each EC2 instance."
  type        = number
  default     = 8

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 100
    error_message = "root_volume_size must be between 8 and 100 GiB."
  }
}
