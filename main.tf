provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

## Local
#module "module_keygen" {
#  source   = "./modules/local/keygen"
#  key_name = var.key_name
#}

# VPC
module "module_vpc" {
  source             = "./modules/aws/vpc"
  availability_zones = var.vpc_availability_zones
  common_prefix      = var.common_prefix
}

# EC2
module "module_ec2" {
  source                     = "./modules/aws/ec2"
  vpc_id                     = module.module_vpc.vpc_id
  subnet_public_a_web_id     = module.module_vpc.subnet_public_a_web_id
  subnet_public_b_web_id     = module.module_vpc.subnet_public_b_web_id
  ec2_is_enabled             = var.aws_ec2_is_enabled
  key_name                   = var.key_name
  security_ssh_ingress_cidrs = var.security_ssh_ingress_cidrs
  common_prefix              = var.common_prefix
  ec2_instance_type          = var.ec2_instance_type
  ec2_root_block_volume_type = var.ec2_root_block_volume_type
  ec2_root_block_volume_size = var.ec2_root_block_volume_size
  #ec2_ebs_block_volume_type  = var.ec2_ebs_block_volume_type
  #ec2_ebs_block_volume_size  = var.ec2_ebs_block_volume_size
  #public_key_value           = module.module_keygen.public_key_openssh
}

# ELB
module "module_elb" {
  source                 = "./modules/aws/elb"
  vpc_id                 = module.module_vpc.vpc_id
  subnet_public_a_web_id = module.module_vpc.subnet_public_a_web_id
  subnet_public_b_web_id = module.module_vpc.subnet_public_b_web_id
  common_prefix          = var.common_prefix
  health_check_path      = var.elb_health_check_path
  #ec2_web1_id            = module.module_ec2.ec2_web1_id
  #ec2_web2_id            = module.module_ec2.ec2_web2_id
}

# RDS
module "module_rds" {
  source                 = "./modules/aws/rds"
  vpc_id                 = module.module_vpc.vpc_id
  vpc_cidr_block         = module.module_vpc.vpc_cidr_block
  subnet_group_db_name   = module.module_vpc.subnet_group_db_name
  db_is_enabled          = var.aws_db_is_enabled
  db_is_enabled_multi_az = var.aws_db_is_enabled_multi_az
  db_instance_type       = var.aws_db_instance_type
  db_allocated_storage   = var.aws_db_allocated_storage
  db_block_volume_type   = var.aws_db_block_volume_type
  db_engine              = var.aws_db_engine
  db_engine_version      = var.aws_db_engine_version
  db_port                = var.aws_db_port
  db_username            = var.aws_db_username
  db_password            = var.aws_db_password
  db_name                = var.aws_db_name
  common_prefix          = var.common_prefix
}

## Setup WebApp
#module "module_webapp" {
#  source         = "./modules/remote/webapp"
#  app_is_enabled = var.app_is_enabled
#  key_name       = var.key_name
#  key_file_path  = var.key_file_path
#  ec2_obj_web1   = module.module_ec2.ec2_obj_web1
#  ec2_obj_web2   = module.module_ec2.ec2_obj_web2
#  #rds_obj   = module.module_rds.rds_obj
#}


variable "common_prefix" {}
variable "aws_profile" {}
variable "aws_region" {}
variable "aws_db_is_enabled" {}
variable "aws_db_is_enabled_multi_az" {}
variable "aws_db_instance_type" {}
variable "aws_db_allocated_storage" {}
variable "aws_db_block_volume_type" {}
variable "aws_db_engine" {}
variable "aws_db_engine_version" {}
variable "aws_db_port" {}
variable "aws_db_username" {}
variable "aws_db_password" {}
variable "aws_db_name" {}
variable "vpc_availability_zones" {}
variable "app_is_enabled" {}
variable "key_name" {}
variable "key_file_path" {}
variable "security_ssh_ingress_cidrs" {}
variable "aws_ec2_is_enabled" {}
variable "ec2_instance_type" {}
variable "ec2_root_block_volume_type" {}
variable "ec2_root_block_volume_size" {}
variable "elb_health_check_path" {}
#variable "ec2_ebs_block_volume_type" {}
#variable "ec2_ebs_block_volume_size" {}
