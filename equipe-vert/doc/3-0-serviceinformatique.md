# Introduction

Le pôle informatique de l'organisation joue un rôle essentiel dans la mise en place, la gestion et la sécurisation des services réseau de l'entreprise.

Dans le cadre de ce projet, plusieurs services ont été déployés au sein du réseau privé du service informatique, notamment un serveur DHCP, un annuaire LDAP, un service de fichiers NFS, ainsi qu’un proxy web chargé de sécuriser l'accès à Internet depuis le réseau de production. Ces services permettent de centraliser la gestion des utilisateurs, d’automatiser l’attribution des adresses IP, de mutualiser le stockage de données, et de contrôler les accès au réseau.

Ce document détaille l’architecture réseau déployée, la configuration des différents services, les choix techniques effectués, ainsi que les étapes de validation mises en œuvre.

# Résumé de l'infrastructure du pôle informatique

Le pôle informatique de l'organisation *`Vert`* s'appuie sur plusieurs machines virtuelles, chacune dédiée à un service ou à un rôle spécifique.

 Le tableau suivant résume l'infrastructure mise en place :

| Nom de la VM             | Rôle / Service                   | Adresse IP       | Remarques                                                    |
|--------------------------|----------------------------------|------------------|--------------------------------------------------------------|
| *`dhcp-vert`*            | Serveur DHCP                     | 192.168.3.2      | Attribution automatique des adresses IP                     |
| *`ldap-vert`*            | Serveur LDAP                     | 192.168.3.3      | Annuaire centralisé des utilisateurs                        |
| *`nfs-vert`*             | Serveur NFS                      | 192.168.3.5      | Partage des répertoires utilisateurs                        |
| *`poste1-Info`*          | Client PAM / NSS / NFS + Bureau graphique | 192.168.3.7      | XFCE, Firefox, Thunderbird, authentification LDAP, Autofs    |

---

#  Documentation détaillée des services dans le pôle informatique 
1. [Serveur DHCP](./3-1-serveurdhcp.md)
2. [Serveur LDAP](./3-2-serveurldap.md)
3. [Serveur NFS](./3-3-serveurnfs.md)
4. [Serveur Proxy (Squid)](./3-4-serveurproxysquid.md)
5. [Poste de travail (PAM, NSS, Autofs, Thunderbird, Firefox)](./3-5-postetravailinfo.md)








