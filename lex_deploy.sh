#!/bin/sh

PROFILE="uzura"
#REGION="us-west-2"
INTENT_NAME="FirstSupport"
BOT_NAME="GCSupportBot"

LAMBDA_ARN=`cat terraform.tfstate|grep '"arn": "arn:aws:lambda:'|sed -e 's/.*"\(.*\)": "\(arn:aws:lambda:\(.*\):\(.*\):function:\(.*\)\)",/\2/g'`
REGION=`cat terraform.tfstate|grep '"arn": "arn:aws:lambda:'|sed -e 's/.*"\(.*\)": "\(arn:aws:lambda:\(.*\):\(.*\):function:\(.*\)\)",/\3/g'`
ACCOUNT_ID=`cat terraform.tfstate|grep '"arn": "arn:aws:lambda:'|sed -e 's/.*"\(.*\)": "\(arn:aws:lambda:\(.*\):\(.*\):function:\(.*\)\)",/\4/g'`
LAMBDA_FUNCTION=`cat terraform.tfstate|grep '"arn": "arn:aws:lambda:'|sed -e 's/.*"\(.*\)": "\(arn:aws:lambda:\(.*\):\(.*\):function:\(.*\)\)",/\5/g'`
sed -e 's/\("uri"\: \)"arn\:aws\:lambda:xxxx",$/\1"'${LAMBDA_ARN}'",/g' data/FirstSupport.json > var/${INTENT_NAME}.json

aws lambda add-permission \
  --profile ${PROFILE} \
  --region ${REGION} \
  --function-name ${LAMBDA_FUNCTION} \
  --statement-id Allow${BOT_NAME} \
  --action lambda:InvokeFunction \
  --principal lex.amazonaws.com \
  --source-arn "arn:aws:lex:${REGION}:${ACCOUNT_ID}:intent:${INTENT_NAME}:*"

aws lex-models put-intent \
  --profile ${PROFILE} \
  --region ${REGION} \
  --name ${INTENT_NAME} \
  --cli-input-json file://var/${INTENT_NAME}.json

aws lex-models put-bot \
  --profile ${PROFILE} \
  --region ${REGION} \
  --name ${BOT_NAME} \
  --cli-input-json file://data/${BOT_NAME}.json
