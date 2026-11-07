# Installation — le marteau (opencode) + le coffre (Obsidian) + le menu natif (assistant.ps1 / .sh)

> Par défaut : **opencode** (agent IA) + **Obsidian** (coffre Markdown).
> Les deux sont interchangeables : n'importe quel **agent qui lit un dossier de Markdown** (opencode, Claude Code, gemini-cli…) + n'importe quel **gestionnaire de notes Markdown** (Obsidian, Logseq, VS Code…). Ici on installe la pile par défaut.

## 1. Le coffre — Obsidian
1. Installer **Obsidian** (https://obsidian.md) — gratuit pour usage perso.
2. **Créer un vault** : « Open folder as vault » → le dossier qui contiendra tes projets (ex. `C:\vault` ou un dossier git).
3. **Aucun plugin requis** par l'assistant (tout est Markdown + frontmatter). Optionnel recommandé :
   - **Templater** ou **Core Templates** : pour cloner le squelette d'un projet mince en un clic (§ prise-en-main §6).
4. (Recommandé) mettre le vault **sous git** (`git init`) → chaque projet est versionné.

## 2. Le marteau — opencode
1. Prérequis : **Node.js ≥ 18** (https://nodejs.org).
2. Installer opencode (global) :
   ```
   npm install -g opencode-ai
   ```
3. Vérifier :
   ```
   opencode --version
   ```
4. Se connecter (première fois) : `opencode /login` (ou configure ton provider/LLM).
5. **Lancer dans un projet** :
   ```
   cd <vault>/projects/Mon-Projet
   opencode
   ```
6. (Optionnel) dans `opencode.json` du projet ou du vault : autoriser l'écriture dans le dossier projet.

> **Projet mince (WP-0025)** : le `opencode.json` du projet pointe sur l'`AGENT-projet.md` **du bundle** (chemin absolu) + la copie machine de l'harness vit **dans** le projet (`.opencode/` — créée par `sync` / `bootstrap`). Le projet ne porte pas lui-même le protocole.
>
> **Pourquoi « le marteau » ?** l'agent est l'outil qui frappe : il ne contient pas la connaissance du projet — **c'est le dossier projet (la data) + le bundle (l'outillage) qui la contiennent**. Changer de marteau ne change rien au projet.

## 3. Le menu natif — `assistant.ps1` / `assistant.sh` (sans IA)

> **Principe** : *tout ce qui est faisable sans IA, se fait sans IA.* Le script natif (sans dépendance, aucun package) fait le travail **déterministe** ; l'agent ne raisonne que pour conduire, écouter, décider.

À la racine du **bundle** :
- Windows : `.\assistant.ps1 <cmd>` (PowerShell 5.1+ / pwsh, ASCII pur)
- macOS / Linux : `./assistant.sh <cmd>`

| Commande | Nature | Ce qu'elle fait |
|---|---|---|
| `scan` | déterministe | les projets des racines : 3 buckets (assistés **mince / copie complète** · pourraient · sans signal) + signaux + phase/gate |
| `statut <projet>` | déterministe | phase + gate + rôles + tickets + tableau d'avancement |
| `new <nom> [racine] [-doc]` | déterministe | crée un projet **MINCE** (doc `projet.md` + `01..05` + `_meta/` neuf, config de connexion, lanceur mince, bootstrap — `projet.md` pré-rempli) · **`-doc`** = projet sans code : seul `_meta/` est créé (fiche + squelette), l'outillage n'est pas déployé — à compléter plus tard avec `add` |
| `add <dossier>` | déterministe | ajoute l'assistant (mince) à un projet existant — **jamais d'écrasement** (le pré-existant est signalé et ignoré) |
| `sync [--force-harness]` *(depuis un projet)* | déterministe | (remplace `update` — WP-0025) vérifie le **bundle** (version, `assistant_ref`) + déploie le **harness opencode** du projet (`.opencode/` + `opencode.json`, zéro écrasement). Chemins écrits en `C:/...` (lisibles PS + bash + opencode) |
| `bootstrap` *(depuis un projet)* | déterministe | (ré)installe le bundle sur **cette machine** : `pointer` / `chercher` / `installer` + harness — **sans IA**, annonce + confirmation avant chaque action. C'est ce que le lanceur mince d'un projet sync chez un tiers déclenche si le bundle est introuvable |
| `commence <nom>` | handoff IA | ouvre opencode dans le projet — l'agent prend le relais (mode B/C) |
| `menu` / `?` | — | le menu |

> **Projet mince (WP-0025)** : le projet ne contient **que** la doc + la config de connexion (`_meta/registry/connexions.md` partagée, `connexions.local.md` machine gitignorée) + le lanceur mince + le bootstrap. L'outillage (templates, checklists, protocole, harness) **vit dans le bundle** et reste là.

> **Source unique** : la logique de scan/statut vit **une seule fois** — dans le script. Les commandes opencode `/ap-scan-projets` et `/ap-statut-projet` **l'appellent** ; l'agent présente le résultat et conduit (il ne re-développe pas la logique).

## 4. Brancher le bundle (une fois)
```
git clone <url-du-repo> ~/templates/assistant-projet-pm2
```
Puis pour chaque projet : `assistant.ps1 new <Nom>` (création, **projet mince**) ou `assistant.ps1 add <dossier>` (projet existant) — depuis le bundle, ou depuis un projet (le lanceur mince délègue au bundle). La config partagée du projet pointe sur le repo (`assistant_git`) ; le bootstrap `installer` le clone là où tu le dis.

## 5. Projets déjà organisés (multi-racines)

Tu as déjà tes dossiers de projets, peut-être par plateforme (`code/github/…`, `code/gitlab/…`) ? **Ne change rien** : l'assistant ne demande jamais de réorganiser, déplacer ou renommer.

- Le wizard d'installation (`install.ps1` / `install.sh`) te demande **où vivent tes projets** : **1 ou plusieurs racines** (pas un « vault » monolithe). **Une racine = un dossier qui *contient* des projets (1 projet = 1 sous-dossier)**. Le wizard propose : le **dossier du bundle + 2 niveaux au-dessus** (si tes projets vivent dans le même dossier que le bundle — cas le plus fréquent) + **les dossiers à côté** (max 5) ; tu choisis par numéro, ou `A` pour ajouter un chemin (tout autre niveau), `V` pour passer.
- **Racine non vide** → le wizard la liste (« je te montre, tu valides ») et note `déjà rempli, rien ne sera déplacé` dans le registre. **Racine absente** → création **uniquement** si tu confirmes.
- Les racines sont écrites dans la **config machine à la racine du bundle** (`.assistant.config`, gitignored — WP-0017 ; le wizard utilise le 1ᵉʳ des 3 noms possibles `.assistant.config` / `assistant.config` / `assistant.config.md`). Les **secrets** (tokens) vivent dans `.assistant-projet.env` (généré par le wizard, saisie masquée), jamais dans la config ni dans un registre. **Convention de chemin** : les chemins partagés (racines, `assistant_local`) sont écrits en `C:/...` (barres obliques) sur Windows — lisibles par le moteur PS, le moteur bash (MSYS) et opencode.
- Dans chaque projet, la **data** = **manifeste** (`projet.md`, frontmatter source de vérité) + couche **`_meta/`** (fiche, backlog, registres, **config de connexion** `registry/connexions.md` + `connexions.local.md`). Ajouter l'assistant à un dossier existant = **layout mince seulement** (doc + config + lanceur + bootstrap) ; un conflit (`projet.md` ou `_meta/` déjà présent) est signalé, rien n'est écrasé.
- **Scan** : `assistant.ps1 scan` (natif) — ou `/ap-scan-projets` dans l'agent (même logique, source unique) → liste les projets en **3 buckets** (`assistés` — suffixés **mince** (outillage dans le bundle) ou **copie complète** (legacy pré-WP-0025) / `pourraient` (≥1 signal léger : `.git`, `package.json`, `README`…) / `sans signal`) + les `à compléter` (partiels), annonce la phase des projets déjà connus, propose l'ajout aux dossiers « pourraient ».
- **Ajout** : `assistant.ps1 add <dossier>` (natif, jamais d'écrasement) — le pré-existant (`projet.md` ou `_meta/`) est signalé et ignoré.
- **Chez un tiers** : un projet mince sync ne porte pas la config machine (`connexions.local.md` gitignorée) ni le bundle. Son lanceur mince localise le bundle (lecture seule) ; s'il est introuvable, il lance le **bootstrap** : `pointer` (tu donnes l'emplacement) / `chercher` (scan des dossiers) / `installer` (git clone du `assistant_git` de la config partagée) — **annonce + confirmation avant chaque action**, puis propose le harness opencode.
- À l'**activation** d'un projet (« commence le projet X », ou `assistant commence <nom>`), l'agent propose les **add-ons pertinents** d'après les signaux de CE projet (ex. `.git` + remote GitHub → GitHub Issue avec le repo pré-rempli) et remplit le frontmatter du projet (`op_id`, `sp_project`).

## 6. Tests de fumée
- [ ] `opencode --version` OK
- [ ] `install.ps1` / `install.sh` relançable : récap honnête, registre à jour, zéro dossier parasite, **menu natif + conseil affichés à la fin** (scan si projets existants, sinon créer un premier projet)
- [ ] `assistant.ps1 scan` / `./assistant.sh scan` : les racines sont scannées, les 3 buckets affichés, les projets « assistés » annoncés avec leur phase **+ suffixe mince / copie complète**
- [ ] `assistant new <nom>` (dossier temp) : `projet.md` pré-rempli + `01..05/` + `_meta/` + `assistant.ps1/.sh` + `bootstrap.ps1/.sh` + `opencode.json` + config de connexion présents — **SANS** `AGENT-projet.md`, `checklists/`, `tools/`, `.opencode/` (le projet est mince)
- [ ] `assistant add <dossier>` (dossier temp avec contenu pré-existant) : zéro écrasement, les ignorés sont signalés
- [ ] Depuis le projet : `assistant sync` → « Bundle … Version … (référence : latest) », le harness `.opencode/` déployé au 1ᵉʳ `o`, **idempotent** au 2ᵉ sync
- [ ] Scénario tiers : copier le projet (sans `connexions.local.md` ni `.opencode/`) → le lanceur mince détecte l'absence → **bootstrap** (pointer) → délégation au bundle ; les chemins écrits sont en `C:/...`
- [ ] `/ap-scan-projets` + `/ap-statut-projet` dans opencode : appellent le script natif (pas une 2ᵉ implémentation)
- [ ] Dans opencode : `commence le projet Mon-Projet` → l'agent annonce la phase Lancement et propose le PM2-01
