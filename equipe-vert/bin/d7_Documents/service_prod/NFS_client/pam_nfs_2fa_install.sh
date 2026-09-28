#!/bin/bash


sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
nslcd \
libnss-ldapd \
libpam-ldapd \
ldap-utils \
libpam-google-authenticator
