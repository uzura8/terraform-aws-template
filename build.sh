#!/bin/sh

GIT_URL="https://github.com/uzura8/gc-support-chat-lex-bot.git"
DIR_NAME="workspace"

cd var

if [ -f ${DIR_NAME} ]; then
    echo "${DIR_NAME} already exists" ; exit 1
fi

git clone ${GIT_URL} ${DIR_NAME}
cd ${DIR_NAME}
npm install
mkdir lambda_function
cp index.js lambda_function/
cp -r node_modules lambda_function/
#zip -r ${DIR_NAME}.zip index.js node_modules
#mv ${DIR_NAME}.zip /tmp/
