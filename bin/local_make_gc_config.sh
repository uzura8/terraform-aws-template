# include config file

## include config file
CONFIG_FILE="`dirname $0`/setup.conf"
if [ ! -f $CONFIG_FILE ]; then
  echo "Not found config file : ${CONFIG_FILE}" ; exit 1
fi
. $CONFIG_FILE

## include common file
COMMON_FILE="`dirname $0`/common.sh"
if [ ! -f $COMMON_FILE ]; then
  echo "Not found common file : ${COMMON_FILE}" ; exit 1
fi
. $COMMON_FILE

cp bin/setup.conf var/gc_configs/

cd ./var
if [ -e ${GC_DIR_NAME} ]; then
  rm -rf ${GC_DIR_NAME}
fi
git clone ${GC_GIT_REPO} ${GC_DIR_NAME}
cd ${GC_DIR_NAME}
git checkout origin/${GC_GIT_BRANCH}
git checkout -b ${GC_GIT_BRANCH}
cp src/server/config/config.json.sample ../gc_configs/config-server.json
cp src/client/js/config/config.json.sample ../gc_configs/config-client.json
cp src/server/config/aws-config.json.sample ../gc_configs/aws-config.json
cp data/sql/setup.sql ../gc_configs/
cd ../gc_configs

## setup for server config
### setup client config
cp config-server.json /tmp/config-server.json.0
for ((i = 0; i < ${#SERVER_CONFS[@]}; i++))
do
  #echo "${SERVER_CONFS[$i]}"
  input_file=/tmp/config-server.json.${i}
  h=$((i+1))
  output_file=/tmp/config-server.json.${h}
  jq "${SERVER_CONFS[$i]}" $input_file > $output_file
done
mv $output_file config-server.json

### set client config
cp config-client.json /tmp/config-client.json.0
for ((i = 0; i < ${#CLIENT_CONFS[@]}; i++))
do
  #echo "${CLIENT_CONFS[$i]}"
  input_file=/tmp/config-client.json.${i}
  h=$((i+1))
  output_file=/tmp/config-client.json.${h}
  jq "${CLIENT_CONFS[$i]}" $input_file > $output_file
done
mv $output_file config-client.json

### set aws config
cp aws-config.json /tmp/aws-config.json.0
for ((i = 0; i < ${#AWS_LEX_CONFS[@]}; i++))
do
  #echo "${AWS_LEX_CONFS[$i]}"
  input_file=/tmp/aws-config.json.${i}
  h=$((i+1))
  output_file=/tmp/aws-config.json.${h}
  jq "${AWS_LEX_CONFS[$i]}" $input_file > $output_file
done
mv $output_file aws-config.json

### set db connection
cd ../../
TF_STATE_FILE="`dirname $0`/../terraform.tfstate"
RDS_EP=`jq -r '.resources|.[]|select(.name=="db")|.instances|.[]|select(.schema_version==0)|.attributes.endpoint' $TF_STATE_FILE`
RDS_DB_NAME=`tf_conf aws_db_name`
RDS_USERNAME=`tf_conf aws_db_username`
RDS_PASSWORD=`tf_conf aws_db_password`
cd ./var/gc_configs
cp config-server.json /tmp/config-server.json.0
jq ".dbs.mysql.host=\"${RDS_EP}\"" /tmp/config-server.json.0 > /tmp/config-server.json.1
jq ".dbs.mysql.database=\"${RDS_DB_NAME}\"" /tmp/config-server.json.1 > /tmp/config-server.json.2
jq ".dbs.mysql.user=\"${RDS_USERNAME}\"" /tmp/config-server.json.2 > /tmp/config-server.json.3
jq ".dbs.mysql.password=\"${RDS_PASSWORD}\"" /tmp/config-server.json.3 > config-server.json

cat >> .my.cnf <<EOF
[client]
password="${RDS_PASSWORD}"

EOF
