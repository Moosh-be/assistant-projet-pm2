# _meta/backlog/ — 1 fichier = 1 package de travail (WP)

Chaque WP est un fichier Markdown : **frontmatter YAML = la partie « ticket »** (machine, transformable), **corps = la description lisible** (humain / Obsidian).

## Convention de nom

`WP-NNNN-slug-court.md` — `NNNN` = numéro stable (jamais réutilisé, même après annulation), `slug` = titre court en minuscules-traits.

## Format du frontmatter

| Champ | Valeurs | → export ticket |
|---|---|---|
| `wp_id` | `WP-NNNN` | clé interne (préfixe du sujet) |
| `titre` | texte libre | sujet du ticket |
| `statut` | `a-faire` · `en-cours` · `bloque` · `fait` · `annule` | workflow SP / statut OP |
| `priorite` | `haute` · `moyenne` · `basse` | priorité |
| `phase` | `Lancement` · `Planification` · `Execution` · `Suivi-Controle` · `Cloture` | milestone OP / tag SP |
| `roles` | liste de `sponsor` · `bm` · `cp` · `moe` | assigné / participants |
| `sp_id` | `""` ou id SuperProductivity | **rempli à l'export** (liaison) |
| `op_id` | `""` ou id OpenProject | **rempli à l'export** (liaison) |
| `source` | ex. `session du 26/10/2026` | traçabilité (mode C) |
| `créé` | `AAAA-MM-JJ` | création |
| `mis_a_jour` | `AAAA-MM-JJ` | dernière modification |

## Corps (recommandé)

- `## Objectif` — 1 à 2 phrases
- `## Critères de réalisation` — checklist `- [ ]` (nativement lisible Obsidian / SuperProductivity)
- `## Notes` — contexte, liens

## Règles

- **Granularité** : un WP = une tâche faisable, pas un livrable entier.
- **Changement de statut** → mettre à jour `mis_a_jour` (et `logs/` si décision notable).
- **Jamais de suppression** : un WP terminé reste `fait` ; un WP abandonné passe `annule`.
- **Export** : les futurs scripts (`tools/backlog_to_sp.py`, `tools/backlog_to_op.py`) n'écrivent dans le frontmatter que `sp_id` / `op_id` — jamais le reste.
