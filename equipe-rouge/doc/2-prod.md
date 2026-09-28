## Préambule

Ces fichiers de documentation ont pour objectif de détailler les installations présentes pour chaque partie de l'infrastructure du projet de SAÉ.

## Présentation

@PROD est un sous-réseau privé contenant simplement 2 stations de travail. La particularité de ce sous-réseau est que celui-ci ne peut pas se connecter directement à l'Internet (le réseau public des autres groupes), mais à travers un proxy web présent dans le sous-réseau @IT. Celui-ci est déployé sur la machine hôte `douglas14`.

## Services/machines demandé(e)s

| Hostname   | Rôle dans l'infrastructure                                                 | Service utilisé | IP statique? | DHCP? | Image Vagrant     |
| ---------- | -------------------------------------------------------------------------- | --------------- | ------------ | ----- | ----------------- |
| `ws1-prod` | Station de travail avec Firefox (navigateur) et Thunderbird (client mail). | ❌               | ❌            | ✅     | debian/bookworm64 |
| `ws2-prod` | Station de travail avec Firefox (navigateur) et Thunderbird (client mail). | ❌               | ❌            | ✅     | debian/bookworm64 |
