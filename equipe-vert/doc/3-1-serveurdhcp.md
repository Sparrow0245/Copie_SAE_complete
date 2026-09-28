


# DHCP - *Dynamic Host Configuration Protocol* 

Le service DHCP  permet d'attribuer automatiquement des adresses IP aux machines situées sur les différents réseaux privés de l’organisation.

 Cela simplifie la gestion des configurations réseau et garantit une cohérence dans l’attribution des paramètres IP.

---

## Création et setup serveur `dhcp`

Le serveur `DHCP` a été créé à l'aide d’un fichier `Vagrantfile`.

Toutes les machines sont connectées en mode bridge à l’interface réseau *`enp3s0`*, car il s'agit de la carte réseau reliée directement à la baie réseau.

 Cette interface permet de communiquer avec les équipements réseau (commutateurs, routeurs) configurés pour assurer l’interconnexion entre les machines virtuelles.


```bash
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  config.vm.define "dhcp-vert" do |conf|
    conf.vm.hostname = "dhcp-vert"
    conf.vm.network "public_network",
      ip: "192.168.3.2",
      netmask: "255.255.255.192",
      bridge: "enp3s0"
    #conf.vm.provision "shell", path: "conf_vm_info"
    #conf.vm.provision "shell", path: "setup-dhcp.sh"
  end
```

démarrer vm `dhcp-vert`


```bash

vagrant up dhcp-vert
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

## 1, Installation et configuration



 Un script *`setup-dns.sh`* d’automatisation a été utilisé pour installer le service, configurer l’interface réseau concernée (`eth1`), et définir les plages d’adresses pour chaque sous-réseau.

 ```bash
 #!/bin/bash
set -e

apt update -y
apt install -y isc-dhcp-server

sed -i 's/^INTERFACESv4=.*/INTERFACESv4="eth1"/' /etc/default/isc-dhcp-server

cat > /etc/dhcp/dhcpd.conf <<EOF
subnet 192.168.3.0 netmask 255.255.255.192 {
    range 192.168.3.3 192.168.3.61;
    option routers 192.168.3.62;
    option domain-name-servers 192.168.3.194;
}

subnet 192.168.3.64 netmask 255.255.255.192 {
    range 192.168.3.66 192.168.3.125;
    option routers 192.168.3.126;
    option domain-name-servers 192.168.3.194;
}

subnet 192.168.3.128 netmask 255.255.255.192 {
    range 192.168.3.130 192.168.3.189;
    option routers 192.168.3.190;
    option domain-name-servers 192.168.3.194;
}
EOF

systemctl restart isc-dhcp-server
systemctl status isc-dhcp-server --no-pager
```

## Point clé de la configuration

- `/etc/default/isc-dhcp-server`: Ce fichier définit les interfaces réseau sur lesquelles le serveur DHCP doit écouter.

- `/etc/dhcp/dhcpd.conf`: Ce fichier est le cœur de la configuration DHCP. Il définit les plages d’adresses, les options, les baux, etc.




---
## 2, Configuration `ip-help-address` sur routeur 2 

Dans notre infrastructure, le serveur DHCP est situé dans le VLAN 10 (réseau du pôle informatique), avec l’adresse `192.168.3.2`.

Si un client situé dans le VLAN 20 (réseau administratif) exécute la commande `dhclient`, sa requête DHCP sera envoyée en *broadcast* uniquement dans le VLAN 20. Le serveur DHCP, étant dans un autre réseau, ne verra jamais cette requête.

Pour résoudre ce problème, on configure le routeur avec l’option `ip helper-address` sur l’interface correspondant au VLAN 20. Cela permet au routeur d’intercepter les requêtes DHCP *broadcast* provenant de ce VLAN, et de les renvoyer en *unicast* ( ciblé ) vers le serveur DHCP (`192.168.3.2`).

---

### Configuration du routeur (R2)

```bash
interface Vlan10
 ip address 192.168.3.62 255.255.255.192
 ip helper-address 192.168.3.2
!
interface Vlan20
 ip address 192.168.3.126 255.255.255.192
 ip helper-address 192.168.3.2
!
interface Vlan30
 ip address 192.168.3.190 255.255.255.192
 ip helper-address 192.168.3.2
!

```

## 3. Validation et tests

Afin de valider le bon fonctionnement du serveur DHCP depuis des machines situées dans d'autres pôles (autres VLANs), nous avons réalisé une série de commandes sur une machine virtuelle cliente.

L’objectif est de s’assurer que le serveur DHCP attribue correctement une adresse IP aux machines distantes à travers le routeur configuré avec `ip helper-address`.

### Étapes réalisées sur la machine cliente :

```bash
# 1. Supprimer la route par défaut créée par le NAT de Vagrant
sudo ip route del default

# 2. Libérer l'adresse IP actuelle de l'interface eth1 (si existante)
sudo dhclient -r eth1

# 3. Demander une nouvelle adresse IP depuis le serveur DHCP
sudo dhclient -v eth1


```

Résultat attendu:

```bash

vagrant@nss-pam-admin:/vagrant$ sudo dhclient -v eth1

Listening on LPF/eth1/08:00:27:ee:25:c4
Sending on   LPF/eth1/08:00:27:ee:25:c4
Sending on   Socket/fallback
DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 5
DHCPOFFER of 192.168.3.73 from 192.168.3.126
DHCPREQUEST for 192.168.3.73 on eth1 to 255.255.255.255 port 67
DHCPACK of 192.168.3.73 from 192.168.3.126
bound to 192.168.3.73 -- renewal in 17521 seconds.
```


---

 [Retour au sommaire des services](./3-0-serviceinformatique.md)
