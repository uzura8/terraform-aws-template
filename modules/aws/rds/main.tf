variable "vpc_id" {}
variable "subnet_group_db_name" {}
variable "security_group_web_id" {}
variable "db_username" {}
variable "db_password" {}
variable "db_name" {}
variable "ec2_key_name" {}
variable "ec2_public_ip" {}
variable "gc_admin_email" {}
variable "gc_admin_password" {}

locals {
  private_key_file = "var/${var.ec2_key_name}.id_rsa"
}

resource "aws_security_group" "this" {
  name        = "aws-db-sg"
  description = "It is a security group on db of aws_vpc."
  vpc_id      = "${var.vpc_id}"
  tags = {
    Name = "aws-rds"
  }
}

resource "aws_security_group_rule" "db" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = "${var.security_group_web_id}"
  security_group_id        = "${aws_security_group.this.id}"
}

resource "aws_db_instance" "db" {
  identifier                = "tf-dbinstance"
  allocated_storage         = 5
  engine                    = "mysql"
  engine_version            = "5.7.26"
  instance_class            = "db.t2.micro"
  storage_type              = "gp2"
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

resource "null_resource" "ec2-ssh-connection" {
  provisioner "remote-exec" {
    inline = [
      #"echo 'CREATE DATABASE ${var.db_name} DEFAULT CHARACTER SET utf8' | mysql -u ${var.db_username} -p ${var.db_password} -h ${aws_db_instance.db.address} -P 3306",
      "mysql -u ${var.db_username} -h ${aws_db_instance.db.address} -P 3306 ${var.db_name} < /home/ec2-user/gc_configs/setup.sql",
      "node /home/ec2-user/grateful_chat/server/create_admin_user.js ${gc_admin_email} ${gc_admin_password} 'AdminUser'"
    ]

    connection {
      host        = "${var.ec2_public_ip}"
      type        = "ssh"
      port        = 22
      user        = "ec2-user"
      private_key = file("${local.private_key_file}")
      timeout     = "10m"
      agent       = false
    }
  }
}
