#!/bin/bash
if [ "$#" -lt 6 ]; then
  echo "Usage: $0 <cn> <student|teacher> <uid> <mail> <password> <year>"
  exit 2
fi

CN="$1"
SN=$(echo "$CN" | cut -d' ' -f2-)
TYPE="$2"
USER_UID="$3"
MAIL="$4"
PW="$5"
YEAR="$6"

BASE_DN="dc=but3b,dc=local"

if [ "$TYPE" = "teacher" ]; then
  DN="uid=$USER_UID,ou=enseignants,$BASE_DN"
elif [ "$TYPE" = "student" ]; then
  if [ -z "$YEAR" ]; then
    echo "For students you must provide a year (e.g. 1,2,3)"
    exit 2
  fi
  DN="uid=$USER_UID,ou=annee${YEAR},ou=etudiants,$BASE_DN"
else
  echo "Unknown type: $TYPE"
  exit 2
fi

EPW=$(slappasswd -s "$PW")

echo "Creating user $DN"
echo "dn: $DN
objectClass: inetOrgPerson
cn: $CN
sn: $SN
mail: $MAIL
uid: $USER_UID
userPassword: $EPW" > /tmp/new_user.ldif
LDIF="/tmp/new_user.ldif"


ldapadd -Y EXTERNAL -H ldapi:/// -f "$LDIF"
rm -f "$LDIF"

echo "Created $DN"
