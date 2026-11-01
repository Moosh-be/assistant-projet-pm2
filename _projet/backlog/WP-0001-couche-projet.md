---
wp_id: WP-0001
titre: "Créer la couche _projet/ (fiche, backlog, logs, report, registry) + format des WPs"
statut: fait
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 26/10/2026"
créé: 2026-10-26
mis_a_jour: 2026-10-26
---

# WP-0001 — Couche _projet/ + format des WPs

## Objectif

Donner au repo sa couche de développement de lui-même : fiche projet PM² du repo, backlog (1 WP = 1 fichier), logs, report, registry — et un format de WP universel, transformable en ticket.

## Critères de réalisation

- [x] `_projet/fiche.md` : fiche projet du repo (frontmatter rempli)
- [x] `_projet/backlog/README.md` : format des WPs défini (frontmatter universel + corps)
- [x] 1 WP d'exemple rempli (`WP-0001`, celui-ci)
- [x] `_projet/logs/`, `_projet/report/`, `_projet/registry/` créés avec un README d'intention
- [x] Routing mis à jour : `README.md`, `AGENT-projet.md`, agent `assistant-projet`, commande `/statut`

## Notes

- Les scripts d'export `backlog → SuperProductivity / OpenProject` feront l'objet de WPs distincts, une fois le format éprouvé sur quelques WPs réels.
- Inception assumée : ce WP est le premier « ticket » du repo, écrit avec le format du repo.
