#!/bin/bash
set -e

LDAP_SERVER="ldap://192.168.3.3"
BASE_DN="dc=vert,dc=iut"
INFO_NET="192.168.3.0/24"

# CHANGED: Use /home instead of /srv/nfs/home
NFS_HOME="/home"

echo "=== Installation du serveur NFS ==="
apt update -y
apt install -y nfs-kernel-server ldap-utils

echo ""
echo "=== Création de l'arborescence NFS ==="
mkdir -p $NFS_HOME
chmod 755 $NFS_HOME

echo ""
echo "=== Lecture des utilisateurs LDAP (bind anonyme) ==="

USERS=$(ldapsearch -x -H "$LDAP_SERVER" \
        -b "ou=people,$BASE_DN" "(objectClass=posixAccount)" \
        uid uidNumber gidNumber | \
        awk '
          /uid: /        { u=$2 }
          /uidNumber: /  { uid=$2 }
          /gidNumber: /  { gid=$2 }
          /^$/ {
              if (u!="") print u,uid,gid
              u=""; uid=""; gid=""
          }
        ')

echo "$USERS"

echo ""
echo "=== Création des HOME directories ==="

while read -r user uid gid; do
    DIR="$NFS_HOME/$user"
    echo "[+] Création : $DIR (UID=$uid GID=$gid)"
    mkdir -p "$DIR"
    chown $uid:$gid "$DIR"
    chmod 700 "$DIR"
done <<< "$USERS"

echo ""
echo "=== Configuration de /etc/exports ==="

# CHANGED: Export only /home
cat <<EOF >/etc/exports
/home   ${INFO_NET}(rw,sync,no_subtree_check)
EOF

exportfs -ra
systemctl restart nfs-server
systemctl enable nfs-server

echo ""
echo "=== Exports NFS ==="
exportfs -v

echo ""
echo "==============================================="
echo "[✓] SERVEUR NFS prêt (Équipe Vert)"
echo "    Home: /home"
echo "    Réseau autorisé: ${INFO_NET}"
echo "==============================================="
