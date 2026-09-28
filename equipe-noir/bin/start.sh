#!/bin/bash

echo "Veilliez donner le chemin absolu du dossier equipe-noir sur votre machine actuelle, laissez vide si vous y êtes déjà (ex: /home/user/s5b01/equipe-noir) :"
read -r CHEMIN_EQUIPE_NOIR

if [ -z "$CHEMIN_EQUIPE_NOIR" ]; then
    CHEMIN_EQUIPE_NOIR=$(pwd)
    echo "Utilisation du chemin courant : $CHEMIN_EQUIPE_NOIR"
    echo "Vous comfirmez que ce chemin est correct et contient le dossier 'projet' et 'bin' ? (O/n)"
    read -r CONFIRMATION
    if [ "$CONFIRMATION" != "O" ] && [ "$CONFIRMATION" != "o" ] && [ -n "$CONFIRMATION" ]; then
        echo "Opération annulée. Veuillez relancer le script avec le chemin correct."
        exit 1
    fi
elif [ ! -d "$CHEMIN_EQUIPE_NOIR" ]; then
    echo "Chemin invalide. Veuillez vérifier et réessayer."
    exit 1
fi

scp -r "$CHEMIN_EQUIPE_NOIR/projet/service_info" cisco@douglas09:/home/cisco/
scp -r "$CHEMIN_EQUIPE_NOIR/projet/dmz" cisco@douglas10:/home/cisco/
scp -r "$CHEMIN_EQUIPE_NOIR/projet/service_admin" cisco@douglas11:/home/cisco/

ssh cisco@douglas09 'mkdir -p /home/cisco/service_info/scripts/vm'
ssh cisco@douglas10 'mkdir -p /home/cisco/dmz/scripts/vm'
ssh cisco@douglas11 'mkdir -p /home/cisco/service_admin/scripts/vm'

scp "$CHEMIN_EQUIPE_NOIR/bin/douglas09.sh" cisco@douglas09:/home/cisco/service_info/scripts/
scp -r "$CHEMIN_EQUIPE_NOIR/bin/douglas09" cisco@douglas09:/home/cisco/service_info/scripts/vm/

scp "$CHEMIN_EQUIPE_NOIR/bin/douglas10.sh" cisco@douglas10:/home/cisco/dmz/scripts/
scp -r "$CHEMIN_EQUIPE_NOIR/bin/douglas10" cisco@douglas10:/home/cisco/dmz/scripts/vm/

scp "$CHEMIN_EQUIPE_NOIR/bin/douglas11.sh" cisco@douglas11:/home/cisco/service_admin/scripts/
scp -r "$CHEMIN_EQUIPE_NOIR/bin/douglas11" cisco@douglas11:/home/cisco/service_admin/scripts/vm/
echo "Les scripts ont été copiés avec succès sur les machines distantes."

ssh cisco@douglas09 'bash /home/cisco/service_info/scripts/douglas09.sh create'
ssh cisco@douglas10 'bash /home/cisco/dmz/scripts/douglas10.sh create'
ssh cisco@douglas11 'bash /home/cisco/service_admin/scripts/douglas11.sh create'

echo "Les scripts ont été exécutés avec succès sur les machines distantes."

echo "Configuration terminée."