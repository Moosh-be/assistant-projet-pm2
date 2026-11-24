---
name: "DOC-INSTA.P — Installation & maintenance"
description: "Remplir / relire le DOC-INSTA.P Installation & maintenance (Transverse, sans gate direct) : questions d'entretien, discipline [À confirmer] + source, mise à jour frontmatter et phase. À utiliser quand on travaille ce document dans un projet assisté."
---

# DOC-INSTA.P — Installation & maintenance (skill de remplissage)

> **1 skill = 1 document de méthode** (WP-0050). Le **template** (structure, champs) = source de
> vérité : `methode/Doc/fr/01 Livrables/DOC-INSTA.P-installation-maintenance.md` (bundle). Ce skill = le **protocole de remplissage** de ce
> document ; le protocole commun (modes A/B/C, annonce de session, journal des échanges) :
> `AGENT-projet.md` §3 (bundle).

## Position

- **Phase** : Transverse · **Gate** : —
- **Dans le cycle** : DOC-DOCHS · DOC-TECHN · DOC-EMPLO · DOC-INSTA · DOC-ROLES · DOC-PRISE · DOC-SPECI · DOC-COMPS · DOC-PHILO · DOC-INTEG · DOC-COMPA
- **Dans le projet** : `01 Livrables/DOC-INSTA.P-installation-maintenance.md` (1 projet = 1 folder ; les templates vivent dans le bundle).
  Absent du projet → le **créer depuis le template du bundle** (copie) ; présent → on
  **complète** (jamais d'écrasement).

## Questions de l'entretien (du template §2 — au fil de l'eau, quand les données viennent)

- Qui installe et exploite (profil, environnement, plateformes) ? → §1
- Quels prérequis, et comment les vérifier ? → §1
- Quel est le parcours d'installation, et quoi tester pour prouver qu'elle est bonne ? → §2
- Quelle première configuration, et dans quel ordre ? → §3
- Quelles sont les opérations courantes (màj, sauvegarde/restauration, logs) ? → §4
- Comment surveiller la santé, et comment faire passer une version majeure ? → §5

## Protocole de remplissage

1. **Mode B** : une question à la fois, quand la donnée vient (pas un interrogatoire en bloc).
2. **Ne jamais inventer** : donnée absente → on la demande ; donnée déduite → `[À confirmer]` + sa `source`.
3. **À chaque remplissage** : frontmatter de l'artefact (`statut` · `date_maj` · `source`) +
   sa section « Statut de remplissage ».
4. **La phase** : tableau §3 de `projet.md` (artefacts faits / dus) — mis à jour par l'assistant.
5. **Mode C** : une donnée qui tombe dans un échange → la proposer dans ce document
   (inscription avec sa `source` : « échange du JJ/MM »).

## Gate

- Pas de gate direct (document de conduite / de suivi).
