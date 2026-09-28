#!/bin/bash
set -e

echo "=== STEP 1: Install slapd (non-interactive) ==="
apt update
DEBIAN_FRONTEND=noninteractive apt install -y slapd ldap-utils

echo "=== Ensure slapd is running ==="
systemctl start slapd
systemctl enable slapd

echo "=== STEP 2.1: Delete default MDB database (if exists) ==="

# Find default mdb database DN
DB_DN=$(ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config "(olcDatabase=mdb)" dn | grep "^dn:" | cut -d' ' -f2)

if [ -n "$DB_DN" ]; then
  echo "Found existing DB: $DB_DN → deleting"
  ldapdelete -Y EXTERNAL -H ldapi:///"$DB_DN"
else
  echo "No existing MDB database found"
fi

echo "=== Cleaning /var/lib/ldap ==="
rm -rf /var/lib/ldap/*
chown -R openldap:openldap /var/lib/ldap

echo "=== STEP 2.2: Create new MDB database (dc=iut,dc=vert) ==="

read -s -p "Enter LDAP admin password: " ADMIN_PW
echo
HASH=$(slappasswd -s "$ADMIN_PW")

cat > /tmp/01-create-db.ldif <<EOF
dn: olcDatabase=mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: mdb
olcSuffix: dc=iut,dc=vert
olcRootDN: cn=admin,dc=iut,dc=vert
olcRootPW: $HASH
olcDbDirectory: /var/lib/ldap
olcDbIndex: objectClass eq
olcDbIndex: uid eq
olcDbIndex: cn eq
olcDbIndex: gidNumber eq
olcDbIndex: uidNumber eq
EOF

ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/01-create-db.ldif

echo "=== Restart slapd ==="
systemctl restart slapd

echo "=== VERIFY: empty search on dc=iut,dc=vert ==="
ldapsearch -x -D "cn=admin,dc=iut,dc=vert" -W -b "dc=iut,dc=vert" || true

echo "=== STEP 1 + STEP 2 DONE SUCCESSFULLY ==="
