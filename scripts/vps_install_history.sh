#!/bin/bash
#######################################################
# THIS IS JUST A HISTORY OF USED COMMANDS AND WHERE - NOT A BASH SCRIPT
#######################################################

#######################################################
# !!!!!!!!!!!!!!!!!DO NOT RUN!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!DO NOT RUN!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!DO NOT RUN!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!DO NOT RUN!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!DO NOT RUN!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!DO NOT RUN!!!!!!!!!!!!!!!!!
#######################################################


#######################################################
# ON HOST MACHINE
#######################################################

# vagrant install -> need virtualbox first
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt install vagrant

# init vagrant, spin up vm
mkdir vps-vm
cd vps-vm
vagrant init ubuntu/jammy64
vagrant up

# ssh in vagrant
ssh vagrant@localhost -p 2222 -i $(vagrant ssh-config | grep IdentityFile | awk '{print $2}')

# useful vagrant commands:
# vagrant up - spin up vm
# vagrant halt - stop the vm
# vagrant destroy - delete the vm
# vagrant reload - restart the vm
# exit - leave ssh session
# after DESTROYING a vm please do this before ssh-ing again: ssh-keygen -f '/home/doga/.ssh/known_hosts' -R '[localhost]:2222'

# TRANSFER MUSIC files from host machine to vm:
scp -P 2222 -i $(vagrant ssh-config | grep IdentityFile | awk '{print $2}') -r /home/doga/Desktop/thesis/local-vps-seedbox/CreativeCommonsMusic/TestMusic/* vagrant@localhost:/home/vagrant/music/

#######################################################
# ON HOST MACHINE
#######################################################

