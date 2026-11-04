---
wp_id: WP-0024
titre: "Commande liste + statut (introuvable/hors projet) affiche la liste + menu en 2 blocs (gérer / dans un projet)"
statut: en-cours
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 04/11/2026 — retour terrain menu à la racine du kit, 2 remarques : 'statut <projet> — je dois donner le nom d'un projet ? sous quelle forme, comment obtenir la liste ?' + 'on doit distinguer la commande qui lance le gestionnaire d'assistance, locale (pour gérer les projets), et l'assistance qu'on retrouve dans chaque projet séparément'"
créé: 2026-11-04
mis_a_jour: 2026-11-04
---

# WP-0024 — `liste` + le menu distingue « gérer les projets » de « dans un projet »

## Contexte

Retour terrain du 04/11 : lancé à la **racine du kit**, le menu mélange deux positions
l'une de l'autre :
1. **Gérer les projets** — on est dans le kit / sur les racines (scan, new, add, statut par nom) ;
2. **Dans un projet** — on est dans le dossier d'un projet (statut sans argument, update,
   remark). Comme le kit est lui-même un projet (inception), les deux se retrouvent dans
   le même menu, et rien ne le disait.

+ la question « statut : sous quelle forme le nom ? comment obtenir la liste ? » →
il n'y avait pas de voie simple vers la liste, et `statut toto-introuvable` ne donnait
aucune piste.

## Décision (validée utilisateur : « 1 + 2 + une commande liste pour celui qui y pense avant »)

1. **`statut <nom> introuvable`** → message d'introuvable **+ la liste des projets**
   (nom + phase + gate, cherchée dans les racines, dédupliquée).
2. **`statut` sans argument** :
   - dans le dossier d'un projet → le statut de ce projet (comportement existant) ;
   - **hors de tout projet → la liste** (remplace l'usage sec).
   - Nuance assumée : le kit est un projet (inception) → `statut` sans argument dans le
     kit = le statut du kit, pas la liste (le kit apparaît dans la liste des racines).
3. **Nouvelle commande `liste`** : la liste des projets (nom + phase + gate) — pour celui
   qui y pense avant de taper `statut <nom>`. Le nom = le nom du dossier.
4. **Menu en 2 blocs** :
   - `-- Gérer les projets (depuis le kit ou les racines) --` : scan, **liste**,
     `statut <projet>`, new, add, install ;
   - `-- Dans un projet (depuis le dossier du projet) --` : `statut` (courant), update,
     remark, commence.
   Idem pour les menus de fin d'`install.ps1`/`install.sh` (qui dataient d'avant
   WP-0020/0021 : `update`/`remark` y manquaient).

## Périmètre

- [x] `assistant.ps1` : `Show-ProjetListe` + `Cmd-Statut` (introuvable → liste ; hors
      projet → liste) + dispatch `^liste$` + menu 2 blocs + header
- [x] `assistant.sh` : `liste_projects` + `cmd_statut` (idem) + dispatch `liste)` + menu
      2 blocs + header
- [x] `install.ps1` / `install.sh` : menu de fin restructuré + `liste` + `update`/`remark`
      manquants ajoutés
- [x] Tests sandbox PS + bash (8 cas chacun) : verts — liste, introuvable→liste, statut
      sans arg (kit=projet / hors projet / dans projet), menu 2 blocs
- [x] `decisions.md` : 1 ligne
- [ ] Validation terrain : le menu du 04/11 relancé à la racine du kit

## Notes

- La liste ne lit que les **racines** (pas le kit ni le cwd) : `statut`/`commence`
  continuent de chercher dans le kit + cwd + racines, la liste montre la flotte.
- Le kit (inception) apparaît dans la liste des racines : c'est un projet comme les autres.
- Pas d'autocomplete (fichier script simple ; un vrai tab-completion = wrapper + profil
  PowerShell — add-on éventuel, hors v1).

## Implémentation (04/11)

- **PS** : `Show-ProjetListe` (balise les racines via `Get-Racines`, `Test-ProjectDir`,
  dédup par chemin résolu, `Read-Frontmatter` pour phase/gate, alignement `"{0,-28}"`).
- **bash** : `liste_projects` (même logique, awk frontmatter, `printf '%-28s'`,
  dédup par `case` sur la liste de chemins).
- Config machine de test : attention au format **`racines = <chemin> (<qualificatif>)`**
  — sans le `(...)` le parse renvoie rien (bug du test, pas du produit).
