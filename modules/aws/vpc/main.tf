variable "availability_zone" {}

resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "aws-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"
  tags = {
    Name = "aws-gw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.this.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.this.id}"
  }
  tags = {
    Name = "aws-public-rt"
  }
}

resource "aws_subnet" "public_web" {
  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "${var.availability_zone}"
  map_public_ip_on_launch = true
  tags = {
    Name = "aws-public-web-subnet"
  }
}

resource "aws_route_table_association" "public_web" {
  subnet_id      = "${aws_subnet.public_web.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

# network db
resource "aws_subnet" "private_db1" {
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.availability_zone}"
  tags = {
    Name = "aws-private-db1-subnet"
  }
}

resource "aws_subnet" "private_db2" {
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "aws-private-db2-subnet"
  }
}

resource "aws_db_subnet_group" "main" {
  description = "It is a DB subnet group on tf_vpc."
  subnet_ids  = ["${aws_subnet.private_db1.id}", "${aws_subnet.private_db2.id}"]
  tags = {
    Name = "aws-dbsubnet"
  }
}
