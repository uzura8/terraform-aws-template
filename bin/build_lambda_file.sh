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


cd var

if [ -e ${LAMBDA_TMP_DIR_NAME} ]; then
    rm -rf ${LAMBDA_TMP_DIR_NAME}
fi

git clone ${LAMBDA_GIT_REPO} ${LAMBDA_TMP_DIR_NAME}
cd ${LAMBDA_TMP_DIR_NAME}
npm install
mkdir lambda_function
cp index.js lambda_function/
cp -r node_modules lambda_function/
