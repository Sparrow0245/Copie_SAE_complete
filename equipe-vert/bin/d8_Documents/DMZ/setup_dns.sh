#!/bin/bash

apt update -y
apt install -y bind9

###############################################
# named.conf.options — recursion + forwarders #
###############################################

cat >/etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";

    recursion yes;
    allow-recursion {
        192.168.0.0/16;
    };

    allow-query {
        192.168.0.0/16;
    };

    forwarders {
        192.168.4.20;
    };

    dnssec-validation no;

    auth-nxdomain no;
    listen-on { any; };
};
EOF

#########################################
# named.conf.local — authoritative zone #
#########################################

cat >/etc/bind/named.conf.local <<EOF
zone "vert.iut" {
    type master;
    file "/var/cache/bind/db.vert.iut";
};
EOF

#########################################
# Zone file db.vert.iut —   #
#########################################

cat >/var/cache/bind/db.vert.iut <<EOF
\$TTL 604800
@   IN  SOA ns.vert.iut. admin.vert.iut. (
            1
            604800
            86400
            2419200
            604800
)
@       IN  NS      ns.vert.iut.

ns      IN  A       192.168.3.194
www     IN  A       192.168.3.194
mail    IN  A       192.168.3.194

@       IN  MX 10   mail.vert.iut.
EOF

systemctl restart bind9
