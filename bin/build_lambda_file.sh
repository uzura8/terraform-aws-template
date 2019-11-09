#!/bin/bash

# include common file
COMMON_FILE="`dirname $0`/common.sh"
if [ ! -f $COMMON_FILE ]; then
  echo "Not found common file : ${COMMON_FILE}" ; exit 1
fi
. $COMMON_FILE


GIT_URL=`tf_conf lambda_git_repo`
DIR_NAME=`tf_conf lambda_tmp_dir_name`

cd var

if [ -e ${DIR_NAME} ]; then
    rm -rf ${DIR_NAME}
fi

git clone ${GIT_URL} ${DIR_NAME}
cd ${DIR_NAME}
npm install
mkdir lambda_function
cp index.js lambda_function/
cp -r node_modules lambda_function/
