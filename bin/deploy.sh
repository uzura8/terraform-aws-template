#!/bin/bash

terraform init && bash ./bin/build_lambda_file.sh && terraform apply -auto-approve && bash ./bin/lex_deploy.sh
