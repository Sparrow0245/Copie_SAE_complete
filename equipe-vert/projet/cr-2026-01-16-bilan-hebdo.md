# Compte Rendu d'Activité - Semaine 52

**Équipe :** Équipe Verte  
**Membres :** LEBAS, TRAN, BOUMEDRAR

---

## Contexte

Cette semaine a été principalement consacrée à la mise en place et à la configuration des services d’annuaire et d’authentification centralisée, ainsi qu’à l’intégration de solutions de partage de fichiers pour les utilisateurs du réseau.

## Activités réalisées

### 1. Mise en place et configuration de LDAP

Nous avons créé les utilisateurs Linux dans la base LDAP, défini l’arborescence de l’annuaire et configuré les droits ACL afin de sécuriser les attributs sensibles. Une automatisation partielle des services LDAP a également été réalisée à l’aide de scripts Bash.

### 2. Mise en place de l’authentification centralisée (PAM / NSS)

Nous avons configuré PAM et NSS pour permettre l’authentification des machines Linux via LDAP. Le TP PAM/NSS a été finalisé et documenté.

### 3. Mise en place du service NFS et de l’automontage

Un serveur NFS a été installé et configuré, avec définition des machines autorisées à monter les répertoires. Le service autofs a été mis en place afin d’automatiser les montages NFS selon les utilisateurs et leurs sessions. Des corrections ont ensuite été apportées pour résoudre les problèmes rencontrés (notamment la gestion des répertoires personnels).

### 4. Automatisation et ajustements

Nous avons ajusté la configuration réseau entre les clients et le serveur NFS et automatisé les scripts nécessaires au bon fonctionnement des services côté clients et serveur .
