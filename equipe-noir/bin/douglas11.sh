#!/bin/bash
if [ $# != 1 ]; then
    echo "Usage: douglas11.sh < create | destroy >"
    echo "Error: no or too much arguments"
    exit 1
fi

INTERFACE="enp3s0"
## TODO
# sudo ip addr flush dev $INTERFACE
# sudo ip link set dev $INTERFACE up
# sudo ip addr add 192.168.4.XX/26 dev $INTERFACE
# sudo ip route add 192.168.0.0/16 via 192.168.4.XX dev $INTERFACE

export 'VBOXES=/home/cisco/VirtualBox VMs/'
export 'MODELE=/home/cisco/bookworm-12.12.vdi'

if [ $1 == "create" ]; then
    set -e

    for vm in client_admin1 client_admin2; do
        echo "Création de la VM $vm..."

        vboxmanage createvm --name $vm --ostype Debian_64 --basefolder "$VBOXES" --register
        vboxmanage clonemedium --format VMDK disk "$MODELE" "$VBOXES/$vm/$vm.vdi"
        vboxmanage storagectl $vm --name controller1 --add scsi
        vboxmanage storageattach $vm --storagectl controller1 --port 0 --device 0 --type hdd --medium "$VBOXES/$vm/$vm.vdi"

        echo "Configuration de la VM $vm..."

        vboxmanage modifyvm $vm --memory 4096 
        vboxmanage modifyvm $vm --cpus 2
        vboxmanage modifyvm $vm --nic1 nat
        vboxmanage modifyvm $vm --natpf1 "guestssh,tcp,,220${id},,22"
        vboxmanage modifyvm $vm --nic2 bridged
        vboxmanage modifyvm $vm --bridgeadapter2 enp3s0
        vboxmanage modifyvm $vm --vram 128
        vboxmanage modifyvm $vm --drag-and-drop bidirectional
        vboxmanage modifyvm $vm --clipboard bidirectional
        vboxmanage modifyvm $vm --defaultfrontend headless

        echo "Partage du dossier de configuration pour $vm..."

        vboxmanage sharedfolder add $vm --name conf_$vm --hostpath /home/cisco/service_admin/conf_$vm --automount
    done

    sleep 30s

    ### Démarrage des VMs
    vboxmanage startvm client_admin1 
    vboxmanage startvm client_admin2 
    for i in {1..90} ; do
        printf "\rAttente de la configuration des VMs%-5s" "$(printf '.%.0s' $(seq 1 $((i % 5 + 1))))"
        sleep 1s
    done

    for vm in client_admin1 client_admin2; do
        vboxmanage guestcontrol $vm copyto --username=root --password=root --target-directory=/tmp/ /home/cisco/service_admin/scripts/vm/douglas11/$vm.sh
        vboxmanage guestcontrol $vm run --username=root --password=root /bin/chmod +x /tmp/$vm.sh
        vboxmanage guestcontrol $vm run --username=root --password=root /tmp/$vm.sh
    done
elif [ $1 == "destroy" ]; then
    vboxmanage controlvm client_admin1 poweroff
    vboxmanage controlvm client_admin2 poweroff

    sleep 20s

    vboxmanage unregistervm client_admin1 --delete-all
    vboxmanage unregistervm client_admin2 --delete-all

    list=$(vboxmanage list hdds | grep -e "^UUID" -e "^Location")

    echo "disks restants :"
    echo "$list" 

    disk=$(vboxmanage list hdds | grep "^UUID" | tail -2 | cut -d ' ' -f 12)
    
    ## should be only one line i need to keep (bookworm-12.12.vdi), but in case of broken script, we close admin disks
    if [ $(echo "$disk" | wc -l) -gt 1 ]; then
        echo "$disk" | while read -r line; do
            vboxmanage closemedium disk "$line" --delete
        done
    fi

else
    echo "Usage: douglas11.sh < create | destroy >"
    echo "Error: no argument corresponding to $1"
    exit 1
fi

