---
wp_id: WP-0020
titre: "Commande update : un projet met à jour SON kit depuis le projet (zéro écrasement)"
statut: en-cours
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 03/11/2026 — verbatim : 'ok mais maintenant je suis dans le rep du projet, je devrais pouvoir lancer cet update sans retourner dans le repo qui gère les projets'"
créé: 2026-11-03
mis_a_jour: 2026-11-03
---

# WP-0020 — `update` : le projet resync son kit sans revenir au repo du kit

## Contexte

Le kit évolue (nouveaux templates, nouvelles commandes, corrections). Un projet créé par `new`/`add`
garde une **photographie** du kit au moment de la copie. Aujourd'hui, pour bénéficier des nouveautés,
il faudrait revenir dans le repo du kit — ce qui contredit le principe posé le 03/11 : **le projet est
autonome** (il porte déjà ses scripts `assistant.ps1`/`.sh`).

## Décision

**`assistant update`** se lance **depuis le projet** (dossier courant) :
1. **Origine du kit** = la ligne `kit_source: <chemin>` dans `_meta/registry/connexions.md`, **écrite
   automatiquement** par `new`/`add` au moment du copy (le projet sait d'où vient son kit).
2. **Resync zéro écrasement** : seuls les fichiers du kit **manquants** dans le projet sont ajoutés —
   - fichiers racine : `AGENT-projet.md`, `referentiel-templates-PM2.md`, `opencode.json`,
     `assistant.ps1`, `assistant.sh` (**jamais `.gitignore`** = data du projet) ;
   - dossiers `0*` / `checklists` / `docs` / `tools` : les fichiers manquants, **recursif**
     (un dossier existant est complété, jamais touché dans son contenu) ;
   - `.opencode/agent` + `.opencode/command` : les fichiers manquants, recursif.
3. **Le contenu existant du projet est sacré** : un fichier présent côté projet (modifié ou non) n'est
   **jamais** modifié/remplacé. Un 2ᵉ run affiche « Déjà à jour — rien à ajouter ».
4. **Gardes-fous** : pas dans un projet → message ; pas de `kit_source` → message + la ligne à ajouter ;
   kit source invalide → message.

**Limites assumées** (v1) : `update` **ajoute** des fichiers, il ne **met pas à jour** le contenu d'un
fichier déjà présent (pas de diff/merge — la règle zéro écrasement est absolue). Le contenu évolue soit
en main (c'est la data du projet), soit en recréant le projet.

## Périmètre

- [x] `assistant.ps1` : `Update-Kit` + `Cmd-Update` + dispatch `^update$` + menu + `kit_source` écrit par `Copy-Kit`
- [x] `assistant.sh` : `update_kit` + `cmd_update` + dispatch + menu + `kit_source` écrit par `copy_kit`
- [x] Tests sandbox PS + bash : `new` → modification du kit → `update` (ajout sans écrasement) → 2ᵉ run « déjà à jour »
      + 3 cas d'erreur (pas un projet / pas de kit_source / kit invalide)
- [x] `decisions.md` : 1 ligne
- [ ] Validation terrain (`2ndb-toolbox` : ré-`add` pour récupérer les scripts + `kit_source`, puis `update`)

## Notes

- Les projets créés **avant** ce WP (ex. `2ndb-toolbox`) n'ont pas de `kit_source` : il faut ré-`add`
  (idempotent, zéro écrasement) — ou ajouter la ligne manuellement dans leur `_meta/registry/connexions.md`.
- Bug de reconstrution documenté : l'insertion par l'edit tool a **tronqué** `assistant.sh` (3ᵉ occurrence
  de troncature) → reconstruction byte-level depuis `git checkout HEAD --` (script `.ps1` en Temp,
  échappement apostrophe PS = `''`).

## Implémentation (03/11)

- **PS** : `Update-Kit` (liste des manquants) + `Cmd-Update` (cwd + lecture `kit_source`) ; `Copy-Kit`
  écrit `kit_source: <$Root>` dans le `registry/connexions.md` du nouveau projet.
- **bash** : `update_kit` (find -type f + test d'existence relative) + `cmd_update` ; `copy_kit` écrit
  `kit_source: %s` via printf.
- **Tests sandbox** : les 5 cas PS + les 5 cas bash tous verts (ajout `docs/nouveau.md`, `AGENT-projet.md`
  côté projet non écrasé, 2ᵉ run « déjà à jour », 3 messages d'erreur corrects).
