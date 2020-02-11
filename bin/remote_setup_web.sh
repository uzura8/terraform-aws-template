#!/bin/bash

NODE_VER=12.15.0
SERVISE_DOMAIN=example.com

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

### Install Apache ###
sudo yum install -y httpd httpd-devel zlib-devel
sudo systemctl start httpd
sudo systemctl enable httpd

#### Create Web directries
sudo rm -f /etc/httpd/conf.d/welcome.conf
sudo rm -f /var/www/error/noindex.html
sudo rm -f /var/www/error/noindex.html
sudo mkdir -p /var/www/sites

#### Apache setting
#SERVISE_DOMAIN="ec2-13-112-39-117.ap-northeast-1.compute.amazonaws.com"
sudo cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.ori
#sed -e "s/^#ServerName www.example.com:80/ServerName ${WEB_DOMAIN}:80/" /etc/httpd/conf/httpd.conf > /tmp/httpd.conf.$$
sudo sed -e "s/^\(AddDefaultCharset UTF-8\)/#\1/g" /tmp/httpd.conf > /tmp/httpd.conf.$$
sudo sed -e "s/^\(\s\+\)\(CustomLog .\+\)$/\1\#\2/" /tmp/httpd.conf.$$ > /tmp/httpd.conf.2.$$

sudo cat >> /tmp/httpd.conf.2.$$ <<EOF
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

sudo mv /tmp/httpd.conf.2.$$ /etc/httpd/conf/httpd.conf
sudo rm -f /tmp/httpd.conf.$$
sudo rm -f /tmp/httpd.conf.2.$$

sudo cat > /etc/httpd/conf.d/virtualhost.conf <<EOF
<VirtualHost *:80>
  ServerName localhost
  VirtualDocumentRoot /var/www/sites/%0/public
</VirtualHost>
<Directory "/var/www/sites">
  AllowOverride All
</Directory>

EOF

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

# Install python
sudo yum install -y python3-devel python3-libs python3-setuptools python3-pip
sudo yum install -y httpd-devel
sudo pip3 install mod_wsgi
#MOD_WSGI_PATH=`find /usr/local/ -type f -name "mod_wsgi*.so"`
#sudo cat >> /etc/httpd/conf.d/virtualhost.conf <<EOF
#LoadModule wsgi_module ${MOD_WSGI_PATH}
#<VirtualHost *:80>
#  ServerName ${SERVISE_DOMAIN}
#  DocumentRoot /var/www/sites/${SERVISE_DOMAIN}
#  WSGIScriptAlias / /var/www/sites/${SERVISE_DOMAIN}/adapter.wsgi
#  <Directory "/var/www/sites/${SERVISE_DOMAIN}/">
#    Order deny,allow
#    Allow from all
#  </Directory>
#</VirtualHost>
#EOF
#
#sudo systemctl restart httpd
