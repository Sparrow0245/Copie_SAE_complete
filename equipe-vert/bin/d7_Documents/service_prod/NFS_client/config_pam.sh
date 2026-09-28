#!/bin/bash
set -e

echo "[+] Configuration PAM pour le TP 5"

# 1. Backup des fichiers PAM importants
cp /etc/pam.d/common-auth /etc/pam.d/common-auth.bak 2>/dev/null || true
cp /etc/pam.d/common-session /etc/pam.d/common-session.bak 2>/dev/null || true
cp /etc/pam.d/sshd /etc/pam.d/sshd.bak 2>/dev/null || true

# 2. Activer PAM LDAP et Unix proprement
echo " Activation PAM LDAP et Unix"
pam-auth-update --enable ldap --enable unix --force

# 3. Ajouter pam_mkhomedir si absent
# echo "[+] Vérification pam_mkhomedir"
# if ! grep -q "pam_mkhomedir.so" /etc/pam.d/common-session; then
#   echo "session required pam_mkhomedir.so skel=/etc/skel umask=0022" >> /etc/pam.d/common-session
# fi

# 4. Préparer PAM pour la 2FA (SSH)
echo " Configuration PAM SSH pour 2FA (Google Authenticator)"
if ! grep -q "pam_google_authenticator.so" /etc/pam.d/sshd; then
  sed -i '/@include common-auth/i auth required pam_google_authenticator.so nullok' /etc/pam.d/sshd
fi

# 5. Vérifier SSH config
echo " Vérification sshd_config"
sed -i 's/^#\?UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config
sed -i 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config

# 6. Restart SSH
systemctl restart ssh

echo " PAM configuré avec succès"