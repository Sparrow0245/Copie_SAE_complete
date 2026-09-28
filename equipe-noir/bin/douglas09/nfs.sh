#!/bin/bash
ifdown enp0s8

echo '
iface enp0s8 inet static
    address 192.168.4.10/26
    gateway 192.168.4.62
' > /etc/network/interfaces

ifup enp0s8

hostnamectl set-hostname nfs

if [ -e /media/sf_conf_nfs/ ]; then
    CONFDIR=/media/sf_conf_nfs
elif [ -e /media/user/sf_conf_nfs/ ]; then
    CONFDIR=/media/user/sf_conf_nfs
else
    echo "Dossier de configuration partagé introuvable."
    exit 1
fi

apt-get update
apt-get install -y nfs-kernel-server
mkdir -p /home
chown nobody:nogroup /home
chmod 777 /home
cp $CONFDIR/exports /etc/exports
exportfs -a
systemctl restart nfs-kernel-server
ip r add 192.168.0.0/16 via 192.168.4.126 dev enp0s8 
ip r add 192.168.4.64 via 192.168.4.126 dev enp0s8 