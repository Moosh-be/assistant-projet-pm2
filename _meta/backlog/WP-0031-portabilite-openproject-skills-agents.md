---
wp_id: WP-0031
titre: "Portabilité OpenProject : skills/agents réutilisables sans l'assistant"
statut: a-faire
priorite: moyenne
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 09/11/2026 — verbatim : « Idéalement les skill et agent à développer dans le cadre de cet assistant seront compatible pour une utilisation par openproject (sans avoir mon assistant) »"
créé: 2026-11-09
mis_a_jour: 2026-11-09 (tracé)
---

# WP-0031 — Portabilité OpenProject des skills/agents

## Objectif
Que les **skills et agents** développés pour cet assistant soient **compatibles pour une
utilisation par OpenProject**, sans l'assistant personnel. C'est une contrainte de
**portabilité** à intégrer dès la conception : un skill/agent = une unité autonome,
transportable.

## Critères de réalisation
- [ ] Un skill/agent est **autonome** (pas de dépendance dure à l'assistant / au poste)
- [ ] Format exportable vers OpenProject (doc / skill importable)
- [ ] Le kit (fabrique de nœuds) produit des skills/agents portables par construction

## Ouvert (à trancher)
- Quel format OpenProject attend-il pour un skill/agent (doc ? prompt ? workflow) ?
- Le lien avec la connexion OpenProject existante (`op_id`, export `backlog/`) ?
- Le rapprochement avec le projet 2ndB « assistant d'organisation » (→ WP-0032) ?

## Notes
- Série « portefeuille » (WP-0028 → 0032). Relie au concept « kit = fabrique de nœuds ».
