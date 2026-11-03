---
description: Statut du projet et des tickets (artefacts dus, gates, tâches SuperProductivity/OpenProject).
agent: assistant-projet
---

Donne le statut du projet selon le protocole d'ouverture de session d'`AGENT-projet.md`.

> **Source unique (WP-0016)** : la lecture du frontmatter + du tableau d'avancement est déterministe → elle vit **dans le script natif** `assistant.ps1` / `assistant.sh`. Cette commande l'**appelle** : l'IA ne relit pas les fichiers en parallèle, elle s'appuie sur le résultat et ajoute le raisonnement PM² (gate, WPs, mode C).

## 1. Exécuter le script natif

- Windows : `powershell -NoProfile -ExecutionPolicy Bypass -File .\assistant.ps1 statut $ARGUMENTS`
- macOS / Linux : `./assistant.sh statut $ARGUMENTS`

(Sans argument : le script prend **le projet du dossier courant** — c'est le cas normal : la commande est lancée DEPUIS le projet. L'appeler avec un nom cherche dans le kit, le dossier courant et les racines.)

→ le script affiche : **phase + gate suivant**, **rôles** (sponsor / bm / cp / moe), **tickets** (ids SP / OP), le **tableau d'avancement** (artefacts dus / faits par phase).

## 2. Le raisonnement PM² que le script ne fait pas (l'IA)

1. **Le gate en cours** : état de la checklist `checklists/gate-<RfP|RfE|RfC>.md` (items verts / rouges) — la règle du gate : tant que la checklist PM2-27 n'est pas verte, aucun artefact de la phase suivante.
2. **Les WPs** : lire `backlog/` du projet (1 fichier = 1 WP : statut, priorité, phase) ; si connexion active (frontmatter `sp_project` / `op_id`), inclure les ids de liaison `sp_id` / `op_id`. Sinon : « aucune connexion ticketing active ».
3. **Les propositions mode C en attente de validation** (si accumulées dans la session).

## 3. Terminer par

- Le **prochain artefact dû** à traiter (ordre du référentiel) + la question associée.
- Si le gate est vert : proposer le passage (`gate_suivant` → phase + 1).

$ARGUMENTS
