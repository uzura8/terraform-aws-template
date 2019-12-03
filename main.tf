variable "common_prefix" {}
variable "aws_profile" {}
variable "aws_region" {}
variable "key_name" {}

provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

# Local
module "module_keygen" {
  source   = "./modules/local/keygen"
  key_name = "${var.key_name}"
}

# VPC
module "module_vpc" {
  source = "./modules/aws/vpc"
}

# EC2
module "module_ec2" {
  source               = "./modules/aws/ec2"
  vpc_id               = "${module.module_vpc.vpc_id}"
  subnet_public_web_id = "${module.module_vpc.subnet_public_web_id}"
  public_key_value     = "${module.module_keygen.public_key_openssh}"
  key_name             = "${var.key_name}"
  common_prefix        = "${var.common_prefix}"
}

## RDS
#module "module_rds" {
#  source                = "./modules/aws/rds"
#  vpc_id                = "${module.module_vpc.vpc_id}"
#  security_group_web_id = "${module.module_ec2.security_group_web_id}"
#  subnet_group_db_name  = "${module.module_vpc.subnet_group_db_name}"
#  db_username           = "${var.aws_db_username}"
#  db_password           = "${var.aws_db_password}"
#  db_name               = "${var.aws_db_name}"
#  common_prefix         = "${var.common_prefix}"
#}

# Setup GC
module "module_gc" {
  source   = "./modules/remote/gc"
  key_name = "${var.key_name}"
  ec2_obj  = "${module.module_ec2.ec2_obj}"
  #rds_obj   = "${module.module_rds.rds_obj}"
  public_ip = "${module.module_ec2.elastic_ip_of_web}"
}

