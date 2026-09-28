
# Poste de travail dans le pôle admin - PAM NSS NFS Client (Autofs) Thunderbird Firefox

Le but de ce poste de travail permet de valider l'intégration des services LDAP (via **NSS** - *Name Service Switch* et **PAM** - *Pluggable Authentication Modules*) pour l'authentification centralisée, ainsi que le montage automatique des répertoires personnels via NFS (grâce à Autofs), offrant ainsi aux utilisateurs un environnement cohérent et nomade au sein de l’organisation.

- `NSS` est un système qui permet à Linux de chercher des informations sur les utilisateurs, groupes, hôtes, etc., à travers différentes sources de données.

- `PAM` est un système modulaire d’authentification utilisé sous Linux pour gérer les mécanismes d’identification des utilisateurs.

- `Autofs` est un service Linux qui monte automatiquement des systèmes de fichiers à la demande (comme NFS), et les démonte après inactivité pour optimiser l’utilisation des ressources  

- `Thunderbird` outils de gestions du mail entre les organisation

---
## Création et setup poste de travail dans le pôle admin 


Le poste de travail `poste1-Admin` a été configuré à l’aide du fichier `Vagrantfile` en mode **interface graphique (XFCE)** pour simuler une machine utilisateur complète.

Toutes les machines sont connectées en mode bridge à l’interface réseau *`enp3s0`*, car il s'agit de la carte réseau reliée directement à la baie réseau.

 Cette interface permet de communiquer avec les équipements réseau (commutateurs, routeurs) configurés pour assurer l’interconnexion entre les machines virtuelles.

```ruby
 config.vm.define "poste1-Admin" do |conf|
    conf.vm.hostname = "poste1-Admin"
    conf.vm.network "public_network", ip: "192.168.3.70", netmask: "255.255.255.192",bridge: "enp3s0"

    conf.vm.provision "shell", inline: <<-SHELL
      sudo apt update
      sudo apt install -y xfce4 lightdm firefox-esr thunderbird thunderbird-l10n-fr
      sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
    SHELL
  end
  ```


  
démarrer vm `poste1-Admin`


```bash

vagrant up poste1-Admin
```

Ensuite, nous avons exécuté le script `vm_conf_admin`, dont le but est de configurer la **passerelle par défaut** ainsi que les paramètres DNS sur les machines.

Cela permet de garantir l’interconnexion entre les machines des différents VLANs, ainsi que la résolution des noms via le serveur DNS de l’organisation.

```bash
#!/bin/bash

sudo ip r add 192.168.0.0/16 via 192.168.3.126 dev eth1


echo "
domain vert.iut
search vert.iut
nameserver 192.168.3.194
" > /etc/resolv.conf

```

---


## 1. Intégration LDAP avec NSS

###  Installation des paquets nécessaires

```bash
#!/bin/bash


sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
nslcd \
libnss-ldapd \
libpam-ldapd \
ldap-utils \
libpam-google-authenticator

```

###  Fichier `/etc/nslcd.conf`

```conf
uid nslcd
gid nslcd
uri ldap://192.168.3.3
base dc=vert,dc=iut
binddn cn=admin,dc=vert,dc=iut
bindpw admin
ssl off
tls_reqcert never
```

###  Mise à jour de `/etc/nsswitch.conf`

```conf
passwd:         files systemd ldap
group:          files systemd ldap
shadow:         files systemd ldap
```

### Redémarrage du service

```bash
systemctl restart nslcd
systemctl enable nslcd
```

### Point clé de configurations

- `nslcd` daemon permet de faire le lien entre le service LDAP et les composants du système (PAM, NSS), en assurant les requêtes d’identités et d’authentification des utilisateurs.


- `/etc/nslcd.conf` : configure le client LDAP pour permettre à NSS et PAM d’interroger l’annuaire.

- `/etc/nsswitch.conf` : définit les sources (fichiers locaux, LDAP, etc.) utilisées pour résoudre les utilisateurs, groupes et mots de passe.

- `binddn cn=admin,dc=vert,dc=iut` permet de lire les mots de passe pour l’authentification, car selon les règles ACL de notre LDAP, seul l’admin a le droit de lire l’attribut `userPassword` -> Faut vérifier que seuls `root` et `nslcd` ont les droits de lecture sur `/etc/nslcd.conf` afin de protéger les identifiants LDAP.



---

## 2. Configuration PAM (authentification LDAP + 2FA)

L’intégration de PAM permet l’authentification des utilisateurs LDAP, avec en option l’ajout d’un second facteur (2FA) via Google Authenticator.

###  Étapes de configuration

```bash
# 1. Activer LDAP et Unix via PAM
pam-auth-update --enable ldap --enable unix --force


# 2. Intégrer Google Authenticator pour SSH
sed -i '/@include common-auth/i auth required pam_google_authenticator.so nullok' /etc/pam.d/sshd

# 3. Activer PAM dans SSH
sed -i 's/^#\?UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config
sed -i 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config

# 4. Redémarrer le service SSH
systemctl restart ssh
```

---


### Point clé de configurations

- `etc/pam.d/*` : contient les fichiers de configuration PAM pour chaque service (SSH, login, su…), utilisés pour définir les modules d’authentification.

