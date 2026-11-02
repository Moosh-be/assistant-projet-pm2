---
wp_id: WP-0015
titre: "Fix YAML : les frontmatter avec « : » dans une valeur non quotée cassent la lecture (agent assistant-projet)"
statut: fait
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "erreur signalée sur GitHub le 01/11/2026 — « Error in user YAML: mapping values are not allowed in this context at line 1 column 87 » sur le frontmatter de l'agent"
créé: 2026-11-01
mis_a_jour: 2026-11-01
---

# WP-0015 — Frontmatter YAML invalides (deux-points dans les valeurs)

## Objectif

Une valeur de frontmatter contenant ` : ` (deux-points + espace) **sans guillemets** est invalide en YAML → l'outil qui lit le fichier (ici le parsing des agents par opencode) lève `mapping values are not allowed in this context`. Identifié via le badge d'erreur **sur GitHub** (le fichier était validé en local par l'agent mais pas par le parser strict de l'outil/forge).

## Critères de réalisation

- [x] `.opencode/agent/assistant-projet.md` : `description` quotée (cause de l'erreur affichée)
- [x] `_projet/fiche.md` : `mis_a_jour` quoté (même pattern, introduit par mes propres edits v2-v8)
- [x] Audit **complet** des frontmatter du repo avec un vrai parser YAML (paquet `yaml`) : 58 fichiers MD vérifiés, 0 erreur
- [x] Convention : les valeurs contenant ` : ` (ou `,`, `[`, `{`) sont **toujours** entre guillemets doubles (c'est déjà le cas des `titre` des WPs — c'est ce qui a protège le backlog)

## Notes

- Le checker de frontmatter (`node`, script ad-hoc dans la session) est à **fixer en `tools/frontmatter_check.js`** pour la CI / pré-push → à trancher (petit WP ou critère d'un WP existant).
- Le YAML tolère ` : ` si la valeur est quotée — c'est la **seule** convention fiable, pas d'exception à mémoriser.
