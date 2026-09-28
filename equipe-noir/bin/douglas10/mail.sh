#!/bin/bash
ifdown enp0s8

echo '
iface enp0s8 inet static
    address 192.168.4.40/26
    gateway 192.168.4.62
' >> /etc/network/interfaces

ifup enp0s8

hostnamectl set-hostname mail

if [ -e /media/sf_conf_mail/ ]; then
    CONFDIR=/media/sf_conf_mail
elif [ -e /media/user/sf_conf_mail/ ]; then
    CONFDIR=/media/user/sf_conf_mail
else
    echo "Dossier de configuration partagé introuvable."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
# echo 'postfix postfix/main_mailer_type string Internet Site' | debconf-set-selections
apt-get install -y postfix dovecot-imapd dovecot-pop3d
cp $CONFDIR/main.cf /etc/postfix/main.cf
cp $CONFDIR/mailname /etc/mailname
cp $CONFDIR/10-auth.conf /etc/dovecot/conf.d/10-auth.conf
cp $CONFDIR/10-mail.conf /etc/dovecot/conf.d/10-mail.conf
cp $CONFDIR/resolv.conf /etc/resolv.conf
systemctl restart postfix dovecot
ip r add 192.168.0.0/16 dev enp0s8 via 192.168.4.62