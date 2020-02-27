# terraform-aws-template

## 事前準備
### CNAME で登録するドメインの所有者確認
* Google Search Console( https://search.google.com/search-console )にアクセス
* TXT に登録する文字列をコピーし、gcs-site.example.com の TXT にペースト&DNSレコードに反映
    + 参考: https://support.google.com/webmasters/answer/7687615?hl=ja#manage-owners
* Google Search Console で「承認」を実行
* gcs-site.example.com の CNAME に c.storage.googleapis.com を登録
* billing 権限を持つサービスアカウントを ウェブマスターツールでドメイン所有者に追加する
    + 参考: https://cloud.google.com/storage/docs/domain-name-verification?hl=ja

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
RUN wget https://releases.hashicorp.com/terraform/0.12.12/terraform_0.12.12_linux_amd64.zip
RUN unzip terraform_0.12.12_linux_amd64.zip
RUN cp terraform /usr/local/bin

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

python2_version = "2.7.15" # Set python2 version on your enviroment
python3_version = "3.7.2" # Set python3 version on your enviroment
```

### Deploy Resources

```bash
bash ./bin/deploy.sh
```

## Destroy Resources

```bash
bash ./bin/destroy.sh
```

