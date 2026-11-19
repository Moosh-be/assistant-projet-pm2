---
name: "PM2-10.P — Plan de mise en œuvre"
description: "Remplir / relire le PM2-10.P Plan de mise en œuvre (02 Planification, gate RfE) : questions d'entretien, discipline [À confirmer] + source, mise à jour frontmatter et phase. À utiliser quand on travaille ce document dans un projet assisté."
---

# PM2-10.P — Plan de mise en œuvre (skill de remplissage)

> **1 skill = 1 document de méthode** (WP-0050). Le **template** (structure, champs) = source de
> vérité : `methode/PM2/fr/02 Planification/PM2-10.P-plan-de-mise-en-œuvre-de-lactivité.md` (bundle). Ce skill = le **protocole de remplissage** de ce
> document ; le protocole commun (modes A/B/C, annonce de session, journal des échanges) :
> `AGENT-projet.md` §3 (bundle).

## Position

- **Phase** : 02 Planification · **Gate** : RfE
- **Dans le cycle** : PM2-04 · PM2-05 · PM2-06 · PM2-07 · PM2-08 · PM2-09 · PM2-10
- **Dans le projet** : `02 Planification/PM2-10.P-*.md` (1 projet = 1 folder ; les templates vivent dans le bundle).
  Absent du projet → le **créer depuis le template du bundle** (copie) ; présent → on
  **complète** (jamais d'écrasement).

## Questions de l'entretien (du template §2 — au fil de l'eau, quand les données viennent)

- Comment le déploiement est-il découpé (phases/lots) ?
- Quelles conditions techniques/orga pour chaque lot ?
- Qui accompagne les utilisateurs, comment ?
- Comment mesure-t-on que c'est adopté ?

## Protocole de remplissage

1. **Mode B** : une question à la fois, quand la donnée vient (pas un interrogatoire en bloc).
2. **Ne jamais inventer** : donnée absente → on la demande ; donnée déduite → `[À confirmer]` + sa `source`.
3. **À chaque remplissage** : frontmatter de l'artefact (`statut` · `date_maj` · `source`) +
   sa section « Statut de remplissage ».
4. **La phase** : tableau §3 de `projet.md` (artefacts faits / dus) — mis à jour par l'assistant.
5. **Mode C** : une donnée qui tombe dans un échange → la proposer dans ce document
   (inscription avec sa `source` : « échange du JJ/MM »).

6. **Anti-surcharge** : proposer le statut **envisagé / utilisé / ignoré** (tableau §4 de `projet.md`) — aucun plan n'est créé par défaut.

## Gate

- Cet artefact alimente la checklist **RfE** (PM2-27) : `checklists/gate-RfE.md` (bundle).
- Règle du gate : tant que la checklist n'est pas verte, **aucun artefact de la phase suivante**.
