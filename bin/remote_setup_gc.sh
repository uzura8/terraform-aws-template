# include config file

ADMIN_USER="ec2-user"

### load config ###
CONFIG_FILE="/home/${ADMIN_USER}/gc_configs/setup.conf"
if [ ! -f $CONFIG_FILE ]; then
  echo "Not found config file : ${CONFIG_FILE}" ; exit 1
fi
. $CONFIG_FILE

#DB_CONFIG_FILE="/home/${ADMIN_USER}/gc_configs/setup_db.conf"
#if [ ! -f $DB_CONFIG_FILE ]; then
#  echo "Not found config file : ${DB_CONFIG_FILE}" ; exit 1
#fi
#. $DB_CONFIG_FILE

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

sudo yum install -y etckeeper --enablerepo=epel
sudo touch /etc/.gitignore
sudo echo "shadow*" >> /etc/.gitignore
sudo echo "gshadow*" >> /etc/.gitignore
sudo echo "passwd*" >> /etc/.gitignore
sudo echo "group*" >> /etc/.gitignore
sudo git config --global user.email "${GIT_USER_EMAIL}"
sudo git config --global user.name "${GIT_USER_NAME}"
sudo etckeeper init
sudo etckeeper commit "First Commit"

sudo yum install -y nkf --enablerepo=epel
sudo setenforce 0
sudo yum -y install rsyslog
sudo systemctl start rsyslog
sudo systemctl enable rsyslog
sudo yum -y install sysstat

### User setting
#### bash setting
cat >> /home/${ADMIN_USER}/.bash_profile <<EOF
export PS1="[\u@\h \W]\\$ "
export EDITOR=vim
alias V='vim -R -'
EOF
source /home/${ADMIN_USER}/.bash_profile

#### Screen setting
cat > /home/${ADMIN_USER}/.screenrc <<EOF
escape ^Jj
hardstatus alwayslastline "[%02c] %-w%{=b bw}%n %t%{-}%+w"
startup_message off
vbell off
autodetach on
defscrollback 10000
termcapinfo xterm* ti@:te@
EOF

#### Vim setting
cat > /home/${ADMIN_USER}/.vimrc <<EOF
syntax on
"set number
set enc=utf-8
set fenc=utf-8
set fencs=iso-2022-jp,euc-jp,cp932
set backspace=2
set noswapfile
"set shiftwidth=4
"set tabstop=4
set shiftwidth=2
set tabstop=2
"set expandtab
set hlsearch
set backspace=indent,eol,start
"" for us-keybord
"nnoremap ; :
"nnoremap : ;
"" Remove comment out as you like
"hi Comment ctermfg=DarkGray
EOF
ln -s /home/${ADMIN_USER}/.vimrc /root/

### git setting
cat > /home/${ADMIN_USER}/.gitconfig <<EOF
[color]
  diff = auto
  status = auto
  branch = auto
  interactive = auto
[alias]
  co = checkout
  st = status
  ci = commit -v
  di = diff
  di-file = diff --name-only
  up = pull --rebase
  br = branch
  ll  = log --graph --pretty=full --stat
  l  = log --oneline
EOF
echo "[user]" >> /home/${ADMIN_USER}/.gitconfig
echo "  email = ${GIT_USER_EMAIL}" >> /home/${ADMIN_USER}/.gitconfig
echo "  name = ${GIT_USER_NAME}" >> /home/${ADMIN_USER}/.gitconfig
ln -s /home/${ADMIN_USER}/.gitconfig /root/


#### Install MySQL ###
#sudo yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
#sudo yum-config-manager --disable mysql80-community
#sudo yum-config-manager --enable mysql57-community
#sudo yum install -y mysql-community-client
#cp /home/${ADMIN_USER}/gc_configs/.my.cnf /home/${ADMIN_USER}/.my.cnf
#chmod 600 /home/${ADMIN_USER}/.my.cnf

#### Install Nginx ###
#sudo amazon-linux-extras install -y nginx1
#sudo cp -a /etc/nginx/nginx.conf /etc/nginx/nginx.conf.ori
#sudo systemctl start nginx
#sudo systemctl enable nginx

### Install Apache ###
sudo yum install -y httpd httpd-devel zlib-devel

#### Create Web directries
sudo rm -f /etc/httpd/conf.d/welcome.conf
sudo rm -f /var/www/error/noindex.html

#### Add webadmin group
sudo groupadd webadmin
sudo gpasswd -a ${ADMIN_USER} webadmin
sudo gpasswd -a apache webadmin

### Create Web directries ###
#echo "umask 002" > /etc/profile.d/umask.sh
sudo mkdir -p /var/www/sites
sudo chown -R ${ADMIN_USER} /var/www/sites /var/www/html
sudo chgrp -R webadmin /var/www/sites /var/www/html
sudo chmod -R 775 /var/www/sites /var/www/html
sudo chmod -R g+s /var/www/sites /var/www/html

#### Apache setting
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

sudo cat > /etc/httpd/conf.d/virtualhost.conf <<EOF
<VirtualHost *:80>
  ServerName localhost
  VirtualDocumentRoot /var/www/sites/%0/public
</VirtualHost>
<Directory "/var/www/sites">
  AllowOverride All
</Directory>

EOF

sudo sed -e "s/^\(\s\+\)\(missingok\)/\1daily\n\1dateext\n\1rotate 16\n\1\2/" /etc/logrotate.d/httpd > /tmp/logrotate.d.httpd.$$
sudo mv /tmp/logrotate.d.httpd.$$ /etc/logrotate.d/httpd

sudo systemctl start httpd
sudo systemctl enable httpd

