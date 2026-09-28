## Préambule

Ces fichiers de documentation ont pour objectif de détailler les installations présentes pour chaque partie de l'infrastructure du projet de SAÉ.

## Présentation

@ADMIN est un sous-réseau privé contenant simplement 2 stations de travail. Celui-ci est déployé sur la machine hôte `douglas15`.

## Services/machines demandé(e)s

| Hostname  | Rôle dans l'infrastructure                                                 | Service utilisé | IP statique? | DHCP? | Image Vagrant     |
| --------- | -------------------------------------------------------------------------- | --------------- | ------------ | ----- | ----------------- |
| `ws1-adm` | Station de travail avec Firefox (navigateur) et Thunderbird (client mail). | ❌               | ❌            | ✅     | debian/bookworm64 |
| `ws2-adm` | Station de travail avec Firefox (navigateur) et Thunderbird (client mail). | ❌               | ❌            | ✅     | debian/bookworm64 |
