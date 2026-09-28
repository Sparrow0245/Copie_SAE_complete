# Compte rendu Abderrahim - 13/10/2025

On a simplifié notre réseau en abandonnant les VLAN pour le réseau privé, ce qui a permis de réduire la complexité de l’infrastructure.

Ensuite, on a créé les Vagrantfile pour simuler les différentes machines sur les réseaux. Ces fichiers permettent de lancer des machines virtuelles représentant les hôtes sur chaque réseau.

On a essayé de faire communiquer ces machines virtuelles avec les machines hôtes du réseau physique, mais ça n’a pas fonctionné.

Cette étape nous a permis de mieux cerner les problèmes à résoudre pour la suite.

# Compte rendu Abderrahim - 14/10/2025

## Modifications du Vagrantfile

Aujourd'hui, j'ai travaillé sur le Vagrantfile que j'avais créé la veille. J'ai modifié la configuration pour mettre les machines virtuelles (VM) en public_network en mode **bridged** sur l'interface réseau `enp3s0` de la machine hôte `douglas02`. Cette configuration permet aux VM d'être reliées directement au réseau physique via cette interface. Les machines virtuelles ont pu communiquer correctement avec la machine hôte `douglas02`, ce qui permet la mise en place d'un routage fonctionnel.

Vous pouvez consulter le fichier Vagrantfile modifié ici :  
[Vagrantfile Informatique](equipe-blanc/projet/services_vagrantfiles/informatique/Vagrantfile)

La prochaine phase du projet consistera à se documenter et à se concerter afin de définir la politique de sécurité à appliquer. Cette politique servira à configurer le pare-feu **Stormshield**.

Dans l'après-midi, j'ai consacré du temps à la recherche de stage. 

# Compte rendu Abderrahim - 15/10/2025

Aujourd'hui, j'ai réalisé sur draw.io un diagramme de l'infrastructure réseau telle qu'on l'a imaginée. Ce diagramme permet de visualiser clairement l'organisation prévue du réseau.

J'ai également mis ce diagramme en ligne pour qu'il soit accessible à toute l'équipe.

Enfin, j'ai créé un fichier Markdown dans lequel je mettrai à jour régulièrement cette infrastructure au fur et à mesure de l'évolution de nos choix et de nos configurations.

# Compte rendu Abderrahim - 16/10/2025  

Révision du TP DNS et participation à la JMI  

# Compte rendu Abderrahim - 17/10/2025  

Révision des TP, pas de progression sur l'infra  
# Compte rendu Abderrahim - 10/11/2025  

Suite à une erreur de manipulation, j’ai supprimé le fichier de démarrage du switch.  

J’ai donc passé la journée à réinstaller l’image IOS sur le switch en panne. j'ai pu remettre le switch en service et j'ai rédigé un compte rendu pour documenter la procédure de récupération.  
# Compte rendu Abderrahim - 12/11/2025  

- Mise à jour de l'infrastructure, ajout des VLAN dans le réseau privé :  

- vlan 20 : informatique
- vlan 30: administratif
- vlan 40: production  

- Installation et configuration du parefeu Stormshield  
# Compte rendu Abderrahim - 13/11/2025  

Afin de respecter les consignes du projet, j’ai pris la décision de créer des VLAN afin d’isoler les flux réseau entre chaque service des deux réseaux.  
Étant donné que nous utilisons un pare-feu physique Stormshield, celui-ci se charge d’assurer le routage entre les différents VLAN.  
Après m’être documenté sur le fonctionnement du pare-feu et réalisé plusieurs essais, j’ai finalement réussi à établir la communication entre la DMZ et le réseau privé.  

Une fois cette étape validée, j’ai défini les règles de filtrage au niveau du pare-feu :  
- La DMZ peut communiquer avec l’ensemble du réseau privé.  
- Le réseau privé ne peut communiquer avec la DMZ que pour le service de production.    

J’ai également récupéré les fichiers de configuration du switch 2 et du switch 3.  
Je rédigerai ensuite différentes procédures pour expliquer la configuration du pare-feu.  
J’attends désormais l’intervention du FAI pour la mise en place de l’accès à Internet.    

Remarque : le pare-feu, étant au centre de l’architecture réseau, offre une grande flexibilité en cas de modification de la topologie.  


# Compte rendu Abderrahim - 14/11/2025  

J'ai rédigé une procédure pour configurer [le routage inter-VLAN sur le pare-feu](../../../../doc/procedure_vlan_parefeu.md).  

