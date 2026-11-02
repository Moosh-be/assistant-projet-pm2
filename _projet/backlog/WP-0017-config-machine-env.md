---
wp_id: WP-0017
titre: "Config machine à la racine (.assistant.config) + génération du .env secrets par le wizard"
statut: en-cours
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "décision utilisateur du 02/11/2026 — « quand l'install demande la clé API, ça devrait générer le fichier d'environnement, c'est une valeur de config » + « _projet doit être une valeur par défaut mais venir d'une valeur de config ; .env est commun, quid si un autre outil veut aussi l'utiliser ? »"
créé: 2026-11-02
mis_a_jour: "2026-11-02 (implémenté ps+sh, tests sandbox : migration token, .env généré, scan depuis config, meta_folder respecté)"
---

# WP-0017 — Config machine `.assistant.config` + secrets `.assistant-projet.env`

## Le problème

Le wizard d'install **parle du token comme valeur de config sans jamais générer l'endroit où elle vit** :
il demande le nom de variable et un fichier d'env *déjà existant*, mais ne crée rien. Résultat observé :
la valeur du token a atterri dans le champ `token_env:` du registre (anti-pattern : secret posé dans un
registre, même gitignored).

## Les décisions (tranchées avec l'utilisateur, 02/11)

1. **`.env` est un nom commun** → le kit a son **fichier de secrets dédié** : `.assistant-projet.env` (racine du kit, gitignored).
2. **Le nom du dossier méta `_projet` devient une valeur de config** (défaut `_projet`) → donc le
   **fichier de config ne peut pas vivre DANS `_projet/`** (chicken-and-egg) → il vit **à la racine du kit,
   à un nom fixe**.
3. **Nom du fichier de config** : le code est **compatible avec les 3 noms** et le fichier généré porte un
   commentaire qui explique les 3 possibilités :
   - `.assistant.config` ← **défaut** (fichier caché, nom fixe)
   - `assistant.config` (variante visible)
   - `assistant.config.md` (variante markdown, lisible dans Obsidian)
   → le code lit/écrit **le 1ᵉʳ qui existe** (sinon crée le défaut).
4. **Séparation config / secrets** :
   - `.assistant.config` = valeurs machine (meta_folder, env_file, racines, opencode, connexions, **noms de variables**)
   - `.assistant-projet.env` = **les valeurs sensibles seules** (`OP_API_TOKEN=…`)
   - La valeur du token n'est **jamais** dans la config, jamais dans un registre.
5. **Le wizard génère le `.env`** : après le lien de fabrication de la clé, il demande la clé en **saisie
   masquée** ; **les deux** : saisie masquée, et si vide → **placeholder** `OP_API_TOKEN=` à remplir plus tard.
   Idempotent (maj de la ligne `VAR=` si le fichier existe déjà, jamais d'affichage de la valeur).
6. **Fusion** : le bloc wizard de `_projet/registry/connexions.md` **déménage** dans `.assistant.config`
   (1 seule source de vérité de la config machine). `connexions.md` ne garde que les registres de **projet**
   (ids `sp_project` / `op_id` / MCP) — ce qui existe déjà dans les projets créés par `new`/`add`.
7. **Migration** : le token déjà posé dans `connexions.md` du kit (ligne `token_env: opapi-…`) est déplacé
   dans `.assistant-projet.env`, le champ devient `openproject_token_env = OP_API_TOKEN`.

## Format de `.assistant.config` (INI simple, bloc wizard entre marqueurs, idempotent)

```
meta_folder = _projet
env_file = .assistant-projet.env
racines = <liste ; <chemin> (qualificatif) ; …>
opencode = <statut>
openproject = oui
openproject_url = <url>
openproject_token_env = OP_API_TOKEN        ; NOM de variable (jamais la valeur)
openproject_token_file = <chemin abs .env>
superproductivity = oui
github_issue = oui
github_repo = <owner/name>
gitlab_issue = oui
gitlab_url = <url>
```

## Critères de réalisation

- [x] `.gitignore` du kit : + `.assistant.config` / `assistant.config` / `assistant.config.md` / `.assistant-projet.env`
- [x] `install.ps1` (ASCII) : écrit `.assistant.config` (INI, marqueurs idempotents, commentaire des 3 noms) ; saisie masquée de la clé ; génération/maj du `.env` (saisie ou placeholder) ; récap à jour
- [x] `install.sh` : idem
- [x] `assistant.ps1` / `assistant.sh` : lisent la racine de la config (1ᵉʳ des 3 noms) au lieu de `connexions.md` ; `new`/`add` créent le dossier méta selon `meta_folder` (défaut `_projet`)
- [x] **Migration** du token existant (connexions.md → .env) + config migrée + connexions.md vidé de son bloc wizard
- [x] Docs alignés : `docs/install.md`, `.opencode/command/scan.md`, `_projet/registry/README.md`
- [x] Tests : syntaxe PS/bash + `scan` fonctionne avec la nouvelle config + zéro token affiché/committable
- [ ] **Validation terrain** (relance de l'install sur la machine réelle)

## Notes

- `new`/`add` ne copient **ni** la config **ni** le `.env` dans les projets (config **machine**, locale au kit — même principe que le `connexions.md` local d'avant).
- Le `.env` est **dédié au kit** (`.assistant-projet.env`) : aucun autre outil ne le touche ; les outils tiers (op, MCP…) chargent la variable `OP_API_TOKEN` depuis ce fichier (chemin connu via la config).
- Ouvert (hors périmètre ici) : un projet utilise le kit via le `.opencode/` copié — si on lance `/scan` **depuis un projet**, le script vit dans le kit (à chercher à proximité) ; à trancher dans WP-0014/à venir.
