#!/bin/bash
set -e

NFS_SERVER="192.168.3.5"      # IP du serveur NFS

echo "=== Installation du client NFS ==="
apt update -y
apt install -y nfs-common autofs

echo ""
echo "=== Configuration AUTOFS ==="

cat <<EOF >/etc/auto.master.d/home.autofs
/home   /etc/auto.home
EOF

cat <<EOF >/etc/auto.home
*   -fstype=nfs4    ${NFS_SERVER}:/home/&
EOF

echo ""
systemctl restart autofs

echo "nfs configuré , aller test !"


