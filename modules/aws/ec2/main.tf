variable "vpc_id" {}
variable "subnet_public_web_id" {}
variable "public_key_value" {}
variable "key_name" {}
variable "common_prefix" {}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key_value}"
}

# security_group
resource "aws_security_group" "this" {
  name        = "${var.common_prefix}-aws-web-sg"
  description = "It is a security group on http of aws_vpc"
  vpc_id      = "${var.vpc_id}"
  tags = {
    Name = "${var.common_prefix}-aws-web"
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.this.id}"
}

resource "aws_security_group_rule" "web" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.this.id}"
}

resource "aws_security_group_rule" "web8080" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.this.id}"
}

resource "aws_security_group_rule" "all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.this.id}"
}

# EC2
resource "aws_instance" "web1" {
  ami                         = "ami-0ff21806645c5e492"
  instance_type               = "t2.micro"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.this.id}"]
  subnet_id                   = "${var.subnet_public_web_id}"
  associate_public_ip_address = "true"
  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = "100"
  }
  tags = {
    Name = "${var.common_prefix}-aws-ec2-web1"
    Role = "web1"
  }
}

# EIP
resource "aws_eip" "this" {
  instance = "${aws_instance.web1.id}"
  vpc      = true
  tags = {
    Name = "${var.common_prefix}-aws-ec2-web1"
  }
}
