---
description: Scan des racines de projets (registres _projet/registry/connexions.md) — classe chaque dossier (kit / partiel / plain), annonce la phase des projets déjà connus, propose l'ajout du kit aux plain.
agent: assistant-projet
---

Lance le **scan des racines de projets** (WP-0005). Le but : voir ce qui vit déjà dans les racines, sans rien déplacher ni réécrire.

## 1. Lire les racines

Ouvrir `_projet/registry/connexions.md` → ligne `- racines:` dans le bloc wizard. Chaque entrée de la forme `<chemin> (<qualificatif>)` = une racine. Si `aucune` ou ligne absente : demander à l'utilisateur de relancer `install` pour définir les racines, et s'arrêter là.

## 2. Scanner chaque racine

Pour chaque racine, lister les **dossiers enfants** (pas les fichiers, pas les dossiers cachés `.*`). Pour CHAQUE dossier, classifier :

| Classe | Test | Sens |
|---|---|---|
| **kit** | a `projet.md` **et** `AGENT-projet.md` | un projet PM² déjà connu |
| **partiel** | a l'un des deux seulement | un kit inachevé / à compléter |
| **plain** | aucun des deux | un dossier qui n'est pas encore un projet PM² |

## 3. Ce qu'on fait par classe

- **kit** → lire le frontmatter de `projet.md` et annoncer : `phase:` courante + `gate_suivant:`. Format : `  ✔ <nom> — phase <Phase>, gate <Gate>`. (Le projet est déjà connu, rien à faire.)
- **partiel** → annoncer ce qui manque (`projet.md` ou `AGENT-projet.md`) et proposer de compléter (sans inventer : poser les questions du template).
- **plain** → proposer **deux** options, sans jamais déplacer ni réécrire :
  - **ajouter le kit** → copier les fichiers du kit (`projet.md`, `AGENT-projet.md`, `referentiel-templates-PM2.md`, `checklists/`, `docs/`, `tools/`, `opencode.json`, `_projet/`) DANS le dossier existant. **Jamais** écraser un fichier pré-existant ; si `projet.md` ou `_projet/` existe déjà dans la cible → conflit signalé, l'utilisateur tranche.
  - **laisser tel quel** → on ne touche à rien.

> Règle de tolérance au pré-existant : le kit **s'ajoute** à un dossier qui existe déjà (manifeste `projet.md` + couche `_projet/`). Il ne demande jamais de réorganiser, déplacer ou renommer les fichiers de l'utilisateur.

## 4. Résumé final

Terminer par un tableau récapitulatif :
```
Racine <chemin> : <N> dossiers scannés — <x> kit · <y> partiel · <z> plain
```
Puis la ligne globale : `Total : <N> dossiers · <x> kit · <y> partiel · <z> plain · <w> à ajouter`.

Et l'inversement de la question : **c'est la racine qui contient les projets, pas le projet qui vit dans le kit.**

## 5. Contraintes

- Ne **jamais** : déplacer, renommer, supprimer ni réécrire un fichier pré-existant.
- Ne **jamais** remplir un template : le scan identifie et propose, l'assistant remplit ensuite en mode B.
- Proposer **un seul** projet à traiter à la fois (règle du kit), commencer par les `partiel` puis les `plain` que l'utilisateur veut adopter.

$ARGUMENTS
