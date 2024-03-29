#!/bin/sh
source ./vars.sh

set -x

VBoxManage modifyvm ${NAME} \
    --boot1 disk --boot2 none --boot3 none --boot4 none \

VBoxManage storagectl ${NAME} \
    --name SATA --remove

VBoxManage storagectl ${NAME} \
    --name SATA --add sata --portcount 1 --bootable on

VBoxManage storageattach ${NAME} \
    --storagectl SATA --port 0 --type hdd \
    --medium "${HOME}/VirtualBox VMs/${NAME}/${NAME}.vmdk"
