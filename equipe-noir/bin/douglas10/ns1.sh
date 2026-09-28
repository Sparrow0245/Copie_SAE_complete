#!/bin/bash
ifdown enp0s8

echo '
iface enp0s8 inet static
    address 192.168.4.10/26
    gateway 192.168.4.62
' >> /etc/network/interfaces

ifup enp0s8

hostnamectl set-hostname ns1

if [ -e /media/sf_conf_ns1/ ]; then
    CONFDIR=/media/sf_conf_ns1
elif [ -e /media/user/sf_conf_ns1/ ]; then
    CONFDIR=/media/user/sf_conf_ns1
else
    echo "Dossier de configuration partagé introuvable."
    exit 1
fi

apt-get update
apt-get install -y bind9
cp $CONFDIR/db.* /var/cache/bind/
cp $CONFDIR/named.conf.local /etc/bind/named.conf.local
cp $CONFDIR/resolv.conf /etc/resolv.conf
systemctl restart named
ip r add 192.168.0.0/16 dev enp0s8 via 192.168.4.62