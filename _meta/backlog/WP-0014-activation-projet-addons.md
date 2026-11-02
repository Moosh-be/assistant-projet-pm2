---
wp_id: WP-0014
titre: "Activation d'un projet : add-ons pertinents proposés selon les signaux du projet (pas à l'install)"
statut: a-faire
priorite: moyenne
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "discussion du 01/11/2026 — « je me pressais de découvrir les projets pour proposer les add-ons pertinents lors de l'install, mais ça pourrait se faire à l'activation de l'assistance d'un projet »"
créé: 2026-11-01
mis_a_jour: 2026-11-01
---

# WP-0014 — Activation d'un projet : add-ons pertinents (projet-aware)

## Objectif

Quand l'utilisateur **active l'assistance** sur un projet (« commence le projet X » / ajout du kit via `/scan`), l'agent propose les **connexions/add-ons pertinents** en s'appuyant sur les **signaux de CE projet** — pas une liste générique posée à l'install (qui ne sait pas dans quel projet tu vas travailler).

## Le mécanisme (spec)

- À l'activation, l'agent observe les signaux du projet (même liste que WP-0012 : `.git`, `package.json`, …) **et** la config transversale du registre (`registry/connexions.md`).
- Proposition ciblée, exemples :
  - `.git` + remote GitHub → « Brancher **GitHub Issue** ? (repo détecté : `owner/name`) »
  - OpenProject actif dans le registre → « Quel **numéro de projet** OpenProject pour X ? » (champ `op_id` du frontmatter)
  - SuperProductivity actif → « Créer un **projet SP** ? » (champ `sp_project`)
- L'agent **remplit le frontmatter** du projet avec les ids de connexion (`op_id`, `sp_project`) — c'est la liaison projet ↔ outil.
- Un « non » = aucune question de détail (règle du wizard, transposée).

## Critères de réalisation

- [ ] Point d'activation : dans `AGENT-projet.md` (étape d'ouverture de session) ou une commande `/activer` ? (à trancher)
- [ ] Mapping signal → add-on défini (tableau dans la doc de la commande)
- [ ] Frontmatter `op_id` / `sp_project` remplis à l'activation
- [ ] Tests : un projet `.git`+npm, un projet sans signal, un projet OpenProject connu

## Notes

- **Lien WP-0010** : la mécanique « lien de fabrication de la clé + fichier d'env » (faite dans l'install) se **réutilise** ici quand la connexion OpenProject est branchée pour un projet.
- **Lien WP-0013** : c'est la suite logique du découpage install (transversal) / activation (projet-aware).
- **Lien WP-0009** : le niveau 1 (signaux) suffit ; le scoring (niveau 2) affinera si besoin.
