#!/bin/bash
ifdown enp0s8

echo '
iface enp0s8 inet static
    address 192.168.4.10/26
    gateway 192.168.4.62
' >> /etc/network/interfaces

ifup enp0s8

hostnamectl set-hostname ldap

if [ -e /media/sf_conf_ldap/ ]; then
    CONFDIR=/media/sf_conf_ldap
elif [ -e /media/user/sf_conf_ldap/ ]; then
    CONFDIR=/media/user/sf_conf_ldap
else
    echo "Dossier de configuration partagé introuvable."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y slapd ldap-utils

mkdir -p /srv/ldap/noir.iut
chown -R openldap:openldap /srv/ldap/noir.iut

echo "Adding DB configuration to cn=config (requires root)"
ldapadd -Y EXTERNAL -H ldapi:/// -f "$CONFDIR/newdb.ldif"
ldapmodify -Y EXTERNAL -H ldapi:/// -f "$CONFDIR/acces.ldif"

echo "Adding base entries to the new database"
ldapadd -Y EXTERNAL -H ldapi:/// -f "$CONFDIR/root.ldif"
ldapadd -Y EXTERNAL -H ldapi:/// -f "$CONFDIR/objects.ldif"
echo "Initialization complete."

systemctl restart slapd
ip r add 192.168.0.0/16 via 192.168.4.126 dev enp0s8 
ip r add 192.168.4.64 via 192.168.4.126 dev enp0s8