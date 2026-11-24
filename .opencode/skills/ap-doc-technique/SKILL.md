---
name: "DOC-TECHN.P — Doc technique"
description: "Remplir / relire le DOC-TECHN.P Doc technique (Transverse, sans gate direct) : questions d'entretien, discipline [À confirmer] + source, mise à jour frontmatter et phase. À utiliser quand on travaille ce document dans un projet assisté."
---

# DOC-TECHN.P — Doc technique (skill de remplissage)

> **1 skill = 1 document de méthode** (WP-0050). Le **template** (structure, champs) = source de
> vérité : `methode/Doc/fr/01 Livrables/DOC-TECHN.P-technique.md` (bundle). Ce skill = le **protocole de remplissage** de ce
> document ; le protocole commun (modes A/B/C, annonce de session, journal des échanges) :
> `AGENT-projet.md` §3 (bundle).

## Position

- **Phase** : Transverse · **Gate** : —
- **Dans le cycle** : DOC-DOCHS · DOC-TECHN · DOC-EMPLO · DOC-INSTA · DOC-ROLES · DOC-PRISE · DOC-SPECI · DOC-COMPS · DOC-PHILO · DOC-INTEG · DOC-COMPA
- **Dans le projet** : `01 Livrables/DOC-TECHN.P-technique.md` (1 projet = 1 folder ; les templates vivent dans le bundle).
  Absent du projet → le **créer depuis le template du bundle** (copie) ; présent → on
  **complète** (jamais d'écrasement).

## Questions de l'entretien (du template §2 — au fil de l'eau, quand les données viennent)

- Quelle audience technique lit cette doc (devs, mainteneurs, architectes) ? → frontmatter `audience`
- Quels sont les composants principaux et comment interagissent-ils ? → §1
- Quels choix techniques majeurs, et pourquoi (le « pourquoi » autant que le « quoi ») ? → §1
- Quels mécanismes internes méritent d'être documentés ? → §3
- Où sont les points d'extension pour un dev qui veut aller plus loin ? → §4
- Quel dépannage technique (logs, pannes connues) la doc doit-elle couvrir ? → §5

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
