#!/bin/sh -e
source ./vars.sh

VBoxManage createvm --name ${NAME} --ostype ${TYPE} --register

VBoxManage modifyvm ${NAME} \
    --vram 12 \
    --accelerate3d off \
    --memory 613 \
    --usb off \
    --audio none \
    --boot1 disk --boot2 dvd --boot3 none --boot4 none \
    --nictype1 virtio --nic1 nat --natnet1 "${NATNET}" \
    --nictype2 virtio \
    --nictype3 virtio \
    --nictype4 virtio \
    --acpi on --ioapic off \
    --chipset piix3 \
    --rtcuseutc on \
    --hpet on \
    --bioslogofadein off \
    --bioslogofadeout off \
    --bioslogodisplaytime 0 \
    --biosbootmenu disabled

VBoxManage createhd --format VMDK --size 73728 --filename "${HDD}"

VBoxManage storagectl ${NAME} \
    --name SATA --add sata --portcount 2 --bootable on

VBoxManage storageattach ${NAME} \
    --storagectl SATA --port 0 --type hdd --medium "${HDD}"
VBoxManage storageattach ${NAME} \
    --storagectl SATA --port 1 --type dvddrive --medium "${INSTALLER}"
VBoxManage storageattach ${NAME} \
    --storagectl SATA --port 2 --type dvddrive --medium "${GUESTADDITIONS}"

VBoxManage startvm ${NAME} --type gui

# This only really caters for the common case. If you have problems, please
# discover your host's IP address and adjust accordingly.
IP=`echo ${NATNET} | sed -nE 's/^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*/\1/p'`

echo 'At the boot prompt, hit <TAB> and then type:'
echo " ks=http://${IP}.3:8081"
sh ./httpd.sh | nc -l 8081 >/dev/null


! [ -e boxes ] && mkdir boxes

echo When finished:
echo "./cleanup.sh && vagrant package --base ${NAME} --output boxes/${NAME}-`date -j +%Y%m%d`.box"
