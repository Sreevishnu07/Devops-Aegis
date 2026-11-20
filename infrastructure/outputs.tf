output "vpc_id" {
  description = "Sentinel VPC ID."
  value       = aws_vpc.sentinel.id
}

output "vpc_cidr" {
  description = "Sentinel VPC CIDR."
  value       = aws_vpc.sentinel.cidr_block
}

output "availability_zones" {
  description = "Availability Zones selected for the two public subnets."
  value       = local.availability_zones
}

output "public_subnet_ids" {
  description = "IDs of the two public subnets."
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "operations_security_group_id" {
  description = "Security Group ID attached to sentinel-ops."
  value       = aws_security_group.operations.id
}

output "application_security_group_id" {
  description = "Security Group ID attached to sentinel-blue and sentinel-green."
  value       = aws_security_group.application.id
}

output "ubuntu_ami_id" {
  description = "Canonical Ubuntu 22.04 LTS AMI selected for this region."
  value       = var.ubuntu_ami_id
}

output "ops_instance_id" {
  description = "EC2 instance ID for sentinel-ops."
  value       = aws_instance.ops.id
}

output "ops_public_ip" {
  description = "Public IPv4 address of sentinel-ops. Use SSM or restricted SSH for administration."
  value       = aws_instance.ops.public_ip
}

output "ops_private_ip" {
  description = "Private IPv4 address of sentinel-ops."
  value       = aws_instance.ops.private_ip
}

output "blue_instance_id" {
  description = "EC2 instance ID for sentinel-blue."
  value       = aws_instance.blue.id
}

output "blue_public_ip" {
  description = "Public IPv4 address of sentinel-blue; application ports are not publicly reachable."
  value       = aws_instance.blue.public_ip
}

output "blue_private_ip" {
  description = "Private IPv4 address of sentinel-blue."
  value       = aws_instance.blue.private_ip
}

output "green_instance_id" {
  description = "EC2 instance ID for sentinel-green."
  value       = aws_instance.green.id
}

output "green_public_ip" {
  description = "Public IPv4 address of sentinel-green; application ports are not publicly reachable."
  value       = aws_instance.green.public_ip
}

output "green_private_ip" {
  description = "Private IPv4 address of sentinel-green."
  value       = aws_instance.green.private_ip
}

output "application_entrypoint_url" {
  description = "Public Nginx entry point on sentinel-ops (after Nginx is configured)."
  value       = "http://${aws_instance.ops.public_ip}"
}

output "nagios_ui_url" {
  description = "Planned Nagios UI endpoint; Apache/Nagios will be configured on port 8080 later."
  value       = "http://${aws_instance.ops.public_ip}:8080/nagios"
}

output "ec2_instance_profile_name" {
  description = "Instance profile granting EC2 Systems Manager core permissions."
  value       = aws_iam_instance_profile.ec2_ssm.name
}
