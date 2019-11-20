#common.sh

tf_conf() {
  NAME=$1
  CONF_FILE="`dirname $0`/../terraform.tfvars"
  cat ${CONF_FILE}|grep ${NAME}|sed -e 's/.*= "\(.*\)"$/\1/g'
}

