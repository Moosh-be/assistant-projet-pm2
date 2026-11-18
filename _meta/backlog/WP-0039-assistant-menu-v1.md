---
wp_id: WP-0039
titre: "« assistant menu » v1 — commande d'état : les actions à envisager au vu de l'état du projet (dans ET hors opencode)"
type: livrable
statut: en-cours
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 17/11/2026 — verbatim : 'ajoutons une commande à l'assistant qui va fonctionner dans ou hors de opencode. /assistant-menu : elle affiche un menu des actions à envisager au vu de l'état du projet' + 'ajouter un ticket de type livrable qui \"assistant menu\" v1'"
créé: 2026-11-17
mis_a_jour: 2026-11-18
---

# WP-0039 — « assistant menu » v1 (livrable)

## Objectif

Une **seule commande, dans et hors opencode**, qui affiche **les actions à envisager au vu de l'état** :

- **dans un projet** : l'état (phase, gate, avancement, items `[À confirmer]`, rôles, WPs, git) + la liste des actions proposées, chacune avec sa commande.
- **hors projet** : le portefeuille (projets des racines + état du gate) + les projets « à pousser » + les actions de gestion.

## La commande

- **Natif** : `assistant menu` (moteur : `assistant.ps1` / `assistant.sh` — source unique, même règle que
  `statut`/`scan` : lecture déterministe, sans IA). Le menu statique (toutes les commandes) reste sur
  `?` / sans argument.
- **opencode** : slash-commande **`/assistant-menu`** (`.opencode/command/assistant-menu.md`) — pont mince :
  elle **appelle le natif**, l'agent présente le résultat + le raisonnement PM² (gate, WPs, mode C).
  Le nom `/assistant-menu` est **EXPLICITE de l'utilisateur** (verbatim 17/11) : exception au schéma
  `/ap-<nom>-<domaine>` (WP-0023). Si le schéma l'emporte plus tard : ajouter l'alias `/ap-menu-projet`
  (1 fichier en double), sans renommer.

## Critères de réalisation

- [x] `menu` natif (PS) : vue projet (état + actions proposées) + vue portefeuille (hors projet)
- [x] `menu` natif (bash) : parité PS (18/11 : parité vérifiée item par item — aConfirmer 59/59, WPs ouverts 23/23, git dirty 47/47, liste haute priorité limitée à 3)
- [x] `/assistant-menu` (opencode) : pont mince vers le natif + interprétation PM²
- [x] Champ `type` du ticket (format WP — `backlog/README.md`, valeur `livrable`)
- [ ] Validation terrain : `assistant menu` natif dans un projet ET hors projet + `/assistant-menu` dans opencode (relancer la session)
- [ ] Propagation bundle (refresh délibéré WP-0033) + `sync` des projets existants (le fichier de commande voyage via `deploy_harness`)
- [x] Docs : 1 ligne dans `README.fr.md` / `README.en.md` / `docs/install.md`

## Notes

- **État lu (déterministe, sans IA)** : frontmatter (`phase`, `gate_suivant`, rôles) + table
  d'avancement (section 3 : avancement + check du gate) + compte `[À confirmer]` (artefacts `0*` + racine)
  + WPs ouverts (si kit : `<meta>/backlog`, statuts `a-faire`/`en-cours`) + git (fichiers modifiés) +
  portefeuille (les racines de la config machine).
- **Règle du gate respectée** : le menu ne « propose » jamais un artefact de la phase suivante tant que
  le check du gate courant n'est pas vert (l'action proposée = terminer la phase courante / la checklist).
- **v2 (hors v1)** : factoriser la lecture d'état entre `statut` et `menu` ; état du gate = lire la
  checklist du bundle (items verts/rouges) ; registre d'inventaire machine (WP-0037) dans la vue portefeuille.
- **Artefact git (documenté, non bloquant — 18/11)** : le compte « fichiers modifiés » a ponctuellement
  affiché 66 au lieu de 47, **uniquement** dans des exécutions où `git status` courait sur un état
  transitoire (SynologyDrive : synchronisation réseau + détection de rename git). Anatomie : 47 = 14 `M`
  + 31 renames staged (1 ligne `RM` chacun) + 6 untracked ; quand 19 renames perdent la détection de
  similarité (seuil 50 %) dans l'état transitoire, chaque `RM` s'affiche `D`+`A` → 47 + 19 = 66.
  Preuves : 4 exécutions séquentielles + 15 paires de `git status` **concurrents** = toujours 47,
  listes byte-identiques entre PS et bash ; la valeur se réaligne toute seule à l'exécution suivante.
  → pas de bug moteur (même commande standard des deux côtés) ; rien à corriger, le compte reste un
  signal « commit/push dû », pas un audit.
