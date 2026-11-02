---
wp_id: WP-0016
titre: "assistant.ps1 / assistant.sh — entry-point natif (scan, statut, new, add sans IA ; commence = handoff opencode)"
statut: en-cours
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "décision utilisateur du 02/11/2026 — « tout ce qui est faisable sans IA se fait sans IA ; pour trouver les repos, et pour ajouter l'espace _projet à un projet, pas besoin d'IA » + choix « assistant.ps1 : /scan + /statut natifs »"
créé: 2026-11-02
mis_a_jour: 2026-11-02
---

# WP-0016 — Entry-point natif `assistant.ps1` / `assistant.sh`

## Le principe

> **Tout ce qui est faisable sans IA, se fait sans IA.**

L'IA (l'agent opencode) n'intervient que pour **conduire** (remplir les templates, mode B), **écouter** (mode C) et **décider** (add-ons pertinents). Le reste est **déterministe** → un **script natif sans dépendance** (`assistant.ps1` / `assistant.sh`), rapide, gratuit, scriptable, reproductible.

## Les commandes (split déterministe / raisonnement)

| Commande | Nature | Ce qu'elle fait |
|---|---|---|
| `scan` | **déterministe** | lit les racines du registre, classe chaque dossier (kit / partiel / plain), signaux légers, **3 buckets** (assistés / pourraient / sans signal) + résumé |
| `statut <projet>` | **déterministe** | lit le frontmatter de `projet.md` + le tableau « État de la phase » (dus / faits / gate) |
| `new <nom>` | **déterministe** | crée `<racine>/<nom>/` + copie du kit + `_projet/` **neuf** + `projet.md` au nom |
| `add <dossier>` | **déterministe** | ajoute le kit à un projet existant (copie fichiers génériques + `_projet/` neuf), **jamais d'écrasement** |
| `commence <nom>` | **handoff IA** | cd dans le projet + ouvre **opencode** (l'agent prend le relais) |
| `menu` / `?` | — | le menu (distingue déterministe / IA) |

Usage : `.\assistant.ps1 <cmd> [args]` (le `/` est optionnel : `scan` = `/scan`).

## La règle d'or de `add` / `new`

**Ne PAS copier les données d'inception du kit** (`_projet/fiche.md` du kit, `backlog/WP-*.md`, `logs/*`, `registry/connexions.md` local). On copie les fichiers **génériques** (`projet.md`, `AGENT-projet.md`, `referentiel-templates-PM2.md`, `checklists/`, `docs/`, `tools/`, `opencode.json`, `.opencode/` sans `node_modules`, + les README de format `_projet/`) et on **crée** un `_projet/` neuf au nom du projet. **Jamais** d'écrasement d'un fichier pré-existant.

## Critères de réalisation

- [x] `assistant.ps1` (ASCII, sans dépendance) : `scan`, `statut`, `new`, `add`, `commence`, `menu`
- [x] `assistant.sh` (bash, macOS/Linux) : mêmes commandes, comportement aligné
- [x] `scan` testé sur une **copie temp** (jamais sur les vrais projets) : buckets corrects
- [x] `new` + `add` testés sur un dossier temp : `_projet/` neuf (pas l'inception du kit), zéro écrasement
- [x] Menu de fin d'install (`install.ps1` / `install.sh`) → pointe sur `assistant.ps1 scan`
- [x] Commandes opencode `/scan` + `/statut` → **appellent le script** (source unique, pas deux implémentations)
- [x] README fr/en + `docs/install.md` alignés
- [ ] **Validation terrain** (relance install + `scan`/`statut`/`new`/`add` sur machine réelle)

## Notes

- **Source unique** : la logique de scan/statut vit **une seule fois** (dans le script). Les commandes opencode `/scan` `/statut` l'appellent — pas de divergence.
- `commence` est le **seul** pont vers l'IA : après le handoff, c'est l'agent qui conduit (mode B/C, add-ons pertinents → WP-0014).
- Découpe issue de la longue discussion 01-02/11 (install = config transversale ; projet = agent ; déterministe = script).
