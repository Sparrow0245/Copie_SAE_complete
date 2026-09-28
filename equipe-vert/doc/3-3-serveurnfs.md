# NFS - *Network File System*


Le but est de mettre en place un **serveur NFS** qui centralise les répertoires personnels (`/home`) de tous les utilisateurs de l'organisation Vert. Ces répertoires seront ensuite montés automatiquement sur les machines clientes via **Autofs**.

Cette solution permet :
- Une gestion centralisée des données utilisateurs
- Un accès cohérent aux fichiers quel que soit le poste de travail
- Une compatibilité avec l’annuaire LDAP (UID/GID)

---

## Création et setup serveur `nfs-vert`

Le serveur `DHCP` a été créé à l'aide d’un fichier `Vagrantfile`.

Toutes les machines sont connectées en mode bridge à l’interface réseau *`enp3s0`*, car il s'agit de la carte réseau reliée directement à la baie réseau.

 Cette interface permet de communiquer avec les équipements réseau (commutateurs, routeurs) configurés pour assurer l’interconnexion entre les machines virtuelles.


```bash
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  config.vm.define "nfs-vert" do |conf|
    conf.vm.hostname = "nfs-vert"
    conf.vm.network "public_network",
      ip: "192.168.3.5",
      netmask: "255.255.255.192",
      bridge: "enp3s0"
    #conf.vm.provision "shell", path: "conf_vm_info"
    #conf.vm.provision "shell", path: "setup-dhcp.sh"
  end
```

démarrer vm `nfs-vert`


```bash

vagrant up nfs-vert
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

## 1. Déploiement du serveur NFS (`nfs-vert`)

Un script `nfs_setup.sh` a été utilisé pour automatiser l’installation et la configuration du service , ainsi que la création des utilisateurs à partir du serveur LDAP.

### Contenu du script

```bash
#!/bin/bash
set -e

LDAP_SERVER="ldap://192.168.3.3"
BASE_DN="dc=vert,dc=iut"
INFO_NET="192.168.3.0/24"
NFS_HOME="/home"

# 1. Installation
apt update -y
apt install -y nfs-kernel-server ldap-utils

# 2. Création du répertoire /home
mkdir -p $NFS_HOME
chmod 755 $NFS_HOME

# 3. Lecture des utilisateurs depuis LDAP (bind anonyme)
USERS=$(ldapsearch -x -H "$LDAP_SERVER" \
  -b "ou=people,$BASE_DN" "(objectClass=posixAccount)" \
  uid uidNumber gidNumber | awk '
    /uid: /        { u=$2 }
    /uidNumber: /  { uid=$2 }
    /gidNumber: /  { gid=$2 }
    /^$/ {
        if (u!="") print u,uid,gid
        u=""; uid=""; gid=""
    }')

# 4. Création des répertoires /home/<user>
while read -r user uid gid; do
  DIR="$NFS_HOME/$user"
  mkdir -p "$DIR"
  chown $uid:$gid "$DIR"
  chmod 700 "$DIR"
done <<< "$USERS"

# 5. Configuration de /etc/exports
cat <<EOF >/etc/exports
/home   ${INFO_NET}(rw,sync,no_subtree_check)
EOF

exportfs -ra
systemctl restart nfs-server
systemctl enable nfs-server

```

### Points clés de la configuration

-  `/etc/exports` : Ce fichier permets de définir quels répertoires du serveur seront partagés via NFS, à quelles machines ils sont accessibles, et avec quelles permissions.

Cela signifie que le répertoire `/home` est accessible :

- en lecture/écriture (rw)

- uniquement pour les machines du sous-réseau 192.168.3.0/24

- avec synchronisation (sync) pour garantir l'intégrité des données

- et que la vérification des sous-répertoires est désactivée (no_subtree_check), ce qui évite certains problèmes de performance.
- root_squash : active par défaut -> l’utilisateur `root` sur le client NFS n’aura pas les privilèges root sur le serveur.


- Commande `exportfs -ra` permets de recharger les règles sans redémarrer le service NFS.
## 2. Validations et tests

Une fois le serveur NFS configuré, plusieurs vérifications ont été effectuées :

### Vérification des exports actifs

```bash
sudo exportfs -v
```

Résultat attendu :

```bash
vagrant@nfs-vert:~$ sudo exportfs -v
/home           192.168.3.0/24(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)

```

---

 [Retour au sommaire des services](./3-0-serviceinformatique.md)
