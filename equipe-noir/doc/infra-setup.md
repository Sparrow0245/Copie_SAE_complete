# Documentation des Scripts de Configuration - Dossier `/bin`

Ce dossier contient tous les scripts bash de déploiement et configuration des machines virtuelles de l'infrastructure réseau.

---

## Scripts Principaux

### `start.sh`
**Objectif:** Script maître de déploiement qui orchestre l'ensemble de l'infrastructure.

**Fonctionnement:**
- Demande le chemin absolu du dossier `equipe-noir`
- Copie les scripts de configuration vers les trois machines distantes (douglas09, douglas10, douglas11)
- Transfère les scripts spécifiques aux VMs dans les répertoires adéquats
- Exécute les scripts de configuration sur chaque machine distante

**Utilisation:**
```bash
./start.sh
```

**Chemin SSH requis:** douglas09, douglas10, douglas11 configurés dans `~/.ssh/config`

---

### `douglas09.sh`
**Objectif:** Orchestration de la création et configuration des VMs de service d'information.

**VMs créées:**
- `ldap` - Serveur LDAP (authentification centralisée)
- `nfs` - Serveur NFS (partage de fichiers)
- `dhcp` - Serveur DHCP (allocation d'adresses IP)
- `client1` - Client pour test d'intégration

**Configuration appliquée:**
1. Création des VMs avec allocation de ressources (4096 MB RAM, 2 CPUs)
2. Configuration des interfaces réseau en bridge avec `enp3s0`
3. Montage des dossiers de configuration partagés via VirtualBox
4. Exécution des scripts de configuration spécifiques
5. Démontage des dossiers partagés

**Interface réseau:** `enp3s0`

---

### `douglas10.sh`
**Objectif:** Orchestration de la création et configuration des VMs DMZ (zone démilitarisée).

**VMs créées:**
- `ns1` - Serveur DNS primaire
- `ns2` - Serveur DNS secondaire
- `resolver` - Résolveur DNS (forwarding)
- `web` - Serveur web Apache
- `mail` - Serveur mail (Postfix + Dovecot)

**Configuration appliquée:**
1. Configuration de l'interface `enp3s0` avec IP statique `192.168.4.61/26`
2. Ajout d'une route vers le réseau `192.168.0.0/16` via `192.168.4.62`
3. Création et démarrage des 5 VMs
4. Allocation de ressources (4096 MB RAM, 2 CPUs chacune)
5. Montage des dossiers de configuration
6. Exécution des scripts VM-spécifiques
7. Démontage des dossiers après configuration

**Interface réseau:** `enp3s0` - IP: `192.168.4.61/26`

---

### `douglas11.sh`
**Objectif:** Orchestration de la création et configuration des VMs de service administratif.

**VMs créées:**
- `admin1` - Poste administrateur 1
- `admin2` - Poste administrateur 2

**Configuration appliquée:**
1. Création des VMs avec allocation de ressources (4096 MB RAM, 2 CPUs)
2. Configuration des interfaces réseau en bridge avec `enp3s0`
3. Montage des dossiers de configuration partagés
4. Exécution des scripts de configuration
5. Démontage des dossiers partagés

**Interface réseau:** `enp3s0`

---

## Scripts de Configuration des VMs

### Dossier `douglas09/`

#### `ldap.sh`
**Service:** OpenLDAP (authentification centralisée)

**Actions:**
- Configuration réseau: IP `192.168.4.10/26`, gateway `192.168.4.62`
- Hostname: `ldap`
- Montage et copie des fichiers de configuration depuis le dossier partagé
- Gestion des erreurs: cherche le dossier partagé à deux emplacements possibles

**Statut:** En développement (TODO: installation et configuration LDAP)

#### `nfs.sh`
**Service:** NFS (Network File System - partage de fichiers)

**Actions:**
- Configuration réseau: IP `192.168.4.10/26`, gateway `192.168.4.62`
- Hostname: `nfs`
- Récupération de la configuration partagée
- Flexibilité: gestion de deux chemins de montage possibles

**Statut:** En développement (TODO: installation et configuration NFS)

#### `dhcp.sh`
**Service:** DHCP (Dynamic Host Configuration Protocol)

**Actions:**
- Configuration réseau: IP `192.168.4.10/26`, gateway `192.168.4.62`
- Hostname: `dhcp`
- Copie des fichiers de configuration partagés
- Chemin de configuration: `/root/conf/`

**Statut:** En développement (TODO: installation et configuration DHCP)

#### `client_info.sh`
**Service:** Client DHCP générique pour service d'information

**Actions:**
- Configuration réseau: DHCP dynamique
- Hostname: `client_info`
- Copie des fichiers de configuration depuis le dossier partagé
- Intégration NFS, PAM, LDAP client

**Statut:** En développement (TODO: intégration NFS, PAM, LDAP)

---

### Dossier `douglas10/`

#### `ns1.sh`
**Service:** BIND9 - DNS primaire (Nameserver 1)

**Actions:**
- Configuration réseau: IP `192.168.4.10/26`, gateway `192.168.4.62`
- Hostname: `ns1`
- Installation de `bind9`
- Copie des fichiers de zone DNS (`db.*`)
- Configuration locale et résolveur
- Route vers réseau interne `192.168.0.0/16` via `192.168.4.62`

**Fichiers de configuration:** 
- `db.iut`, `db.noir.iut`, `db.192.168.4`
- `named.conf.local`, `named.conf.options`
- `resolv.conf`

#### `ns2.sh`
**Service:** BIND9 - DNS secondaire (Nameserver 2)

**Actions:**
- Configuration réseau: IP `192.168.4.11/26`, gateway `192.168.4.62`
- Hostname: `ns2`
- Installation de `bind9`
- Configuration DNS secondaire
- Copie de `named.conf.local` et `resolv.conf`

#### `resolveur.sh`
**Service:** BIND9 - Résolveur DNS (Forwarding)

**Actions:**
- Configuration réseau: IP `192.168.4.20/26`, gateway `192.168.4.62`
- Hostname: `resolveur`
- Installation de `bind9`
- Configuration en tant que résolveur DNS
- Forwarding vers les serveurs DNS primaire/secondaire
- Route vers réseau `192.168.0.0/16` via `192.168.4.62`

#### `web.sh`
**Service:** Apache2 - Serveur web

**Actions:**
- Configuration réseau: IP `192.168.4.30/26`, gateway `192.168.4.62`
- Hostname: `web`
- Installation d'`apache2`
- Copie des fichiers web vers `/var/www/html/` (HTML, CSS, etc.)
- Configuration DNS
- Route vers réseau interne `192.168.0.0/16`

**Fichiers servis:** 
- `index.html`
- `styles.css`
- Autres assets web

#### `mail.sh`
**Service:** Postfix + Dovecot - Serveur mail complet

**Actions:**
- Configuration réseau: IP `192.168.4.40/26`, gateway `192.168.4.62`
- Hostname: `mail`
- Installation de `postfix` et `dovecot` (IMAP + POP3)
- Copie de la configuration:
  - `/etc/postfix/main.cf` - Configuration Postfix
  - `/etc/mailname` - Domaine de courrier
  - `/etc/dovecot/conf.d/10-auth.conf` - Auth Dovecot
  - `/etc/dovecot/conf.d/10-mail.conf` - Mail Dovecot
- Création de 3 utilisateurs de test: `user1`, `user2`, `user3`
- Redémarrage des services
- Route vers réseau interne `192.168.0.0/16`

---

### Dossier `douglas11/`

#### `admin1.sh`
**Service:** Poste d'administration 1

**Actions:**
- Configuration réseau: DHCP dynamique
- Hostname: `admin1`
- Montage et copie des fichiers de configuration
- Gestion des deux chemins de montage possibles

**Statut:** En développement (TODO: intégration NFS, PAM, LDAP client)

#### `admin2.sh`
**Service:** Poste d'administration 2

**Actions:**
- Configuration réseau: DHCP dynamique
- Hostname: `admin2`
- Récupération de la configuration partagée
- Flexibilité: deux emplacements de dossier partagé possibles

**Statut:** En développement (TODO: intégration NFS, PAM, LDAP client)

---

## Résumé de l'Infrastructure

| Machine | Rôle | Services | IP (DMZ) | État |
|---------|------|----------|----------|------|
| **douglas09** | Service Info | LDAP, NFS, DHCP, Client | - | Partiel |
| **douglas10** | DMZ | DNS (ns1/ns2), Résolveur, Web, Mail | 192.168.4.61 | Complet |
| **douglas11** | Admin | Admin1, Admin2 | - | Partiel |

---

## Dépendances et Flux

```
start.sh
├── douglas09.sh
│   ├── ldap.sh (LDAP server)
│   ├── nfs.sh (NFS server)
│   ├── dhcp.sh (DHCP server)
│   └── client_info.sh (DHCP client)
├── douglas10.sh
│   ├── ns1.sh (DNS primary)
│   ├── ns2.sh (DNS secondary)
│   ├── resolveur.sh (DNS forwarder)
│   ├── web.sh (Web server)
│   └── mail.sh (Mail server)
└── douglas11.sh
    ├── admin1.sh (Admin host 1)
    └── admin2.sh (Admin host 2)
```

---

## Prérequis

- Accès SSH configuré vers douglas09, douglas10, douglas11
- `vboxmanage` dans le PATH
- Dossiers de configuration présents aux chemins attendus:
  - `/home/cisco/service_info/conf_*/`
  - `/home/cisco/dmz/conf_*/`
  - `/home/cisco/service_admin/conf_*/`

---

## Notes de Développement

- **Status:** Plusieurs services en cours de développement (marqués TODO)
- **LDAP, DHCP, NFS:** Installation et configuration à finaliser
- **Admin1, Admin2:** Intégration NFS, PAM, LDAP à ajouter

---

## Convention de Nommage

- Scripts principaux: `douglasXX.sh` (exécutés sur chaque machine)
- Scripts VM: dossier `douglasXX/` avec nom du service
- Fichiers de configuration: dossier `/conf_*/` correspondant