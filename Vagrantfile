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

  config.vm.define 'coudhdb.local' do |couchdb|
    couchdb.vm.hostname = 'couchdb'
    couchdb.vm.network :private_network, ip: '192.168.42.10'
    couchdb.hostmanager.aliases = %w(lupolibero.local couchdb.local)
  end
  #config.vm.network "forwarded_port", guest: 5984, host: 55984
  #config.vm.network "forwarded_port", guest: 80, host: 50080

  config.vm.provision :hostmanager
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/site.yml"
    ansible.groups = {
      "couchdbservers" => ["coudhdb.local"],
      "proxyservers" => ["coudhdb.local"]
    }
    ansible.extra_vars = {
      "ansible_ssh_private_key_file" => '~/.vagrant.d/insecure_private_key'
    }
  end
end
