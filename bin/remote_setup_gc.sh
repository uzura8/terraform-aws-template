# include config file

### load config ###
CONFIG_FILE="`dirname $0`/setup.conf"
if [ ! -f $CONFIG_FILE ]; then
    echo "Not found config file : ${CONFIG_FILE}" ; exit 1
fi
. $CONFIG_FILE

### locale setting  ###
localectl set-locale LANG=ja_JP.utf8
ln -sf /usr/share/zoneinfo/Japan /etc/localtime

### Add yum optional repository ###
sudo amazon-linux-extras enable epel
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

#### Setting yum update ###
sudo yum -y update
sudo yum -y install yum-cron
sudo cp /etc/yum/yum-cron.conf /etc/yum/yum-cron.conf.ori
sudo sed -e "s|^apply_updates = no|apply_updates = yes|" /etc/yum/yum-cron.conf > /tmp/yum-cron.conf.$$
sudo mv /tmp/yum-cron.conf.$$ /etc/yum/yum-cron.conf
sudo systemctl start yum-cron
sudo systemctl enable yum-cron
sudo yum -y groupinstall base "Development tools"

sudo yum install -y nkf --enablerepo=epel
sudo setenforce 0
sudo yum -y install rsyslog
sudo systemctl start rsyslog
sudo systemctl enable rsyslog
sudo yum -y install sysstat

### Add MySQL repo ###
sudo yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
sudo yum-config-manager --disable mysql80-community
sudo yum-config-manager --enable mysql57-community
sudo yum install -y mysql-community-client

### Node.js ###
sudo yum -y install gcc-c++
mkdir ~/src
cd ~/src
git clone https://github.com/creationix/nvm.git ~/.nvm
source ~/.nvm/nvm.sh
cat > ~/.bash_profile <<EOF
# nvm
if [[ -s ~/.nvm/nvm.sh ]] ; then
  source ~/.nvm/nvm.sh ;
fi
EOF

nvm install ${NODE_VER}
nvm use ${NODE_VER}
nvm alias default ${NODE_VER}

### grateful_chat ###
cd ~/
git clone ${GC_GIT_REPO} ${GC_DIR_NAME}
cd ${GC_DIR_NAME}
npm install
#cp src/server/config/config.json.sample src/server/config/config.json
#cp src/client/js/config/config.json.sample src/client/js/config/config.json
