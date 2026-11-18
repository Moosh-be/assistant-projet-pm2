---
description: Les actions à envisager AU VU DE L'ÉTAT du projet (ou du portefeuille si hors projet) — WP-0039.
agent: assistant-projet
---

Donne les **actions à envisager au vu de l'état** (WP-0039) : le script natif lit l'état, l'agent l'interprète en PM² et propose LA suite.

> **Source unique (WP-0016)** : la lecture d'état est déterministe → elle vit **dans le script natif** `assistant.ps1` / `assistant.sh` (commande `menu`). Cette commande l'**appelle** : l'IA ne relit pas les fichiers en parallèle, elle s'appuie sur le résultat et ajoute le raisonnement PM².

## 1. Exécuter le script natif

- Windows : `powershell -NoProfile -ExecutionPolicy Bypass -File .\assistant.ps1 menu`
- macOS / Linux : `./assistant.sh menu`

→ **dans un projet** : l'état (phase, gate, avancement, `[À confirmer]`, rôles, WPs, git) + les actions proposées.
→ **hors projet** : le portefeuille (projets des racines + état du gate par projet) + les projets à pousser.

## 2. Le raisonnement PM² que le script ne fait pas (l'IA)

1. **Le gate** : l'état de la checklist du gate (bundle : `methode/PM2/fr/checklists/gate-<RfP|RfE|RfC>.md`) — la règle du gate : tant que la checklist PM2-27 n'est pas verte, aucun artefact de la phase suivante.
2. **Le prochain artefact dû** (ordre du `methode/PM2/fr/referentiel-templates-PM2.md`) + la question qui le débloque.
3. **Les propositions mode C en attente de validation** (si accumulées dans la session).

## 3. Terminer par

- **Une seule** proposition d'action concrète (celle qui fait avancer le gate le plus vite).
- Si le gate est vert : proposer le passage (`gate_suivant` → phase + 1, à valider).

$ARGUMENTS
