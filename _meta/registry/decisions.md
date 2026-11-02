# _projet/registry/decisions.md — décisions structurantes

> 1 ligne : `date | décision | source`. Seules les décisions qui changent la structure / le protocole sont consignées ici.

| Date | Décision | Source |
|---|---|---|
| 2026-11-01 | La couche du kit dans chaque projet = **`_projet/` (par défaut)** : fiche, backlog (1 fichier = 1 WP), registry, logs, report. Le manifeste reste `projet.md` à la racine du projet. | session du 01/11 (demande utilisateur « le répertoire, par défaut _project je pense ») |
| 2026-11-02 | **Verrouillé** : le nom de la couche n'est plus durci — c'est la clé **`meta_folder`** de la config machine `assistant.config` (racine du kit, gitignorée, wizard-générée). Valeur par défaut = `_projet`. « _project doit être une valeur par défaut mais venir d'une valeur de config » (verbatim). | session du 02/11 (WP-0017) |
| 2026-11-02 | **Changement de valeur par défaut : `meta_folder` = `_meta`** (était `_projet`). Termes pesés : `projet` (redondant « Mon-Projet/_projet »), `assistant` (liée à l'outil interchangeable + créée par le script natif sans IA), `artefact` (collision avec les artefacts de phase 01..05), `doc` (générique), **`meta`** (data *sur* le projet ; concept déjà nommé « couche méta » dans AGENT-projet §6 ; neutre FR/EN). Les dossiers créés avant le changement conservent leur nom (pas de migration rétroactive). | session du 02/11 (WP-0018) |
| 2026-11-02 | **Un projet n'est PAS forcément un projet de code** — c'est même la norme d'avoir un repo qui ne contient que `_meta/`. Conséquences : `statut`/`commence` acceptent un dossier sans `projet.md` (frontmatter de `_meta/fiche.md` = source de vérité, même que `projet.md`) ; `scan` classe un dossier sans kit mais avec `_meta/` en « à compléter » (projet sans code) ; `assistant new <nom> -doc` crée un projet minimal (seul `_meta/`, sans kit) — le kit s'ajoute ensuite avec `add` (zéro écrasement, `_meta` conservé). | session du 02/11 (WP-0019) |
| 2026-11-01 | Fin du concept « vault monolithe » : le kit s'appuie sur **des racines de projets (1..N)**, jamais de réorganisation des dossiers existants. | session du 01/11 (retour installation) |
| 2026-11-01 | `AGENT-projet.md` (jamais `AGENTS.md`) : la note de routage IA doit rester **inerte** pour les outils, chargée explicitement par le protocole. | session du 26/10 (règle de nommage) |
