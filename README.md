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
docker run -v /Users/shingo/.aws:/root/.aws -it --name ubuntu_tf_gc_con ubuntu_tf_gc:latest /bin/bash
```
Execute run.sh  
Move to your work dir, and chekout this project.


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



After downloaded, move the file to "src/server/config/" and rename "firebase-admin-credentials.json"

```bash
mv /path-to-downloaded-file var/gc_configs/firebase-admin-credentials.json
```



##### Authentication setting

Open Authentication page.

![firebase_config_07](https://raw.githubusercontent.com/uzura8/expressbird/dev_gc/src/doc/assets/img/firebase_config_07.png)



Register "Email/Password" and "Anonymous" for "Sign-in providers"

![firebase_config_08](https://raw.githubusercontent.com/uzura8/expressbird/dev_gc/src/doc/assets/img/firebase_config_08.png)

![firebase_config_09](https://raw.githubusercontent.com/uzura8/expressbird/dev_gc/src/doc/assets/img/firebase_config_09.png)




## Installation

### Setup config

```bash
cp terraform.tfvars.sample terraform.tfvars
cp bin/setup.conf.sample bin/setup.conf
vim terraform.tfvars
vim bin/setup.conf
# Edit config for your env
```

### Deploy

```bash
bash ./bin/deploy.sh
```

### Destroy

```bash
bash ./bin/destroy.sh
```
If you want to force execute, add option '-auto-approve'

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
