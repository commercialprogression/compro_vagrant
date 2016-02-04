# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # Debian Jessie
  config.vm.box = "debian/jessie64"
  # Set IP address to access the box from
  config.vm.network "private_network", ip: "192.168.33.10"
  # Shared folder
  config.vm.synced_folder ".", "/var/www/html", type: "nfs"
  config.vm.synced_folder "~/.ssh", "/ssh", type: "nfs"
  # VB settings
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true
    # Customize the amount of memory on the VM:
    vb.memory = "1024"
  end
  # Shell provisioner
  config.vm.provision "shell", path: "bootstrap.sh"
end
