# Déploiement du serveur mail

Documentation du serveur mail présent dans la DMZ.
L'objectif est d'avoir un serveur mail accessible par les autres organisations pour envoyer et recevoir des mails entre équipe et également de pouvoir s'envoyer des mails d'un utilisateur à un autre de la même organisation.

## Choix du serveur mail

Nous avons choisi le serveur mail Postfix car c'est le plus simple à configurer et le plus utilisé avec l'implémentation Dovecot.

## Installation

 Pour la création de la VM qui servira de serveur mail, on installe les paquets suivants grâce à la commande suivante : 

 ```bash
 apt-get install -y postfix dovecot-imapd dovecot-pop3d
 ```

## Configuration

Pour la configuration, il y a 4 fichiers à modifier afin d'obtenir un serveur mail fonctionnel.

Tout d'abord, il y a `10-mail.conf` qui va permettre d'avoir le répertoire **Maildir** où il y aura les mails qui arriveront.

```bash
mail_location = maildir:~/Maildir

namespace inbox {
  inbox = yes
}

mail_privileged_group = mail
```
Ensuite, il faut modifier le fichier `mailname` afin de mettre notre préfixe de mail ( **comme par exemple gmail.com*** ). 
```bash
noir.iut
```

Le fichier `10-auth.conf` va servir à l'authentification des utilisateurs et comment ils se connectent.

```bash
disable_plaintext_auth = no

auth_mechanisms = plain login

!include auth-system.conf.ext
```

Le fichier le plus important à modifier est `main.cf` car il concerne tous les paramètres globaux du service comme le hostname et les réseaux autorisés.

```bash
smtpd_banner = $myhostname ESMTP $mail_name (Debian/GNU)
biff = no
append_dot_mydomain = no
readme_directory = no
compatibility_level = 3.6

myhostname = mail.noir.iut
myorigin = /etc/mailname
mydestination = $myhostname, noir.iut, localhost.noir.iut, localhost

relayhost = 
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 192.168.4.0/26 192.168.4.64/26 192.168.4.128/26
inet_interfaces = all
inet_protocols = all

home_mailbox = Maildir/

smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
recipient_delimiter = +
```

## Tests

Il y a 2 tests importants qui montreront tout de suite si le service est fonctionnel ou non.
Premièrement, nous allons essayer d'envoyer un mail à un autre utilisateur de l'organisation puis on testera si on peut envoyer un mail à un utilisateur d'une autre organisation.

### Premier test :
On se connecte au serveur mail créé précédemment puis on change d'utilisateur avec l'un des utilisateurs ajoutés (*par exemple : user1*) et on se connecte via la commande suivante.

```bash
su user1
```
S'il y a un problème d'authentification, il faut vérifier si un mot de passe est attribué à l'utilisateur et/ou le changer.

```bash
sudo passwd user1
```
Ensuite, aller directement dans le dossier où les nouveaux mails apparaitront pour vérifier si le mail partira ou non.

```bash
cd /home/user1/Maildir/new
```
Bien sûr, avant d'envoyer le mail, refaire la procédure de connexion avec un autre utilisateur de l'organisation pour vérifier le mail une fois arrivé puis vérifier si le paquet pour envoyer un mail est présent, sinon il faut l'installer.

```bash
apt-get install mailutils
```

Il ne reste plus qu'à envoyer le mail et pour l'instant il sera en ligne de commande.

```bash
echo "Test réussi" | mail -s "Test de mail" user2@noir.iut
```
Sur user1, faire un `ls`dans le dossier new, si un fichier est apparu, l'envoi a échoué mais l'erreur est écrite à l'intérieur.
Si rien n'est présent, aller sur user2 et faire un `ls` dans ce même dossier. 
Si un fichier est apparu et en le lisant on retrouve le mail envoyé, cela a fonctionné.

### Deuxième test :
Maintenant, on va testé de l'envoyer à une autre équipe donc il faut être au minimum 2 pour effectuer ce test.
Refaire la procédure précédente mais nous allons juste modifier la commande pour mettre le mail d'une autre équipe (*par exemple : test@vert.iut*).

```bash
echo "Test réussi" | mail -s "Test de mail" test@vert.iut
```
Si un fichier est apparu il peut y avoir un problème de DNS ou de configuration selon l'erreur indiquée.
