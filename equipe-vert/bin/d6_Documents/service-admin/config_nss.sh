#!/bin/bash
set -e

echo "[+] Configuration NSS + LDAP LOCAL (serveur-tp5)"


# ----------------------------
# 2. Configuration nslcd pour votre LDAP
# ----------------------------
cat << EOF > /etc/nslcd.conf
uid nslcd
gid nslcd

# LDAP de votre serveur local (pas TLS)
uri ldap://192.168.3.3

# Base LDAP
base dc=vert,dc=iut

# Bind DN pour permettre NSS/PAM de lire la base
binddn cn=admin,dc=vert,dc=iut
bindpw admin

# Pas de TLS
ssl off
tls_reqcert never
EOF

# ----------------------------
# 3. NSS -> ajouter LDAP
# ----------------------------
sed -i \
  -e 's/^passwd:.*/passwd: files systemd ldap/' \
  -e 's/^group:.*/group:  files systemd ldap/' \
  -e 's/^shadow:.*/shadow: files systemd ldap/' \
  /etc/nsswitch.conf

# ----------------------------
# 4. Démarrage
# ----------------------------
systemctl restart nslcd
systemctl enable nslcd

echo "[✓] NSS + LDAP local configuré"