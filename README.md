# Compro vagrant

## Description
Ideally, all client sites would run on a secure up to date version of PHP. While we do recommend this, sometimes it isn't possible for a variety of reasons. The repo exists mostly to properly test sites running on older versions of PHP.

The environment runs Ubuntu 14.04. If no version of PHP is specified when building, the default version that is included with Ubuntu is install. Which is currently version 5.5. This is the preferred method if the production environment will be running Ubuntu 14.04.

## Usage
```
PHP=5.4.32 vagrant up
```
or
```
vagrant up
```

PHP version can be set to any [version](http://php.net/releases/).

Site can be accessed at 192.168.33.10.

Database is accessible remotely, so you can use something like MySQL Workbench on the host machine.

Drush, Git, and build tools like Grunt can be run outside the VM. SSH'ing into the machine shouldn't be necessary, unless you prefer to work that way.
