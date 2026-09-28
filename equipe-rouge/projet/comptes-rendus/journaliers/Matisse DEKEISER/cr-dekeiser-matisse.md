# Comptes-rendus équipe ROUGE (Matisse DEKEISER)

<hr>

## SEMAINE 40 

### Lundi 29/09
- Découverte du sujet de SAÉ

### Mardi 30/09
- Réalisation du schéma réseau de l'infrastructure

### Mercredi 01/10
- Réalisation du schéma réseau de l'infrastructure
- Réflexion sur les services réseau à utiliser

### Jeudi 02/10
- Début du câblage réseau
- Lecture de la documentation du firewall Stormshield SN310

### Vendredi 03/10
- N/A

<hr>

## SEMAINE 42

### Lundi 13/10

- Modifications apportées au branchement sur la baie
- Lecture de la documentation du firewall Stormshield SN310

### Mardi 14/10

- Baies non accessibles (utilisées par les BUT2)
- Travail sur le TP de R5.B.06 (Installation de services complexes) sur le DHCP

### Mercredi 15/10

- Baies non accessibles (utilisées par les BUT2)

### Jeudi 16/10

- Baies non accessibles (utilisées par les BUT2)

### Vendredi 17/10

- Baies non accessibles (utilisées par les BUT2)

<hr>

## SEMAINE 46

### Lundi 10/11

- Réflexion sur les services à utiliser sur OpenBSD (dhcpd, OpenLDAP, etc.)

### Mardi 11/11

- N/A (férié)

### Mercredi 12/11

- Lecture de documentation sur la création d'images Vagrant customisées

### Jeudi 13/11

- Création d'une image Vagrant customisée avec OpenBSD 7.8 amd64 pour l'hébergement des services (DHCP, LDAP, etc.)

### Vendredi 14/11

- Tests effectués sur l'image OpenBSD (ssh, hostname, provisionnement, etc.)

<hr>

## SEMAINE 48

### Lundi 24/11

- N/A

### Mardi 25/11

- Modifications apportées à l'image OpenBSD (installation de logiciels utiles par défaut, désactivation des services inutiles, image plus propre, etc.)
- Tests effectués sur l'image OpenBSD (ssh, hostname, provisionnement, etc.)

### Mercredi 26/11

- N/A

### Jeudi 27/11

- Création d'une image Vagrant customisée avec Ubuntu Desktop 24.04.3 LTS amd64 pour les stations de travail (serveur graphique, Firefox, Thunderbird)

### Vendredi 28/11

- Lecture de documentation de configuration des services sur OpenBSD (DHCP, NFS, etc.)

## SEMAINE 50

### Lundi 08/12

- Écriture initiale des provisions des services (DNS, web http-only)

### Mardi 09/12

- Écriture initiale des provisions des services (mail)

### Mercredi 10/12

- Écriture initiale des provisions des services (DHCP)

### Jeudi 11/12

- Tests des services et fixes

### Vendredi 12/12

- Changement de plan: les daemons OpenBSD ont quelques problèmes, notamment nsd qui s'éteint tout seul si l'on check son status avec rcctl, les machines de services seront plutôt sur l'image "debian/bookworm64" pour garantir une stabilité et un lien avec le cours.

## SEMAINE 03

### Lundi 12/01

- Réécriture des services déjà existants vers Debian pendant les vacances et la dernière semaine
- Écriture initiale des provisions des services (LDAP, NFS, mail)

### Mardi 13/01

- Suite de l'écriture des provisions des services et tests en local sur ma machine personnelle
- Écriture initiale des provisions des stations de travail: auth PAM avec LDAP et NFS (pour le moment seulement sur le subnet IT)
- Tests plus en détails prévus pour le reste de la semaine sur les machines de l'IUT

### Mercredi 14/01

- N/A

### Jeudi 15/01

- N/A

### Vendredi 16/01

- N/A

## SEMAINE 05

### Lundi 26/01

- Suite de l'écriture des provisions des services et tests en local sur ma machine personnelle
- Problème avec l'image custom de Ubuntu: soit le site l'a cut ou corrompue, du coup, on switch sur l'image standard Debian

### Mardi 27/01

- Réécriture des provisions des stations de travail vers Debian 12

### Mercredi 28/01

- N/A

### Jeudi 29/01

- Modifications apportées à l'infra réseau: /26 -> /27 pour la DMZ et les 3 sous-réseaux privés
- Modifications apportées aux services en conséquence (DHCP, DNS, etc.)

### Vendredi 30/01

- N/A

## SEMAINE 06 (hors semaines de SAÉ)

### Vendredi 06/02

- Tests à l'IUT: problèmes rencontrés avec le firewall (impossible de communiquer au-delà de celui-ci), devrait être réglé la semaine prochaine
- Demande de modification à l'équipe noir de leurs services DNS pour accomoder le changement d'IP du serveur d'autorité de la DMZ

## SEMAINE 07 (FIN)

### Lundi 09/02

- Tests avec les autres organisations et modifications apportées aux configurations

### Mardi 10/02 

- Tests avec les autres organisations et modifications apportées aux configurations

### Mercredi 11/02

- Soutenance
- Tests avec les autres organisations et modifications apportées aux configurations