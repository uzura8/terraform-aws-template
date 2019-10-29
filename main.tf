variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {
  default = "ap-northeast-1"
}
variable "aws_db_username" {}
variable "aws_db_password" {}
variable "aws_key_name" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

# network
resource "aws_vpc" "tf_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "tf_vpc"
  }
}

resource "aws_subnet" "public_web" {
  vpc_id                  = "${aws_vpc.tf_vpc.id}"
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "tf_public_web"
  }
}

resource "aws_subnet" "private_db1" {
  vpc_id            = "${aws_vpc.tf_vpc.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1b"
  tags = {
    Name = "tf_private_db1"
  }
}

resource "aws_subnet" "private_db2" {
  vpc_id            = "${aws_vpc.tf_vpc.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "tf_private_db2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.tf_vpc.id}"
  tags = {
    Name = "tf-gw"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = "${aws_vpc.tf_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = {
    Name = "tf_rtb"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = "${aws_subnet.public_web.id}"
  route_table_id = "${aws_route_table.public_rtb.id}"
}

# security_group
resource "aws_security_group" "app" {
  name        = "tf_web"
  description = "It is a security group on http of tf_vpc"
  vpc_id      = "${aws_vpc.tf_vpc.id}"
  tags = {
    Name = "tf_web"
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.app.id}"
}

resource "aws_security_group_rule" "web" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.app.id}"
}

resource "aws_security_group_rule" "all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.app.id}"
}

resource "aws_security_group" "db" {
  name        = "db_server"
  description = "It is a security group on db of tf_vpc."
  vpc_id      = "${aws_vpc.tf_vpc.id}"
  tags = {
    Name = "tf_db"
  }
}

resource "aws_security_group_rule" "db" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.app.id}"
  security_group_id        = "${aws_security_group.db.id}"
}

# network db
resource "aws_db_subnet_group" "main" {
  name        = "tf_dbsubnet"
  description = "It is a DB subnet group on tf_vpc."
  subnet_ids  = ["${aws_subnet.private_db1.id}", "${aws_subnet.private_db2.id}"]
  tags = {
    Name = "tf_dbsubnet"
  }
}

# RDS
resource "aws_db_instance" "db" {
  identifier              = "tf-dbinstance"
  allocated_storage       = 5
  engine                  = "mysql"
  engine_version          = "5.7.26"
  instance_class          = "db.t2.micro"
  storage_type            = "gp2"
  username                = "${var.aws_db_username}"
  password                = "${var.aws_db_password}"
  backup_retention_period = 1
  vpc_security_group_ids  = ["${aws_security_group.db.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.main.name}"
}

# EC2
resource "aws_instance" "web" {
  ami                         = "ami-0ff21806645c5e492"
  instance_type               = "t2.micro"
  key_name                    = "${var.aws_key_name}" # EC2 に登録済の Key Pairs を指定する
  vpc_security_group_ids      = ["${aws_security_group.app.id}"]
  subnet_id                   = "${aws_subnet.public_web.id}"
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
    Name = "tf_instance"
  }
}

# EIP
resource "aws_eip" "web" {
  instance = "${aws_instance.web.id}"
  vpc      = true
}

# for console output
output "elastic_ip_of_web" {
  value = "${aws_eip.web.public_ip}"
}
