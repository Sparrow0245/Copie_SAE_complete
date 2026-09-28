# Déploiement du serveur DNS

Documentation des serveurs DNS de l'organisation **Équipe Noir (FAI)**.  
L'objectif est de fournir l'autorité sur le TLD `iut`, la gestion du domaine `noir.iut` et un service de résolution récursive pour l'ensemble des organisations.

## Installation

Pour la création des VMs (ns1, ns2 et resolver), on installe les paquets nécessaires avec la commande suivante :

```bash
apt-get install -y bind9
```
## Configuration

## Fichiers de configuration BIND9

### 1. Configuration du Serveur Maître (ns1 - 192.168.4.10)

**named.conf.local**

```bash
zone "noir.iut" {
    type master;
    file "/var/cache/bind/db.noir.iut";
    allow-transfer { 192.168.4.11; };
};

zone "iut" {
    type master;
    file "/var/cache/bind/db.iut";
    allow-transfer { 192.168.4.11; };
};

zone "4.168.192.in-addr.arpa" {
    type master;
    file "/var/cache/bind/db.192.168.4";
    allow-transfer { 192.168.4.11; };
};
```

Le transfert sert pour le serveur de secours au cas où le premier serait saturé ou en panne.

**db.iut (Délégation TLD)**

```bash
$TTL    604800
@   IN  SOA iut. admin.noir.iut. ( 2025100801 3600 1800 604800 86400 )
@       IN NS   noir.iut.
@       IN NS   rouge.iut.
@       IN NS   vert.iut.
@       IN NS   blanc.iut.

noir  IN  A  192.168.4.20
blanc IN  A  192.168.1.98
rouge IN  A  192.168.2.5
vert  IN  A  192.168.3.194
```

Cela nous permet de connaître tous les serveurs ns des organisations qui pourront utiliser notre résolveur.

**db.noir.iut (Zone de l'organisation)**

```bash
$TTL    604800
@   IN  SOA iut. admin.noir.iut. ( 2025100801 3600 1800 604800 86400 )
@       IN      NS      ns1.noir.iut.
@       IN      NS      ns2.noir.iut.
@       IN      MX 10   mail.noir.iut.

ns1      IN      A       192.168.4.10
ns2      IN      A       192.168.4.11
resolver IN      A       192.168.4.20
www      IN      A       192.168.4.30
mail     IN      A       192.168.4.40
```

Afin d'avoir toutes les machines de la DMZ comme le serveur mail ou le résolveur.

**db.192.168.4 (Zone Inverse)**

```bash
$TTL    604800
@       IN      SOA     ns1.noir.iut. root.noir.iut. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Minimum TTL

@       IN      NS      ns1.noir.iut.
@       IN      NS      ns2.noir.iut.

10      IN      PTR     ns1.noir.iut.
11      IN      PTR     ns2.noir.iut.
20      IN      PTR     resolver.noir.iut.
30      IN      PTR     www.noir.iut.
40      IN      PTR     mail.noir.iut.
```
Cela permet de traduire un nom en IP.

### 2. Configuration du Serveur Esclave (ns2 - 192.168.4.11)

**named.conf.local**

```bash
zone "noir.iut" {
    type slave;
    file "/var/cache/bind/db.noir.iut";
    masters { 192.168.4.10; };
};

zone "iut" {
    type slave;
    file "/var/cache/bind/db.iut";
    masters { 192.168.4.10; };
};

zone "4.168.192.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.192.168.4";
    masters { 192.168.4.10; };
};
```
Il y a la liste des zones définies, leur emplacement et l'indication du serveur maître.

### 3. Configuration du Résolveur (resolver - 192.168.4.20)

**named.conf.options**

```bash
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.4.10;
        172.18.48.31;
    };
    recursion yes;
    allow-query { any; };
    dnssec-validation no;
    listen-on-v6 { any; };
};
```
Les autres organisations ont accès à notre résolveur si le leur ne connaît pas ce qu'il cherche.

**named.conf.local (Forwarding par zone)**

```bash
zone "noir.iut"  { type forward; forward only; forwarders { 192.168.4.10; }; };
zone "vert.iut"  { type forward; forward only; forwarders { 192.168.3.194; }; };
zone "blanc.iut" { type forward; forward only; forwarders { 192.168.1.98; }; };
zone "rouge.iut" { type forward; forward only; forwarders { 192.168.2.5; }; };
```
## Tests

Pour tester le service DNS, la commande `dig` sert à interroger les serveurs DNS.

```bash
dig NS noir.iut @192.168.4.20 
```

Pour avoir le nameserver de notre équipe.

```bash
dig www.vert.iut @192.168.4.20 
```

Pour avoir le serveur web de l'équipe vert.

```bash
dig @192.168.4.20 -x 192.168.4.10
```

Pour avoir le nom qui correspond à l'IP.
