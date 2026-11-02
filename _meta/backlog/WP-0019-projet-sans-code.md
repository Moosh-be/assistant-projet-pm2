---
wp_id: WP-0019
titre: "Projet sans code : un repo peut ne contenir que _meta (source de verite = fiche.md)"
statut: en-cours
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 02/11/2026 — verbatim : 'mon projet n'est pas forcément (et ca devrai même être la norme) un projet de code, il est imaginable que mon repo ne contienne que _meta'"
créé: 2026-11-02
mis_a_jour: 2026-11-02
---

# WP-0019 — Un projet n'est PAS forcément un projet de code

## Contexte

Le kit traitait un projet comme un dossier de **code** + le kit posé dessus :
- `scan` ne le classait « assisté » que si `projet.md` + `AGENT-projet.md` existaient ; sinon signaux **code** (`.git`, `package.json`, `src/`…).
- `statut` / `commence` (via `Find-Project`) n'existaient qu'avec un `projet.md`.
- Conséquence : un repo ne contenant **que `_meta/`** (projet documentaire — qui devrait être la **norme**) était classé « sans signal » et invisible.

**Position verrouillée** (utilisateur) : un repo peut légitimement ne contenir que `_meta/`. Le kit doit
traiter ce cas comme **premier**, pas comme anomalie.

## Décision

1. **`_meta/fiche.md` est une source de vérité de statut** : `statut` lit le frontmatter de `projet.md`
   **ou** de `_meta/fiche.md` (les champs sont identiques : `phase`, `gate_suivant`, rôles, `sp_project`, `op_id`)
   + la table `## 3. État de la phase` (présente dans les deux). Source lue affichée.
2. **`_meta/` est un signal de scan** : un dossier sans `projet.md`/`AGENT-projet.md` mais avec `<meta>/`
   est classé **[À compléter]** (kit partiel — le dossier méta existe déjà, le reste du kit est à ajouter via `add`).
   Un dossier avec `<meta>/` + `projet.md` = **assisté**.
3. **`commence` fonctionne sans `projet.md`** (même `Find-Project` élargi) : l'agent ouvre dans le projet,
   lit `AGENT-projet.md` s'il existe, sinon `_meta/fiche.md` (le mode B s'appuie alors sur la fiche).
4. **`assistant new <nom> -doc`** : crée un projet **minimal** — `<racine>/<nom>/<meta>/` (fiche + squelette),
   **sans** copier le kit (`projet.md`, `checklists/`, `01..05/`, `.opencode/`…). Si le kit complet est plus
   tard utile : `assistant add <nom>` (zéro écrasement, il compléte sans toucher au `_meta` existant).

## Périmètre

- [x] `assistant.ps1` : `Get-Signaux` (+ `_meta/`) · `Find-Project` (ou `_meta/fiche.md`) · `Cmd-Statut`
      (source = `projet.md` sinon `_meta/fiche.md`, affiche la source lue) · `Cmd-New -doc` · menu · dispatch
- [x] `assistant.sh` : idem (`get_signaux`, `find_project`, `cmd_statut`, `cmd_new -doc`, menu, dispatch)
- [x] Tests sandbox : `new -doc` (PS + bash) → scan classe « à compléter » → `statut` lit la fiche → `commence` résout
- [x] Docs : menu + `docs/install.md` (un mot sur `-doc`)
- [x] `decisions.md` : 1 ligne
- [ ] Validation terrain

## Notes

- Pas de migration rétroactive : les dossiers existants ne sont pas touchés.
- Le frontmatter de `fiche.md` et de `projet.md` partage volontairement les mêmes clés
  (`projet`, `phase`, `gate_suivant`, `sponsor`, `bm`, `cp`, `moe`, `sp_project`, `op_id`) — c'est ce qui
  rend `fiche.md` lisible par les mêmes fonctions sans doublon de code.

## Implémentation (02/11)

- **PS** : helper `Test-ProjectDir` (`projet.md` ou `<meta>/fiche.md`) — un simple
  `Test-Path x -or Test-Path y` **échoue** : `-or` est absorbé comme paramètre de `Test-Path` (bug parseur/astuce).
- **`new -doc`** : seul `<meta>/` est créé (fiche depuis le template + squelette `backlog`/`logs`/`report`/`registry`) —
  **pas** de `projet.md`, **pas** de kit (`checklists/`, `01..05/`, `.opencode/`…). Le message indique l'étape suivante :
  `assistant add <nom>` (zéro écrasement, `_meta/` conservé) quand le kit complet devient utile.
- **Scan** : `<meta>/` est un signal ; un dossier avec `<meta>/` mais sans kit = **[À compléter] — « projet sans code
  (ne contient que _meta) → assistant add »** ; le détail différencie : kit partiel classique vs projet sans code.
- **`statut`** : `projet.md` sinon `<meta>/fiche.md`, avec la ligne `(source : …)` ; frontmatter + table `## 3.` lus
  dans la même source.
- **Bugs trouvés en test** : (1) parenthèse `-or` dans `Test-Path` (voir ci-dessus) ; (2) `$date` définie dans
  `copy_kit` et non dans `cmd_new` → ajoutée dans la branche `-doc` bash.
- **Tests sandbox PS + bash** (E2E du cycle) : `new -doc` (fiche créée, aucun kit) → `scan` = « à compléter / projet
  sans code » → `statut` = `(source : _meta/fiche.md)` + phase/gate → `add` = kit complété, `_meta/` ignoré
  (non écrasé) → `scan` = « assisté ». Tout vert sur les deux plateformes.
