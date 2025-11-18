#!/bin/bash

# vagrant install -> need virtualbox first
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt install vagrant

# test vps -> init vagrant, spin up vm
mkdir vps-vm
cd vps-vm
vagrant init ubuntu/jammy64
vagrant up

# ssh in vagrant
KEY_PATH=$(vagrant ssh-config | grep IdentityFile | awk '{print $2}')
ssh vagrant@localhost -p 2222 -i $KEY_PATH



# vagrant halt - stop the vm
# vagrant destroy - delete the vm
# vagrant reload - restart the vm
# exit - leave ssh session