# Introduction

La zone démilitarisée (DMZ) constitue la partie exposée de l’infrastructure réseau de l’organisation *Vert*. Elle héberge les services publics devant être accessibles depuis les autres organisations du réseau IUT, tout en assurant une isolation stricte vis-à-vis des réseaux internes privés (informatique, administratif, production).

La DMZ joue un rôle essentiel dans la sécurité de l’infrastructure globale. Elle permet de **limiter les risques** en cloisonnant les services exposés (DNS, Mail, Web), afin qu’une éventuelle compromission de l’un d’eux **n’affecte pas les données internes** ou les utilisateurs.

Ce document décrit l'architecture de la DMZ, les services hébergés, ainsi que les configurations techniques associées.

---

# Résumé de l'infrastructure de la DMZ
>  Les services DNS, Mail et Web ont été regroupés sur une seule machine pour simplifier la gestion et économiser les ressources, tout en respectant les contraintes du sujet.


La DMZ de l'organisation *Vert* s’appuie sur **une machine virtuelle unique** hébergeant tous les services publics accessibles depuis les autres organisations.


| Nom de la VM     | Rôle / Service     | Adresse IP       | Remarques                                       |
|------------------|--------------------|------------------|-------------------------------------------------|
| `dns-vert`       | Serveur DNS        | 192.168.3.194      | DNS autorité pour le domaine `vert.iut`        |
| `mail-vert`      | Serveur Mail `postfix` et `dovecot`       | 192.168.3.194      | Serveur SMTP/IMAP pour `@vert.iut`             |
| `web-vert`       | Serveur Web deployé avec Nginx       | 192.168.3.194      | Site web de l'organisation `vert.iut`          |

Toutes les machines de la DMZ sont configurées avec une **interface réseau publique**, connectée via bridge à l’interface physique `enp3s0`, reliée à la baie réseau.  
Elles sont protégées par les équipements de routage et firewall du réseau.

---

# Documentation détaillée des services de la DMZ

1. [Serveur DNS (bind9)](./2-1-serveurdns.md)
2. [Serveur de messagerie (Postfix + Dovecot)](./2-2-serveurmail.md)
3. [Serveur Web (Nginx)](./2-3-serveurweb.md)

---

