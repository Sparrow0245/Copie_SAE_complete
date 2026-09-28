# Serveur Mail – *Postfix & Dovecot*

Le service de messagerie permet aux utilisateurs de l’organisation **Vert** d’envoyer et recevoir des e‑mails via le domaine `@vert.iut`.

Deux composants principaux sont utilisés :

- **Postfix** : serveur SMTP, responsable de l’envoi et de la réception des messages.
- **Dovecot** : serveur IMAP/POP3, permettant aux utilisateurs de consulter leur boîte mail via un client (Thunderbird, `mail`, etc.)

---

## Création et setup du serveur `mail-vert`

Le service mail est déployé sur la même machine `dmz-vert` que le serveur DNS et le serveur Web.  
Il n’est donc **pas nécessaire de redéfinir la machine virtuelle**.

L'installation a été automatisée via un script `setup_mail.sh` déployé sur la VM.

---

## 1. Installation et configuration automatique

Le script `setup_mail.sh` installe les paquets nécessaires, configure les services, initialise les comptes locaux, et applique les fichiers de configuration.

### Contenu du script :

```bash
#!/bin/bash

apt update -y

# Configuration non interactive de Postfix
echo "postfix postfix/mailname string vert.iut" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
apt install -y postfix mailutils

# Installation de Dovecot
apt install -y dovecot-imapd dovecot-pop3d

# Création des utilisateurs locaux si non existants
id -u kevin &>/dev/null || adduser --disabled-password --gecos "" kevin
id -u minhtue &>/dev/null || adduser --disabled-password --gecos "" minhtue
id -u mohane &>/dev/null || adduser --disabled-password --gecos "" mohane

# Création des dossiers Maildir pour chaque utilisateur

sudo -u kevin maildirmake.dovecot /home/kevin/Maildir
sudo -u minhtue maildirmake.dovecot /home/minhtue/Maildir
sudo -u mohane maildirmake.dovecot /home/mohane/Maildir

# Application du fichier de configuration
cat backup_10-mail_conf.txt > /etc/dovecot/conf.d/10-mail.conf
cat save_main_cfg.txt > /etc/postfix/main.cf

# Redémarrage des services
systemctl restart postfix dovecot
systemctl enable postfix dovecot
```

---

## 2. Fichier de configuration Postfix : `main.cf`

Le fichier principal de Postfix `/etc/postfix/main.cf` contient :

```conf# See /usr/share/postfix/main.cf.dist for a commented, more complete version


# Debian specific:  Specifying a file name will cause the first
# line of that file to be used as the name.  The Debian default
# is /etc/mailname.
#myorigin = /etc/mailname

smtpd_banner = $myhostname ESMTP $mail_name (Debian/GNU)
biff = no

# appending .domain is the MUA's job.
append_dot_mydomain = no

# Uncomment the next line to generate "delayed mail" warnings
#delay_warning_time = 4h

readme_directory = no

# See http://www.postfix.org/COMPATIBILITY_README.html -- default to 3.6 on
# fresh installs.
compatibility_level = 3.6



# TLS parameters
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_tls_security_level=may

smtp_tls_CApath=/etc/ssl/certs
smtp_tls_security_level=may
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache


smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
myhostname = mail.vert.iut
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = /etc/mailname
mydestination = vert.iut, $myhostname, DMZ-vert, localhost.localdomain, localhost
relayhost =
mynetworks = 127.0.0.0/8, 192.168.3.0/24
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
inet_protocols = ipv4
home_mailbox = Maildir/

```


### Points clé de la configuration `Postfix`

- **`myhostname`** : définit le nom du serveur mail, utilisé dans les en-têtes SMTP et l’identification du serveur.
- **`mydestination`** : liste les domaines que Postfix considère comme *locaux* - cela permet aux utilisateurs d’avoir des adresses en `@vert.iut`.
- **`home_mailbox = Maildir/`** : indique que chaque message doit être délivré dans le dossier `~/Maildir` du compte utilisateur, en utilisant le format Maildir.
- **`mynetworks`** : définit quels réseaux sont autorisés à utiliser ce serveur pour envoyer des mails - cela garantit que seuls les hôtes du réseau Vert peuvent relayer du courrier via Postfix.

- **`inet_protocols = ipv4`** : force Postfix à utiliser uniquement IPv4. Cela évite les erreurs de type *“Host or domain not found. Name does not resolve (AAAA record)”* lorsque certains serveurs distants ne sont pas accessibles en IPv6.

- **`smtpd_relay_restrictions`** : définit les règles de relais SMTP. Elle contrôle **qui est autorisé à envoyer des mails vers l’extérieur** via le serveur. Typiquement, seuls les clients authentifiés ou situés dans `mynetworks` peuvent relayer du courrier, empêchant ainsi l'utilisation abusive (anti-spam).


- TLS en mode "may" (non strict)

---

## 3. Fichier de configuration Dovecot : `10-mail.conf`

Le fichier `/etc/dovecot/conf.d/10-mail.conf` 

```conf
mail_location = maildir:~/Maildir

inbox = yes

```

Cela indique à Dovecot où lire les courriels des utilisateurs.

Ce format Maildir est recommandé car :

- il est compatible avec Postfix,
- il permet une meilleure performance que mbox,
- il organise les mails sous forme de fichiers séparés.

---

## 4. Utilisateurs et boîtes mail

Le script `setup_mail.sh` vérifie et crée les utilisateurs Linux suivants :

- `kevin`
- `minhtue`
- `mohane`

Il initialise également leur répertoire de réception `~/Maildir` via :

```bash
sudo -u <utilisateur> maildirmake.dovecot /home/<utilisateur>/Maildir
```

Ces comptes sont ensuite utilisables pour tester l’envoi et la réception de mails en local (Postfix à Dovecot), ou via un client comme Thunderbird.

---

### 4.1 Modification du mot de passe d’un utilisateur local

Pour changer le mot de passe d’un utilisateur (par exemple `minhtue`), on utilise la commande suivante :

```bash
sudo passwd minhtue
```

Cela permet de définir un mot de passe pour un utilisateur local afin qu’il puisse se connecter depuis un client mail comme Thunderbird.



## 5. Tests et validation

### 5.1 Vérifier les services

```bash
systemctl status postfix
systemctl status dovecot
```


### 5.2 Tester depuis Thunderbird

Configurer un client comme Thunderbird :

- **Serveur IMAP** : `mail.vert.iut`
- **Serveur SMTP** : `mail.vert.iut`
- Ports standards, **sans chiffrement**
- Authentification simple avec les comptes locaux (`kevin`, `minhtue`, etc.)

---

## Résultat attendu

- Le mail est envoyé sans erreur avec Postfix.
- L’utilisateur reçoit le message via IMAP grâce à Dovecot.
- Thunderbird fonctionne en lecture/écriture.
- Le nom de domaine `mail.vert.iut` est résolu grâce au DNS DMZ (`192.168.3.194`).

---

[Retour à la DMZ](./2-0-dmz.md)
