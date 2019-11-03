variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "aws_db_username" {}
variable "aws_db_password" {}
variable "aws_key_name" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
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
  aws_key_name         = "${var.aws_key_name}"
}

# RDS
module "module_rds" {
  source                = "./modules/aws/rds"
  vpc_id                = "${module.module_vpc.vpc_id}"
  security_group_web_id = "${module.module_ec2.security_group_web_id}"
  subnet_group_db_name  = "${module.module_vpc.subnet_group_db_name}"
  db_username           = "${var.aws_db_username}"
  db_password           = "${var.aws_db_password}"
}

