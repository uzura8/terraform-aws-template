# terraform-aws-template

## Before Setup
You have to install AWS-CLI, terraform, jq before setup

### Setup for mac
```bash
brew install terraform
brew install jq
```
Refer to [AWS docs](https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html) to install AWS-CLI

### Firebase registration
Save local and move to dir var/gc_configs and rename to "firebase-admin-credentials.json"

## Installation

Setup config.

```bash
cp terraform.tfvars.sample terraform.tfvars
vi terraform.tfvars
# Edit config
```

Execute

```bash
terraform init
make deploy
```

Destroy

```bash
make destroy
```
