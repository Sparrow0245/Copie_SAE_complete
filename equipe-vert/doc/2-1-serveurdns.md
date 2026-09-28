# DNS – *Domain Name System*

Le service DNS est essentiel dans cette SAÉ : il permet de résoudre les noms de domaine internes de l’organisation, notamment `vert.iut`, et de rendre accessibles les services publics hébergés dans la **DMZ** (web, mail, DNS lui‑même).  
Il joue également un rôle dans la délégation DNS mise en place par le FAI.

---

## 1. Création et setup du serveur `dns-vert`

Le serveur DNS `dns-vert` a été créé à l’aide d’un fichier `Vagrantfile`.  
Toutes les machines de la DMZ sont connectées en mode bridge à l’interface *`enp3s0`*, reliée à la baie réseau. Cela permet au DNS d’être accessible depuis les autres organisations, comme spécifié dans les exigences du projet.

```ruby
config.vm.define "dmz-vert" do |conf|
  conf.vm.hostname = "dmz-vert"
  conf.vm.network "public_network",
    ip: "192.168.3.194",
    netmask: "255.255.255.192",
    bridge: "enp3s0"
end
```

### Démarrage de la VM :

```bash
vagrant up dmz-vert
```
Ensuite, nous avons exécuté le script `conf_vm_dmz`, qui configure la **passerelle par défaut** ainsi que les **paramètres DNS** sur les machines de la DMZ.

Cela permet de garantir l’interconnexion entre la DMZ et les autres réseaux de l’organisation, ainsi que la résolution des noms internes via le serveur DNS exposé dans la DMZ.

```bash
#!/bin/bash

# Routes vers les autres réseaux via la passerelle du pare-feu DMZ
sudo ip r add 192.168.0.0/16 via 192.168.3.254 dev eth1
sudo ip r add 192.168.3.0/24 via 192.168.3.253 dev eth1

# Configuration du résolveur DNS local
echo "
domain vert.iut
search vert.iut
nameserver 192.168.3.194
" > /etc/resolv.conf
---

## 2. Installation et configuration de BIND9

Le serveur DNS utilise **BIND9**, une solution DNS open-source fiable et largement répandue.

Un script `setup_dns.sh` a été utilisé pour automatiser l’installation et la configuration :

```bash
apt update -y
apt install -y bind9
```

---

###  Fichiers de configuration principaux

####  2.1 `/etc/bind/named.conf.options`

Configure les **options globales** du serveur DNS :

```conf
options {

    directory "/var/cache/bind";

    recursion yes;
    allow-recursion {
        192.168.0.0/16;
    };

    allow-query {
        192.168.0.0/16;
    };

    forwarders {
        192.168.4.20;
    };

    dnssec-validation no;
    auth-nxdomain no;
    listen-on { any; };
};

```

- Active la **récursion DNS** pour les clients internes
- Définit le **DNS du FAI** comme forwarder
- Autorise les requêtes DNS uniquement depuis les réseaux de les organisation

---

####  2.2 `/etc/bind/named.conf.local`

Déclare la zone DNS interne `vert.iut` comme zone **maître** :

```conf
zone "vert.iut" {
    type master;
    file "/var/cache/bind/db.vert.iut";
};
```

---

####  2.3 `/var/cache/bind/db.vert.iut` (fichier de zone)

Contient les enregistrements DNS pour l’organisation :

```dns
$TTL 604800
@   IN  SOA ns.vert.iut. admin.vert.iut. (
            1         ; Serial
            604800    ; Refresh
            86400     ; Retry
            2419200   ; Expire
            604800 )  ; Negative Cache TTL

@       IN  NS      ns.vert.iut.
ns      IN  A       192.168.3.194
www     IN  A       192.168.3.194
mail    IN  A       192.168.3.194
@       IN  MX 10   mail.vert.iut.

; Optionnel : enregistrement SPF (anti-spoofing)
@       IN  TXT     "v=spf1 mx ~all"
```

---

## 3. Points clés de la configuration

- **`named.conf.options`** : options globales (récursion, droits, forwarders, interfaces)
- **`named.conf.local`** : déclare les zones DNS gérées par ce serveur
- **`db.vert.iut`** : base de données DNS du domaine

###  Répertoires utilisés

- `/etc/bind` → Fichiers de configuration de BIND
- `/var/cache/bind` → Fichiers de zones modifiables par le service

> Cette séparation respecte les bonnes pratiques Debian et renforce la sécurité.

---

## 4. Tests et validation

###  Tester localement depuis `dns-vert`

```bash
dig @localhost vert.iut
dig @localhost www.vert.iut
dig @localhost mail.vert.iut
```

###  Tester depuis une autre machine du réseau

```bash
dig @192.168.3.194 vert.iut
dig @192.168.3.194 www.vert.iut
host mail.vert.iut 192.168.3.194
```

---

###  Résultats attendus

- Le serveur DNS retourne les bonnes adresses IP pour chaque nom.
- La zone `vert.iut` est résolue correctement depuis toutes les machines autorisées.
- Les services **Web** et **Mail** deviennent accessibles grâce à la résolution DNS.

---

[Retour à la documentation DMZ](./2-0-dmz.md)
