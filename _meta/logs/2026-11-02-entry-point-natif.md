# Session 2026-11-02 — entry-point natif assistant.ps1 / .sh (WP-0016) + config machine & secrets (WP-0017)

> Principe directeur posé (verbatim utilisateur) : **« j'aime que tout ce qui est faisable sans IA le soit. et pour trouver les repos, tout comme pour ajouter l'espace _projet à un des projets, pas besoin d'IA. »** → Le script natif fait le déterministe ; l'agent raisonne seulement pour conduire (B), écouter (C), décider (add-ons).

## WP-0016 — entry-point natif `assistant.ps1` / `assistant.sh`

**Commandes** (split déterministe / raisonnement) :
- `scan` / `statut <projet>` / `new <nom>` / `add <dossier>` = **déterministe** (sans IA, sans dépendance)
- `commence <nom>` = **handoff IA** (ouvre opencode dans le projet)
- `menu` / `?` = le menu (distingue déterministe / IA)

**Règle d'or `add`/`new`** : ne **jamais** copier les données d'inception du kit (`_projet/fiche.md` du kit, `backlog/WP-*`, `logs/*`, `registry/connexions.md` local). On copie les fichiers **génériques** + on **crée** un `_projet/` **neuf** au nom du projet. **Jamais** d'écrasement d'un fichier pré-existant (signalé + ignoré).

### Ce qui a été fait + testé