# Compte rendu Abderrahim - 24/11/2025  

Je n'ai rien fait aujourd'hui j'étais malade  

# Compte rendu Abderrahim - 25/11/2025  

J'ai commencé à installer les services, aujourd'hui j'ai configuré le serveur dns sur la dmz, il y a un serveur de noms et un resolveur. 
- Seul le résolveur peut interroger le nameserver, et seuls les machines du réseau 192.168.1.0 qui sont autorisées à communiquer avec la dmz
peuvent interroger le résolveur  

J'ai aussi autorisé les différents services du réseau privé à communiquer entre eux  

# Compte rendu Abderrahim - 26/11/2025  

Je suis resté chez moi pour avancer sur le tp nfs  


# Compte rendu Abderrahim - 27/11/2025  

J'essaye d'avancer sur les tp qui concernent les services que l'on doit installer  

# Compte rendu Abderrahim - 28/11/2025  

Je n'ai rien fait ce jour là  

# Compte rendu Abderrahim - 08/12/2025  

J'ai configuré le Dynamic DNS avec DHCP, Ansible afin d'installer NFS, Apache pour le reverse-proxy. Je dois maintenant tester le bon fonctionnement des services, je déposerai tous les fichier sur gitlab une fois que j'aurais validé le bon fonctionnement.  
Aussi, pour gérer les postes utilisateurs je vais générer une clé ssh statique que je récupérerais dans un fichier et avec laquelle je provisionnerais les machines utilisateurs lors du déploiement des VM.  

# Compte rendu Abderrahim - 09/12/2025  
J'ai testé le bon fonctionnement du Dynamic Dns, configuré le Dhcp relay sur le pare-feu, je testerais demain NFS et le reverse-proxy 
# Compte rendu Abderrahim - 10/12/2025  
J'ai ajouté une zone DNS privée pour le DDNS afin que les autres organisations ne puissent avoir accès aux ip des machines privées, j'ai testé le fonctionnement d'NFS et je de dois refaire la configuration du parefeu afin de pouvoir communiquer avec le FAI  
# Compte rendu Abderrahim - 11/12/2025     
Avec Kevin on a aidé Sofiane à reconfigurer le réseau pour que les organisations puissent communiquer      
# Compte rendu Abderrahim - 12/12/2025     
Avec Sofiane on a fait le découpage en sous-réseau de l'organisation équipe noir (FAI), puis j'ai configuré leur parefeu afin qu'il communique avec les autres organisations, on a également rédigé une procédure pour le routage qui sera publiée par Sofiane pour les autres organisations afin que tout le monde puisse se joindre.  
# Compte rendu Abderrahim - 12/01/2026
Rien fait aujourd'hui, je compte faire le TP mail depuis chez moi     
# Compte rendu Abderrahim - 13/01/2026  
J'ai testé le service mail, ça fonctionnait en local, je ferais les tests avec les autres groupes demain
# Compte rendu Abderrahim - 14/01/2026 
J'ai finis de configurer le service mail et le client mail (roundbox), j'ai fait les tests avec les autres organisations, j'ai mis à jour mes enregistrements DNS afin de rajouter ceux du serveur mail et j'ai supprimé mon resolveur afin d'utiliser le resolveur du FAI 
# Compte rendu Abderrahim - 15/01/2026 
J'ai commencé la configuration du forward-proxy dans le service informatique et j'ai installé une VM utilisateur (userprod) dans le réseau production avec 3 services, un client nfs, un navigateur firefox configuré pour utiliser le proxy 192.168.1.5 avec interface graphique et un client mail roundbox
# Compte rendu Abderrahim - 16/01/2026 
J'ai finis la configuration de la vm userprod du service production, je vais commencer l'installation du serveur web du service informatique
# Compte rendu Abderrahim - 26/01/2026 
Résolution d'un problème réseau lié aux routes, j'ai également terminé la configuration de la machine utilisateur userprod.  
# Compte rendu Abderrahim - 27/01/2026 
Test de la machine userprod et du réseau production. Le réseau production ne peut accéder à internet qu'a travers le navigateur web et ne peut pas communiquer avec les autres organisations , test du bon fonctionnement des autres services.  
# Compte rendu Abderrahim - 28/01/2026 
J'ai testé les différents services notamments Nfs et dhcp 
# Compte rendu Abderrahim - Du 29 Janvier au 31  
J'ai effectué les derniers tests concernant tous les services sauf ldap  