- `pam-auth-update --enable ldap --enable unix --force` : permet d’activer les modules LDAP et Unix dans PAM afin d’autoriser l’authentification des utilisateurs locaux et LDAP sur l’ensemble du système.


## 3. Déplacement du `/home` de Vagrant

Le répertoire `/home/vagrant` doit être déplacé pour libérer `/home` en vue du montage NFS.

###  Script de migration

```bash
#!/bin/bash
set -e

OLD_HOME="/home/vagrant"
NEW_HOME="/home-local/vagrant"

# Vérification de l'utilisateur
id vagrant >/dev/null 2>&1 || { echo "Utilisateur vagrant introuvable"; exit 1; }

# Installer rsync si nécessaire
apt update
apt install -y rsync

# Créer le nouveau répertoire et copier les fichiers
mkdir -p "$NEW_HOME"
rsync -a "$OLD_HOME/" "$NEW_HOME/"
chown -R vagrant:vagrant "$NEW_HOME"

# Modifier le fichier /etc/passwd
cp /etc/passwd /etc/passwd.bak
sed -i "s|$OLD_HOME|$NEW_HOME|" /etc/passwd

# Sauvegarder l'ancien répertoire
mv "$OLD_HOME" "${OLD_HOME}.backup_$(date +%s)"
```

---

## 4. Configuration du client NFS avec `Autofs`

Autofs permet de monter dynamiquement les dossiers utilisateurs depuis le serveur NFS (`192.168.3.5`).

###  Installation et configuration

```bash
# Installer les paquets nécessaires
apt install -y nfs-common autofs

# Configurer le fichier auto.master.d
echo "/home /etc/auto.home" > /etc/auto.master.d/home.autofs

# Définir les règles dans /etc/auto.home
echo "* -fstype=nfs4 192.168.3.5:/home/&" > /etc/auto.home

# Redémarrer le service
systemctl restart autofs
```

## Points clé de la configuration

- ` /etc/auto.home`: Fichier de règles (map file) : définit comment chaque sous-dossier de `/home` doit être monté, en fonction du nom d’utilisateur (avec *).

contient la règle de montage dynamique pour chaque utilisateur.

-  ` /etc/auto.master.d/home.autofs`: Fichier maître (master map) : indique à Autofs quel chemin `(/home)` doit être géré automatiquement, et quel fichier de règles utiliser `(/etc/auto.home)`.

- `* -fstype=nfs4 192.168.3.5:/home/&`: indique que chaque dossier `/home/<user>` doit être monté à la volée depuis le serveur NFS.

- Le `*` signifie "tout nom d'utilisateur" : chaque accès à `/home/<user>` déclenche un montage NFS depuis `192.168.3.5:/home/<user>`.


---

## 5. Tests de validation

### Étape 1 – Vérifier la détection d’un utilisateur LDAP

```bash
getent passwd <nom_utilisateur>
```

Cette commande permet de s'assurer que l'utilisateur est bien visible via **NSS** (résolution LDAP).

### Connexion avec un utilisateur LDAP

```bash
su - minh
```

Le répertoire `/home/minh` est automatiquement monté depuis le serveur NFS grâce à **Autofs**.

### Résultat attendu

```bash
vagrant@nss-pam-admin:~$ su - minh
Password:
minh@nss-pam-admin:~$ pwd
/home/minh
```

---

### Étape 2 – Vérifier le montage entre les pôles et équipes

Créer un répertoire de test dans le home de l'utilisateur `minh` :

```bash
minh@nss-pam-admin:~$ mkdir minh_test
minh@nss-pam-admin:~$ ls
minh_test
```

Se connecter ensuite sur un autre poste ou directement sur le serveur `nfs-vert` pour vérifier que le répertoire a bien été synchronisé entre client et serveur via **NFS**.

Il est également recommandé de tester les **droits d'accès**, pour s'assurer qu'un utilisateur ne peut accéder qu'à son propre dossier.

### Résultat attendu

```bash
vagrant@nfs-vert:/home$ sudo su
root@nfs-vert:/home# ls
kevin  minh  mohane  vagrant
root@nfs-vert:/home# cd minh/
root@nfs-vert:/home/minh# ls
minh_test
```

```bash
minh@nss-pam-admin:/home$ ls
kevin  minh  mohane  vagrant
minh@nss-pam-admin:/home$ cd kevin/
-bash: cd: kevin/: Permission denied
minh@nss-pam-admin:/home$ ls -ld kevin/
drwx------ 2 kevin it 4096 Feb  8 19:46 kevin/
```

Ces résultats montrent que :
- Les montages NFS sont **fonctionnels et synchronisés** entre client et serveur.
- Les **droits d'accès** sont respectés : les utilisateurs ne peuvent pas accéder aux dossiers d'autres comptes.

---

###  Étape 3 – Outils de messagerie : Thunderbird

- Tester l’envoi et la réception de courriels entre des utilisateurs appartenant à **des organisations différentes**, pour valider la communication inter-pôles via le service de messagerie.

###  Résultat attendu

- Les utilisateurs peuvent **envoyer et recevoir des mails entre équipes et entre organisations**, confirmant le bon fonctionnement du système de messagerie.

---

 [Retour au sommaire des services](./4-0-serviceadministratif.md)
