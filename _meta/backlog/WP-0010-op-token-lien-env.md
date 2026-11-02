---
wp_id: WP-0010
titre: "Wizard 3/3 OpenProject : lien de fabrication de la clÃ© API + dÃ©tection du fichier d'env du token"
statut: fait
priorite: moyenne
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "proposition utilisateur du 01/11/2026 â€” Â« il connaÃ®t dÃ©jÃ  l'URL, il peut proposer un lien pour fabriquer la clÃ©, ou demander s'il y a un fichier d'env qui la connaÃ®t Â»"
crÃ©Ã©: 2026-11-01
mis_a_jour: 2026-11-02

## Objectif

AprÃ¨s la saisie de l'URL de l'instance OpenProject, le wizard :
1. affiche le **lien direct** pour fabriquer la clÃ© API (`<url>/api/access`, section Â« API access Â») ;
2. propose de **pointer un fichier d'env** qui contient dÃ©jÃ  le token : il en **liste les variables `*token*`** (valeurs jamais affichÃ©es) et **prÃ©-remplit** le nom de variable par dÃ©faut.

RÃ¨gle invariÃ©e : **le token n'est jamais Ã©crit dans le repo** â€” seul le nom de variable (+ Ã©ventuellement le chemin du fichier, `token_file`) est persistÃ© dans `_projet/registry/connexions.md`.

## CritÃ¨res de rÃ©alisation

- [x] Lien de clÃ© affichÃ© aprÃ¨s l'URL â€” **page Â« Mes jetons d'accÃ¨s Â» `<url>/my/access_tokens`** (corrigÃ© le 02/11 : `api/access` Ã©tait l'endpoint REST, pas la page de fabrication) ; URL saisie sans deviner de mont
- [x] Question Â« Un fichier d'env contient dÃ©jÃ  le token ? Â» â†’ chemin â†’ variables `*token*` listÃ©es, valeurs masquÃ©es â†’ variable par dÃ©faut prÃ©-remplie
- [x] Fichier absent ou aucune variable â†’ fallback `OP_API_TOKEN` (message explicite)
- [x] `token_file` persistÃ© dans le bloc wizard du registre (quand fourni)
- [x] `install.ps1` (ASCII) + `install.sh` alignÃ©s ; syntaxe des deux validÃ©e
- [x] Logique de parse du fichier d'env testÃ©e (fichier d'essai)
- [ ] Validation terrain : relancer `.\install.ps1`, brancher OpenProject

## Notes

- **Correction 02/11 (test utilisateur)** : le 1áµ‰Ê³ lien gÃ©nÃ©rÃ© (`<url>/api/access`) Ã©tait l'**endpoint REST/OAuth2**, pas la page de fabrication. La page Â« Mes jetons d'accÃ¨s Â» est **`<url>/my/access_tokens`** â€” le lien appose dÃ©sormais ce suffixe sur l'URL saisie (trailing `/` retirÃ©, sans deviner de mont `/openproject`).
- Regex de parse des deux scripts : `^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=` â†’ nom de variable, insensible Ã  la casse, filtre `*token*` sur les noms.
- `token_file` dans le registre = traÃ§abilitÃ© pour l'agent (savoir **oÃ¹** charger le token sans l'Ã©crire).
- GÃ©nÃ©ralisable aux autres connexions (GitHub/GitLab ont aussi des pages de tokens) â€” hors pÃ©rimÃ¨tre de ce WP, noter si demande.
