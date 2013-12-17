#!/bin/bash -x

#Tools
VBM="/usr/bin/VBoxManage"
WGET="/usr/local/bin/wget"

ISO_NAME="CentOS-6.5-x86_64-netinstall.iso"
ISO_URL="http://mirror.yandex.ru/centos/6.5/isos/x86_64/${ISO_NAME}"

VM="base_test_alpha"
OSTYPE="RedHat_64"
VM_FS_PATH="$(dirname $0)/${VM}"
VM_FS_SIZE="8192"
VM_RAM=512

function websrv {
		nc -l 3333  < anaconda-ks.cfg; 
}


$WGET -c ${ISO_URL} -O "$(dirname $0)/${ISO_NAME}"
#########

mkisofs -o  CentOS-6.5-x86_64-netinstall-kickstart.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -R -J -v -T .

$VBM createvm --name "${VM}" --ostype "${OSTYPE}" --register

$VBM createhd --filename "${VM_FS_PATH}/${VM}.vdi" --size "${VM_FS_SIZE}"

$VBM modifyvm "${VM}" --memory "${VM_RAM}"

$VBM storagectl "${VM}" --name "SATA Controller" --add sata  --controller IntelAHCI

$VBM storageattach "${VM}" --storagectl "SATA Controller" --port 0  --device 0 --type hdd --medium "${VM_FS_PATH}/${VM}.vdi"

$VBM storageattach "${VM}" --storagectl "SATA Controller" --port 1  --device 0 --type dvddrive --medium "${ISO_NAME}"

VirtualBox --startvm "${VM}"

