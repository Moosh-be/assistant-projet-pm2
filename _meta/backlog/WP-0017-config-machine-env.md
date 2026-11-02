---
wp_id: WP-0017
titre: "Config machine Ã  la racine (.assistant.config) + gÃ©nÃ©ration du .env secrets par le wizard"
statut: fait
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "dÃ©cision utilisateur du 02/11/2026 â€” Â« quand l'install demande la clÃ© API, Ã§a devrait gÃ©nÃ©rer le fichier d'environnement, c'est une valeur de config Â» + Â« _projet doit Ãªtre une valeur par dÃ©faut mais venir d'une valeur de config ; .env est commun, quid si un autre outil veut aussi l'utiliser ? Â»"
crÃ©Ã©: 2026-11-02
mis_a_jour: "2026-11-02 (implÃ©mentÃ© ps+sh, tests sandbox : migration token, .env gÃ©nÃ©rÃ©, scan depuis config, meta_folder respectÃ©)"
---

# WP-0017 â€” Config machine `.assistant.config` + secrets `.assistant-projet.env`

## Le problÃ¨me

Le wizard d'install **parle du token comme valeur de config sans jamais gÃ©nÃ©rer l'endroit oÃ¹ elle vit** :
il demande le nom de variable et un fichier d'env *dÃ©jÃ  existant*, mais ne crÃ©e rien. RÃ©sultat observÃ© :
la valeur du token a atterri dans le champ `token_env:` du registre (anti-pattern : secret posÃ© dans un
registre, mÃªme gitignored).

## Les dÃ©cisions (tranchÃ©es avec l'utilisateur, 02/11)

1. **`.env` est un nom commun** â†’ le kit a son **fichier de secrets dÃ©diÃ©** : `.assistant-projet.env` (racine du kit, gitignored).
2. **Le nom du dossier mÃ©ta `_projet` devient une valeur de config** (dÃ©faut `_projet`) â†’ donc le
   **fichier de config ne peut pas vivre DANS `_projet/`** (chicken-and-egg) â†’ il vit **Ã  la racine du kit,
   Ã  un nom fixe**.
3. **Nom du fichier de config** : le code est **compatible avec les 3 noms** et le fichier gÃ©nÃ©rÃ© porte un
   commentaire qui explique les 3 possibilitÃ©s :
   - `.assistant.config` â† **dÃ©faut** (fichier cachÃ©, nom fixe)
   - `assistant.config` (variante visible)
   - `assistant.config.md` (variante markdown, lisible dans Obsidian)
   â†’ le code lit/Ã©crit **le 1áµ‰Ê³ qui existe** (sinon crÃ©e le dÃ©faut).
4. **SÃ©paration config / secrets** :
   - `.assistant.config` = valeurs machine (meta_folder, env_file, racines, opencode, connexions, **noms de variables**)
   - `.assistant-projet.env` = **les valeurs sensibles seules** (`OP_API_TOKEN=â€¦`)
   - La valeur du token n'est **jamais** dans la config, jamais dans un registre.
5. **Le wizard gÃ©nÃ¨re le `.env`** : aprÃ¨s le lien de fabrication de la clÃ©, il demande la clÃ© en **saisie
   masquÃ©e** ; **les deux** : saisie masquÃ©e, et si vide â†’ **placeholder** `OP_API_TOKEN=` Ã  remplir plus tard.
   Idempotent (maj de la ligne `VAR=` si le fichier existe dÃ©jÃ , jamais d'affichage de la valeur).
6. **Fusion** : le bloc wizard de `_projet/registry/connexions.md` **dÃ©mÃ©nage** dans `.assistant.config`
   (1 seule source de vÃ©ritÃ© de la config machine). `connexions.md` ne garde que les registres de **projet**
   (ids `sp_project` / `op_id` / MCP) â€” ce qui existe dÃ©jÃ  dans les projets crÃ©Ã©s par `new`/`add`.
7. **Migration** : le token dÃ©jÃ  posÃ© dans `connexions.md` du kit (ligne `token_env: opapi-â€¦`) est dÃ©placÃ©
   dans `.assistant-projet.env`, le champ devient `openproject_token_env = OP_API_TOKEN`.

## Format de `.assistant.config` (INI simple, bloc wizard entre marqueurs, idempotent)

```
meta_folder = _projet
env_file = .assistant-projet.env
racines = <liste ; <chemin> (qualificatif) ; â€¦>
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

## CritÃ¨res de rÃ©alisation

- [x] `.gitignore` du kit : + `.assistant.config` / `assistant.config` / `assistant.config.md` / `.assistant-projet.env`
- [x] `install.ps1` (ASCII) : Ã©crit `.assistant.config` (INI, marqueurs idempotents, commentaire des 3 noms) ; saisie masquÃ©e de la clÃ© ; gÃ©nÃ©ration/maj du `.env` (saisie ou placeholder) ; rÃ©cap Ã  jour
- [x] `install.sh` : idem
- [x] `assistant.ps1` / `assistant.sh` : lisent la racine de la config (1áµ‰Ê³ des 3 noms) au lieu de `connexions.md` ; `new`/`add` crÃ©ent le dossier mÃ©ta selon `meta_folder` (dÃ©faut `_projet`)
- [x] **Migration** du token existant (connexions.md â†’ .env) + config migrÃ©e + connexions.md vidÃ© de son bloc wizard
- [x] Docs alignÃ©s : `docs/install.md`, `.opencode/command/scan.md`, `_projet/registry/README.md`
- [x] Tests : syntaxe PS/bash + `scan` fonctionne avec la nouvelle config + zÃ©ro token affichÃ©/committable
- [ ] **Validation terrain** (relance de l'install sur la machine rÃ©elle)

## Notes

- `new`/`add` ne copient **ni** la config **ni** le `.env` dans les projets (config **machine**, locale au kit â€” mÃªme principe que le `connexions.md` local d'avant).
- Le `.env` est **dÃ©diÃ© au kit** (`.assistant-projet.env`) : aucun autre outil ne le touche ; les outils tiers (op, MCPâ€¦) chargent la variable `OP_API_TOKEN` depuis ce fichier (chemin connu via la config).
- Ouvert (hors pÃ©rimÃ¨tre ici) : un projet utilise le kit via le `.opencode/` copiÃ© â€” si on lance `/scan` **depuis un projet**, le script vit dans le kit (Ã  chercher Ã  proximitÃ©) ; Ã  trancher dans WP-0014/Ã  venir.
