---
name: "PM2-27.MC — Liste de contrôle de sortie de phase"
description: "Remplir / relire le PM2-27.MC Liste de contrôle de sortie de phase (04 Suivi-Controle, gate RfP/RfE/RfC) : questions d'entretien, discipline [À confirmer] + source, mise à jour frontmatter et phase. À utiliser quand on travaille ce document dans un projet assisté."
---

# PM2-27.MC — Liste de contrôle de sortie de phase (skill de remplissage)

> **1 skill = 1 document de méthode** (WP-0050). Le **template** (structure, champs) = source de
> vérité : `methode/PM2/fr/04 Suivi-Controle/PM2-27.MC-liste-de-contrôle-de-sortie-de-phase.md` (bundle). Ce skill = le **protocole de remplissage** de ce
> document ; le protocole commun (modes A/B/C, annonce de session, journal des échanges) :
> `AGENT-projet.md` §3 (bundle).

## Position

- **Phase** : 04 Suivi-Controle · **Gate** : RfP/RfE/RfC
- **Dans le cycle** : PM2-19 · PM2-21 · PM2-22 · PM2-27 — c'est LE pilote des 3 gates
- **Dans le projet** : `04 Suivi-Controle/PM2-27.MC-*.md` (1 projet = 1 folder ; les templates vivent dans le bundle).
  Absent du projet → le **créer depuis le template du bundle** (copie) ; présent → on
  **complète** (jamais d'écrasement).

## Questions de l'entretien (du template §2 — au fil de l'eau, quand les données viennent)

- Quel artefact manque pour valider ce gate ?
- Quelle condition de passage n'est pas encore remplie ?

## Protocole de remplissage

1. **Mode B** : une question à la fois, quand la donnée vient (pas un interrogatoire en bloc).
2. **Ne jamais inventer** : donnée absente → on la demande ; donnée déduite → `[À confirmer]` + sa `source`.
3. **À chaque remplissage** : frontmatter de l'artefact (`statut` · `date_maj` · `source`) +
   sa section « Statut de remplissage ».
4. **La phase** : tableau §3 de `projet.md` (artefacts faits / dus) — mis à jour par l'assistant.
5. **Mode C** : une donnée qui tombe dans un échange → la proposer dans ce document
   (inscription avec sa `source` : « échange du JJ/MM »).

## Gate

- Ce document **est** la checklist de sortie de phase (PM2-27) — le **pilote des
  gates** : une checklist par gate (`checklists/gate-RfP.md` / `gate-RfE.md` /
  `gate-RfC.md`). Elle **bloque ou fait passer** la phase : items tous verts →
  proposer le passage (`gate_suivant` → phase + 1 dans le frontmatter de `projet.md`).
