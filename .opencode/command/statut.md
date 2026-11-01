---
description: Statut du projet et des tickets (artefacts dus, gates, tâches SuperProductivity/OpenProject).
agent: assistant-projet
---

Donne le statut du projet selon le protocole d'ouverture de session d'`AGENT-projet.md` :

1. Frontmatter de `projet.md` : phase, gate suivant, rôles, connexions actives.
2. Tableau des artefacts : dus / faits / en cours par phase (section 3 de `projet.md`).
3. Gate en cours : état de la checklist `checklists/gate-<RfP|RfE|RfC>.md` (items verts / rouges).
4. Tickets / WPs : liste du `backlog/` du projet (fichiers WP-NNNN : statut, priorité, phase) ; si connexion SuperProductivity ou OpenProject active (frontmatter `sp_project` / `op_id`), inclure les ids de liaison `sp_id` / `op_id`. Sinon : « aucune connexion ticketing active ».
5. Propositions mode C en attente de validation (si accumulées).
6. Terminer par : le prochain artefact dû à traiter + la question associée.

$ARGUMENTS
