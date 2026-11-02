# _meta/ — le développement du repo lui-même (inception)

Ce repo est à la fois un **kit** (templates + protocole pour des projets) et **un projet** (sa propre construction). Ce dossier contient la documentation PM² **du repo vu comme projet** — d'où l'inception : le kit remplit lui-même sa propre documentation.

> ⭐ **Exemple vivant** : ce que vous voyez ici, c'est **exactement** ce qui se passe quand on utilise l'assistant sur un projet. Chaque WP du backlog a produit un commit, chaque session a laissé un log, chaque décision structurante est au registry.

| Sous-dossier / fichier | Contenu |
|---|---|
| `fiche.md` | fiche projet PM² du repo (frontmatter = source de vérité de la couche méta) |
| `backlog/` | **1 fichier = 1 package de travail (WP)** — format transformable en ticket OpenProject / SuperProductivity |
| `logs/` | journal des sessions / échanges (traçabilité) |
| `report/` | états périodiques du projet |
| `registry/` | registres : rôles, connexions, décisions |

> ⚠️ Ne pas confondre : les dossiers `01 Lancement/` … `05 Cloture/` à la racine sont des **templates** pour des projets clients. Ici, seuls l'**état** du projet et les **WPs de développement** sont tenus.
