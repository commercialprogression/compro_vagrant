# -*- mode: ruby -*-
# vi: set ft=ruby :

# Check for vagrant triggers plugin
unless Vagrant.has_plugin?("vagrant-triggers")
  raise 'vagrant-triggers needs to be installed: vagrant plugin install vagrant-triggers'
end

# Configuration
Vagrant.configure(2) do |config|
  # Debian Jessie
  config.vm.box = "ubuntu/trusty64"
  # Set IP address to access the box from
  config.vm.network "private_network", ip: "192.168.33.10"
  # Shared folder
  config.vm.synced_folder ".", "/var/www/html", type: "rsync",
    rsync__exclude: ".git/"
  # VB settings
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true
    # Customize the amount of memory on the VM:
    vb.memory = "1024"
  end
  # SSH
  config.ssh.forward_agent = true
  # Shell provisioner
  config.vm.provision "shell", path: "bootstrap.sh"
  # Triggers - requires vagrant triggers
  config.trigger.after :up do
    run "vagrant rsync-auto"
  end
end
