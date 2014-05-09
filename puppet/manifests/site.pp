exec {'update':
  command => '/usr/bin/apt-get update',
}

exec {'remove-www-directory':
  command => 'rm -rf /var/www',
  path => ['/usr/bin', '/bin'],
  require => Package['apache2'],
}

exec {'allow-override':
  command => "sed -i '/AllowOverride None/c AllowOverride All' /etc/apache2/sites-available/default",
  path => ['/usr/bin', '/bin', '/usr/sbin'],
  require => Package['apache2'],
  notify => Service['apache2'],
}

exec {'link-vagrant-directory':
  command => 'ln -s /vagrant /var/www',
  path => ['/usr/bin', '/bin'],
  require => Exec['remove-www-directory'],
}

exec {'mod-rewrite':
  command => 'a2enmod rewrite',
  path => ['/usr/sbin', '/bin', '/usr/bin'],
  require => Exec['link-vagrant-directory'],
}

exec {'xdebug':
  command => "echo 'xdebug.default_enable=1\nxdebug.remote_enable=1\nxdebug.remote_handler=dbgp\nxdebug.remote_host=192.168.33.1\nxdebug.remote_port=9000\nxdebug.remote_autostart=0\n' >> /etc/php5/conf.d/xdebug.ini",
  path => '/bin:/usr/bin',
  require => Package['php5-xdebug'],
  notify => Service['apache2'],
}

exec {'drush-channel':
  command => 'pear channel-discover pear.drush.org',
  path => '/usr/bin',
  require => Package['php-pear'],
}

exec {'drush-install':
  command => 'pear install drush/drush',
  path => '/usr/bin',
  require => Exec['drush-channel'],
}

exec {'console-table-install':
  command => 'pear install Console_Table',
  path => '/usr/bin',
  require => Exec['drush-install'],
}

exec {'create-database':
  command => 'mysql -u root -e "create database drupal";',
  path => '/usr/bin',
  require => Package['mysql-server'],
}

file {'/etc/php5/conf.d/upload_limits.ini':
  ensure => present,
  owner => root, group => root, mode => 444,
  content => "post_max_size = 128M \nupload_max_filesize = 128M \n",
  require => Package['apache2', 'php5-mysql'],
  notify => Service['apache2'],
}

package {['lamp-server^', 'apache2', 'php-pear', 'php5-mysql', 'php5-gd', 'mysql-server', 'php5-xdebug']:
  ensure => present,
  require => Exec['update'],
}

service {'apache2':
  ensure => running,
  enable => true,
  require => Package['apache2'],
}

