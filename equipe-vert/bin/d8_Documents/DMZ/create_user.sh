#!/bin/bash

# Usage: ./create_user.sh username password

USER="$1"
PASS="$2"

# ---- Checks ----
if [ -z "$USER" ] || [ -z "$PASS" ]; then
  echo "Usage: $0 <username> <password>"
  exit 1
fi

# ---- Create user ----
echo "[+] Creating user: $USER"
useradd "$USER" -m || { echo "User already exists?"; exit 1; }

echo "[+] Setting password"
echo "${USER}:${PASS}" | chpasswd

# ---- Create Maildir ----
echo "[+] Creating Maildir for $USER"
sudo -u "$USER" maildirmake.dovecot "/home/$USER/Maildir"
sudo -u "$USER" maildirmake.dovecot "/home/$USER/Maildir/.Drafts"
sudo -u "$USER" maildirmake.dovecot "/home/$USER/Maildir/.Sent"
sudo -u "$USER" maildirmake.dovecot "/home/$USER/Maildir/.Trash"

chown -R "$USER:$USER" "/home/$USER/Maildir"

echo "[✔] User $USER created with Maildir ready."
