#!/bin/sh

GIT_URL="https://github.com/uzura8/gc-support-chat-lex-bot.git"
DIR_NAME="workspace"

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
