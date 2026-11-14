resource "aws_security_group" "operations" {
  name        = "${local.name_prefix}-ops-sg"
  description = "Ingress to the Sentinel operations node and public Nginx entry point."
  vpc_id      = aws_vpc.sentinel.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ops-sg"
    Role = "operations"
  })
}

resource "aws_security_group" "application" {
  name        = "${local.name_prefix}-app-sg"
  description = "Application nodes accept service traffic only from the operations node."
  vpc_id      = aws_vpc.sentinel.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-sg"
    Role = "application"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ops_http" {
  security_group_id = aws_security_group.operations.id
  description       = "Public HTTP entry point through Nginx."
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ops_ssh" {
  count = var.admin_cidr != null && var.ec2_key_name != null ? 1 : 0

  security_group_id = aws_security_group.operations.id
  description       = "SSH from the administrator's public IP range only."
  cidr_ipv4         = var.admin_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ops_nagios_ui" {
  count = var.admin_cidr != null ? 1 : 0

  security_group_id = aws_security_group.operations.id
  description       = "Nagios web interface; administrator IP only."
  cidr_ipv4         = var.admin_cidr
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_http_from_ops" {
  security_group_id            = aws_security_group.application.id
  description                  = "Gunicorn application traffic from the operations node only."
  referenced_security_group_id = aws_security_group.operations.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_ssh_from_ops" {
  security_group_id            = aws_security_group.application.id
  description                  = "SSH administration from the operations node only."
  referenced_security_group_id = aws_security_group.operations.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_nrpe_from_ops" {
  security_group_id            = aws_security_group.application.id
  description                  = "NRPE monitoring from the operations node only."
  referenced_security_group_id = aws_security_group.operations.id
  from_port                    = 5666
  to_port                      = 5666
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ops_all_outbound" {
  security_group_id = aws_security_group.operations.id
  description       = "Outbound package updates, AWS APIs, and managed-node communication."
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "app_all_outbound" {
  security_group_id = aws_security_group.application.id
  description       = "Outbound package updates and AWS Systems Manager communication."
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
