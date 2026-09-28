#!/bin/bash
set -e

echo "=== Installation des outils LDAP ==="
sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y slapd ldap-utils

#################################
# CONFIG
#################################
SUFFIX="dc=vert,dc=iut"
ADMIN_DN="cn=admin,$SUFFIX"
DBDIR="/srv/ldap/vert"

echo "=== Configuration du mot de passe ADMIN LDAP ==="
echo "→ Entrez le mot de passe ADMIN LDAP :"
ADMIN_PW_HASH=$(sudo slappasswd)
echo "✔ Mot de passe chiffré généré"
echo ""


#################################
echo "==  SET UP LDAP =="
#################################

mkdir -p /var/lib/ldap
mkdir -p $DBDIR
chown -R openldap:openldap /var/lib/ldap $DBDIR
chmod 700 /var/lib/ldap $DBDIR


#################################
echo "== CREATE MAIN DB =="
#################################

cat > /tmp/db.ldif <<EOF
dn: olcDatabase={1}mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: {1}mdb
olcSuffix: $SUFFIX
olcRootDN: $ADMIN_DN
olcRootPW: $ADMIN_PW_HASH
olcDbDirectory: $DBDIR
olcDbIndex: objectClass eq
olcDbIndex: uid eq
EOF

ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/db.ldif


#################################
echo "== ACL LOGIN + SEARCH =="
#################################

cat > /tmp/acl.ldif <<EOF
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by dn.exact="$ADMIN_DN" manage by self write by anonymous auth by * none
-
add: olcAccess
olcAccess: {1}to attrs=mail,telephoneNumber by dn.exact="$ADMIN_DN" manage by self write by anonymous none by * none
-
add: olcAccess
olcAccess: {2}to * by dn.exact="$ADMIN_DN" manage by self write by users read by anonymous read by * none
EOF

ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/acl.ldif


#################################
echo "==  CREATE DIRECTORY TREE =="
#################################

cat > /tmp/tree.ldif <<EOF
dn: $SUFFIX
objectClass: dcObject
objectClass: organization
dc: vert
o: Organisation Vert

dn: ou=people,$SUFFIX
objectClass: organizationalUnit
ou: people

dn: ou=groups,$SUFFIX
objectClass: organizationalUnit
ou: groups

dn: cn=it,ou=groups,$SUFFIX
objectClass: posixGroup
cn: it
gidNumber: 20001

dn: cn=admin,ou=groups,$SUFFIX
objectClass: posixGroup
cn: admin
gidNumber: 20002

dn: cn=prod,ou=groups,$SUFFIX
objectClass: posixGroup
cn: prod
gidNumber: 20003
EOF

ldapadd -x -D "$ADMIN_DN" -W -f /tmp/tree.ldif


#################################
echo "== TEST =="
#################################

echo "-- Test structure LDAP --"
ldapsearch -x -b "$SUFFIX" "(objectClass=*)" dn

echo ""
echo "======================================================"
echo "✔ INSTALLATION LDAP VERT.IUT TERMINÉE AVEC SUCCÈS"
echo "✔ Base créée"
echo "✔ ACL appliquées"
echo "✔ Arborescence people + groups OK"
echo "➡ Prêt à ajouter des utilisateurs"
echo "======================================================"
