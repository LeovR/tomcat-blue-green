# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.define "blue" do |blue|
    blue.vm.provision :puppet, :module_path => "manifests/modules" do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file  = "default.pp"
    end
    blue.vm.network :private_network, ip: "192.168.50.4"
  end

  config.vm.define "green" do |green|
    green.vm.provision :puppet, :module_path => "manifests/modules" do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file  = "default.pp"
    end
    green.vm.network :private_network, ip: "192.168.50.5"
  end

  config.vm.define "proxy" do |proxy|
    proxy.vm.network :private_network, ip: "192.168.50.6"
    proxy.vm.provision :puppet, :module_path => "manifests/modules" do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file  = "proxy.pp"
    end
  end

end
