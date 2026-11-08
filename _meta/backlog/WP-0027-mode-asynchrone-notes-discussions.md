---
wp_id: WP-0027
titre: "Mode asynchrone : un espace de notes (listes de points à traiter) découpé en discussions isolées"
statut: a-faire
priorite: moyenne
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 08/11 — verbatim : « c'est comme ca que je fonctionne dans Moosh-2ndb, je fais des notes quotidienne avec un marqueur de séparation d'item, puis ia le lit et les traite, et remplis un document (Question-a-Moosh) pour le suivi. Mais ici on peut améliorer. L'idée est d'avoir un espace ou je peux faire des notes avec des listes de points à traiter, et le tout va être découpé en discussion asynchrone »"
créé: 2026-11-08
mis_a_jour: 2026-11-08 (tracé, brouillon v0 à raffiner avec l'utilisateur)
---

# WP-0027 — Mode asynchrone : notes → discussions isolées

## Contexte
Dans **Moosh-2ndb**, l'utilisateur fonctionne déjà ainsi : notes quotidiennes avec un
**marqueur de séparation d'item** → l'IA lit et traite → remplit un **document de suivi**
(`Question-a-Moosh`). L'objectif ici : un espace équivalent **dans un projet PM²**,
amélioré — chaque item est traité comme une **discussion à part** (isolement de contexte
par item, et non une grosse conversation unique). C'est le volet **asynchrone** du
« mode IA » des 3 modes d'utilisation (WP-0026).

## Brouillon v0 (à raffiner avec l'utilisateur)
- **Espace d'entrée** (data, voyage avec le projet) : `<projet>/_meta/inbox/` (nom à
  trancher) — un fichier par note (ex. `2026-11-08.md`), une **liste d'items séparés par
  un marqueur** (à choisir : lisible humain + sans ambiguïté pour le découpage).
- **Découpage = standalone** (sans IA) : nouvelle commande native (ex. `assistant prompts`)
  qui lit le fichier et découpe par marqueur — le split fonctionne sans opencode.
- **Traitement = IA isolée** : pour chaque item, **une session opencode dédiée**
  (`opencode run` non-interactif) — **1 item = 1 discussion** (isolement de contexte).
- **Sortie** : un fichier par item traité (`_meta/inbox/out/` ?) + un **document de suivi**
  (l'esprit `Question-a-Moosh`) : item, date, lien du résultat, statut.
- **Résilience** : sans opencode → la commande liste les items et dit « IA requise » ;
  le découpage fonctionne sans IA (échelle des 3 modes).

## Ouvert (à trancher à l'implémentation)
- Le **marqueur de séparation** d'item (reprendre le format des notes 2ndb ?)
- Le **nom** de l'espace + de la commande (inbox / prompts / notes ?)
- **Où atterrissent les résultats** : `out/` + doc de suivi ? remplissage direct
  d'artefacts PM² (mode C) ?
- Le **contexte injecté par item** (frontmatter du projet, `AGENT-projet.md`,
  la phase courante ?)
- **Invocation** : manuelle (`assistant prompts`) ou mise en file + traitement ?
