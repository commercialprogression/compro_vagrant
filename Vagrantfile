# -*- mode: ruby -*-
# vi: set ft=ruby :

# Configuration
Vagrant.configure(2) do |config|
  # Ubuntu 14.04
  config.vm.box = "ubuntu/trusty64"
  # Set IP address to access the box from
  config.vm.network "private_network", ip: "192.168.33.10"
  # Shared folder
  config.vm.synced_folder ".", "/var/www/html", type: "nfs"
  # VB settings
  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = "1024"
  end
  # SSH
  config.ssh.forward_agent = true
  # Shell provisioner
  config.vm.provision "shell", path: "bootstrap.sh", :args => ENV['PHP']
end
