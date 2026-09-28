#!/bin/bash
# Usage :
#   ./delete_user.sh minhtue

set -e

LOGIN=$1

if [ -z "$LOGIN" ]; then
    echo "Usage: $0 <login>"
    exit 1
fi

BASE_DN="dc=vert,dc=iut"
ADMIN_DN="cn=admin,$BASE_DN"

USER_DN="uid=$LOGIN,ou=people,$BASE_DN"

echo "→ Suppression de l'utilisateur : $LOGIN"
echo "   DN = $USER_DN"
echo ""

cat <<EOF > delete.ldif
dn: $USER_DN
changetype: delete
EOF

ldapmodify -x -D "$ADMIN_DN" -W -f delete.ldif

rm delete.ldif

echo "[✓] Utilisateur $LOGIN supprimé du LDAP."
