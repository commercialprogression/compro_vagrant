#!/bin/bash

# Update packages
apt-get update

# MySQL
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
apt-get install -y mysql-server mysql-client
mysql -u root -proot -e "CREATE DATABASE drupal"
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION"
sudo sed -i '/bind-address/c #bind-address = 127.0.0.1' /etc/mysql/my.cnf

# Apache
apt-get install -y apache2
touch /etc/apache2/sites-available/drupal.conf
echo "<VirtualHost *:80>" | tee -a /etc/apache2/sites-available/drupal.conf
echo "  ServerName drupal.dev" | tee -a /etc/apache2/sites-available/drupal.conf
echo "  ServerAlias *.drupal.dev" | tee -a /etc/apache2/sites-available/drupal.conf
echo "  DirectoryIndex index.php index.html" | tee -a /etc/apache2/sites-available/drupal.conf
echo "  DocumentRoot /var/www/html" | tee -a /etc/apache2/sites-available/drupal.conf
echo "  <Directory /var/www/html/ >" | tee -a /etc/apache2/sites-available/drupal.conf
echo "    Options Indexes FollowSymLinks" | tee -a /etc/apache2/sites-available/drupal.conf
echo "    AllowOverride All" | tee -a /etc/apache2/sites-available/drupal.conf
echo "    Require all granted" | tee -a /etc/apache2/sites-available/drupal.conf
echo "  </Directory>" | tee -a /etc/apache2/sites-available/drupal.conf
echo "</VirtualHost>" | tee -a /etc/apache2/sites-available/drupal.conf
a2dissite 000-default.conf
a2ensite drupal.conf
a2enmod rewrite
rm /var/www/html/index.html

# PHP
apt-get install -y php5 php5-mysql libapache2-mod-php5 php5-gd php5-xdebug php5-curl
echo "xdebug.default_enable=1" | tee -a /etc/php5/mods-available/xdebug.ini
echo "xdebug.remote_enable=1" | tee -a /etc/php5/mods-available/xdebug.ini
echo "xdebug.remote_handler=dbgp" | tee -a /etc/php5/mods-available/xdebug.ini
echo "xdebug.remote_host=192.168.33.1" | tee -a /etc/php5/mods-available/xdebug.ini
echo "xdebug.remote_port=9000" | tee -a /etc/php5/mods-available/xdebug.ini
echo "xdebug.remote_autostart=0" | tee -a /etc/php5/mods-available/xdebug.ini

# Clean up
service mysql restart
service apache2 restart
