## Préambule

Ces fichiers de documentation ont pour objectif de détailler les installations présentes pour chaque partie de l'infrastructure du projet de SAÉ.

## Présentation

@IT est un sous-réseau privé dédié au service informatique. Celui-ci centralise les services internes nécessaires au bon fonctionnement des stations de travail et à la gestion des utilisateurs. Celui-ci est déployé sur la machine hôte `douglas16`.

## Services/machines demandé(e)s

| Hostname | Rôle dans l'infrastructure                                                          | Service utilisé   | IP statique?     | DHCP? | Image Vagrant     |
| -------- | ----------------------------------------------------------------------------------- | ----------------- | ---------------- | ----- | ----------------- |
| `dhcp`   | Serveur DHCP permettant l'attribution d'adresses IP aux stations de travail.        | isc-dhcp-server   | 192.168.2.99/27  | ❌     | debian/bookworm64 |
| `ldap`   | Annuaire LDAP pour la gestion des utilisateurs sur les stations de travail.         | OpenLDAP          | 192.168.2.100/27 | ❌     | debian/bookworm64 |
| `nfs`    | Serveur NFS hébergeant les dossiers /home des utilisateurs des stations de travail. | nfs-kernel-server | 192.168.2.101/27 | ❌     | debian/bookworm64 |
| `proxy`  | Proxy web servant d'intermédiaire entre les stations de travail de @PROD et le web. | Squid             | 192.168.2.102/27 | ❌     | debian/bookworm64 |
| `ws1-it` | Station de travail avec Firefox (navigateur) et Thunderbird (client mail).          | ❌                 | ❌                | ✅     | debian/bookworm64 |
