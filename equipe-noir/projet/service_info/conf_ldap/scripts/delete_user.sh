#!/bin/bash
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Usage: $0 <-d <dn> | -u <uid>> "
  exit 2
fi

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <-d <dn> | -u <uid>> "
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

ldapdelete -Y EXTERNAL -H ldapi:/// "$DN"

echo "Deleted $DN"
