resource "aws_instance" "ops" {
  ami                         = var.ubuntu_ami_id
  instance_type               = var.ops_instance_type
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.operations.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm.name
  associate_public_ip_address = true
  key_name                    = var.ec2_key_name
  user_data                   = file("${path.module}/cloud-init/ssm-agent.sh")

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ops"
    Role = "operations"
  })
}

resource "aws_instance" "blue" {
  ami                         = var.ubuntu_ami_id
  instance_type               = var.app_instance_type
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.application.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm.name
  associate_public_ip_address = true
  key_name                    = var.ec2_key_name
  user_data                   = file("${path.module}/cloud-init/ssm-agent.sh")

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-blue"
    Role = "application-blue"
  })
}

resource "aws_instance" "green" {
  ami                         = var.ubuntu_ami_id
  instance_type               = var.app_instance_type
  subnet_id                   = aws_subnet.public_b.id
  vpc_security_group_ids      = [aws_security_group.application.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm.name
  associate_public_ip_address = true
  key_name                    = var.ec2_key_name
  user_data                   = file("${path.module}/cloud-init/ssm-agent.sh")

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-green"
    Role = "application-green"
  })
}
