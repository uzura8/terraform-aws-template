variable "db_is_enabled" {}
variable "db_is_enabled_multi_az" {}
variable "vpc_id" {}
variable "vpc_cidr_block" {}
variable "subnet_group_db_name" {}
variable "db_instance_type" {}
variable "db_block_volume_type" {}
variable "db_allocated_storage" {}
variable "db_engine" {}
variable "db_engine_version" {}
variable "db_port" {}
variable "db_username" {}
variable "db_password" {}
variable "db_name" {}
variable "common_prefix" {}

resource "aws_security_group" "db" {
  name   = join("-", [var.common_prefix, "sg", "db"])
  vpc_id = var.vpc_id
  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = join("-", [var.common_prefix, "sg", "db"])
    ManagedBy = "terraform"
  }
}

resource "aws_db_instance" "db" {
  count                     = var.db_is_enabled
  identifier                = join("-", [var.common_prefix, "rds", "db"])
  allocated_storage         = var.db_allocated_storage
  storage_type              = var.db_block_volume_type
  engine                    = var.db_engine
  engine_version            = var.db_engine_version
  instance_class            = var.db_instance_type
  username                  = var.db_username
  password                  = var.db_password
  name                      = var.db_name != "" ? var.db_name : ""
  vpc_security_group_ids    = [aws_security_group.db.id]
  db_subnet_group_name      = var.subnet_group_db_name
  multi_az                  = var.db_is_enabled_multi_az == 1 ? true : false
  backup_retention_period   = 1
  final_snapshot_identifier = false
  skip_final_snapshot       = true
  apply_immediately         = true
  #parameter_group_name   = "default.mysql5.7"

  tags = {
    Name      = join("-", [var.common_prefix, "rds", "db"])
    ManagedBy = "terraform"
  }
}

