#!/bin/bash

terraform destroy -auto-approve && rm -rf var/site-generator # Use only develop env. Not use on production!
#terraform destroy && rm -rf var/site-generator
