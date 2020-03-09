# terraform-aws-template

### Build enviroment of Terraform exicution
You have to install AWS-CLI, terraform, jq, npm on enviroment of terraform execution

#### Setup enviroment on mac
```bash
brew install jq
brew install tfenv
tfenv install 0.12.12
```
Refer to [AWS docs](https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html) to install AWS-CLI

#### Setup enviroment on Ubuntu by Docker
##### Dockerfile

```
FROM ubuntu:18.04
RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN yes | add-apt-repository ppa:jonathonf/vim
RUN apt-get -y update
RUN apt-get -y install zsh
RUN chsh -s /usr/bin/zsh
RUN /usr/bin/zsh
RUN apt-get -y install git docker python vim neovim
RUN apt-get install -y python-pip
RUN pip install --upgrade pip
RUN yes|pip install awscli
RUN apt-get -y update
RUN apt-get install wget
RUN apt-get -y install zip unzip
RUN apt-get -y install jq
RUN wget https://releases.hashicorp.com/terraform/0.12.12/terraform_0.12.12_linux_amd64.zip
RUN unzip terraform_0.12.12_linux_amd64.zip
RUN cp terraform /usr/local/bin
RUN apt-get -y install nodejs npm
RUN npm install n -g
RUN n stable

WORKDIR /root
```

##### run.sh
```bash
docker build -t ubuntu_tf_gc .
docker stop ubuntu_tf_gc_con
docker rm ubuntu_tf_gc_con
docker run -v /user-home-dir-path/.aws:/root/.aws -it --name ubuntu_tf_gc_con ubuntu_tf_gc:latest /bin/bash
```
Execute run.sh  
Move to your work dir, and chekout this project.


## Setup AWS Resources by Terraform
### Setup config

```bash
cp terraform.tfvars.sample terraform.tfvars
vim terraform.tfvars
vim bin/remote_setup_web.sh
# Edit config for your env
```

```bash
# terraform.tfvars

# General
aws_profile = "default"
aws_region  = "ap-northeast-1"

common_prefix = "tf"

# VPC
vpc_availability_zone = "ap-northeast-1a"

# EC2
key_name                   = "your-ssh-key-name"
ec2_ami                    = "ami-011facbea5ec0363b"
ec2_instance_type          = "t2.micro"
ec2_root_block_volume_type = "standard" # gp2 / io1 / standard
ec2_root_block_volume_size = "15"
ec2_ebs_block_volume_type  = "standard" # gp2 / io1 / standard
ec2_ebs_block_volume_size  = "50"

# RDS
aws_db_instance_type     = "db.t2.micro"
aws_db_block_volume_type = "gp2" # gp2 / io1 / standard
aws_db_allocated_storage = "20"  # GB
aws_db_engine            = "mysql"
aws_db_engine_version    = "5.7.28"
aws_db_port              = "3306"
aws_db_name              = "set-db_name"
aws_db_username          = "set-db_admin"
aws_db_password          = "set-db_password"
```

```bash
# bin/remote_setup_web.sh

NODE_VER=12.15.0
SERVISE_DOMAIN=example.com
```

### Deploy

```bash
bash ./bin/deploy.sh
```

### Check on browser
Get ec2 dns

```bash
jq -r '.resources[]|select(.type == "aws_eip").instances[0].attributes.public_dns' terraform.tfstate

# You get like ec2-xxx-xxx-xxx-xxx.ap-northeast-1.compute.amazonaws.com
```
And you request http://ec2-xxx-xxx-xxx-xxx.ap-northeast-1.compute.amazonaws.com on browser.

#### Other informations after deploy
Get RDS address

```bash
jq -r '.resources[]|select(.type == "aws_db_instance").instances[0].attributes.address' terraform.tfstate
```

Get Elastick IP address

```bash
jq -r '.resources[]|select(.type == "aws_eip")|.instances[0] | .attributes | .public_ip' terraform.tfstate
```


## Destroy AWS Resources

```bash
bash ./bin/destroy.sh
```

