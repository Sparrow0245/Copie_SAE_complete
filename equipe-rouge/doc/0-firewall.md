# Documentation SAÉ - Firewall Stormshield

## Introduction :

Le firewall ou pare-feu, ici le modèle Stormshield Network Security (SNS) SN310, est une solution de sécurité informatique conçu pour protéger les réseaux d'entreprise. Son rôle principale consiste à analyser et contrôler le trafic entrant comme sortant, et cela en  s'appuyant sur des règles définies par l'administrateur informatique. De cette façon, en bloquant les accès non autorisés tout en permettant les communications dites légitimes, le firewall protège l'infrastructure ainsi que les données sensibles contre les intrusions, les logiciels malveillants, et les fuites de données.



## Le choix du firewall : Stormshield SN310  
  

Pour le choix de notre firewall, nous avions 2 choix possibles qui étaient un firewall logiciel, ou un firewall physique Stormshield. Notre choix s'est porté sur ce dernier pour les raisons suivante :  

- Plus efficace qu'un firewall logiciel  
  
- Le firewall Stormshield peut, en plus d'agir comme un firewall, se comporter comme un routeur en même temps, cela permet un câblage plus optimisé et plus simple qu'avec 2 routeurs en plus du firewall  
  
- Le firewall physique centralise toute la protection et la gestion en un seul point, à la différence d'un firewall logiciel qui doit se configurer sur chaque machine individuellement  
  
- Un firewall physique est indépendant du système d'exploitation de la machine  
  
- Le fait d'avoir un firewall physique économise de la ressource CPU et ne dépend pas des ressources physiques et logicielles d'une machine hôte  
  
- Un firewall physique offre donc une meilleure performance et un meilleur débit

___
## Procédure de configuration :

### Configuration des interfaces

- Pour pouvoir configurer le firewall nous avons du le brancher à un des Douglas sur le port 2 du firewall (port in) puis ajouter l'adresse IP 10.0.0.253/24 pour pouvoir ensuite avoir accès a l'interface utilisateur 10.0.0.254 sur un moteur de recherche.

- une fois sur l'interface utilisateur nous nous connectons avec les identifiants de base (admin admin) que nous modifierons plus tard, puis nous pouvons démarrer la configuration.

- La première chose de faite a été de configurer les interfaces. Pour chaque PC Douglas que nous avons nous branchons un cable entre le firewall et le pc, c'est a dire 4 interfaces a configurer pour les PC puis 1 interface pour la liaison entre le routeur WAN et le firewall.

- Pour se faire il faut aller dans la section "Réseau > Interfaces" et assigner pour chaque interface qui sera utilisée l'ip correspondante. Dans notre cas nous avons choisi le masque /27 qui nous permettra d'avoir assez de sous réseaux disponibles (5) et assez de place pour les machines dans chaque sous réseau. Dans notre cas nous avons notre DMZ appartenant au sous réseau 192.168.2.0/27, notre service de production en 192.168.2.32/2, notre service administratif en 192.168.2.64/27 et notre service informatique en 192.168.2.96/27

- Pour chaque interface du firewall nous avons assigné l'ip la plus basse disponible soit respectivement .1, .33, .65 et .97 sauf pour l'interface WAN ou nous avons mis .253 car le routeur est en .254.

### Configuration des routes

- Pour la configuration des routes ça se trouve dans la section "Réseau > Routage"

- Avec les informations données par le groupe FAI, nous savons que le réseau inter groupes se trouve sur le plan d'adressage 192.168.10.0/24 donc nous avons simplement à ajouter la route statique en destination du réseau 192.168.10.0/24 en passant par l'interface de sortie du stormshield soit l'interface avec comme ip 192.168.2.253 et comme passerelle 192.168.2.254

### Configuration des filtres et du NAT

- Pour la configuration des filtres et du NAT nous trouvons ca dans la section "Politique de sécurité > filtrage et NAT"

- Nous avons simplement créé les regles suivantes dans la section Filtrage pour les filtres et NAT pour le NAT

![Règle de filtrage firewall](../projet/img/filtrage.png)

![Règle NAT du firewall](../projet/img/NAT.png)