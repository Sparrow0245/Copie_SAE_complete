#!/bin/bash

# === Configuration de Squid ===
echo "=== Installation de Squid ==="
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y squid

echo "=== Sauvegarde de la configuration originale ==="
mv /etc/squid/squid.conf /etc/squid/squid.conf.bak

echo "=== Création du nouveau fichier squid.conf ==="
cat <<EOF >/etc/squid/squid.conf
# Définir le nom du proxy
visible_hostname Proxy

# Autoriser uniquement le réseau de production
acl production_net src 192.168.3.128/26
http_access allow production_net

# Port d'écoute
http_port 3128

# Autoriser les ports HTTP/HTTPS
acl Safe_ports port 80
acl Safe_ports port 443
http_access allow Safe_ports

# Refuser tout le reste par défaut
http_access deny all
EOF



echo "=== Redémarrage de Squid ==="
systemctl restart squid
systemctl enable squid

echo "=== Configuration terminée avec succès ==="
