## Semaine 40

### Lundi 2025/09/29

- Prise en main du sujet et compréhension globale des attentes du projet.
- Révision des bases via les TP de routage pour remise à niveau.
- Élaboration d’un premier **proto-schéma réseau** servant de base au projet.

### Mardi 2025/09/30

- Finalisation du schéma réseau à partir de l’architecture fournie par l’équipe FAI (équipe noire).
- Répartition des rôles et des tâches au sein du groupe.
- Début de la configuration du **routeur privé vers la DMZ**.
- Discussion et choix des technologies à utiliser :  
  - **OS retenu : Debian 12**  
  - **Hyperviseur : OpenTofu**

### Mercerdi 2025/10/01

- Révision des bases à travers le TP sur les VLAN.
- Exploration et documentation autour de l’hyperviseur OpenTofu.


### Jeudi 2025/10/02

- Configuration de routeur 

### Vendredi 2025/10/02

- Rechere et apprendre pour utiliser opentofu 

## Semaine 42

### Lundi 2025/10/13

- Pratiquer opentofu et rechere des providers adapté pour le sae


### Mardi 2025/10/14

- Entraînement avec le provider OpenStack pour récupérer les données sur le cloud de l’Université de Lille et création de compute

### Mercerdi 2025/10/15

- Préparation des CV et lettres de motivation pour le Job Meeting

### Jeudi 2025/10/16
- Participation au Job Meeting
- Lecture de documents pour mieux comprendre les outils Cloud-init

### Vendredi 2025/10/17
- Pratiquer des options comme for_each , variable sur opentofu et Cloud init , clé SSH , Vagrantfile
- Reviser les cours théoriques Virtualisation Avancé

## Semaine 46

### Lundi 20255/11/10

- création vagrant file pour les machines infos,admins, productions 

### Mardi 2025/11/11

- ferié

### Mercerdi 2025/11/12

- Réflexionsur l’utilisation de sous-réseaux au lieu des VLAN

### Jeudi 2025/11/13

- Aide à la configuration des sous-réseaux et du firewall

### Vendredi 2025/11/14

- Réflexion sur la mise en place d’une DMZ


## Semaine 48

### Lundi 2025/11/24

- Aide à la configuration et à la création des VLAN sur le switch

### Mardi 2025/11/25

- Création d’un DNS faisant autorité et d’un DNS résolveur

### Mercerdi 2025/11/26
- Création d’un serveur web et réflexion sur la mise en place d’un serveur mail

### Jeudi 2025/11/27
- Tentative de mise en place d’un serveur mail avec Postfix, mais fonctionnement incorrect

### Vrendredi 2025/11/28

- Révision pour le CTP

## Semaine 50

### Lundi 2025/12/08
- Mise en place DHCP pour les machines informatiques mais non fonctionnel pour les autres machines

### Mardi 2025/12/09

- Configuration du routeur et des VLAN pour que le DHCP fonctionne correctement sur les autres machines du réseau interne

### Mercredi 2025/12/10

- Lecture du cours sur la mise en place de LDAP

### Jeudi 2025/12/11

- Création de la base de données pour l’utilisation de LDAP

### Vendredi  2025/12/12

- Révision pour le CTP


## Semaine 51

### Lundi 2026/01/12
- Création des utilisateurs Linux dans la base LDAP.
- Configuration des droits ACL pour sécuriser les attributs sensibles dans LDAP.
- Mise en place de l’arborescence LDAP pour l’organisation.

### Mardi 2026/01/13
- Automatisation des services LDAP via un script Bash.
- Finalisation du TP PAM/NSS et rédaction de la documentation.

### Mercredi 2026/01/14
- Mise en place de PAM et NSS pour permettre l’authentification Linux via LDAP.
- Recherche d’une méthode d’automontage NFS adaptée pour les clients utilisant PAM/NSS (montage automatique selon l’utilisateur et sa session).

### Jeudi 2026/01/15
- Mise en place du serveur NFS et définition des machines autorisées à monter les répertoires.
- Installation et configuration du service autofs pour automatiser les montages NFS dans le pôle informatique.

### Vendredi 2026/01/16
- Correction des problèmes autofs (notamment l’absence de répertoire home) et ajustement de la configuration réseau entre les clients NFS et le serveur.
- Automatisation des scripts pour les clients et le serveur NFS.


## Semaine 52

### Lundi 2026/01/26
- Assistance à Mohane pour la configuration du proxy et des paramètres réseau des machines de production.
- Tests des outils : gestion du mail, DHCP, NFS.

### Mardi 2026/01/27
- Identification des erreurs de configuration du serveur mail.
- Reconfiguration de Postfix et Dovecot pour corriger les problèmes d’envoi et de réception entre organisations.

### Mercredi 2026/01/28
- Nouveaux tests fonctionnels du serveur mail.
- Séparation des services du pôle informatique sur plusieurs machines pour faciliter la supervision.
- Installation de postes graphiques pour utiliser Thunderbird et un navigateur web.

### Jeudi 2026/01/29
- Automatisation des scripts pour tous les services du pôle Informatique et de la DMZ.
- Suppression et recréation des machines, puis tests complets après déploiement automatisé.
- Configuration du pare-feu pour filtrer les connexions non autorisées.

### Vendredi 2026/01/30
- Tests des services après application des règles du pare-feu.
- Définition des règles nécessaires pour autoriser les serveurs mail à communiquer avec les autres organisations.
- Derniers tests et vérifications finales des services et des contraintes du SAÉ.
