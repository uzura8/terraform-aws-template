#!/bin/shell


IP=`cat ./terraform.tfstate|jq -r '.resources[]|select(.type == "aws_eip")|.instances[0] | .attributes | .public_ip'`
echo ${IP}
ssh -i var/greatefulchat.id_rsa ec2-user@${IP}
