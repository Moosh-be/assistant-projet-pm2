---
wp_id: WP-0002
titre: "Commande démo : 1 commande → projet bidon + plan de découverte de l'outil"
statut: a-faire
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 26/10/2026 — scénario utilisateur lu dans le README"
créé: 2026-10-26
mis_a_jour: 2026-10-26
---

# WP-0002 — Commande démo (projet bidon + plan de découverte)

## Objectif

Faire vivre au lecteur du README **l'expérience complète du kit en une commande** : créer un projet bidon, pré-rempli de données fictives, qui propose un **plan de découverte** de l'outil — pour comprendre ce que ça fait sans rien risquer.

## Le scénario (verbatim)

> « Je lis le readme, je veux tester pour comprendre ce que ça fait. En une commande, crée un projet bidon qui propose un plan de découverte de l'outil. »

## Critères de réalisation

- [ ] Une commande unique (ex. `/demo` ou « démarre le projet bidon ») dans un clone vierge du kit
- [ ] L'assistant **clone le template** en projet d'exemple (ex. `demo/` ou `Exemple-Decouverte`) — jamais de remplissage dans le repo template
- [ ] Le projet bidon est **pré-rempli de données fictives** (fiche, 1 artefact par phase, rôles inventés, gate partiel)
- [ ] Le projet contient un **plan de découverte** : parcours guidé — quoi essayer d'abord, quel artefact remplir en mode B (entretien), quoi observer en mode C (écoute passive), quel gate franchir
- [ ] Le plan de découverte est le **premier document annoncé** à l'ouverture de session sur le projet bidon
- [ ] Aucune dépendance externe (pas de SP/OP requis pour la démo)
- [ ] Documenté dans le `README.md` (section Quick start) et `docs/prise-en-main.md`

## Notes

- Ce WP est l'**onboarding** du kit : c'est lui qui doit rendre le README honnête (« ask: start the project <Project> »).
- Le projet bidon est un **fork du template** (règle du kit : 1 projet = 1 folder, le template n'est jamais rempli).
- Le plan de découverte peut vivre dans `_projet/`-style du projet bidon ou comme artefact dédié du projet (`plan-decouverte.md`).
- Après implémentation : exécuter la commande en réel et valider que l'expérience du scénario est respectée bout en bout.
