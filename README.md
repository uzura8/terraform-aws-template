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
Move to your work dir on Docker container, and chekout this project.
If you have no need to push this repository, you use https protocol.

```bash
# On Docer Container

cd /your-work-dir/
git clone https://github.com/**********.git dir-name
cd dir-name
```

### Firebase registration

You need register and sign in to [Firebase](https://firebase.google.com/), before below settings

##### Create FIrebase Project

* Set project name
* Set to use GoogleAnalytics, if you need

##### Add web app

Choose icon for "Add Web App" ![firebase_config_01](https://raw.githubusercontent.com/uzura8/expressbird/dev_gc/src/doc/assets/img/firebase_config_01.png)



Input app-nickname and push "Register app" button

![firebase_config_02](https://raw.githubusercontent.com/uzura8/expressbird/dev_gc/src/doc/assets/img/firebase_config_02.png)



After registered, push "Next" button

And press "Continue to  console" button, then you go back to the project top



##### Set web app config to client side setting

Press "1 app" label, and press the cog icon of registered Web App ![firebase_config_03](https://raw.githubusercontent.com/uzura8/expressbird/dev_gc/src/doc/assets/img/firebase_config_03.png)

 ![firebase_config_04](https://raw.githubusercontent.com/uzura8/expressbird/dev_gc/src/doc/assets/img/firebase_config_04.png)



Scroll to "Firebase SDK snippet" section, and select "config" radio button ![firebase_config_05](https://raw.githubusercontent.com/uzura8/expressbird/dev_gc/src/doc/assets/img/firebase_config_05.png)



Copy rows in "const firebaseConfig" object on the source code, and exec below.

```bash
cp data/firebase_config.js.sample var/gc_configs/firebase_config.js
vi var/gc_configs/firebase_config.js
# Paste firebaseConfig object.
```

```js
const firebaseConfig = {
  // Paste Here!
}
```


##### Set web app config to server side setting

Press "Service account" tab on "Settings" page, and press "Generate new private key" button

![firebase_config_06](https://raw.githubusercontent.com/uzura8/expressbird/dev_gc/src/doc/assets/img/firebase_config_06.jpg)



After downloaded, copy this file and paste to var/gc_configs/firebase-admin-credentials.json

```bash
vi var/gc_configs/firebase-admin-credentials.json

# Paste credentials json
```



##### Authentication setting

Open Authentication page.

![firebase_config_07](https://raw.githubusercontent.com/uzura8/expressbird/dev_gc/src/doc/assets/img/firebase_config_07.png)



Register "Email/Password" and "Anonymous" for "Sign-in providers"

![firebase_config_08](https://raw.githubusercontent.com/uzura8/expressbird/dev_gc/src/doc/assets/img/firebase_config_08.png)

![firebase_config_09](https://raw.githubusercontent.com/uzura8/expressbird/dev_gc/src/doc/assets/img/firebase_config_09.png)




## Setup AWS Resources by Terraform
### Setup config

```bash
cp terraform.tfvars.sample terraform.tfvars
cp bin/setup.conf.sample bin/setup.conf
vi terraform.tfvars
vi bin/setup.conf
# Edit config for your env
```

```bash
# General
aws_profile = "default"
aws_region  = "ap-northeast-1"

common_prefix = "tf" # If set this, apply to AWS resource name

# EC2
key_name = "greatefulchat"
ec2_ami                    = "ami-052652af12b58691f"  # Set this latest Amazon Linux 2(64bit x86) AMI
ec2_instance_type          = "t2.micro"
ec2_root_block_volume_type = "standard" # gp2 / io1 / standard
ec2_root_block_volume_size = "15"
ec2_ebs_block_volume_type  = "standard" # gp2 / io1 / standard
ec2_ebs_block_volume_size  = "50"

# RDS
aws_db_name     = "dbgc"
aws_db_username = "db_admin"
aws_db_password = "set-password"

# Lambda
aws_lambda_region = "us-west-2"
```

```bash
# bin/setup.conf

## Local
### Lambda deploy
LAMBDA_GIT_REPO="https://github.com/uzura8/gc-support-chat-lex-bot.git"
LAMBDA_TMP_DIR_NAME="workspace"

### Amazon Lex
AWS_LEX_INTENT_NAME="FirstSupport"
AWS_LEX_BOT_NAME="GCSupportBot"

### common
GC_DIR_NAME="grateful_chat"
GC_GIT_REPO="https://github.com/uzura8/expressbird.git"
GC_GIT_BRANCH="dev_gc"

### Local
#### common
GC_PORT="8080"
GC_USE_SSL="false"

#### server
GC_SESSION_SECRET_KEY="set-secret-key" # Use for session key. You have to change this!

#### client
#WEB_DOMAIN="chat.example.com" # Set site domain, if you have own domain name
WEB_BASE_URL="/" # Set document root path
WEB_SITE_NAME="Sample Chat Support Site" # Set site name

##### AWS
AWS_LEX_REGION="us-west-2"

### Remote
NODE_VER="v10.17.0" # Set NodeJS Version
GC_ADMIN_EMAIL="admin@example.com" # Use for GC login by Admin user
GC_ADMIN_PASSWORD="password"       # Use for GC login by Admin user
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

### Set GratefulChat window on outer site

You set below tag on your site HTML, and Access the page!

```html
<script src="http://ec2-xxx-xxx-xxx-xxx.ap-northeast-1.compute.amazonaws.com/assets/js/chat_frame.js"></script>
```


## Destroy AWS Resources

```bash
bash ./bin/destroy.sh
```

