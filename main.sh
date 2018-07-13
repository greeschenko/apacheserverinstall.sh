#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
if [[ $# -ne 2 ]]; then
    echo "bash main.sh {project name} {mysql password}"
fi

NAME=`$1`
PASSWORD=`$2`

# update / upgrade
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get -y update
sudo apt-get -y upgrade

# install apache 2.5 and php 5.5
sudo apt-get install -y libapache2-mod-php5.6
sudo apt-get install -y php5.6-mbstring php5.6-zip php5.6-curl php5.6-gd php5.6-intl php-pear php5.6-imagick php5.6-imap php5.6-mcrypt php5.6-pspell php5.6-recode php5.6-sqlite php5.6-tidy php5.6-xmlrpc php5.6-xsl

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server
sudo apt-get -y install php5.6-mysql

# install phpmyadmin and give password(s) to installer
#for simplicity I'm using the same password for mysql and phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin

mkdir /home/www/${NAME}/
mkdir /home/www/${NAME}/web/

touch /etc/apache2/sites-available/${NAME}-ssl.conf

# setup hosts file
echo "<VirtualHost *:80>" >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        ServerAdmin greeschenko@gmail.com" >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        ServerName  ${NAME}" >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        DocumentRoot /home/www/${NAME}/web/" >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        <Directory />" >>  /etc/apache2/sites-available/${NAME}-ssl.conf
echo "                Options Indexes FollowSymLinks MultiViews" >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "                AllowOverride All" >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "                Order allow,deny" >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "                allow from all" >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "                DirectoryIndex index.php" >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        </Directory>" >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        ServerAlias www.${NAME}" >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        ErrorLog /var/log/apache2/${NAME}_error.log" >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        CustomLog /var/log/apache2/${NAME}_asses.log combined" >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "</VirtualHost>" >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "<IfModule mod_ssl.c>"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "<VirtualHost *:443>"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        ServerAdmin greeschenko@gmail.com"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        ServerName  ${NAME}"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        ServerAlias www.${NAME}"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        DocumentRoot /home/www/${NAME}/web/"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        <Directory />"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "                Options Indexes FollowSymLinks MultiViews"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "                AllowOverride All"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "                Order allow,deny"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "                allow from all"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "                DirectoryIndex index.php"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        </Directory>"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        ErrorLog /var/log/apache2/${NAME}.log"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        CustomLog /var/log/apache2/${NAME}.log combined"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        SSLEngine on"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        SSLCertificateKeyFile /etc/apache2/crts/${NAME}/key.key"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        SSLCertificateFile    /etc/apache2/crts/${NAME}/crt.crt"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        SSLCACertificateFile /etc/apache2/crts/${NAME}/ca.bundle"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        #SSLCertificateChainFile /etc/apache2/crts/${NAME}/ca_1.crt"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        #SSLCertificateChainFile /etc/apache2/crts/${NAME}/ca_2.crt"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        #SSLVerifyClient require"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "        #SSLVerifyDepth  10"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "</VirtualHost>"  >> /etc/apache2/sites-available/${NAME}-ssl.conf
echo "</IfModule>"  >> /etc/apache2/sites-available/${NAME}-ssl.conf

mysqladmin -uroot -p${PASSWORD} create ${NAME}

# enable mod_rewrite
sudo a2enmod rewrite

# restart apache
service apache2 restart

# install git
sudo apt-get -y install git
sudo apt-get -y install curl

# install Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

composer global require "fxp/composer-asset-plugin=*"

sudo apt-get install -y htop
sudo apt-get install -y redis-server
sudo apt-get install -y unzip
sudo apt-get install -y vim
sudo apt-get install -y mc
sudo apt-get install -y gconf2

echo "127.0.0.1    ${NAME}" >> /etc/hosts
