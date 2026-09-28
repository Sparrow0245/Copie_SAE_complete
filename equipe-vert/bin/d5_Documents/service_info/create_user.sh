#!/bin/bash
# Exemple :
# ./create_user.sh it unused minhtue "Minh-Tue" "Tran" minhtue@vert.iut
set -e

ROLE=$1
GROUP=$2     # Gardé pour compatibilité, mais pas utilisé
LOGIN=$3
CN=$4
SN=$5
MAIL=$6

BASE_DN="dc=vert,dc=iut"
ADMIN_DN="cn=admin,$BASE_DN"

# Choix du groupe LDAP
if [ "$ROLE" = "it" ]; then
  NEW_GID=20001
elif [ "$ROLE" = "admin" ]; then
  NEW_GID=20002
elif [ "$ROLE" = "prod" ]; then
  NEW_GID=20003
else
  echo "Role invalide (it | admin | prod)"
  exit 1
fi

# OU unique (selon sujet SAÉ)
USER_OU="ou=people,$BASE_DN"

# Générer uidNumber unique
LAST_UID=$(ldapsearch -LLL -x -b "$BASE_DN" "(objectClass=posixAccount)" uidNumber \
            | grep "^uidNumber:" | awk '{print $2}' | sort -n | tail -1)

if [ -z "$LAST_UID" ]; then
  NEW_UID=21000
else
  NEW_UID=$((LAST_UID + 1))
fi

PASSWORD_HASH=$(slappasswd)

# Fichier LDIF
cat <<EOF > user.ldif
dn: uid=$LOGIN,$USER_OU
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: $LOGIN
cn: $CN
sn: $SN
mail: $MAIL
uidNumber: $NEW_UID
gidNumber: $NEW_GID
homeDirectory: /home/$LOGIN
loginShell: /bin/bash
userPassword: $PASSWORD_HASH
EOF

ldapadd -x -D "$ADMIN_DN" -W -f user.ldif
rm user.ldif

echo "[✓] Utilisateur $LOGIN créé avec UID $NEW_UID et GID $NEW_GID"
