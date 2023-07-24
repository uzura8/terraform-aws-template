# terraform-aws-template

### Build enviroment of Terraform exicution

You have to install AWS-CLI, terraform, jq, npm on enviroment of terraform execution

#### Setup enviroment on mac

```bash
brew install jq
brew install tfenv
tfenv install 1.4.6
```

Refer to [AWS docs](https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html) to install AWS-CLI

## Setup AWS Resources by Terraform

### Setup config

```bash
cp terraform.tfvars.sample terraform.tfvars
vim terraform.tfvars
vim bin/remote_setup_webapp.sh
# Edit config for your env
```

```bash
# terraform.tfvars

# General
aws_profile = "default"
aws_region  = "ap-northeast-1"

common_prefix = "tf"

# VPC
vpc_availability_zones = ["ap-northeast-1c", "ap-northeast-1d"]

# EC2
key_name                   = "your-ssh-keypair-name"
key_file_path              = "~/.ssh/your-ssh-key-file-name"
security_ssh_ingress_cidrs = ["0.0.0.0/0"]          # Set by Array type
ec2_instance_type          = "t2.micro"
ec2_root_block_volume_type = "gp2" # gp2 / io1 / standard
ec2_root_block_volume_size = "20"
#ec2_ebs_block_volume_type  = "gp2" # gp2 / io1 / standard
#ec2_ebs_block_volume_size  = "50"

# RDS
aws_db_instance_type     = "db.t2.micro"
aws_db_block_volume_type = "gp2" # gp2 / io1 / standard
aws_db_allocated_storage = "20"  # GB
aws_db_engine            = "mysql"
aws_db_engine_version    = "5.7.28"
aws_db_port              = "3306"
aws_db_name              = "" # Set this, if create db
aws_db_username          = "set-db_admin"
aws_db_password          = "set-db_password"
```

Set execute file on remote server

```bash
cp bin/remote_setup_web.sh.sample bin/remote_setup_web.sh
```

```bash
# bin/remote_setup_web.sh

NODE_VER=18.16.1
```

### Deploy

```bash
terraform init -backend-config="bucket=your-deployment" -backend-config="key=terraform/your-project/terraform.tfstate" -backend-config="region=ap-northeast-1" -backend-config="profile=your-aws-profile-name"
terraform apply -auto-approve -var-file=./terraform.tfvars
```

### Check on browser

Get ec2 dns

```bash
jq -r '.resources[]|select(.type == "aws_eip").instances[0].attributes.public_dns' terraform.tfstate

# You get like ec2-xxx-xxx-xxx-xxx.ap-northeast-1.compute.amazonaws.com
```

And you request http://ec2-xxx-xxx-xxx-xxx.ap-northeast-1.compute.amazonaws.com on browser.

#### Other informations after deploy

First, you have to get terraform.json from S3 Bucket

Get RDS address

```bash
jq -r '.resources[]|select(.type == "aws_db_instance").instances[0].attributes.address' terraform.json
```

Get Elastick IP address

```bash
jq -r '.resources[]|select(.type == "aws_eip")|.instances[0] | .attributes | .public_ip' terraform.json
```

## Destroy AWS Resources

```bash
bash ./bin/destroy.sh
```
