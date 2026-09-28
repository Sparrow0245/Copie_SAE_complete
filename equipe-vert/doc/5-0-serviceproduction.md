# Introduction

Le pôle Production représente un réseau privé strictement encadré, dédié aux utilisateurs exécutant des tâches métiers. Conformément aux exigences du sujet SAÉ 5B.01, les machines de ce réseau n’ont pas le droit d’accéder librement à Internet : **tout accès Web doit obligatoirement passer par le proxy Squid hébergé dans le pôle Informatique**.

Ce pôle ne contient aucun service serveur (pas de LDAP, pas de DHCP, pas de NFS). Il se limite aux postes de travail, configurés pour accéder uniquement aux services internes et au Web via le proxy, en respectant l’isolation des flux demandée.

Ce document présente les deux postes de travail du pôle Production ainsi que leur configuration réseau et proxy.

---

# Résumé de l’infrastructure du pôle Production

Le pôle Production de l’organisation *`Vert`* repose sur deux postes de travail graphiques.

| Nom de la VM        | Rôle / Service             | Adresse IP       | Remarques                                      |
|---------------------|----------------------------|------------------|------------------------------------------------|
| `poste1-prod`       | Poste de travail graphique | 192.168.3.140    | XFCE, Firefox, Thunderbird, PAM , NSS                   |
| `poste2-prod`       | Poste de travail graphique | 192.168.3.142    | XFCE, Firefox, Thunderbird , PAM , NSS                  |

Les deux postes sont identiques et destinés aux utilisateurs du service Production.

---

# Documentation détaillée du pôle Production

1. [Poste de travail Production utilisé proxy `squid` (poste1/2-prod)](./5-1-postetravailproduction.md)  
