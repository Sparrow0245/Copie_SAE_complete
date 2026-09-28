#!/bin/bash
set -e

echo "=== Force DNS configuration in /etc/resolv.conf ==="

cat <<EOF > /etc/resolv.conf
domain iut-infobio.priv.univ-lille1.fr
search iut-infobio.priv.univ-lille1.fr
nameserver 172.18.48.31
EOF

echo "=== /etc/resolv.conf updated ==="
cat /etc/resolv.conf
