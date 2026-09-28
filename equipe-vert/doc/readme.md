#  Documentation Technique – SAÉ 5B.01

Bienvenue dans la documentation technique du projet d’infrastructure réseau réalisé dans le cadre de la SAÉ 5B.01.

Ce projet vise à simuler une organisation répartie en plusieurs pôles avec des services réseau réalistes et interconnectés, selon un cahier des charges fourni.

---

##  Structure de la documentation

La documentation est organisée par grandes parties du réseau et suit une logique fonctionnelle. Vous pouvez cliquer directement sur chaque lien pour accéder à la partie correspondante.

| Étape | Lien vers le fichier | Description |
|-------|----------------------|-------------|
| 1️ | [0-0-presentationglobal.md](./0-0-presentationglobal.md) | Présentation générale du projet |
| 2️ | [1-0-architecturereseau.md](./1-0-architecturereseau.md) | Architecture réseau (VLANs, IP, routage) |
| 3️ | [2-0-dmz.md](./2-0-dmz.md) | Services publics exposés en DMZ |
|     | [2-1-serveurdns.md](./2-1-serveurdns.md) | Configuration du serveur DNS (BIND9) |
|     | [2-2-serveurmail.md](./2-2-serveurmail.md) | Configuration du serveur Mail (Postfix + Dovecot) |
|     | [2-3-serveurweb.md](./2-3-serveurweb.md) | Configuration du serveur Web (Nginx) |
| 4️ | [3-0-serviceinformatique.md](./3-0-serviceinformatique.md) | Services du pôle informatique |
|     | [3-1-serveurdhcp.md](./3-1-serveurdhcp.md) | Serveur DHCP pour les réseaux privés |
|     | [3-2-serveurldap.md](./3-2-serveurldap.md) | Serveur LDAP (authentification centralisée) |
|     | [3-3-serveurnfs.md](./3-3-serveurnfs.md) | Partage NFS pour les utilisateurs |
|     | [3-4-serveurproxysquid.md](./3-4-serveurproxysquid.md) | Proxy Web (Squid) pour le réseau de production |
|     | [3-5-postetravailinfo.md](./3-5-postetravailinfo.md) | Poste client (PAM, LDAP, Autofs, Firefox, Thunderbird) |
| 5️ | [4-0-serviceadministratif.md](./4-0-serviceadministratif.md) | Réseau et machines du pôle administratif |
|     | [4-1-postetravailadmin.md](./4-1-postetravailadmin.md) | Poste(s) de travail administratif |
| 6️ | [5-0-serviceproduction.md](./5-0-serviceproduction.md) | Réseau du service production |
|     | [5-1-postetravailproduction.md](./5-1-postetravailproduction.md) | Poste(s) de travail production |
| 7️ | [6-0-securisation.md](./6-0-securisation.md) | Pare-feu, filtrage, séparation des flux |

---

## Schémas disponibles

- [schema-physique.png](./schema-physique.png) : schéma de câblage et connexions physiques
- [schema-service.png](./schema-service.png) : vue logique des services réseau

---

## Conseils de lecture

Pour une **vue d’ensemble rapide et cohérente**, nous recommandons de commencer par :

- [1-0-architecturereseau.md](./1-0-architecturereseau.md)
- [2-0-dmz.md](./2-0-dmz.md)
- [3-0-serviceinformatique.md](./3-0-serviceinformatique.md)
- [4-0-serviceadministratif.md](./4-0-serviceadministratif.md)
- [5-0-serviceproduction.md](./5-0-serviceproduction.md)
- [6-0-securisation.md](./6-0-securisation.md)

---


##  Projet réalisé par

**Équipe Verte** — IUT de Lille  
Étudiants : `minh-tue.tran.etu`, `mohane.boumedrar.etu`, `kevin.lebas.etu`  

Dans le cadre de la SAÉ 5B.01 – Semestre 5  


---

Merci pour votre lecture et évaluation !   
