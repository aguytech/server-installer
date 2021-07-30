#!/bin/bash
#
#

#######################  SSH

ssh_port=2002

file="/root/.ssh/authorized_keys"
sudo  cp -a ${file} ${file}.$(date +%s)

file="/etc/ssh/sshd_config"
sed -i "s|^#\?\(PermitRootLogin\) .*$|\1 without-password|" $file
sed -i "s|^#\?\(Port\) .*$|\1 ${ssh_port}|" $file

systemctl restart ssh.service
