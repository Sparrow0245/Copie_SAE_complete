#!/bin/bash

mkdir -p /srv/ldap/noir.iut
chown -R openldap:openldap /srv/ldap/noir.iut

echo "Adding DB configuration to cn=config (requires root)"
ldapadd -Y EXTERNAL -H ldapi:/// -f "/root/config/newdb.ldif"
ldapmodify -Y EXTERNAL -H ldapi:/// -f "/root/config/acces.ldif"

echo "Adding base entries to the new database"
ldapadd -Y EXTERNAL -H ldapi:/// -f "/root/config/root.ldif"
ldapadd -Y EXTERNAL -H ldapi:/// -f "/root/config/objects.ldif"
echo "Initialization complete."
