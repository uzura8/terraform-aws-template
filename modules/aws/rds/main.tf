variable "vpc_id" {}
variable "subnet_group_db_name" {}
variable "security_group_web_id" {}
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

resource "aws_security_group" "this" {
  name        = "aws-db-sg"
  description = "It is a security group on db of aws_vpc."
  vpc_id      = "${var.vpc_id}"
  tags = {
    Name = "${var.common_prefix}-aws-rds"
  }
}

resource "aws_security_group_rule" "db" {
  type                     = "ingress"
  from_port                = "${var.db_port}"
  to_port                  = "${var.db_port}"
  protocol                 = "tcp"
  source_security_group_id = "${var.security_group_web_id}"
  security_group_id        = "${aws_security_group.this.id}"
}

resource "aws_db_instance" "db" {
  identifier                = "${var.common_prefix}-aws-rds-db01"
  allocated_storage         = "${var.db_allocated_storage}"
  engine                    = "${var.db_engine}"
  engine_version            = "${var.db_engine_version}"
  instance_class            = "${var.db_instance_type}"
  storage_type              = "${var.db_block_volume_type}"
  username                  = "${var.db_username}"
  password                  = "${var.db_password}"
  name                      = "${var.db_name}"
  backup_retention_period   = 1
  vpc_security_group_ids    = ["${aws_security_group.this.id}"]
  db_subnet_group_name      = "${var.subnet_group_db_name}"
  final_snapshot_identifier = false
  skip_final_snapshot       = true
  apply_immediately         = true
}

