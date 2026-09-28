#!/bin/bash
# ============================================================
# Déplacement sécurisé du HOME de l'utilisateur Vagrant
# Objectif :
#   - Libérer /home pour autofs/NFS
#   - Garder Vagrant fonctionnel via SSH
#   - Installer rsync si nécessaire
# ============================================================

set -e

OLD_HOME="/home/vagrant"
NEW_HOME="/home-local/vagrant"

echo "=== Vérification de l'utilisateur vagrant ==="
if ! id vagrant >/dev/null 2>&1; then
    echo "[ERREUR] L'utilisateur vagrant n'existe pas."
    exit 1
fi

echo "=== Installation de rsync si absent ==="
apt update -y
apt install -y rsync

echo "=== Création du nouveau répertoire HOME ==="
mkdir -p "$(dirname "$NEW_HOME")"
mkdir -p "$NEW_HOME"

echo "=== Copie sécurisée du HOME avec rsync ==="
rsync -a "$OLD_HOME/." "$NEW_HOME/"

echo "=== Mise à jour des permissions ==="
chown -R vagrant:vagrant "$NEW_HOME"

echo "=== Mise à jour du HOME dans /etc/passwd ==="
cp /etc/passwd /etc/passwd.bak

# Remplacement du chemin dans passwd
sed -i "s|$OLD_HOME|$NEW_HOME|" /etc/passwd

echo "=== Sauvegarde de l'ancien HOME ==="
BACKUP="${OLD_HOME}.backup_$(date +%s)"
mv "$OLD_HOME" "$BACKUP"

echo ""
echo "===================================================="
echo "[✓] HOME Vagrant déplacé avec succès !"
echo "    Nouveau HOME : $NEW_HOME"
echo "    Ancien HOME sauvegardé dans : $BACKUP"
echo "===================================================="
echo "Vous pouvez maintenant activer autofs sur /home."

