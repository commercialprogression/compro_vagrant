Vagrant file for Drupal development.
Simply download into Drupal root and run:
vagrant up

Server located @ 192.168.33.10. Database should be accessible remotely.
Drush and build tools like Grunt should be run outside the VM on the host.

Requires vagrant-triggers plugin:
vagrant plugin install vagrant-triggers
