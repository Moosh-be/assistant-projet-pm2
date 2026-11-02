# _projet/registry/decisions.md — décisions structurantes

> 1 ligne : `date | décision | source`. Seules les décisions qui changent la structure / le protocole sont consignées ici.

| Date | Décision | Source |
|---|---|---|
| 2026-11-01 | La couche du kit dans chaque projet = **`_projet/` (par défaut)** : fiche, backlog (1 fichier = 1 WP), registry, logs, report. Le manifeste reste `projet.md` à la racine du projet. | session du 01/11 (demande utilisateur « le répertoire, par défaut _project je pense ») |
| 2026-11-02 | **Verrouillé** : le nom de la couche n'est plus durci — c'est la clé **`meta_folder`** de la config machine `assistant.config` (racine du kit, gitignorée, wizard-générée). Valeur par défaut = `_projet`. « _project doit être une valeur par défaut mais venir d'une valeur de config » (verbatim). | session du 02/11 (WP-0017) |
| 2026-11-01 | Fin du concept « vault monolithe » : le kit s'appuie sur **des racines de projets (1..N)**, jamais de réorganisation des dossiers existants. | session du 01/11 (retour installation) |
| 2026-11-01 | `AGENT-projet.md` (jamais `AGENTS.md`) : la note de routage IA doit rester **inerte** pour les outils, chargée explicitement par le protocole. | session du 26/10 (règle de nommage) |
