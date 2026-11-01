# Installation — le marteau (opencode) + le coffre (Obsidian)

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

## 3. Brancher le kit (une fois)
```
git clone <url-du-repo> ~/templates/assistant-projet-pm2
```
Puis pour chaque projet : copier le contenu du kit dans `<vault>/projects/<Projet>/` (ou bouton Obsidian si le kit est dans les templates).

## 4. Projets déjà organisés (multi-racines)

Tu as déjà tes dossiers de projets, peut-être par plateforme (`code/github/…`, `code/gitlab/…`) ? **Ne change rien** : le kit ne demande jamais de réorganiser, déplacer ou renommer.

- Le wizard d'installation (`install.ps1` / `install.sh`) te demande **où vivent tes projets** : **1 ou plusieurs racines** (pas un « vault » monolithe). Il liste les dossiers détectés à côté du kit ; tu choisis par numéro, ou `A` pour ajouter un chemin, `V` pour passer.
- **Racine non vide** → le wizard la liste (« je te montre, tu valides ») et note `déjà rempli, rien ne sera déplacé` dans le registre. **Racine absente** → création **uniquement** si tu confirmes.
- Les racines sont écrites dans `_projet/registry/connexions.md` (ligne `- racines:`).
- Dans chaque projet, le kit = **manifeste** (`projet.md`, frontmatter source de vérité) + couche **`_projet/`** (fiche, backlog, registres). Ajouter le kit à un dossier existant = **copie des fichiers du kit seulement** ; un conflit (`projet.md` ou `_projet/` déjà présent) est signalé, rien n'est écrasé.
- Dans l'agent : **`/scan`** → scanne les racines, classe chaque dossier (`kit` / `partiel` / `plain`), annonce la phase des projets déjà connus, propose l'ajout du kit aux plain.

## 5. Tests de fumée
- [ ] `opencode --version` OK
- [ ] `install.ps1` / `install.sh` relançable : récap honnête, registre à jour, zéro dossier parasite
- [ ] `/scan` : les racines du registre sont scannées, les projets « kit » annoncés avec leur phase
- [ ] Un projet cloné du kit : `AGENT-projet.md` + `projet.md` + 5 dossiers de phases présents
- [ ] Dans opencode : `commence le projet Mon-Projet` → l'agent annonce la phase Lancement et propose le PM2-01
