---
wp_id: WP-0028
titre: "Scope multi-niveaux : ajouter le niveau « portefeuille » (pf) au modèle (pgm/prj/prd/srv/vs)"
statut: a-faire
priorite: moyenne
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 09/11/2026 — verbatim : « mon assistant sera plus complet s'il prend en compte l'aspect portefeuille. On n'est pas obligé de gérer le portefeuille, mais d'identifier les informations qu'il contient et lié aux projets que j'ai. Donc pf ou portefeuille, vient s'ajouter au scope prj/projet et pgm/programme et prd/produit et srv/service et vs/valuestream »"
créé: 2026-11-09
mis_a_jour: 2026-11-09 (tracé)
---

# WP-0028 — Scope multi-niveaux : le niveau portefeuille (pf)

## Objectif
Élargir le modèle de scope de l'assistant au-delà du seul niveau « projet » :
représenter les niveaux **portefeuille (pf)**, **programme (pgm)**, **projet (prj)**,
**produit (prd)**, **service (srv)**, **value stream (vs)**. Le portefeuille est
**identifié, pas géré** : l'assistant repère les informations du portefeuille qui sont
liées aux projets de l'utilisateur, sans chercher à piloter le portefeuille.

## Critères de réalisation
- [ ] Le modèle de scope distingue les niveaux pf / pgm / prj / prd / srv / vs
- [ ] Un portefeuille est **identifié** (info liée aux projets) et **non géré**
- [ ] Le niveau `pf` s'ajoute sans casser le niveau `prj` (PM², projet-centrique)
- [ ] Cadré : périmètre du kit vs add-on (PM² n'est pas portefeuille-centrique)

## Ouvert (à trancher)
- Ces niveaux (pgm / prd / srv / vs) existent-ils déjà dans le modèle, ou sont-ils aussi à ajouter ?
- La notation `pf / pgm / prj / prd / srv / vs` : est-elle celle déjà utilisée dans 2ndB (à reprendre telle quelle) ?
- Où vivent ces niveaux : frontmatter `projet.md` ? un `portefeuille.md` ? un registre ?

## Notes
- Premier WP d'une série « portefeuille » (WP-0028 → 0032) tracée le 09/11.
- Rapprochement possible avec le projet 2ndB « assistant d'organisation » (→ WP-0032).
