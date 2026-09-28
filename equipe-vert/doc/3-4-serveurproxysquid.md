
# Squid - Service forward proxy WEB

Le but de ce service est de mettre en place un **forward proxy HTTP/HTTPS** (proxy de sortie) à l’aide de **Squid**, pour permettre aux machines du réseau **Production** d’accéder à Internet **de manière contrôlée**.

Ce proxy est une **exigence du cahier des charges** : les machines du pôle Production ne doivent pas avoir un accès direct à Internet, elles doivent obligatoirement passer par un proxy configuré.

---

## Création et setup serveur `squid-proxy-vert`

Le serveur `squid-proxy-vert` a été créé à l'aide d’un fichier `Vagrantfile`.

Toutes les machines sont connectées en mode bridge à l’interface réseau *`enp3s0`*, car il s'agit de la carte réseau reliée directement à la baie réseau.

 Cette interface permet de communiquer avec les équipements réseau (commutateurs, routeurs) configurés pour assurer l’interconnexion entre les machines virtuelles.


```bash
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  config.vm.define "ldap-vert" do |conf|
    conf.vm.hostname = "ldap-vert"
    conf.vm.network "public_network",
      ip: "192.168.3.6",
      netmask: "255.255.255.192",
      bridge: "enp3s0"
  end
```

démarrer vm `squid-proxy-vert`


```bash

vagrant up squid-proxy-vert
```

Ensuite, nous avons exécuté le script `conf_vm_info`, dont le but est de configurer la **passerelle par défaut** ainsi que les paramètres DNS sur les machines.

Cela permet de garantir l’interconnexion entre les machines des différents VLANs, ainsi que la résolution des noms via le serveur DNS de l’organisation.

```bash
#!/bin/bash

sudo ip r add 192.168.0.0/16 via 192.168.3.62 dev eth1


echo "
domain vert.iut
search vert.iut
nameserver 192.168.3.194
" > /etc/resolv.conf

```
---
## 1. Installation et configuration de Squid

Une fois la connectivité réseau assurée, nous avons installé et configuré **Squid**, l’un des serveurs proxy HTTP/HTTPS les plus utilisés.

### Script d’installation et de configuration

```bash
#!/bin/bash

echo "=== Installation de Squid ==="
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y squid

echo "=== Sauvegarde de la configuration originale ==="
mv /etc/squid/squid.conf /etc/squid/squid.conf.bak

echo "=== Nouvelle configuration Squid ==="
cat <<EOF >/etc/squid/squid.conf
visible_hostname Proxy

# Autoriser uniquement le réseau de production
acl production_net src 192.168.3.128/26
http_access allow production_net

# Port d'écoute du proxy
http_port 3128

# Autoriser les ports HTTP et HTTPS uniquement
acl Safe_ports port 80
acl Safe_ports port 443
http_access allow Safe_ports

# Refuser tout le reste
http_access deny all
EOF

# Redémarrage et activation du service
systemctl restart squid
systemctl enable squid

echo "=== Configuration terminée avec succès ==="
```

### Points clés de la configuration
- **Réseau autorisé** : Seuls les clients du sous-réseau `192.168.3.128/26` peuvent utiliser le proxy.
- **Ports autorisés** : Uniquement les ports `80` (HTTP) et `443` (HTTPS) sont ouverts.
- **Port d’écoute** : Le proxy écoute sur le port `3128`.
- **Sécurité** : Toute autre requête est explicitement refusée (`http_access deny all`).
- `/etc/squid/squid.conf` est le fichier principal de configuration de Squid, où l’on définit toutes les règles du proxy (ports, accès, cache, filtrage, authentification).

---

 [Retour au sommaire des services](./3-0-serviceinformatique.md)
