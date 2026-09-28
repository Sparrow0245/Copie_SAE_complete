#!/bin/bash

apt update -y
apt install -y nginx

mkdir -p /var/www/vert
echo "<h1>Organisation Vert - WEB OK</h1>" > /var/www/vert/index.html

cat >/etc/nginx/sites-available/vert <<EOF
server {
    listen 80;
    server_name www.vert.iut vert.iut;
    root /var/www/vert;
    index index.html;
}
EOF

ln -sf /etc/nginx/sites-available/vert /etc/nginx/sites-enabled/vert
rm -f /etc/nginx/sites-enabled/default

systemctl restart nginx
