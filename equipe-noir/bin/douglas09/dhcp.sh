#!/bin/bash
ifdown enp0s8

echo '
iface enp0s8 inet static
    address 192.168.4.10/26
    gateway 192.168.4.62
' >> /etc/network/interfaces

ifup enp0s8

hostnamectl set-hostname dhcp

if [ -e /media/sf_conf_dhcp/ ]; then
    CONFDIR=/media/sf_conf_dhcp
elif [ -e /media/user/sf_conf_dhcp/ ]; then
    CONFDIR=/media/user/sf_conf_dhcp
else
    echo "Dossier de configuration partagé introuvable."
    exit 1
fi

apt-get update
apt-get install -y isc-dhcp-server
cp $CONFDIR/dhcpd.conf /etc/dhcp/dhcpd.conf
cp $CONFDIR/isc-dhcp-server /etc/default/isc-dhcp-server 
systemctl restart isc-dhcp-server
ip r add 192.168.0.0/16 via 192.168.4.126 dev enp0s8 
ip r add 192.168.4.64 via 192.168.4.126 dev enp0s8