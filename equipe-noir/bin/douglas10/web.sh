#!/bin/bash
ifdown enp0s8

echo '
iface enp0s8 inet static
    address 192.168.4.30/26
    gateway 192.168.4.62
' >> /etc/network/interfaces

ifup enp0s8

hostnamectl set-hostname web

if [ -e /media/sf_conf_web/ ]; then
    CONFDIR=/media/sf_conf_web
elif [ -e /media/user/sf_conf_web/ ]; then
    CONFDIR=/media/user/sf_conf_web
else
    echo "Dossier de configuration partagé introuvable."
    exit 1
fi

apt-get update
apt-get install -y apache2
cp -r $CONFDIR/* /var/www/html/
cp $CONFDIR/resolv.conf /etc/resolv.conf
ip r add 192.168.0.0/16 dev enp0s8 via 192.168.4.62