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
cp bin/setup.conf.sample bin/setup.conf
vim terraform.tfvars
vim bin/setup.conf
# Edit config for your env
```

```bash
# terraform.tfvars

# General
aws_profile = "default"
aws_region  = "ap-northeast-1"

# RDS
aws_db_name     = "dbgc"
aws_db_username = "db_admin"
aws_db_password = ""

# Lambda
aws_lambda_region = "us-west-2"
```

```bash
# bin/setup.conf

### Local
#### common
GC_PORT="3000"
GC_USE_SSL="true"

#### server
GC_SESSION_SECRET_KEY="set-secret-key" # Use for session key

#### client
#GC_DOMAIN="chat.example.com" # Set site domain
GC_BASE_URL="/" # Set document root path
GC_SITE_NAME="Sample Chat Support Site" # Set site name
```

### Deploy

```bash
bash ./bin/deploy.sh
```

### Check GratefulChat on browser
Get ec2 dns

```bash
jq -r '.resources[]|select(.type == "aws_eip").instances[0].attributes.public_dns' terraform.tfstate

# You get like ec2-xxx-xxx-xxx-xxx.ap-northeast-1.compute.amazonaws.com
```
And you request http://ec2-xxx-xxx-xxx-xxx.ap-northeast-1.compute.amazonaws.com on browser.


## Destroy AWS Resources

```bash
bash ./bin/destroy.sh
```

