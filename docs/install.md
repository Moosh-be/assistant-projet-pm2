# Installation — le marteau (opencode) + le coffre (Obsidian) + le menu natif (assistant.ps1 / .sh)

> Par défaut : **opencode** (agent IA) + **Obsidian** (coffre Markdown).
> Les deux sont interchangeables : n'importe quel **agent qui lit un dossier de Markdown** (opencode, Claude Code, gemini-cli…) + n'importe quel **gestionnaire de notes Markdown** (Obsidian, Logseq, VS Code…). Ici on installe la pile par défaut.

## 1. Le coffre — Obsidian
1. Installer **Obsidian** (https://obsidian.md) — gratuit pour usage perso.
2. **Créer un vault** : « Open folder as vault » → le dossier qui contiendra tes projets (ex. `C:\vault` ou un dossier git).
3. **Aucun plugin requis** par le kit (tout est Markdown + frontmatter). Optionnel recommandé :
   - **Templater** ou **Core Templates** : pour cloner le kit en un clic (§ prise-en-main §6).
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

> **Pourquoi « le marteau » ?** l'agent est l'outil qui frappe : il ne contient pas la connaissance du projet — **c'est le dossier (le kit + AGENT-projet.md) qui la contient**. Changer de marteau ne change rien au projet.

## 3. Le menu natif — `assistant.ps1` / `assistant.sh` (sans IA)

> **Principe** : *tout ce qui est faisable sans IA, se fait sans IA.* Le script natif (sans dépendance, aucun package) fait le travail **déterministe** ; l'agent ne raisonne que pour conduire, écouter, décider.

À la racine du kit :
- Windows : `.\assistant.ps1 <cmd>` (PowerShell 5.1+ / pwsh, ASCII pur)
- macOS / Linux : `./assistant.sh <cmd>`

| Commande | Nature | Ce qu'elle fait |
|---|---|---|
| `scan` | déterministe | les projets des racines : 3 buckets (assistés / pourraient / sans signal) + signaux + phase/gate |
| `statut <projet>` | déterministe | phase + gate + rôles + tickets + tableau d'avancement |
| `new <nom> [racine] [-doc]` | déterministe | crée un projet (kit + `_meta/` neuf, `projet.md` pré-rempli) · **`-doc`** = projet sans code : seul `_meta/` est créé (fiche + squelette), le kit n'est pas copié — à compléter plus tard avec `add` |
| `add <dossier>` | déterministe | ajoute le kit à un projet existant — **jamais d'écrasement** (le pré-existant est signalé et ignoré) |
| `update` *(depuis un projet)* | déterministe | resync les fichiers génériques du kit (WP-0020) : seuls les fichiers **manquants** du kit sont ajoutés — le contenu côté projet est sacré. Origine du kit = `kit_source` (écrite par `new`/`add` dans `_meta/registry/connexions.md`) |
| `commence <nom>` | handoff IA | ouvre opencode dans le projet — l'agent prend le relais (mode B/C) |
| `menu` / `?` | — | le menu |

> **Source unique** : la logique de scan/statut vit **une seule fois** — dans le script. Les commandes opencode `/scan` et `/statut` **l'appellent** ; l'agent présente le résultat et conduit (il ne re-développe pas la logique).

## 4. Brancher le kit (une fois)
```
git clone <url-du-repo> ~/templates/assistant-projet-pm2
```
Puis pour chaque projet : `assistant.ps1 new <Nom>` (création) ou `assistant.ps1 add <dossier>` (projet existant) — ou copier le contenu du kit dans `<vault>/projects/<Projet>/` (bouton Obsidian si le kit est dans les templates).

## 5. Projets déjà organisés (multi-racines)

Tu as déjà tes dossiers de projets, peut-être par plateforme (`code/github/…`, `code/gitlab/…`) ? **Ne change rien** : le kit ne demande jamais de réorganiser, déplacer ou renommer.

- Le wizard d'installation (`install.ps1` / `install.sh`) te demande **où vivent tes projets** : **1 ou plusieurs racines** (pas un « vault » monolithe). **Une racine = un dossier qui *contient* des projets (1 projet = 1 sous-dossier)**. Le wizard propose : le **dossier du kit + 2 niveaux au-dessus** (si tes projets vivent dans le même dossier que le kit — cas le plus fréquent) + **les dossiers à côté** (max 5) ; tu choisis par numéro, ou `A` pour ajouter un chemin (tout autre niveau), `V` pour passer.
- **Racine non vide** → le wizard la liste (« je te montre, tu valides ») et note `déjà rempli, rien ne sera déplacé` dans le registre. **Racine absente** → création **uniquement** si tu confirmes.
- Les racines sont écrites dans la **config machine à la racine du kit** (`.assistant.config`, gitignored — WP-0017 ; le wizard utilise le 1ᵉʳ des 3 noms possibles `.assistant.config` / `assistant.config` / `assistant.config.md`). Les **secrets** (tokens) vivent dans `.assistant-projet.env` (généré par le wizard, saisie masquée), jamais dans la config ni dans un registre.
- Dans chaque projet, le kit = **manifeste** (`projet.md`, frontmatter source de vérité) + couche **`_meta/`** (fiche, backlog, registres). Ajouter le kit à un dossier existant = **copie des fichiers du kit seulement** ; un conflit (`projet.md` ou `_meta/` déjà présent) est signalé, rien n'est écrasé.
- **Scan** : `assistant.ps1 scan` (natif) — ou `/scan` dans l'agent (même logique, source unique) → liste les projets en **3 buckets** (`assistés` / `pourraient` (≥1 signal léger : `.git`, `package.json`, `README`…) / `sans signal`) + les `partiel` à compléter, annonce la phase des projets déjà connus, propose l'ajout du kit aux dossiers « pourraient ».
- **Ajout du kit** : `assistant.ps1 add <dossier>` (natif, jamais d'écrasement) — le pré-existant (`projet.md` ou `_meta/`) est signalé et ignoré.
- À l'**activation** d'un projet (« commence le projet X », ou `assistant commence <nom>`), l'agent propose les **add-ons pertinents** d'après les signaux de CE projet (ex. `.git` + remote GitHub → GitHub Issue avec le repo pré-rempli) et remplit le frontmatter du projet (`op_id`, `sp_project`).

## 6. Tests de fumée
- [ ] `opencode --version` OK
- [ ] `install.ps1` / `install.sh` relançable : récap honnête, registre à jour, zéro dossier parasite, **menu natif + conseil affichés à la fin** (scan si projets existants, sinon créer un premier projet)
- [ ] `assistant.ps1 scan` / `./assistant.sh scan` : les racines du registre sont scannées, les 3 buckets affichés, les projets « assistés » annoncés avec leur phase
- [ ] `assistant new <nom>` (dossier temp) : `projet.md` + `_meta/` neuf + `AGENT-projet.md` présents, `node_modules` absent
- [ ] `assistant add <dossier>` (dossier temp avec contenu pré-existant) : zéro écrasement, les ignorés sont signalés
- [ ] `/scan` + `/statut` dans opencode : appellent le script natif (pas une 2ᵉ implémentation)
- [ ] Dans opencode : `commence le projet Mon-Projet` → l'agent annonce la phase Lancement et propose le PM2-01
