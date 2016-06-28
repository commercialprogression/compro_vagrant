#!/bin/bash

# Update packages
apt-get update

# MySQL
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
apt-get install -y mysql-server mysql-client
mysql -u root -proot -e "CREATE DATABASE drupal"
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION"
sed -i '/bind-address/c #bind-address = 127.0.0.1' /etc/mysql/my.cnf

# Check to see if PHP version was provided.
if [ -z "$1" ]; then
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
  echo "xdebug.max_nesting_level=250" | tee -a /etc/php5/mods-available/xdebug.ini
else
  PHP=$1

  # Apache
  apt-get install -y apache2 libapache2-mod-fastcgi apache2-mpm-worker apache2-suexec
  touch /etc/apache2/sites-available/drupal.conf
  echo "<VirtualHost *:80>" | tee -a /etc/apache2/sites-available/drupal.conf
  echo "  ServerName drupal.dev" | tee -a /etc/apache2/sites-available/drupal.conf
  echo "  ServerAlias *.drupal.dev" | tee -a /etc/apache2/sites-available/drupal.conf
  echo "  DirectoryIndex index.php index.html" | tee -a /etc/apache2/sites-available/drupal.conf
  echo "  DocumentRoot /var/www/html" | tee -a /etc/apache2/sites-available/drupal.conf
  echo "  <Directory /var/www/html/ >" | tee -a /etc/apache2/sites-available/drupal.conf
  echo "    AddHandler php-cgi .php" | tee -a /etc/apache2/sites-available/drupal.conf
  echo "    Action php-cgi /cgi-bin-php/php-cgi-$PHP" | tee -a /etc/apache2/sites-available/drupal.conf
  echo "    <FilesMatch "\.php$">" | tee -a /etc/apache2/sites-available/drupal.conf
  echo "      SetHandler php-cgi" | tee -a /etc/apache2/sites-available/drupal.conf
  echo "    </FilesMatch>" | tee -a /etc/apache2/sites-available/drupal.conf
  echo "    Options Indexes FollowSymLinks" | tee -a /etc/apache2/sites-available/drupal.conf
  echo "    AllowOverride All" | tee -a /etc/apache2/sites-available/drupal.conf
  echo "    Require all granted" | tee -a /etc/apache2/sites-available/drupal.conf
  echo "  </Directory>" | tee -a /etc/apache2/sites-available/drupal.conf
  echo "</VirtualHost>" | tee -a /etc/apache2/sites-available/drupal.conf
  a2dissite 000-default.conf
  a2ensite drupal.conf
  a2enmod rewrite actions
  rm /var/www/html/index.html

  # PHP
  sudo apt-get install -y git build-essential libxml2-dev libcurl4-openssl-dev pkg-config libbz2-dev libpng-dev libmcrypt-dev autoconf
  git clone git://git.code.sf.net/p/phpfarm/code /opt/phpfarm
  cp /var/www/html/custom-options.sh /opt/phpfarm/src
  /opt/phpfarm/src/compile.sh $PHP
  echo "FastCgiServer /var/www/cgi-bin/php-cgi-$PHP -idle-timeout 240" >> /etc/apache2/apache2.conf
  echo "ScriptAlias /cgi-bin-php/ /var/www/cgi-bin/" >> /etc/apache2/apache2.conf
  sed -i '/FastCgiIpcDir/c #FastCgiIpcDir /var/lib/apache2/fastcgi' /etc/apache2/mods-enabled/fastcgi.conf
  mkdir /var/www/cgi-bin
  touch /var/www/cgi-bin/php-cgi-$PHP
  echo "#!/bin/bash" >> /var/www/cgi-bin/php-cgi-$PHP
  echo "PHPRC=\"/opt/phpfarm/inst/php-$PHP/lib/php.ini\"" >> /var/www/cgi-bin/php-cgi-$PHP
  echo "export PHPRC" >> /var/www/cgi-bin/php-cgi-$PHP
  echo "PHP_FCGI_CHILDREN=3" >> /var/www/cgi-bin/php-cgi-$PHP
  echo "export PHP_FCGI_CHILDREN" >> /var/www/cgi-bin/php-cgi-$PHP
  echo "PHP_FCGI_MAX_REQUESTS=5000" >> /var/www/cgi-bin/php-cgi-$PHP
  echo "export PHP_FCGI_MAX_REQUESTS" >> /var/www/cgi-bin/php-cgi-$PHP
  echo "exec /opt/phpfarm/inst/bin/php-cgi-$PHP" >> /var/www/cgi-bin/php-cgi-$PHP
  chmod +x /var/www/cgi-bin/php-cgi-$PHP

  # Xdebug
  wget https://xdebug.org/files/xdebug-2.2.7.tgz
  tar xvfz xdebug-2.2.7.tgz
  cd xdebug-2.2.7
  /opt/phpfarm/inst/php-$PHP/bin/phpize
  ./configure --enable-xdebug --with-php-config=/opt/phpfarm/inst/php-$PHP/bin/php-config
  make && make install
  echo "zend_extension=\"/opt/phpfarm/inst/php-$PHP/lib/php/extensions/debug-non-zts-20100525/xdebug.so\"" >> /opt/phpfarm/inst/php-$PHP/lib/php.ini
  echo "xdebug.default_enable=1" >> /opt/phpfarm/inst/php-$PHP/lib/php.ini
  echo "xdebug.remote_enable=1" >> /opt/phpfarm/inst/php-$PHP/lib/php.ini
  echo "xdebug.remote_handler=dbgp" >> /opt/phpfarm/inst/php-$PHP/lib/php.ini
  echo "xdebug.remote_host=192.168.33.1" >> /opt/phpfarm/inst/php-$PHP/lib/php.ini
  echo "xdebug.remote_port=9000" >> /opt/phpfarm/inst/php-$PHP/lib/php.ini
  echo "xdebug.remote_autostart=0" >> /opt/phpfarm/inst/php-$PHP/lib/php.ini
  echo "xdebug.max_nesting_level=250" >> /opt/phpfarm/inst/php-$PHP/lib/php.ini
fi

# Clean up
service mysql restart
service apache2 restart
