#!/bin/shell

STRAGE_NAME=$1
gsutil cp -r var/site-generator/public/* gs://${STRAGE_NAME}
gsutil acl ch -r -u AllUsers:R gs://${STRAGE_NAME}
