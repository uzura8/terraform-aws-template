#!/bin/bash

# include config file
CONFIG_FILE="`dirname $0`/setup.conf"
if [ ! -f $CONFIG_FILE ]; then
    echo "Not found config file : ${CONFIG_FILE}" ; exit 1
fi
. $CONFIG_FILE

# include common file
COMMON_FILE="`dirname $0`/common.sh"
if [ ! -f $COMMON_FILE ]; then
  echo "Not found common file : ${COMMON_FILE}" ; exit 1
fi
. $COMMON_FILE


PROFILE=`tf_conf aws_profile`
REGION=`cat terraform.tfstate|grep '"arn": "arn:aws:lambda:'|sed -e 's/.*"\(.*\)": "\(arn:aws:lambda:\(.*\):\(.*\):function:\(.*\)\)",/\3/g'`

aws lex-models delete-bot \
  --profile ${PROFILE} \
  --region ${REGION} \
  --name ${AWS_LEX_BOT_NAME} \

aws lex-models delete-intent \
  --profile ${PROFILE} \
  --region ${REGION} \
  --name ${AWS_LEX_INTENT_NAME} \

#aws lambda remove-permission \
#  --function-name ${LAMBDA_FUNCTION} \
#  --statement-id Allow${AWS_LEX_BOT_NAME}
