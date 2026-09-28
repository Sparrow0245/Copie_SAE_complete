# Compte rendu Mickhail - 13/10/2025  

Nous avons simplifié notre infrastructure en abandonnant l'idée des VLANs qui nous semblait inutile.
Après avoir effectué quelques tests sur nos machines physiques, nous avons crée des Vagrantfiles pour créer nos machines virtuelles (vierges, seulement avec les bons réseaux), et nous avons testé la communication des machines entre elles et avec internet. Nous n'arrivons néanmoins pas à faire communiquer nos machines virtuelles avec leur machines physiques hôtes alors qu'elles sont dans le même sous-réseau.

Nous prenons notre temps pour bien tester l'infrastructure car elle sera le pilier de tout ce qui sera fait ensuite.
Suite à une erreur de manipulation dans notre groupe, il a fallut réparer le switch 1.  

# Compte rendu Mickhail - 10/11/2025  
Nous n'avons donc pas fait grand chose  
# Compte rendu Mickhail - 12/11/2025  
Aujourd'hui nous avons remis en place notre infrastructure.
Nous avons également commencé à manipuler un firewall stormshield pour comprendre comment il fonctionne et effectuer des tests dessus.
Nous nous sommes également demandé si il vaut mieux utiliser Vagrant ou OpenTofu au sujet du déploiement des services.
