## Préambule

Ces fichiers de documentation ont pour objectif de détailler les installations présentes pour chaque partie de l'infrastructure du projet de SAÉ.

## Présentation

@DMZ est un sous-réseau public qui héberge les services accessibles depuis les autres organisations, services nécessaires à la communication inter-groupes. Celui-ci est déployé sur la machine hôte `douglas13`.

## Services/machines demandé(e)s

| Hostname | Rôle dans l'infrastructure                                          | Service utilisé   | IP statique?   | DHCP? | Image Vagrant     |
|----------|---------------------------------------------------------------------|-------------------|----------------|-------|-------------------|
| `web`    | Serveur web avec une simple page vitrine de présentation du groupe. | nginx             | 192.168.2.3/27 | ❌     | debian/bookworm64 |
| `mail`   | Serveur mail pour les utilisateurs des stations de travail.         | Postfix + Dovecot | 192.168.2.4/27 | ❌     | debian/bookworm64 |
| `dns`    | Serveur DNS d'autorité pour le nom de domaine `rouge.iut`.          | bind9             | 192.168.2.5/27 | ❌     | debian/bookworm64 
