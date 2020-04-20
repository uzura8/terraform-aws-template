variable "common_prefix" {}
variable "vpc_id" {}
variable "subnet_public_web_id" {}
variable "key_name" {}
variable "security_ssh_ingress_cidrs" {}
variable "ec2_instance_type" {}
variable "ec2_root_block_volume_type" {}
variable "ec2_root_block_volume_size" {}
#variable "ec2_ebs_block_volume_type" {}
#variable "ec2_ebs_block_volume_size" {}
#variable "public_key_value" {}

#resource "aws_key_pair" "key_pair" {
#  key_name   = var.key_name
#  public_key = var.public_key_value
#}

# security_group
resource "aws_security_group" "this" {
  name        = join("-", [var.common_prefix, "sg-web"])
  description = "It is a security group on http of aws_vpc"
  vpc_id      = var.vpc_id
  tags = {
    Name      = join("-", [var.common_prefix, "sg-web"])
    ManagedBy = "terraform"
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.security_ssh_ingress_cidrs
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "web" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "web8080" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

# EC2
resource "aws_instance" "web1" {
  ami                         = data.aws_ami.amazon_linux2.id
  instance_type               = var.ec2_instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.this.id]
  subnet_id                   = var.subnet_public_web_id
  associate_public_ip_address = "true"

  root_block_device {
    volume_type = var.ec2_root_block_volume_type
    volume_size = var.ec2_root_block_volume_size
  }

  tags = {
    Name      = join("-", [var.common_prefix, "ec2-web1"])
    Role      = "web1"
    ManagedBy = "terraform"
  }

  #ebs_block_device {
  #  device_name = "/dev/sdf"
  #  volume_type = var.ec2_ebs_block_volume_type
  #  volume_size = var.ec2_ebs_block_volume_size
  #}

  #user_data = file("bin/ec2_userdata.sh")
}

# EIP
resource "aws_eip" "this" {
  instance = aws_instance.web1.id
  vpc      = true
  tags = {
    Name      = join("-", [var.common_prefix, "eip-web1"])
    ManagedBy = "terraform"
  }
}
