# Session 2026-11-03 — le projet est autonome (scripts copiés) + note « Prochain pas »

## Décision

**Un projet assisté est autonome** : `assistant.ps1` / `assistant.sh` sont **copiés dans chaque projet**
par `new` / `add` (comme `docs/`, `checklists/`, `.opencode/`). Résolu l'« ouvert » noté dans WP-0017
(« si on lance `/scan` depuis un projet, le script vit dans le kit — à trancher ») : le script vit **dans le projet**.

Conséquences :
- `/statut` (commande opencode du projet) fonctionne **depuis le projet** sans revenir au kit :
  `statut` **sans argument** = le projet du dossier courant (dossier avec `projet.md` ou `<meta>/fiche.md`).
- `scan` depuis un projet = « aucune racine » (la config machine vit dans le kit, c'est volontaire :
  la config est **machine**, la connaissance des racines aussi).

## Note « Prochain pas » ajoutée dans les 3 commandes (demande utilisateur : « il faut aussi le dire dans la petite note »)

Après `new` / `new -doc` / `add`, le script affiche la suite **et quoi tester** :

```
  Prochain pas : aller dans le projet et lancer l'agent :
    cd <projet>
    opencode   (l'agent lit AGENT-projet.md → annonce la phase + gate : C'EST LE TEST)
  Puis tester :  /statut   (phase + gate + avancement)  -  et dire : « commence le projet »
  (ou, sans ouvrir opencode : assistant commence <nom>)
```

Variante `-doc` (pas de kit = pas d'agent) :
```
  Prochain pas :
    avec l'agent : assistant add <nom>  puis  cd <projet>  +  opencode  (test : il annonce la phase)
    sans l'agent : ouvrir _meta/fiche.md et travailler le markdown directement
```

## Implémentation

- `Copy-Kit` (PS) / `copy_kit` (bash) : + `assistant.ps1` / `assistant.sh` dans la liste des fichiers racine
  (17 éléments copiés au lieu de 15).
- `Cmd-Statut` / `cmd_statut` : **sans argument** = projet du dossier courant (sinon usage) — remplace le
  « demande le nom du projet » de `/statut` (`.opencode/command/statut.md` aligné).
- `add <nom>` : resolution cwd **puis** racines (fix 02/11, validé terrain : `add 2ndb-toolbox` depuis le kit →
  kit ajouté dans `code\github\2ndb-toolbox`).

## Tests sandbox (PS + bash)

- `new` → `assistant.ps1`/`.sh` présents dans le projet ✅
- depuis le projet : `statut` sans argument → `(source : projet.md)` + phase/gate ✅
- depuis le projet : `scan` → « aucune racine » (config machine non copiée, volontaire) ✅
- syntaxe : parse PS 0 erreur, `bash -n` OK, 0 byte non-ASCII, 0 NUL.

## État des validations terrain (après l'add de 2ndb-toolbox)

- WP-0019 : code fait + tests sandbox ; **reste** : `new -doc` en terrain réel.
- Nouveau : le projet `2ndb-toolbox` a le kit (14 éléments + scripts) → test suivant de l'utilisateur :
  `cd 2ndb-toolbox` + `opencode` → l'agent doit annoncer **phase Lancement, gate RfP** ; puis `/statut`.

## + Commande `update` (WP-0020) — demande : « je suis dans le rep du projet, je devrais pouvoir lancer cet update sans retourner dans le repo qui gère les projets »

Le kit va évoluer ; un projet ne doit pas revenir au repo du kit pour se mettre à jour :

- **`assistant update`** se lance **depuis le projet** (dossier courant).
- Origine du kit = ligne `kit_source: <chemin>` dans `_meta/registry/connexions.md`, **écrite
  automatiquement** par `new`/`add` au copy.
- **Resync zéro écrasement** : seuls les fichiers du kit **manquants** sont ajoutés (racine générique —
  jamais `.gitignore` — + `0*`/`checklists`/`docs`/`tools` recursif + `.opencode/agent|command` recursif).
  Le 2ᵉ run = « Déjà à jour ». Un fichier déjà présent côté projet n'est **jamais** modifié.
- Cas d'erreur : pas dans un projet / pas de `kit_source` (message + la ligne à ajouter) / kit invalide.
- **Limite v1 assumée** : `update` **ajoute** des fichiers, il ne met pas à jour le **contenu** d'un
  fichier existant (pas de diff/merge — zéro écrasement = règle absolue).

### Tests sandbox (PS + bash, tous verts)

`new` → modification du kit (`docs/nouveau.md` + `AGENT-projet.md` modifié) → `update` depuis le projet :
`docs/nouveau.md` ajouté, `AGENT-projet.md` **non** écrasé (reste la version projet) → 2ᵉ run « Déjà à jour »
→ 3 cas d'erreur OK. Syntaxe : parse PS 0 erreur (0 byte non-ASCII, 0 NUL — guillemets `« »` remplacés
par `'` dans les 2 notes « Prochain pas »), `bash -n` OK.

### Incident (troncation n°3)

L'insertion de `update_kit`/`cmd_update` par l'edit tool a **tronqué** `assistant.sh` à la ligne 439
(milieu de `cmd_add`). Reconstruction byte-level : `git checkout HEAD -- assistant.sh` + script `.ps1` en
Temp (4 insertions par ancres, échappement apostrophe PS = `''`). Leçon : pour les grosses modifs de
script, préférer `git checkout HEAD --` + reconstruction scriptée plutôt que l'edit tool.

