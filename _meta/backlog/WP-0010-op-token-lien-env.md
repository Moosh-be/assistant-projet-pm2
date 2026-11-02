---
wp_id: WP-0010
titre: "Wizard 3/3 OpenProject : lien de fabrication de la clé API + détection du fichier d'env du token"
statut: en-cours
priorite: moyenne
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "proposition utilisateur du 01/11/2026 — « il connaît déjà l'URL, il peut proposer un lien pour fabriquer la clé, ou demander s'il y a un fichier d'env qui la connaît »"
créé: 2026-11-01
mis_a_jour: 2026-11-02

## Objectif

Après la saisie de l'URL de l'instance OpenProject, le wizard :
1. affiche le **lien direct** pour fabriquer la clé API (`<url>/api/access`, section « API access ») ;
2. propose de **pointer un fichier d'env** qui contient déjà le token : il en **liste les variables `*token*`** (valeurs jamais affichées) et **pré-remplit** le nom de variable par défaut.

Règle invariée : **le token n'est jamais écrit dans le repo** — seul le nom de variable (+ éventuellement le chemin du fichier, `token_file`) est persisté dans `_projet/registry/connexions.md`.

## Critères de réalisation

- [x] Lien de clé affiché après l'URL — **page « Mes jetons d'accès » `<url>/my/access_tokens`** (corrigé le 02/11 : `api/access` était l'endpoint REST, pas la page de fabrication) ; URL saisie sans deviner de mont
- [x] Question « Un fichier d'env contient déjà le token ? » → chemin → variables `*token*` listées, valeurs masquées → variable par défaut pré-remplie
- [x] Fichier absent ou aucune variable → fallback `OP_API_TOKEN` (message explicite)
- [x] `token_file` persisté dans le bloc wizard du registre (quand fourni)
- [x] `install.ps1` (ASCII) + `install.sh` alignés ; syntaxe des deux validée
- [x] Logique de parse du fichier d'env testée (fichier d'essai)
- [ ] Validation terrain : relancer `.\install.ps1`, brancher OpenProject

## Notes

- **Correction 02/11 (test utilisateur)** : le 1ᵉʳ lien généré (`<url>/api/access`) était l'**endpoint REST/OAuth2**, pas la page de fabrication. La page « Mes jetons d'accès » est **`<url>/my/access_tokens`** — le lien appose désormais ce suffixe sur l'URL saisie (trailing `/` retiré, sans deviner de mont `/openproject`).
- Regex de parse des deux scripts : `^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=` → nom de variable, insensible à la casse, filtre `*token*` sur les noms.
- `token_file` dans le registre = traçabilité pour l'agent (savoir **où** charger le token sans l'écrire).
- Généralisable aux autres connexions (GitHub/GitLab ont aussi des pages de tokens) — hors périmètre de ce WP, noter si demande.
