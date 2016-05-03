# Compro vagrant file for local Drupal development

## Purpose
Ideally, all client sites would run on a secure up to date version of PHP. While we do recommend this, sometimes it isn't possible for a variety of reasons. The repo exists mostly to properly test sites running on older versions of PHP.

## Usage
```
PHP=5.3.29 vagrant up
```
PHP version can be set to any [version](http://php.net/releases/).

Site can be accessed at 192.168.33.10.

Database is accessible remotely, so you can use something like MYSQL Workbench on the host machine.

Drush, Git, and build tools like Grunt can be run outside the VM. Drush can also be installed if working from within the guest is more your style.
