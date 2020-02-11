# include config file

### load config ###
CONFIG_FILE="/home/ec2-user/gc_configs/setup.conf"
if [ ! -f $CONFIG_FILE ]; then
  echo "Not found config file : ${CONFIG_FILE}" ; exit 1
fi
. $CONFIG_FILE

DB_CONFIG_FILE="/home/ec2-user/gc_configs/setup_db.conf"
if [ ! -f $DB_CONFIG_FILE ]; then
  echo "Not found config file : ${DB_CONFIG_FILE}" ; exit 1
fi
. $DB_CONFIG_FILE

#### locale setting  ###
sudo timedatectl set-timezone Asia/Tokyo
sudo localectl set-locale LANG=ja_JP.UTF-8

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

### Install MySQL ###
sudo yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
sudo yum-config-manager --disable mysql80-community
sudo yum-config-manager --enable mysql57-community
sudo yum install -y mysql-community-client
cp /home/ec2-user/gc_configs/.my.cnf /home/ec2-user/.my.cnf
chmod 600 /home/ec2-user/.my.cnf

#### Install Nginx ###
#sudo amazon-linux-extras install -y nginx1
#sudo cp -a /etc/nginx/nginx.conf /etc/nginx/nginx.conf.ori
#sudo systemctl start nginx
#sudo systemctl enable nginx

### Install Apache ###
sudo yum install -y httpd httpd-devel zlib-devel
sudo systemctl start httpd
sudo systemctl enable httpd

#### Create Web directries
sudo rm -f /etc/httpd/conf.d/welcome.conf
sudo rm -f /var/www/error/noindex.html

#### Apache setting
#SERVISE_DOMAIN="ec2-13-112-39-117.ap-northeast-1.compute.amazonaws.com"
sudo cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.ori
sed -e "s/^#ServerName www.example.com:80/ServerName ${WEB_DOMAIN}:80/" /etc/httpd/conf/httpd.conf > /tmp/httpd.conf.$$
sed -e "s/^\(AddDefaultCharset UTF-8\)/#\1/g" /tmp/httpd.conf.$$ > /tmp/httpd.conf.2.$$
sed -e "s/^\(\s\+\)\(CustomLog .\+\)$/\1\#\2/" /tmp/httpd.conf.2.$$ > /tmp/httpd.conf.3.$$

cat >> /tmp/httpd.conf.3.$$ <<EOF
ServerSignature Off
ServerTokens Prod
LogFormat "%V %h %l %u %t \"%r\" %>s %b %D \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%V %h %l %u %t \"%!414r\" %>s %b %D" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent
# No log from worm access
SetEnvIf Request_URI "default\.ida" no_log
SetEnvIf Request_URI "cmd\.exe" no_log
SetEnvIf Request_URI "root\.exe" no_log
SetEnvIf Request_URI "Admin\.dll" no_log
SetEnvIf Request_URI "NULL\.IDA" no_log
# No log from intarnal access
SetEnvIf Remote_Addr 127.0.0.1 no_log
# Log other access
CustomLog logs/access_log combined env=!no_log
<DirectoryMatch ~ "/\.(svn|git)/">
  Require all denied
</DirectoryMatch>
<Files ~ "^\.git">
  Require all denied
</Files>

EOF

sudo mv /tmp/httpd.conf.3.$$ /etc/httpd/conf/httpd.conf
rm -f /tmp/httpd.conf.$$
rm -f /tmp/httpd.conf.2.$$
rm -f /tmp/httpd.conf.3.$$
sudo cp /home/ec2-user/gc_configs/virtualhost.conf /etc/httpd/conf.d/

sudo systemctl start httpd
sudo systemctl enable httpd

sudo sed -e "s/^\(\s\+\)\(missingok\)/\1daily\n\1dateext\n\1rotate 16\n\1\2/" /etc/logrotate.d/httpd > /tmp/logrotate.d.httpd.$$
sudo mv /tmp/logrotate.d.httpd.$$ /etc/logrotate.d/httpd
sudo systemctl restart httpd

### Install Node.js ###
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

