#!/bin/sh

PROFILE="uzura"
INTENT_NAME="FirstSupport"
BOT_NAME="GCSupportBot"

REGION=`cat terraform.tfstate|grep '"arn": "arn:aws:lambda:'|sed -e 's/.*"\(.*\)": "\(arn:aws:lambda:\(.*\):\(.*\):function:\(.*\)\)",/\3/g'`
#LAMBDA_FUNCTION=`cat terraform.tfstate|grep '"arn": "arn:aws:lambda:'|sed -e 's/.*"\(.*\)": "\(arn:aws:lambda:\(.*\):\(.*\):function:\(.*\)\)",/\5/g'`

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
