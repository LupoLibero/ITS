# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hashicorp/precise32"

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.vm.define 'couchdb', primary:true do |couchdb|
    couchdb.vm.hostname = 'couchdb'
    couchdb.vm.network :private_network, ip: '192.168.42.10'
    couchdb.hostmanager.aliases = %w(lupolibero.local)
  end
  config.vm.provision :hostmanager
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "../deploying/site.yml"
    ansible.groups = {
      "couchdbservers" => ["couchdb"],
      "proxyservers" => ["couchdb"]
    }
    ansible.extra_vars = {
      "ansible_ssh_private_key_file" => '~/.vagrant.d/insecure_private_key',
      "lupolibero_hostname" => 'lupolibero.local'
    }
  end

  config.vm.define 'manager', autostart: false do |manager|
    manager.vm.hostname = 'manager'
    manager.vm.network :private_network, ip: '192.168.42.9'
    manager.vm.synced_folder "../", "/home/vagrant/projects/"
    manager.vm.provision "shell", path: "manager_init.sh"
  end
end
