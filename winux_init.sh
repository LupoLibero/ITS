#!/usr/bin/env bash

VAGRANT_PATH=/home/vagrant
ANSIBLE_PATH=$VAGRANT_PATH/ansible

# Update source lists.
apt-get update -qq

# Install some tools.
apt-get install make git-core vim-nox tmux -y

# Check if the Ansible repository exists.
if [[ ! -d $ANSIBLE_PATH ]]; then
  # Install Ansible dependencies.
  apt-get install python-httplib2 python-pip python-mysqldb python-yaml python-jinja2 python-paramiko sshpass -y

  # Checkout the Ansible repository.
  su vagrant -c "git clone https://github.com/ansible/ansible.git $ANSIBLE_PATH"
  cd $ANSIBLE_PATH
  sh -c "echo 'source $ANSIBLE_PATH/hacking/env-setup -q' >> $VAGRANT_PATH/.bashrc"

  #ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -q -N ""

fi

if [[ ! `which node` ]]; then
  # Install latest nodejs and ansible
  apt-get install python-software-properties -y
  apt-add-repository ppa:chris-lea/node.js -y
  apt-get update
  apt-get install nodejs -y
fi

if [[ ! `which coffee` ]]; then
  # Install coffeescript and ppa prerequisites
  apt-get install coffeescript -y
fi

if [[ ! `which grunt` ]]; then
  npm install -g kanso grunt-cli
fi

mkdir /etc/ansible
cp /vagrant/.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory /etc/ansible/hosts
sed -i -r 's/^([^ \[#]+) .*$/\1/' /etc/ansible/hosts

echo "Done."
