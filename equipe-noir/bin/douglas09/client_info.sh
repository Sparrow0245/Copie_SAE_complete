#!/bin/bash
ifdown enp0s8

echo '
iface enp0s8 inet dhcp
' >> /etc/network/interfaces

ifup enp0s8

hostnamectl set-hostname client_info

if [ -e /media/sf_conf_client_info/ ]; then
    CONFDIR=/media/sf_conf_client_info
elif [ -e /media/user/sf_conf_client_info/ ]; then
    CONFDIR=/media/user/sf_conf_client_info
else
    echo "Dossier de configuration partagé introuvable."
    exit 1
fi

ip r add 192.168.0.0/16 via 192.168.4.126 dev enp0s8
ip r add 192.168.4.64 via 192.168.4.126 dev enp0s8

apt-get update
apt-get install -y firefox-esr thunderbird xfce4 lightdm

cp -r $CONFDIR/pam.d /etc/
cp $CONFDIR/nsswitch.conf /etc/
cp $CONFDIR/nslcd.conf /etc/
cp $CONFDIR/resolv.conf /etc/
cp $CONFDIR/fstab /etc/