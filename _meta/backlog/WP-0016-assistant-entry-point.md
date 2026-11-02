---
wp_id: WP-0016
titre: "assistant.ps1 / assistant.sh â€” entry-point natif (scan, statut, new, add sans IA ; commence = handoff opencode)"
statut: fait
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "dÃ©cision utilisateur du 02/11/2026 â€” Â« tout ce qui est faisable sans IA se fait sans IA ; pour trouver les repos, et pour ajouter l'espace _projet Ã  un projet, pas besoin d'IA Â» + choix Â« assistant.ps1 : /scan + /statut natifs Â»"
crÃ©Ã©: 2026-11-02
mis_a_jour: 2026-11-02
---

# WP-0016 â€” Entry-point natif `assistant.ps1` / `assistant.sh`

## Le principe

> **Tout ce qui est faisable sans IA, se fait sans IA.**

L'IA (l'agent opencode) n'intervient que pour **conduire** (remplir les templates, mode B), **Ã©couter** (mode C) et **dÃ©cider** (add-ons pertinents). Le reste est **dÃ©terministe** â†’ un **script natif sans dÃ©pendance** (`assistant.ps1` / `assistant.sh`), rapide, gratuit, scriptable, reproductible.

## Les commandes (split dÃ©terministe / raisonnement)

| Commande | Nature | Ce qu'elle fait |
|---|---|---|
| `scan` | **dÃ©terministe** | lit les racines du registre, classe chaque dossier (kit / partiel / plain), signaux lÃ©gers, **3 buckets** (assistÃ©s / pourraient / sans signal) + rÃ©sumÃ© |
| `statut <projet>` | **dÃ©terministe** | lit le frontmatter de `projet.md` + le tableau Â« Ã‰tat de la phase Â» (dus / faits / gate) |
| `new <nom>` | **dÃ©terministe** | crÃ©e `<racine>/<nom>/` + copie du kit + `_projet/` **neuf** + `projet.md` au nom |
| `add <dossier>` | **dÃ©terministe** | ajoute le kit Ã  un projet existant (copie fichiers gÃ©nÃ©riques + `_projet/` neuf), **jamais d'Ã©crasement** |
| `commence <nom>` | **handoff IA** | cd dans le projet + ouvre **opencode** (l'agent prend le relais) |
| `menu` / `?` | â€” | le menu (distingue dÃ©terministe / IA) |

Usage : `.\assistant.ps1 <cmd> [args]` (le `/` est optionnel : `scan` = `/scan`).

## La rÃ¨gle d'or de `add` / `new`

**Ne PAS copier les donnÃ©es d'inception du kit** (`_projet/fiche.md` du kit, `backlog/WP-*.md`, `logs/*`, `registry/connexions.md` local). On copie les fichiers **gÃ©nÃ©riques** (`projet.md`, `AGENT-projet.md`, `referentiel-templates-PM2.md`, `checklists/`, `docs/`, `tools/`, `opencode.json`, `.opencode/` sans `node_modules`, + les README de format `_projet/`) et on **crÃ©e** un `_projet/` neuf au nom du projet. **Jamais** d'Ã©crasement d'un fichier prÃ©-existant.

## CritÃ¨res de rÃ©alisation

- [x] `assistant.ps1` (ASCII, sans dÃ©pendance) : `scan`, `statut`, `new`, `add`, `commence`, `menu`
- [x] `assistant.sh` (bash, macOS/Linux) : mÃªmes commandes, comportement alignÃ©
- [x] `scan` testÃ© sur une **copie temp** (jamais sur les vrais projets) : buckets corrects
- [x] `new` + `add` testÃ©s sur un dossier temp : `_projet/` neuf (pas l'inception du kit), zÃ©ro Ã©crasement
- [x] Menu de fin d'install (`install.ps1` / `install.sh`) â†’ pointe sur `assistant.ps1 scan`
- [x] Commandes opencode `/scan` + `/statut` â†’ **appellent le script** (source unique, pas deux implÃ©mentations)
- [x] README fr/en + `docs/install.md` alignÃ©s
- [ ] **Validation terrain** (relance install + `scan`/`statut`/`new`/`add` sur machine rÃ©elle)

## Notes

- **Source unique** : la logique de scan/statut vit **une seule fois** (dans le script). Les commandes opencode `/scan` `/statut` l'appellent â€” pas de divergence.
- `commence` est le **seul** pont vers l'IA : aprÃ¨s le handoff, c'est l'agent qui conduit (mode B/C, add-ons pertinents â†’ WP-0014).
- DÃ©coupe issue de la longue discussion 01-02/11 (install = config transversale ; projet = agent ; dÃ©terministe = script).
