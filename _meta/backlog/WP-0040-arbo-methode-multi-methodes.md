---
wp_id: WP-0040
titre: "Multi-méthodes : arborescence methode/<M>/<lang>/ — la racine du bundle ne contient plus que le kit (PM2 FR → methode/PM2/fr/)"
type: livrable
statut: fait
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 17/11/2026 — verbatim : 'il faut aussi remettre de l'ordre dans le repo je vois à la racine 01 Lancement 02 . 03 . 04 . 05 cloture, ca dois aller dans le rep methode/PM2/fr parce qu'on va ajouter PfM2 pour la gestion du portefeuille, PMFLEX, et laisser la place pour SaFE, SCRUM, PRINCE2, PMP, LEAN, LEAN6SIGMA, ...'"
créé: 2026-11-17
mis_a_jour: 2026-11-17
---

# WP-0040 — Arborescence multi-méthodes `methode/<M>/<lang>/` (livrable)

## Objectif

La **racine du bundle ne contient que le kit** (moteur, docs, outillage, data du projet assistant).
Chaque **méthode** vit dans `methode/<METHODE>/<langue>/` :

```
methode/
├── PM2/fr/            ← PM² français (déplacé le 17/11, git mv)
│   ├── 01 Lancement/ … 05 Cloture/   (templates PM2-01…33 ; 01 = pré-rempli pour le RfP du kit)
│   ├── checklists/          (gate-RfP/RfE/RfC, role-*)
│   └── referentiel-templates-PM2.md
├── PfM2/fr/           ← à venir : gestion du portefeuille
├── PMFLEX/fr/         ← à venir
└── (SAFe, Scrum, PRINCE2, PMP, Lean, Lean6Sigma…) ← place réservée
```

**Une méthode = la trame de la data d'un projet** (les dossiers de phase, les gates, les templates)
+ l'outillage qui va avec. Le frontmatter `methode:` du projet (ex. `PM2`) est déjà le hook.

## Ce qui bouge / ce qui reste

| Move (17/11, `git mv`) | Reste à la racine (et pourquoi) |
|---|---|
| `01 Lancement`…`05 Cloture` → `methode/PM2/fr/` | `AGENT-projet.md` — l'`opencode.json` de **chaque projet** le pointe par **chemin absolu** (le déplacer = casser tous les projets) ; c'est la note de routage, transversale aux méthodes |
| `checklists/` → `methode/PM2/fr/checklists/` | `projet.md` (manifeste du projet assistant) · `_meta/` (inception) · `assistant.ps1/sh` + `install.*` (moteur) · `tools/` (lanceurs, templates génériques, fiche-projet) · `docs/` (mode d'emploi du kit) · `.opencode/` (harness) · `versions/` |

**Non touché** : les projets (minces) existants — leurs `01..05` restent **à la racine du projet**
(c'est leur data) ; `new`/`add` créent ces dossiers **à la racine du projet** à partir des noms
lus dans `methode/PM2/fr/` (source unique des noms de phases).

## Critères de réalisation

- [x] Move `01..05` + `checklists/` + `referentiel-templates-PM2.md` → `methode/PM2/fr/` (git mv, histoire conservée)
- [x] Références relatives dans les templates PM2-xx : `checklists/gate-*` → `../checklists/gate-*` (sœurs de dossier)
- [x] Moteur PS : `Deploy-Kit` lit les noms de phases dans `methode/PM2/fr/` (+ `menu` scanne les `0*` de la racine ET de `methode/`)
- [x] Moteur bash : parité
- [x] Références mises à jour : `AGENT-projet.md` (table de routage), `fiche.md`, `docs/prise-en-main.md`, `.opencode/command/ap-statut-projet.md`, `.opencode/agent/assistant-projet.md`, `README.fr.md` / `README.en.md` (arbre), `docs/install.md`
- [x] Test : `new` (sandbox) → les dossiers de phase du projet neuf sont bien ceux de `methode/PM2/fr/` ; `statut`/`menu` verts sur le kit (artefacts sous `methode/PM2/fr/0*`)
- [x] `decisions.md` : 1 ligne (arborescence multi-méthodes)

## Notes

- **Convention de nom** : `methode` en ASCII (pas « méthode ») — cohérent avec `04 Suivi-Controle`,
  `05 Cloture` (convention du repo). `<M>` tel que l'utilisateur l'écrit (PM2, PfM2, PMFLEX, SAFe, …).
- **v2 (hors v1)** : descripteur de méthode par dossier (ex. `methode/PM2/fr/methode.md` : trame de
  data, gates, rôles) + le frontmatter `methode:` du projet pilote `new`/`statut`/`menu` (aujourd'hui
  PM2-FR est la seule méthode et le défaut) ; `tools/templates/fiche-projet.md` par méthode.
- **PfM2** (portefeuille) : sera la première méthode à joindre PM2 — voir la série WP-0028→0032
  (scope multi-niveaux, attributs, connecteurs de synchro).
