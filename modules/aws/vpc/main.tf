variable "availability_zones" {}

#data "aws_availability_zones" "available" {
#  state = "available"
#}


resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = join("-", [var.common_prefix, "vpc"])
    ManagedBy = "terraform"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name      = join("-", [var.common_prefix, "igw"])
    ManagedBy = "terraform"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name      = join("-", [var.common_prefix, "rtb", "public"])
    ManagedBy = "terraform"
  }
}

resource "aws_subnet" "public_web" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true
  #availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name      = join("-", [var.common_prefix, "subnet", "web"])
    ManagedBy = "terraform"
  }
}

resource "aws_route_table_association" "public_web" {
  subnet_id      = aws_subnet.public_web.id
  route_table_id = aws_route_table.public_rt.id
}

# network db
resource "aws_subnet" "private_db1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zones[0]
  #availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name      = join("-", [var.common_prefix, "subnet", "db-1"])
    ManagedBy = "terraform"
  }
}

resource "aws_subnet" "private_db2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zones[1]
  #availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name      = join("-", [var.common_prefix, "subnet", "db-2"])
    ManagedBy = "terraform"
  }
}

resource "aws_db_subnet_group" "main" {
  description = "It is a DB subnet group on tf_vpc."
  subnet_ids  = [aws_subnet.private_db1.id, aws_subnet.private_db2.id]

  tags = {
    Name      = join("-", [var.common_prefix, "subnet", "db"])
    ManagedBy = "terraform"
  }
}
