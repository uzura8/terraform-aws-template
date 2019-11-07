# terraform-aws-template

You have to install AWS-CLI, terraform before setup

### Installation

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
