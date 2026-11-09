---
wp_id: WP-0029
titre: "Portefeuille : attributs (multiples, méthode, positionnement, master) + flag « assisté » par projet"
statut: a-faire
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 09/11/2026 — verbatim : « C'est dans ce portefeuille qu'on pourra peut-être mémoriser si le projet en question est assisté. Je peux avoir plusieurs portefeuille, je peux choisir une méthode de gestion distincte pour chaque portefeuille. Je peux me situer par rapport à ce portefeuille. Je peux pointer l'endroit de gestion master de ce portefeuille. »"
créé: 2026-11-09
mis_a_jour: 2026-11-09 (tracé)
---

# WP-0029 — Attributs d'un portefeuille + flag « assisté »

## Objectif
Pour chaque portefeuille (il peut y en avoir **plusieurs**), porter un jeu d'attributs :
la **méthode de gestion** (distincte par portefeuille), la **position de
l'utilisateur** par rapport au portefeuille, le **lieu de gestion « master »** — et, au
niveau projet, le **flag « assisté »** (le projet a-t-il un assistant / est-il branché sur
l'écosystème d'assistance).

## Critères de réalisation
- [ ] Plusieurs portefeuilles possibles (liste)
- [ ] Par portefeuille : méthode de gestion (distincte), position de l'utilisateur, pointeur « master »
- [ ] Par projet : flag « assisté » mémorisé **dans le portefeuille**
- [ ] Le flag « assisté » est exploitable par le routage (voir Contexte)

## Contexte — convergence avec le routage discuté le 09/11
Ce flag « assisté / non-assisté » est le même que la **déclaration de relation** discutée
en session (coordinateur local d'assistance) : un projet partagé (`.opencode` partagé,
contributeur sans fork) sur lequel l'utilisateur refuse de lier son assistant personnel
→ **opt-out**. La décision ne vit PAS dans le projet (étranger) mais dans l'index local.
Ce WP propose que ce flag trouve sa maison **dans la data du portefeuille**, lisible par
le coordinateur.

## Ouvert (à trancher)
- Le flag « assisté » : binaire (oui/non) ou des degrés (assisté / opt-out / non-détecté) ?
- Position de l'utilisateur : rôle libre ou vocabulaire (owner / contributeur / observateur) ?
- Le pointeur « master » : un chemin local, une URL (OpenProject ?), un outil ?

## Notes
- Série « portefeuille » (WP-0028 → 0032).
