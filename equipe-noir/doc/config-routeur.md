# Configuration des interfaces

### Disclaimer

Avant de suivre cette procédure, veuillez prendre en compte que cette dernière suit la configuration de notre routeur.

---


Pour se connecter à l'interface de configuration du routeur on utilise la commande : 
```bash
minicom
```
Pour commencer la configuration, on entre cette commande :
```bash
enable
```

Puis passer en mode de configuration avec :
```bash
conf t
```
On accède ensuite à la configuration de l'interface FastEthernet 4 avec :
```bash
interface FastEthernet 4
```
Ensuite on affecte l'adresse IP pour le réseau externe et le masque en utilisant :
```bash
ip a add 192.168.10.4 255.255.255.0
```
Après avoir fait `exit`on accède à la configuration de l'interface Vlan 1 en faisant :
```bash
interface Vlan 1
```
On attribue l'adresse IP de notre réseau ainsi que son masque :
```bash
ip a add 192.168.4.254 255.255.255.0
```
Puis quitter avec un `exit`.

# Configuration du protocole RIP
Dans le but d'affecter le protocole RIP au routeur, on doit faire :
```bash
router rip
```
Pour commencer sa configuration dans minicom en mode enable. 

On applique la bonne version du protocole avec :
```bash
version 2 
```
Ajout de l'IP du réseau global.
```bash
network 192.168.10.0
```
Ajout de l'IP de notre réseau.
```bash
network 192.168.4.0
```
# Exportation et importation de la configuration

### Exportation

Pour l'exportation de la configuration du routeur, on applique la méthode suivante :

Ouvrir minicom avec la commande `minicom`, passer en `enable` puis faire CTRL-A puis L pour récupérer une configuration.

Il faut ensuite choisir un fichier de sortie et ensuite faire la commande :
```bash
show running-config
```
Après cette étape, faire CTRL-A et L puis arrêter la capture.
En ouvrant le fichier créé, la configuration est normalement présente mais il faut supprimer les 2 premières lignes car la capture a pris en compte la commande précédente.

### Importation

Ensuite, pour importer cette dernière, on procède de la sorte :

Ouvrir minicom avec la commande `minicom`, passer en `enable` puis en `conf t` ensuite faire CTRL-A puis S pour envoyer une configuration.

Choisir l'option **ascii** puis sélectionner le fichier de configuration.
Si tout va bien, la config va s'écrire toute seule.
Pour vérifier si la configuration est bien mise, on peut utiliser la commande : 
```bash
show running-config
```
Si dans la configuration il y a des éléments non voulus, il faut les supprimer car la configuration s'écrit par dessus la configuration existante.

Cette méthode va permettre de récupérer la configuration afin d'en avoir la sauvegarde sur notre machine physique.
