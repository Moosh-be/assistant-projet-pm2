---
wp_id: WP-0046
titre: "Liste des outils d'interface — JIRA · OpenProject · SuperProductivity · Ivanti · …"
type: livrable
statut: a-faire
priorite: moyenne
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 18/11/2026 — verbatim : 'Ensuite l'outil propose la liste des outils avec lequel il peut s'interfacer (JIRA, Openproject, SuperProductivity, Ivanti, …)'"
créé: 2026-11-18
mis_a_jour: 2026-11-18
---

# WP-0046 — Les outils d'interface

## Objectif

L'outil propose la **liste des outils avec lesquels il peut s'interfacer** ; l'utilisateur
sélectionne ce qui s'applique à sa machine → la config s'adapte.

## Critères de réalisation

- [ ] À l'onboarding : **proposer la liste des outils** (sélection persistée dans la config)
- [ ] **Déjà implémentés** : SuperProductivity (1 WP = 1 tâche, `sp_id`) · OpenProject (artefacts = docs à importer, WPs = packages de travail, `op_id`) · GitHub/GitLab Issues (ticketisation du backlog)
- [ ] **À venir** (à préciser avec l'utilisateur) : JIRA · Ivanti · …
- [ ] Chaque outil sélectionné → connexions projet (frontmatter `sp_project` / `op_id` + les champs à venir) + détail dans `docs/guide.md` §5
- [ ] Parité PS + bash, fichiers en LF, tests sandbox

## Notes

- Les connexions **existantes** ne changent pas — le WP rend la liste **proposée à l'onboarding**
  plutôt qu'implémentée à l'aveugle.
- Étape 6 du flux onboarding `docs/comment-commencer.md` (WP-0042).
