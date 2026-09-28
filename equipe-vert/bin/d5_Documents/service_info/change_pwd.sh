#!/bin/bash
# Usage :
#   ./change_password.sh minhtue

set -e

LOGIN=$1

if [ -z "$LOGIN" ]; then
    echo "Usage: $0 <login>"
    exit 1
fi

BASE_DN="dc=vert,dc=iut"
ADMIN_DN="cn=admin,$BASE_DN"
USER_DN="uid=$LOGIN,ou=people,$BASE_DN"

echo "→ Entrer le nouveau mot de passe pour l'utilisateur $LOGIN :"
NEW_PW_HASH=$(slappasswd)

cat <<EOF > change_pw.ldif
dn: $USER_DN
changetype: modify
replace: userPassword
userPassword: $NEW_PW_HASH
EOF

ldapmodify -x -D "$ADMIN_DN" -W -f change_pw.ldif

rm change_pw.ldif

echo " Mot de passe de $LOGIN changé avec succès."
