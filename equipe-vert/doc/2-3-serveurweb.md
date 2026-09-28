# Serveur Web – *Nginx*

Le service Web permet de publier le site de l’organisation `vert.iut` et de le rendre accessible via les noms `www.vert.iut` et `vert.iut`.  
Ce service, situé dans la DMZ, joue un rôle essentiel pour exposer des contenus vers les autres organisations et simuler une publication Internet.

---

## Création et setup serveur `web-vert`

Le serveur Web est hébergé sur la machine `dmz-vert`, déjà utilisée pour les services DNS et Mail.

Toutes les machines de la DMZ sont connectées en mode bridge à l’interface réseau *`enp3s0`*, ce qui permet leur accessibilité depuis les autres réseaux de l’infrastructure.

### Démarrer la machine

```bash
vagrant up dmz-vert
```

Ensuite, nous avons appliqué le script `conf_vm_dmz`, permettant de configurer les routes et les paramètres DNS internes.

```bash
#!/bin/bash

sudo ip r add 192.168.0.0/16 via 192.168.3.254 dev eth1
sudo ip r add 192.168.3.0/24 via 192.168.3.253 dev eth1

echo "
domain vert.iut
search vert.iut
nameserver 192.168.3.194
" > /etc/resolv.conf
```

Cela permet de garantir l’accessibilité inter‑réseaux de la DMZ et la résolution correcte des noms internes.

---

## 1. Installation et configuration

Un script `setup_web.sh` a été utilisé pour installer et préparer le service Nginx.

```bash
apt update -y
apt install -y nginx
```

Création du répertoire du site et d’une page d’accueil :

```bash
mkdir -p /var/www/vert
echo "<h1>Organisation Vert - WEB OK</h1>" > /var/www/vert/index.html
```

---

## 2. Configuration du Virtual Host

Le fichier `/etc/nginx/sites-available/vert` définit la configuration de notre site Web :

```nginx
server {
    listen 80;
    server_name www.vert.iut vert.iut;

    root /var/www/vert;
    index index.html;
}
```

Activation du site :

```bash
ln -sf /etc/nginx/sites-available/vert /etc/nginx/sites-enabled/vert
rm -f /etc/nginx/sites-enabled/default
```

Redémarrage du service :

```bash
systemctl restart nginx
```

---

## Point clé de la configuration

- **`/var/www/vert`** : répertoire racine du site de l’organisation.
- **`/etc/nginx/sites-available/vert`** : fichier Virtual Host du site.
- **`server_name www.vert.iut vert.iut`** : noms de domaine associés au site.
- **Méthode sites-available / sites-enabled** : standard Nginx pour gérer les sites activés.
- **`index.html`** : page d’accueil affichée aux visiteurs.

---

## 3. Tests et validation

### Vérification DNS

```bash
dig +short www.vert.iut
dig +short vert.iut
```

Les deux commandes doivent retourner :

```
192.168.3.194
```

### Vérification de l’accès au site

Depuis une machine de l’organisation :

```bash
curl http://www.vert.iut
```

### Résultat attendu

```html
<h1>Organisation Vert - WEB OK</h1>
```

Cela confirme que :

- le site Web est accessible via DNS,
- la VM DMZ répond correctement aux requêtes HTTP,
- le Virtual Host fonctionne comme prévu.

---

[Retour à la DMZ](./2-0-dmz.md)
