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
