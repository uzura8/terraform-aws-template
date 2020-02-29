# terraform-illuststrap-template

## Preparation
### Verify the owner of the domain you register with CNAME
* Access to Google Search Console( https://search.google.com/search-console )
* Register TXT your domain of DNS record
    + Refer to: https://support.google.com/webmasters/answer/7687615?hl=ja#manage-owners
* Execute "Approve" on Google Search Console
* Register "c.storage.googleapis.com" CNAME of your domain 
* Add a service account with billing privileges to a domain owner in Webmaster Tools
    * Refer to: https://cloud.google.com/storage/docs/domain-name-verification?hl=ja



### Create GCP Project

Refer to [GCP docs](https://cloud.google.com/resource-manager/docs/creating-managing-projects) to create project



### Build enviroment of Terraform exicution
You have to install gsutil, terraform on enviroment of terraform execution



#### Setup enviroment on mac

```bash
brew install tfenv
tfenv install 0.12.12
```
Refer to [GCP docs](https://cloud.google.com/storage/docs/gsutil_install) to install gsutil



#### Setup enviroment on Ubuntu by Docker

##### Dockerfile

```
RUN chsh -s /usr/bin/zsh
FROM ubuntu:18.04
USER root
RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN yes | add-apt-repository ppa:jonathonf/vim
RUN apt-get -y update
RUN apt-get -y install zsh
RUN chsh -s /usr/bin/zsh
RUN /usr/bin/zsh
RUN apt-get -y install git docker vim neovim
RUN apt-get -y install python3.6-dev
RUN apt-get -y install python3-pip
RUN pip install --upgrade pip
RUN apt-get -y update
RUN apt-get install wget
RUN apt-get -y install zip unzip
RUN apt-get install -y curl
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -y && apt-get install google-cloud-sdk -y
RUN wget https://releases.hashicorp.com/terraform/0.12.12/terraform_0.12.12_linux_amd64.zip
RUN unzip terraform_0.12.12_linux_amd64.zip
RUN cp terraform /usr/local/bin

WORKDIR /root
```

##### run.sh
```bash
docker build -t ubuntu_terraform_sg .
docker stop ubuntu_terraform_sg_con
docker rm ubuntu_terraform_sg_con
docker run -v /Users/hogehoge/.config/gcloud:/root/.config/gcloud -v /Users/hogehoge/.vim:/root/.vim -it --name ubuntu_terraform_sg_con ubuntu_terraform_sg:latest /bin/bash
```
Execute run.sh  
Move to your work dir, and chekout this project.




## Setup AWS Resources by Terraform
### Setup config

```bash
cp terraform.tfvars.sample terraform.tfvars
vim terraform.tfvars
# Edit config for your env
```

```bash
# terraform.tfvars

# General
common_prefix = "tf-sg"

gcp_credential_path = "Set your gcp credential json file path"
gcp_project         = "Set your gcp project ID"
gcp_region          = "Set gcp region"

gcs_class = "REGIONAL" # STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE

site_domain  = "example.com" # Apply this as strage name
git_repo_url = "https://github.com/uzura8/simple-site-generator.git"
```

### Deploy Resources

```bash
bash ./bin/deploy.sh
```

### Destroy Resources

```bash
bash ./bin/destroy.sh
```



## Update Site Contents

````bash
cd var/site-generator/
# Edit content files under content dir and build
python3 builder.py

# And upload to GCP Strage
cd ../../
bash bin/upload.sh your-domain.com
````