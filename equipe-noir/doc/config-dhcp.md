# Déploiement du serveur DHCP

Documentation du serveur DHCP présent dans le service informatique.
L'objectif est d'avoir un serveur DHCP qui servira a attribuer une adresse IP au client du service informatique et aux clients du service administratif.

## Installation

 Pour la création de la VM qui servira de serveur DHCP, on installe les paquets suivants grâce à la commande suivante :

 ```bash
 apt-get install -y isc-dhcp-server
 ```
**Si une erreur apparait, c'est normal, il faut d'abord configurer le DHCP avant qu'il soit fonctionnel.**

## Configuration

Pour la configuration du serveur DHCP, il y a 2 fichiers à modifier.
Tout d'abord, il y a le fichier **dhcpd.conf** qui est la configuration de base et **isc-dhcp-server** qui sert à forcer le DHCP sur l'interface voulue.

**dhcpd.conf**

```bash
default-lease-time 7200;
max-lease-time 84400;
authoritative;

subnet 192.168.4.64 netmask 255.255.255.192 {
    range 192.168.4.100 192.168.4.120;
    option routers 192.168.4.126;
    option domain-name-servers 192.168.4.20;
    option domain-name "noir.iut";
}

subnet 192.168.4.128 netmask 255.255.255.192 {
    range 192.168.4.130 192.168.4.150;
    option routers 192.168.4.190;
    option domain-name-servers 192.168.4.20;
    option domain-name "noir.iut";
}
```
Ici, la durée maximale du bail est de 24h et le DHCP est appliqué dans le service informatique (192.168.4.64) pour le client et les IPs données seront entre 192.168.4.100 et 192.168.4.120 en plus de donner l'adresse IP du résolveur (192.168.4.20) et le domaine noir.iut.
De même pour le service administratif (192.168.4.128) pour les 2 clients avec des IPs distribuées entre 192.168.4.130 et 192.164.4.150.

**isc-dhcp-server**

```bash
INTERFACESv4="eth1"
```
Ici, cela sert à indiquer au DHCP d'utiliser uniquement cette interface réseau, donc ici **eth1**.

Ensuite, il faut configurer le firewall pour qu'il serve de relais DHCP pour pouvoir offrir des IPs au service administratif (***voir documentation config-firewall.md***).
## Tests

Pour tester le DHCP, il suffit de démarrer une machine vituelle sans IP statique et de bien définir le bridge de l'interface *enp3s0* puis utiliser la commande suivante :

```bash
sudo dhclient -v
```
Puis normalement une adresse IP a été donné et pour annuler (kill) un bail déjà actif, il faut faire :

```bash
sudo dhclient -r
```