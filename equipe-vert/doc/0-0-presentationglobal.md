# 1.Contexte du Projet 

---

L’objectif de cette SAÉ est de mobiliser et mettre en œuvre l’ensemble des compétences acquises au cours des quatre premiers semestres du BUT à travers un projet proche d’un **cas réel d’infrastructure d’entreprise** 
## 1.2.Résumé du projet 

Le projet consiste à concevoir, déployer et documenter une infrastructure réseau complète pour **quatre organisations distinctes**, interconnectées entre elles.

Parmi ces organisations, l’une joue le rôle de **Fournisseur d’Accès à Internet (FAI)**. Cette organisation est chargée d’assurer l’interconnexion des trois autres organisations, notamment par la mise en place du routage, d’un service DNS récursif, ainsi que par la gestion de l’autorité du domaine de premier niveau `iut`.

Chaque organisation dispose de son propre nom de domaine et d’une infrastructure répondant à des contraintes communes et spécifiques définies dans l’énoncé de la SAÉ.

L'infrastructure dont dispose chaque organisation se découpe en plusieurs éléments :

- Quatre ordinateurs physiques du nom de douglas05, douglas06, douglas07, douglas08.
- Une baie de brassage avec 2 routeurs et 4 switch.
- Un firewall Stormshield.
- Une batterie de câble RJ45.

Dans cette documentation, on partira du principe que toutes les autres équipes sont en place pour les tests et notamment l'équipe FAI.
## 1.3.Composition des équipe

Le projet est réalisé par quatre équipes, chacune responsable d’une organisation distincte :
### Équipe Rouge

- Membres
    - `matisse.dekeiser.etu`
    - `nicolas.eckman.etu`
    - `wassim.koudamra.etu`
- DNS : `rouge.iut`

### Équipe Noir (FAI)

- Membres
    - `maxence.antoine.etu`
    - `sofiane.el-bouhali.etu`
    - `vincent.jacquemelle.etu`
- DNS : `noir.iut`

### Équipe Blanc 

- Membres
    - `mickhail.kochiev.etu`
    - `revaz.khudoev.etu`
    - `abderrahim.boughezal.etu`
- DNS : `blanc.iut`

### Équipe Vert (Notre équipe)

- Membres
    - `minh-tue.tran.etu`
    - `mohane.boumedrar.etu`
    - `kevin.lebas.etu`
- DNS : `vert.iut`

# 2.Objectif de l'organisation

---

L’objectif de l’organisation est de mettre en place une infrastructure réseau complète, structurée et sécurisée, conforme aux contraintes données.
Elle doit permettre l’hébergement de services accessibles depuis l’extérieur, tout en assurant une séparation stricte du réseau interne, divisé en trois parties distinctes, ainsi qu’un contrôle des flux réseau.

L’infrastructure de l’organisation doit s’articuler autour des éléments suivants
## 2.1 Mise en place d’une zone démilitarisée (DMZ)

L’organisation doit disposer d’une **zone démilitarisée (DMZ)** dédiée à l’hébergement des services accessibles depuis les autres organisations.

Cette DMZ doit accueillir a minima :

- Un **serveur DNS autoritaire** pour le domaine `vert.iut`,

- Un **serveur de mail** permettant les échanges inter organisations,

- Un **serveur web** accessible depuis l’extérieur.
 
## 2.2 Séparation du réseau privé

L’organisation doit **diviser son réseau privé en trois parties distinctes**, chacune correspondant à un service spécifique :

- Un **service informatique**, destiné à l’hébergement des services internes et des postes d’administration informatique,

- Un **service administratif**, réservé aux postes de travail des utilisateurs administratifs,

- Un **service de production**, destiné aux postes de production, avec des restrictions d’accès spécifiques.


Cette séparation vise à améliorer la sécurité, la lisibilité de l’architecture et la maîtrise des flux réseau.
## 2.3 Services hébergés sur le réseau du service informatique

Le réseau du service informatique doit héberger les services centraux de l’organisation, notamment :

- Un **service DHCP** assurant la configuration automatique des machines du réseau privé,

- Un **service d’annuaire LDAP** permettant la gestion centralisée des utilisateurs et des groupes,

- Un **service de stockage NFS** destiné au stockage des données utilisateurs,

- Un **serveur proxy web**, utilisé comme point de sortie vers Internet pour le réseau de production.

Ces services doivent être accessibles **uniquement aux machines de l’organisation verte**.

## 2.4 Accès à Internet et contrôle des flux

Les services informatiques et administratifs doivent disposer d’un accès **aux services hébergés dans les DMZ** des autres organisations.

Le service de production, en revanche, ne doit pouvoir accéder aux autres organisations qu’**exclusivement via le proxy web** de l’organisation, et uniquement pour les flux web.

L’ensemble des communications entre les trois services, la DMZ et les autres organisations doivent être contrôlé par un **pare-feu**, garantissant la séparation des flux et la sécurité de l’infrastructure.

---

La section suivante détaille l’architecture réseau.
[Accéder à l’architecture réseau](./1-0-architecturereseau.md)
