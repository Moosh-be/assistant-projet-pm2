---
wp_id: WP-0018
titre: "Renommage de la couche du kit : _projet -> _meta (valeur par defaut de meta_folder)"
statut: fait
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 02/11/2026 — hesite utilisateur sur le nom final (projet / assistant / artefact / doc / meta)"
créé: 2026-11-02
mis_a_jour: 2026-11-02
---

# WP-0018 — Renommage de la couche du kit : `_projet` → `_meta`

## Contexte

La valeur par défaut de `meta_folder` (config machine `assistant.config`, WP-0017) était `_projet`.
L'utilisateur a hésité sur le nom : `projet`, `assistant`, `artefact`, `doc`, `meta`.

## Décision (validée 02/11)

**`_meta`** — pour 4 raisons :
1. C'est le **terme exact** : ce dossier est de la data *sur* le projet (fiche, WPs, journal, reports, registres), pas le projet lui-même.
2. Le kit l'appelle déjà « **couche méta** (inception) » — `AGENT-projet.md` §6 → le nom du dossier s'aligne sur le concept.
3. **Neutre FR/EN** (README bilingue) ; ne retombe pas sur la redondance « Mon-Projet/**_projet**/ » dans un clone.
4. **Décroché de l'outil** : ni `_assistant` (le marteau est interchangeable, et le script natif `assistant.ps1` crée ce dossier sans IA), ni `_artefact` (collision avec les artefacts de phase `01..05`), ni `_doc` (trop générique).

Le nom **reste configurable** (`meta_folder` dans `assistant.config`) — seul le défaut change.

## Périmètre (le renommage)

### À renommer (références vivantes)
- [x] `git mv _projet _meta` (l'histoire git est préservée)
- [x] Défaut `meta_folder = _meta` dans `install.ps1` / `install.sh` + les chemins générés (header du `connexions.md` d'un projet)
- [x] `assistant.ps1` / `assistant.sh` : défaut `_meta` + chemins
- [x] `.gitignore` : `_meta/registry/connexions.md`
- [x] `AGENT-projet.md` : titre §6 + table de routage + liens
- [x] `README.fr.md` / `README.en.md` : section inception + arborescence
- [x] `docs/install.md` : références
- [x] `_meta/README.md`, `_meta/backlog/README.md`, `_meta/logs/README.md`, `_meta/report/README.md`, `_meta/registry/README.md` : auto-références
- [x] `.opencode/agent/assistant-projet.md` + commandes `scan`/`statut` : références
- [x] `decisions.md` : **nouvelle ligne** (append-only) consignant le changement de défaut
- [x] Vérifications : parse PS 5.1 (install + assistant), `bash -n`, grep final « zéro `_projet` vivant »

### À NE PAS toucher (historique — réécrire = falsifier la trace)
- [x] `_meta/logs/2026-*.md` (journaux datés — état au moment où le dossier s'appelait `_projet`)
- [x] `_meta/backlog/WP-0001..0017` (tickets passés, décrivent l'état à leur date)
- [x] `decisions.md` : les lignes du 01/11 et 02/11 restent (elles décrivent la décision d'alors)
