# Sentinel — Terraform Infrastructure

- One VPC (`10.20.0.0/16`) across two Availability Zones
- Two public subnets (`10.20.1.0/24`, `10.20.2.0/24`)
- Internet Gateway and public route table
- Separate operations and application Security Groups
- Three Ubuntu 22.04 EC2 instances: `sentinel-ops`, `sentinel-blue`, `sentinel-green`
- EC2 instance profile with `AmazonSSMManagedInstanceCore`
- Encrypted gp3 root volumes and IMDSv2 enforcement
- S3 remote Terraform state with versioning, encryption, public-access blocking, TLS-only bucket policy, and native S3 lockfile

The two application instances are placed in public subnets so they can obtain package updates without a NAT Gateway. Their Security Group does **not** expose application, SSH, or NRPE ports to the internet: those ports accept traffic from the operations Security Group only.
