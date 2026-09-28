#!/bin/bash
if [ $# != 1 ]; then
    echo "Usage: douglas10.sh < create | destroy >"
    echo "Error: no or too much arguments"
    exit 1
fi

INTERFACE="enp3s0"

sudo ip addr flush dev $INTERFACE
sudo ip link set dev $INTERFACE up
sudo ip addr add 192.168.4.61/26 dev $INTERFACE
sudo ip route add 192.168.0.0/16 via 192.168.4.62 dev $INTERFACE

export 'VBOXES=/home/cisco/VirtualBox VMs/'
export 'MODELE=/home/cisco/bookworm-12.12.vdi'

if [ $1 == "create" ]; then
    set -e

    for vm in ns1 ns2 resolver web mail; do
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

        vboxmanage sharedfolder add $vm --name conf_$vm --hostpath /home/cisco/dmz/conf_$vm --automount
        sleep 5s
    done

    ### Démarrage des VMs
    vboxmanage startvm ns1 
    vboxmanage startvm ns2 
    vboxmanage startvm resolver 
    vboxmanage startvm web 
    vboxmanage startvm mail 
    for i in {1..90} ; do
        printf "\rAttente de la configuration des VMs%-5s" "$(printf '.%.0s' $(seq 1 $((i % 5 + 1))))"
        sleep 1s
    done

    for vm in ns1 ns2 resolver web mail; do
        vboxmanage guestcontrol $vm copyto --username=root --password=root --target-directory=/tmp/ /home/cisco/dmz/scripts/vm/douglas10/$vm.sh
        vboxmanage guestcontrol $vm run --username=root --password=root /bin/chmod +x /tmp/$vm.sh
        vboxmanage guestcontrol $vm run --username=root --password=root /tmp/$vm.sh
    done
    
elif [ $1 == "destroy" ]; then

    for vm in ns1 ns2 resolver web mail; do
        vboxmanage controlvm $vm poweroff 

        vboxmanage unregistervm $vm --delete-all 
    done

    list=$(vboxmanage list hdds | grep -e "^UUID" -e "^Location")

    echo "disks restants :"
    echo "$list" 

    disk="vboxmanage list hdds | grep "^UUID" | tail -5 | cut -d ' ' -f 12"
    ## should be only one line i need to keep (bookworm-12.12.vdi), but in case of broken script, we close admin disks
    if [ $(echo "$disk" | wc -l) -gt 1 ]; then
        echo "$disk" | while read -r line; do
            vboxmanage closemedium disk "$line" --delete
        done
    fi
else
    echo "Usage: douglas10.sh < create | destroy >"
    echo "Error: no argument corresponding to $1"
    exit 1
fi


