
# LDAP - *Lightweight Directory Access Protocol*

Le service LDAP  permet de centraliser la gestion des utilisateurs et des groupes au sein de l'organisation. Grâce à cet annuaire, toutes les machines clientes peuvent s’authentifier de manière unifiée, sans nécessiter une base d’utilisateurs locale.

---


## Création et setup serveur `ldap`

Le serveur `ldap` a été créé à l'aide d’un fichier `Vagrantfile`.

Toutes les machines sont connectées en mode bridge à l’interface réseau *`enp3s0`*, car il s'agit de la carte réseau reliée directement à la baie réseau.

 Cette interface permet de communiquer avec les équipements réseau (commutateurs, routeurs) configurés pour assurer l’interconnexion entre les machines virtuelles.


```bash
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  config.vm.define "ldap-vert" do |conf|
    conf.vm.hostname = "ldap-vert"
    conf.vm.network "public_network",
      ip: "192.168.3.3",
      netmask: "255.255.255.192",
      bridge: "enp3s0"
  end
```

démarrer vm `ldap-vert`


```bash

vagrant up ldap-vert
```

Ensuite, nous avons exécuté le script `conf_vm_info`, dont le but est de configurer la **passerelle par défaut** ainsi que les paramètres DNS sur les machines.

Cela permet de garantir l’interconnexion entre les machines des différents VLANs, ainsi que la résolution des noms via le serveur DNS de l’organisation.

```bash
#!/bin/bash

sudo ip r add 192.168.0.0/16 via 192.168.3.62 dev eth1


echo "
domain vert.iut
search vert.iut
nameserver 192.168.3.194
" > /etc/resolv.conf

```
---

## 1. Installation des outils LDAP

L’installation a été réalisée sous Debian en utilisant les paquets `slapd` et `ldap-utils`.

 Le mode non interactif permet d’automatiser entièrement la procédure.

```bash

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
echo "Mot de passe chiffré généré"
echo ""

```

Un mot de passe administrateur a été défini pour l’entrée suivante :
```
cn=admin,dc=vert,dc=iut
```


Ce mot de passe est chiffré via la commande `slappasswd`.

---
## 2. Configuration du serveur LDAP
Le suffixe utilisé pour l’annuaire LDAP est :
```
dc=vert,dc=iut
```
Le répertoire de stockage des données LDAP a été défini comme suit :
```
/srv/ldap/vert
```
Les permissions sur les dossiers LDAP ont été ajustées pour l’utilisateur `openldap` :

```bash
mkdir -p /var/lib/ldap
mkdir -p /srv/ldap/vert
chown -R openldap:openldap /var/lib/ldap /srv/ldap/vert
chmod 700 /var/lib/ldap /srv/ldap/vert
```


On attribue le répertoire à l'utilisateur `openldap` à l’aide de la commande `chown`, car c’est sous cet utilisateur système que le service LDAP (`slapd`) s’exécute. Cela lui permet d’avoir les droits nécessaires en lecture et écriture sur ses fichiers de base de données, ce qui est indispensable pour assurer le bon fonctionnement et la sécurité du serveur LDAP.

---

## 3. Création de la base de données principale
La base de données principale a été créée via un fichier `db.ldif`, contenant la configuration suivante :
```ldif
dn: olcDatabase={1}mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: {1}mdb
olcSuffix: dc=vert,dc=iut
olcRootDN: cn=admin,dc=vert,dc=iut
olcRootPW: [Le mot de passe chiffré utilisé ici a été généré à l’étape 1 pour le `RootDN`]
olcDbDirectory: /srv/ldap/vert
olcDbIndex: objectClass eq
olcDbIndex: uid eq
```
Importation :
```bash
ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/db.ldif
```
Cette étape initialise l’annuaire LDAP, crée le domaine et configure l’administrateur.

---

## 4. Définition des règles d’accès (ACL)

Les règles d’accès (ACL) permettent de contrôler quelles entrées et quels attributs peuvent être consultés ou modifiés par les utilisateurs.

Voici les ACL appliquées :

```ldif
olcAccess: {0}to attrs=userPassword,shadowLastChange
  by dn.exact="cn=admin,dc=vert,dc=iut" manage
  by self write
  by anonymous auth
  by * none

olcAccess: {1}to attrs=mail,telephoneNumber
  by dn.exact="cn=admin,dc=vert,dc=iut" manage
  by self write
  by anonymous none
  by * none

olcAccess: {2}to *
  by dn.exact="cn=admin,dc=vert,dc=iut" manage
  by self write
  by users read
  by anonymous read
  by * none
```

Application :
```bash
ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/acl.ldif
```

Ces règles garantissent la confidentialité des mots de passe et un accès contrôlé aux données de l’annuaire.

---

## 5. Création de l’arborescence LDAP de l’organisation **`Vert`**

L’arborescence LDAP a été construite autour de deux unités organisationnelles :
- `ou=people` : stocke les utilisateurs
- `ou=groups` : stocke les groupes Unix/Linux

Structure appliquée :

```ldif
dn: dc=vert,dc=iut
objectClass: dcObject
objectClass: organization
dc: vert
o: Organisation Vert

dn: ou=people,dc=vert,dc=iut
objectClass: organizationalUnit
ou: people

dn: ou=groups,dc=vert,dc=iut
objectClass: organizationalUnit
ou: groups

dn: cn=it,ou=groups,dc=vert,dc=iut
objectClass: posixGroup
cn: it
gidNumber: 20001

dn: cn=admin,ou=groups,dc=vert,dc=iut
objectClass: posixGroup
cn: admin
gidNumber: 20002

dn: cn=prod,ou=groups,dc=vert,dc=iut
objectClass: posixGroup
cn: prod
gidNumber: 20003
```

Importation :
```bash
ldapadd -x -D "cn=admin,dc=vert,dc=iut" -W -f /tmp/tree.ldif
```

L’organisation dispose désormais d’un schéma fonctionnel, avec ses unités et groupes métiers.

---
## 6, Création utilisateurs de l'organisation **`vert`**

La création des comptes utilisateurs pour l'organisation Vert a été automatisée à l’aide d’un script nommé `create_user.sh`.

Ce script permet d’ajouter un utilisateur Linux dans l'annuaire LDAP, en générant dynamiquement un UID unique, en choisissant le bon groupe selon le rôle de l’utilisateur, et en chiffrant le mot de passe.



```bash
#!/bin/bash
# Exemple pour utiliser le script :
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

echo "Utilisateur $LOGIN créé avec UID $NEW_UID et GID $NEW_GID"

```
---

## 7. Test de validation

Un test global a été réalisé afin de vérifier l’accès à l’annuaire et l’existence des entrées créées.

```bash
ldapsearch -x -b "dc=vert,dc=iut" "(objectClass=*)" dn
```

Résultats attendus :
- Présence de la racine : `dc=vert,dc=iut`
- Unités organisationnelles :
  - `ou=people`
  - `ou=groups`
- Groupes :
  - `cn=it`
  - `cn=admin`
  - `cn=prod`
- Utilisateurs:

 - `Minh-Tue`
 - `Mohane`
 - `Kevin`

Ce test confirme que :
- la base LDAP est correctement initialisée,
- les ACL sont appliquées,
- la structure de l’annuaire est opérationnelle.
- Les utilisateurs de l'organisation vert


---

 [Retour au sommaire des services](./3-0-serviceinformatique.md)
