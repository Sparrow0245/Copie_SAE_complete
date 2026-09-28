#!/bin/bash

# Proxy settings
PROXY_IP="192.168.3.6"
PORT="3128"

echo "Configuration du proxy"

# 1. Variables globales
cat <<EOF >/etc/environment
http_proxy="http://$PROXY_IP:$PORT/"
https_proxy="http://$PROXY_IP:$PORT/"
ftp_proxy="http://$PROXY_IP:$PORT/"
HTTP_PROXY="http://$PROXY_IP:$PORT/"
HTTPS_PROXY="http://$PROXY_IP:$PORT/"
no_proxy="localhost,127.0.0.1"
EOF

# 2. Variables shell
cat <<EOF >/etc/profile.d/proxy.sh
export http_proxy="http://$PROXY_IP:$PORT/"
export https_proxy="http://$PROXY_IP:$PORT/"
export HTTP_PROXY="http://$PROXY_IP:$PORT/"
export HTTPS_PROXY="http://$PROXY_IP:$PORT/"
EOF

chmod +x /etc/profile.d/proxy.sh

# 3. Proxy APT
cat <<EOF >/etc/apt/apt.conf.d/95proxy
Acquire::http::Proxy "http://$PROXY_IP:$PORT/";
Acquire::https::Proxy "http://$PROXY_IP:$PORT/";
EOF

echo "Terminé. Relancer la session."