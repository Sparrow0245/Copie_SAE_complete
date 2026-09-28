#!/bin/bash
set -e

apt update -y
apt install -y isc-dhcp-server

sed -i 's/^INTERFACESv4=.*/INTERFACESv4="eth1"/' /etc/default/isc-dhcp-server

cat > /etc/dhcp/dhcpd.conf <<EOF
subnet 192.168.3.0 netmask 255.255.255.192 {
    range 192.168.3.3 192.168.3.61;
    option routers 192.168.3.62;
    option domain-name-servers 192.168.3.194;
}

subnet 192.168.3.64 netmask 255.255.255.192 {
    range 192.168.3.66 192.168.3.125;
    option routers 192.168.3.126;
    option domain-name-servers 192.168.3.194;
}

subnet 192.168.3.128 netmask 255.255.255.192 {
    range 192.168.3.130 192.168.3.189;
    option routers 192.168.3.190;
    option domain-name-servers 192.168.3.194;
}
EOF

systemctl restart isc-dhcp-server
systemctl status isc-dhcp-server --no-pager

