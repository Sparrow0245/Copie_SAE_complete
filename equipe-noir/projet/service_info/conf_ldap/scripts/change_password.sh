#!/bin/bash
if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <-d <dn> | -u <uid>> <new_password>"
  exit 2
fi

if [ "$1" = "-d" ]; then
  DN="$2"
else
  USER_UID="$2"
  ldapsearch -Y EXTERNAL -H ldapi:/// -b dc=but3b,dc=local -LLL "(uid=$2)" dn | grep "^dn: " | sed 's/^dn: //' > /tmp/dn_to_delete.txt
  DN=$(cat /tmp/dn_to_delete.txt)
  if [ -z "$DN" ]; then
    echo "User with uid $USER_UID not found."
    exit 1
  fi
fi

ldappasswd -Y EXTERNAL -H ldapi:/// -s "$3" "$DN"

echo "Password changed for $DN"