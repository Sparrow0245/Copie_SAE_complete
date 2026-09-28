# Introduction

Le pôle administratif regroupe les postes de travail destinés aux utilisateurs chargés des tâches de gestion et de suivi administratif de l’organisation. Contrairement au pôle informatique, ce réseau ne contient aucun service centralisé (pas de DHCP, pas de LDAP, pas de NFS). Il héberge uniquement les postes utilisateurs, lesquels doivent néanmoins être configurés pour fonctionner correctement dans l’infrastructure globale.

Conformément au sujet de la SAÉ 5B.01, le pôle administratif doit disposer :
- d’au moins **deux postes de travail** opérationnels ;
- d’un accès réseau cohérent avec les politiques de sécurité ;
- d’outils utilisateurs fonctionnels : **navigateur Web** et **client e‑mail** ;
- de la possibilité d'utiliser les services fournis par le pôle informatique (DNS, e‑mail, Web).

Ce document présente l’infrastructure du pôle administratif ainsi que la configuration des deux postes de travail déployés.

---

# Résumé de l’infrastructure du pôle administratif

Le pôle administratif de l’organisation *`Vert`* repose sur deux machines virtuelles représentant les postes utilisateurs.

| Nom de la VM      | Rôle / Service                | Adresse IP       | Remarques                          |
|-------------------|-------------------------------|------------------|------------------------------------|
| `poste1-admin`    | Poste de travail graphique    | 192.168.3.71     | XFCE, Firefox, Thunderbird , PAM , NSS      |
| `poste2-admin`    | Second poste administratif    | 192.168.3.72     | XFCE, Firefox, Thunderbird , PAM , NSS        |



---

# Documentation détaillée du pôle administratif

1. [Poste de travail Administratif (poste1/2-admin)](./4-1-postetravailadmin.md)  

