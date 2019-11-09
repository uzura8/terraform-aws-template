#!/bin/bash

# include common file
COMMON_FILE="`dirname $0`/common.sh"
if [ ! -f $COMMON_FILE ]; then
  echo "Not found common file : ${COMMON_FILE}" ; exit 1
fi
. $COMMON_FILE


PROFILE=`tf_conf aws_profile`
INTENT_NAME=`tf_conf aws_lex_intent_name`
BOT_NAME=`tf_conf aws_lex_bot_name`
REGION=`cat terraform.tfstate|grep '"arn": "arn:aws:lambda:'|sed -e 's/.*"\(.*\)": "\(arn:aws:lambda:\(.*\):\(.*\):function:\(.*\)\)",/\3/g'`

aws lex-models delete-bot \
  --profile ${PROFILE} \
  --region ${REGION} \
  --name ${BOT_NAME} \

aws lex-models delete-intent \
  --profile ${PROFILE} \
  --region ${REGION} \
  --name ${INTENT_NAME} \

#aws lambda remove-permission \
#  --function-name ${LAMBDA_FUNCTION} \
#  --statement-id Allow${BOT_NAME}
