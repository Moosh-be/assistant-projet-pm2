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

## 4. Tests de fumée
- [ ] `opencode --version` OK
- [ ] Vault Obsidian ouvert, dossier `projects/` visible
- [ ] Un projet cloné du kit : `AGENT-projet.md` + `projet.md` + 5 dossiers de phases présents
- [ ] Dans opencode : `commence le projet Mon-Projet` → l'agent annonce la phase Lancement et propose le PM2-01
