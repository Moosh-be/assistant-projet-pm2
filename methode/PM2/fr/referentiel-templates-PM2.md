# Référentiel des templates PM² (v3.0.1) — catalogue du bundle

> **Source** : catalogue standard PM² v3.0.1 (artefacts de gestion de projet).
> Chaque template a un **code** (PM2-XX), une **phase**, un **gate** associé, et un **fichier Markdown** dans ce bundle.
> Les **forks** (ex. fork RTBF) enrichissent chaque champ avec leurs propres traductions/adaptations des templates d'origine.

## Catalogue (22 artefacts)

| Code | Artefact | Phase | Gate | Fichier du bundle |
|---|---|---|---|---|
| PM2-01.I | Demande de lancement de projet | Lancement | → RfP | `01 Lancement/PM2-01.I-*.md` |
| PM2-02.I | Cas d'usage (business case) | Lancement | → RfP | `01 Lancement/PM2-02.I-*.md` |
| PM2-03.I | Charte du projet | Lancement | → RfP | `01 Lancement/PM2-03.I-*.md` |
| PM2-04.P | Manuel du projet | Planification | → RfE | `02 Planification/PM2-04.P-*.md` |
| PM2-05.P | Matrice des parties prenantes | Planification | → RfE | `02 Planification/PM2-05.P-*.md` |
| PM2-06.P | Plan de travail | Planification | → RfE | `02 Planification/PM2-06.P-*.md` |
| PM2-07.P | Plan d'externalisation | Planification | → RfE | `02 Planification/PM2-07.P-*.md` |
| PM2-08.P | Plan d'acceptation des livrables | Planification | → RfE | `02 Planification/PM2-08.P-*.md` |
| PM2-09.P | Plan de transition | Planification | → RfE | `02 Planification/PM2-09.P-*.md` |
| PM2-10.P | Plan de mise en œuvre | Planification | → RfE | `02 Planification/PM2-10.P-*.md` |
| PM2-11.P | Plan de gestion des exigences | Planification / Suivi | — | `02 Planification/PM2-11.P-*.md` |
| PM2-12.P | Plan de gestion des changements | Planification / Suivi | — | `02 Planification/PM2-12.P-*.md` |
| PM2-13.P | Plan de gestion des risques | Planification / Suivi | — | `02 Planification/PM2-13.P-*.md` |
| PM2-14.P | Plan de gestion des problèmes | Planification / Suivi | — | `02 Planification/PM2-14.P-*.md` |
| PM2-15.P | Plan de gestion de la qualité | Planification / Suivi | — | `02 Planification/PM2-15.P-*.md` |
| PM2-16.P | Plan de gestion de la communication | Planification / Suivi | — | `02 Planification/PM2-16.P-*.md` |
| PM2-18.E | Procès-verbal de réunion | Exécution | — | `03 Exécution/PM2-18.E-*.md` |
| PM2-19.E | Rapport d'état de projet | Suivi & Contrôle | — | `04 Suivi-Controle/PM2-19.E-*.md` |
| PM2-21.E | Demande de modification | Suivi & Contrôle | — | `04 Suivi-Controle/PM2-21.E-*.md` |
| PM2-22.E | Rapport d'état (scorecard) | Suivi & Contrôle | — | `04 Suivi-Controle/PM2-22.E-*.md` |
| PM2-27.MC | Liste de contrôle de sortie de phase | Suivi & Contrôle | RfP/RfE/RfC | `04 Suivi-Controle/PM2-27.MC-*.md` |
| PM2-33.C | Rapport de fin de projet | Clôture | → RfC | `05 Cloture/PM2-33.C-*.md` |

## Lecture
- **Le cycle est couvert** : RfP (01/02/03) · RfE (04-16) · Exécution (18) · M&C (19/21/22/27) · RfC (33).
- **Cœur du corpus** = les **plans de gestion** (04→16) : risques, changements, communication, qualité, exigences, problèmes, transition, externalisation… → c'est là que l'assistant doit le plus **questionner** (et proposer « envisagé / ignoré / utilisé » — anti-surcharge).
- **Le PM2-27 (checklist de sortie de phase)** = **le pilote des gates** : c'est la checklist qui valide RfP/RfE/RfC → elle bloque/passe la phase.

## Régénérer les squelettes
```
python tools/gen_templates.py
```
(Le script régénère les 22 fichiers Markdown à partir du catalogue — utile après modification des sections/questions.)