- **`assistant.ps1`** (PowerShell 5.1/pwsh, ASCII pur, sans dépendance) : les 6 commandes. Bugs corrigés en cours de route :
  - parenthèse en trop dans le `foreach` (ligne 234) ;
  - `$MyInvocation.MyCommand.Path` → `$PSScriptRoot` (robuste quel que soit le mode d'appel) ;
  - **collision de variable** : PowerShell est insensible à la casse → `$root` (locale, racine du projet) écrasait `$Root` (chemin du kit) dans `Cmd-New` → renommé `$rroot` ;
  - regex clés frontmatter : ajout de l'underscore (`gate_suivant`, `sp_project`, `op_id`) ;
  - strings d'affichage en ASCII (PS 5.1 lit les `.ps1` en ANSI sans BOM) → `[Assistes]`, `[A completer]`, etc.
- **`assistant.sh`** (bash, macOS/Linux) : même logique. Bugs corrigés :
  - `new` : `fiche.md` sortait avec `{{NOM}}`/`{{DATE}}` non substitués → réécrit le pré-remplissage de `projet.md`/`fiche.md` via `sed` propre ;
  - `new` : `projet.md` pré-remplissage partiel (le `case` bash était fragile) ;
  - **`SKIPPED_LIST` perdue** : `copy_kit` appelé via `$(...)` = **sous-shell**, la variable globale n'en ressortait pas → remplacée par un **fichier temporaire** (`skipfile`) en 3ᵉ paramètre.
- **Tests (dossier temp, jamais les vrais projets)** :
  - PS `scan` ✅ (buckets + phase/gate corrects sur `code/github` réel) · `statut` ✅ · `new` ✅ (15 éléments, `_projet` neuf, `node_modules` exclu, UTF-8 propre) · `add` ✅ (zéro écrasement, 3 pré-existants ignorés) ;
  - bash `scan` ✅ (fix trailing-comma awk) · `new` ✅ (fiche.md + projet.md pré-remplis, 0 `{{...}}` restants) · `add` ✅ (zéro écrasement, 3 ignorés signalés) ;
  - syntaxe : `PS parse AST` OK + `bash -n` OK ; `assistant.ps1` = **0 byte non-ASCII**, `install.ps1` ASCII (hors 11 bytes pré-existants de commentaire).

### Alignements fin de session

- **Menu de fin d'install** (`install.ps1` / `install.sh`) → présente le **menu natif** + conseil conditionnel (scan si racines, sinon `new`).
- **Commandes opencode `/scan` + `/statut`** → **réécrites pour APPeler le script natif** (source unique — pas deux implémentations). L'agent présente le résultat et conduit (gate, WPs, mode C) ; il ne re-développe pas la logique de scan/statut.
- **Docs alignés** : `README.fr.md` + `README.en.md` (section Démarrage rapide = menu natif + principe « sans IA ») + `docs/install.md` (nouvelle §3 « Le menu natif » + tests de fumée).
- **`tools/templates/fiche-projet.md`** : template `{{NOM}}`/`{{DATE}}` pour le `_projet/fiche.md` neuf (utilisé par `new`).

### Reste (à faire / valider)

- [ ] **Validation terrain** : sur machine réelle, relancer l'install (→ menu natif + conseil), puis `assistant.ps1/.sh scan · statut · new · add` ; vérifier que `/scan` + `/statut` opencode appellent bien le script.
- [x] Commit de WP-0016 (commit WP-alisé, 02/11).
- WP-0008 / 0010 / 0011 / 0012 / 0013 : **toujours en attente de validation terrain** (code fait, voir log 01/11) — une seule relance d'install les valide tous avec WP-0016/0017.
- WP-0002 (commande démo), WP-0003 (backup gzip), WP-0009 (détecteur multi-signaux), WP-0014 (add-ons à l'activation) : `a-faire`.

## WP-0017 — config machine `.assistant.config` + secrets `.assistant-projet.env`

**Décision verrouillée** (validée utilisateur, verbatim) : « _project doit être une valeur par défaut mais venir d'une valeur de config, .env est commun quid si un autre outil veux aussi utiliser cela » + « le fichier de config est forcément à la racine ».

**Choix d'implémentation** :
- **`assistant.config` à la racine du kit** (gitignored) : INI, **entièrement wizard-généré** (bloc entre marqueurs `<!-- wizard:start/end -->`, idempotent — seul le bloc est régénéré à chaque install). Le code est **compatible avec les 3 noms** `.assistant.config` (défaut) / `assistant.config` / `assistant.config.md` (1ᵉʳ qui existe), et le fichier généré porte un **commentaire expliquant les 3 possibilités**.
- **`meta_folder = _projet`** = valeur de config (header statique du fichier) ; `new`/`add` créent le dossier méta selon cette valeur (testé sandbox : `meta_folder = _pm` → `_pm/fiche.md` créé).
- **Secrets : `.assistant-projet.env` dédié** (pas un `.env` commun) — aucun autre outil ne le touche. **Généré par le wizard** : saisie **masquée** (`Read-Host -AsSecureString` en PS / `read -r -s` en bash) ou **placeholder vide** si rien tapé (« Les deux »). La valeur n'est **jamais** affichée ni dans le récap (`op_token_state` dit « saisie dans .assistant-projet.env » sans la valeur).
- **Bloc wizard de `_projet/registry/connexions.md` fusionné dans la config** : `connexions.md` ne garde que les registres **de projet** (ids `sp_project` / `op_id` / MCP).
- **Migration** du token existant (l'ancien `token_env: opapi-…` qui portait la VALEUR) → `.assistant-projet.env` comme `OP_API_TOKEN`. Message honnête : les anciens choix sont **ré-proposés** à l'install (le wizard redemande), pas migrés silencieusement.
- `new`/`add` ne copient **ni** la config **ni** le `.env` dans les projets (config **machine**, locale au kit).
- `assistant.ps1`/`assistant.sh` : `Get-Racines`/`get_racines` lisent la config (1ᵉʳ des 3 noms) avec **fallback** vers l'ancien registre (transition) ; `Copy-Kit`/`copy_kit` utilisent `meta_folder`.

**Bugs découverts en route** :
- **Parseur PS 5.1** : le pattern `"x = $(if ($v -ne "") { $v } else { '?' })"` (string vide imbriquée dans `$(...)` dans une string) échoue au parse (« Le terminateur " est manquant »). Reprodre en isolé → contourné : **extraire la valeur en variable AVANT interpolation**. À garder en tête pour tout code PS 5.1 du kit.
- `env_upsert` (bash) : version `sed -E "s|...|${val}|"` fragile aux valeurs spéciales → réécrite en **réécriture ligne à ligne** (aucun échappement nécessaire).
- `AskSecret` : `[System.Runtime.InteropServices.Marshal]::ZeroLocalFree` n'existe pas → `ZeroFreeBSTR`.
- Bash : `$meta` vs `$META` (bash est sensible à la casse, contrairement à PS) → `local meta="$META"` dans `copy_kit`.

**Tests sandbox** (copies du kit en temp, jamais la machine réelle) :
- migration du token ✅ (bash + PS) · génération `.env` + saisie masquée/placeholder ✅ · `scan` lit les racines depuis la config ✅ · idempotence (1 seul bloc wizard, 1 seul `meta_folder` après 2ᵉ run, clé conservée si non resaisie) ✅ · `meta_folder = _pm` respecté par `new` ✅ · syntaxe : PS parse AST 0 erreur, `bash -n` OK, `assistant.ps1` = 0 byte non-ASCII, `install.ps1` ASCII pur.

## WP-0019 — un projet n'est PAS forcément un projet de code

**Position verrouillée** (verbatim utilisateur) : « mon projet n'est pas forcément (et ça devrait même être la norme) un projet de code — il est imaginable que mon repo ne contienne que `_meta` ».

**Trou identifié** : le kit traitait un projet comme « dossier de code + kit posé dessus » — `scan` ne classait « assisté » que sur `projet.md`+`AGENT-projet.md`, `statut`/`commence` n'existaient qu'avec `projet.md` → un repo contenant **que `_meta/`** était « sans signal » et invisible.

**Implémentation** (PS + bash, tests sandbox E2E verts des deux côtés) :
- `statut` / `commence` / `Find-Project` : un projet = dossier avec `projet.md` **ou** `<meta>/fiche.md` ; `statut` affiche `(source : …)` — les deux fichiers partagent volontairement les mêmes clés de frontmatter + la table `## 3.`.
- `scan` : `<meta>/` est un signal ; sans kit mais avec `<meta>/` → **[À compléter] — « projet sans code → assistant add »**.
- **`assistant new <nom> -doc`** : projet minimal = **seul** `<meta>/` (fiche + squelette), sans kit ; le kit se complète ensuite avec `add` (zéro écrasement, `<meta>/` conservé).
- Bug PS trouvé : `Test-Path x -or Test-Path y` échoue (`-or` absorbé comme paramètre) → helper `Test-ProjectDir`.
- Couche méta : ticket `backlog/WP-0019-projet-sans-code.md` + ligne `decisions.md` + fiche 11/19.

**Reste** : validation terrain (`new -doc` + `statut` sur un vrai projet documentaire).

## Corrections mineures de session (validées terrain)

- **Corruption NUL** : `install.ps1` avait 6 bytes NUL en fin de fichier (écrits par un outil, commités dans WP-0018) → erreur d'exécution « Le terme »» n'est pas reconnu » + `}` orpheline perçu. Réparé (NUL retirés, parse 0 erreur). `assistant.ps1` a **aussi** subi une troncature de fin de fichier en cours de session (fin du menu + dispatch manquant) → réécrit. → **règle : vérifier la FIN des fichiers après toute écriture** (déjà noté, récidive ×2).
- **`add <nom> relatif`** : ne résolvait que le chemin par rapport au **dossier courant** → échec sur un projet vivant dans une racine (`add 2ndb-toolbox` depuis le kit). Corrigé : cwd **puis** recherche sous chaque racine (PS + bash, testé).
- **Validation terrain WP-0016/0017 + 0008/0010/0012/0013** : install relancée sur la machine réelle (22:45) → config `.assistant.config` générée avec les vraies valeurs (racines `code\github` = parent du kit → WP-0008 ✓, OP `projet.rtbf.be` + token dans `.env` → WP-0010 ✓), registre vidé, token migré (WP-0017 ✓), `scan` = 23 dossiers / 2 assistés / 14 pourraient / 7 sans signal (WP-0012 ✓), menu de fin + conseil (WP-0013 ✓), `add` via racine (WP-0016 ✓). WP-0011 (« o » accepté) : pas de preuve directe dans cette relance, reste à confirmer au prochain wizard.

## Notes de design (décisions structurantes)

- **Découpage verrouillé** : **install** (script, 1×, config transversale : env + opencode + racines + connexions) → se termine par **menu natif + conseil** (scan si projets existants, sinon création d'un 1er projet). Le « monde projet » (découverte, adoption, add-ons) = côté **agent** / script natif.
- **Pertinence d'un add-on** = connaissance de **projet**, pas de machine → proposée **à l'activation**, pas à l'install (WP-0014).
- **Source unique** : la logique scan/statut vit **une seule fois** dans `assistant.ps1`/`assistant.sh` ; les commandes opencode l'appellent.
- **Lien OpenProject** : page de fabrication = `<url>/my/access_tokens` (PAS `/openproject/api/access` = endpoint REST) ; URL d'instance = celle qui charge la page d'accueil.
