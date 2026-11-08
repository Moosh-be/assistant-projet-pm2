# assistant-projet-pm2 — assistant de constitution de projet PM² (le bundle — projets minces)

> **Ce que c'est** : un **assistant Markdown + protocole d'agent IA** qui t'aide à **constituer et mener un projet selon PM²** (v3.0.1). **Le projet est MINCE** : le projet = la **data** (un dossier : `projet.md`, les phases `01..05`, `_meta`) ; l'**outillage** (templates, checklists, protocole, harness agent) = **ce repo, le « bundle »**, pointé par la config de connexion du projet. Un projet sync chez un tiers ne porte que la doc + la config + un lanceur mince + un bootstrap qui retablit le lien vers le bundle **sans IA** (pointer / chercher / installer, annonce + confirmation à chaque action).
>
> **L'idée** : l'assistant **te pose les questions** (phase par phase) pour que les artefacts PM² se remplissent — et, au fil du temps, **écoute tes échanges** (mails, réunions, conversations) pour **proposer** quoi mettre où. *Poser la question, c'est aussi t'apprendre à te la poser.*
>
> **Pile par défaut** : n'importe quel agent IA qui lit un dossier (**opencode** par défaut — « le marteau ») + n'importe quel gestionnaire de notes Markdown (**Obsidian** par défaut — « le coffre »).
>
> **Principe** : *tout ce qui est faisable sans IA, se fait sans IA.* Le script natif (`assistant.ps1` / `assistant.sh`) fait le travail déterministe (scanner, classer, lire le frontmatter, **déployer le projet mince**, pointer le bundle) ; l'agent ne raisonne que là où c'est nécessaire : **conduire** (mode B), **écouter** (mode C), **décider** (add-ons).

<p align="center">
🇫🇷 <b>Français</b> &nbsp;|&nbsp; 🇬🇧 <a href="./README.en.md">English</a>
</p>

## Démarrage rapide
```
1. Lance le script d'installation à la racine du repo :  install.ps1 (Windows) · install.sh (macOS/Linux)
   → il met en place la config transversale : ton environnement, opencode, tes racines de projets (1..N dossiers),
     et les connexions optionnelles (OpenProject, SuperProductivity, GitHub/GitLab Issues).
   Il ne réorganise JAMAIS les dossiers existants. À la fin, il présente le menu natif + un conseil.
2. Le menu natif (sans IA : rapide, gratuit) :  assistant.ps1 (Windows) · assistant.sh (macOS/Linux)
     scan               → tes projets existants : liste en 3 buckets (assistés mince / copie complète · pourraient · sans signal)
     statut <projet>    → où en est un projet (phase + gate + avancement)
     new <nom>          → créer un projet MINCE (doc + config de connexion + lanceur + bootstrap)
     add <dossier>      → ajouter l'assistant (mince) à un projet existant (jamais d'écrasement)
     sync               → (depuis un projet) vérifier le bundle (version) + le harness opencode (remplace update)
     bootstrap          → (depuis un projet) (ré)installer le bundle : pointer / chercher / installer + harness
     commence <nom>     → L'AGENT : ouvre opencode dans le projet (conduite, mode B/C)
3. Dans l'agent (opencode) :
     /ap-scan-projets                 → le scan natif, présenté et conduit par l'agent
     /ap-statut-projet                → le statut natif (phase + gate + avancement)
     « commence le projet <Nom> » → démarrer / reprendre un projet PM²
     « crée un projet <Nom> »     → nouveau projet MINCE (doc + phase Lancement ; l'outillage reste dans le bundle)
4. Conseil : des projets existants ? commence par scan. Sinon : crée ton premier projet.
```
> Tes projets sont déjà organisés (ex. `code/github/…` + `code/gitlab/…`) ? Garde-les ainsi :
> l'assistant travaille sur des **racines de projets** (plusieurs dossiers), il ne demande pas de coffre monolithe.

Parcours complet → [`docs/prise-en-main.md`](docs/prise-en-main.md) · détails d'installation → [`docs/install.md`](docs/install.md)

## Le bundle (arborescence)
```
assistant.ps1 / assistant.sh ← LE MOTEUR natif du bundle (sans IA, sans dépendance) : scan, statut, new, add, sync, bootstrap, commence
install.ps1 / install.sh     ← wizard d'installation (1×) : config transversale (env, opencode, racines, connexions)
.assistant.version           ← la version du bundle (le marqueur que le bootstrap cherche sur disque)
versions/                    ← les versions figées du bundle (assistant_ref: <version> → versions/<version>/)
AGENT-projet.md              ← LA note de routage IA — le projet mince la pointe via son opencode.json
projet.md                    ← template de la fiche projet (pré-rempli à la création : nom + date)
01..05/                      ← les phases PM² (ici : la data du projet méta ; dans un projet créé : vides, la data s'y écrit)
checklists/                  ← par gate (RfP/RfE/RfC) et par rôle (sponsor/BM/CP)
referentiel-templates-PM2.md ← le mapping des templates PM²
tools/                       ← templates/ (les gabarits des projets minces : lanceur, bootstrap, gitignore, fiche) + gen_templates.py
docs/                        ← prise en main + installation (marteau / coffre)
_meta/                       ← INCEPTION : le repo mené comme son propre projet PM²
```
> ⭐ **Le projet est MINCE** : `assistant new` crée un projet qui ne contient que la **doc** (`projet.md`, `01..05`, `_meta`), la **config de connexion** (`_meta/registry/connexions.md` partagée + `connexions.local.md` machine), le **lanceur mince** (`assistant.ps1/.sh`) et le **bootstrap** (`bootstrap.ps1/.sh`). Le reste — templates, checklists, protocole, harness `.opencode/` — **reste dans le bundle**. C'est pour ça qu'un projet sync chez un tiers reste lisible, et c'est pour ça que le bootstrap existe : **sans IA**, il retablit le lien vers le bundle (pointer / chercher / installer), en **annonçant + confirmant chaque action**, puis propose le harness opencode.
> **Versionnage** : pas de breaking change. Si un jour un changement cassant est inévitable, le bundle porte **toutes** les versions (`versions/<ref>/`, les anciennes = rétro-compat) et chaque projet migre **quand il le sent** (`assistant_ref: <version>` dans sa config partagée).
> Préfixe `_` = artefact « méta » du repo, pas un dossier de phase PM².
> ⚠️ **Règle de nom** : la note de routage IA s'appelle délibérément `AGENT-projet.md`, **jamais `AGENTS.md`** — dans les écosystèmes d'outils agent, un `AGENTS.md` est auto-chargé et capturerait tout ton contexte global. Le skill/protocole lit `AGENT-projet.md` explicitement.

## La couche inception (`_meta/`)
> ⭐ **Ce bundle s'utilise lui-même** (inception). Dans `_meta/` vous retrouvez **exactement ce qui se passe quand on utilise l'assistant sur un projet** : la fiche, le backlog (1 fichier = 1 WP), le journal des sessions, les registres. C'est le bundle qui remplit sa propre documentation — un exemple réel, pas une maquette.

`_meta/` tient l'état du repo vu comme projet :
- `fiche.md` — fiche du repo (frontmatter = vérité pour la couche méta)
- `backlog/` — **1 fichier = 1 package de travail** (frontmatter universel, transformable en ticket — voir `_meta/backlog/README.md`)
- `logs/` · `report/` · `registry/` — journal de session, rapports périodiques, registres

## Les 3 modes d'utilisation (dégradation résiliente)
L'assistant se pilote à **3 niveaux**, **chacun fonctionnel seul** — on perd des capacités à chaque cran vers le bas, **jamais les données** :

| Mode | A besoin de | Ce que ça fait |
|---|---|---|
| **1 — Fichier** | rien (un simple drive suffit) | la data seule : templates du bundle copiés à la main, `projet.md` / `01..05` / `_meta` remplis à la main |
| **2 — Exécution natif** | le bundle + PowerShell/bash (**sans IA, sans internet**) | le lanceur mince du projet (le « relai ») délègue au moteur du bundle : `scan`, `statut`, `liste`, `new`, `add`, `sync`, `remark`, `bootstrap` |
| **3 — IA** | opencode (ou tout agent qui lit le dossier) | la session agent applique le protocole `AGENT-projet.md` — **synchrone** (chat) ou **asynchrone** (notes en fichiers texte → discussions isolées, WP-0027) |

- **L'échelle** : IA → natif → fichier. L'IA indisponible → cran natif ; le bundle indisponible → cran fichier. Les données restent lisibles et modifiables à chaque cran.
- **Remonter l'échelle** : le `bootstrap` d'un projet (ex. chez un tiers, depuis une copie bare) retablit le lien vers le bundle — pointer / chercher / installer — **sans IA**, annonce + confirmation à chaque action.

> Ne pas confondre avec les « 3 modes d'**alimentation** » (A/B/C, plus bas) : ceux-là disent **comment la donnée entre** dans les artefacts ; ceux-ci disent **à quel niveau on pilote l'assistant**.

### Dans le mode IA — agent, command, skill
| | C'est quoi | Exemple |
|---|---|---|
| **agent** | **qui parle** : l'identité et le rôle de l'IA — le protocole `AGENT-projet.md` est chargé comme primary | `assistant-projet` |
| **command** | **ce qu'on déclenche** par nom (slash-commande) — pont vers le moteur natif quand c'est faisable sans IA | `/ap-scan-projets`, `/ap-statut-projet` |
| **skill** | **comment faire X bien** : un module de procédure chargé à la demande quand la tâche y correspond | (à venir) |

## Les 3 modes d'alimentation
| Mode | Ce qui se passe |
|---|---|
| **A — Direct** | tu remplis le Markdown toi-même |
| **B — Entretien** | l'agent pose les questions du template et remplit **au fil des données** (pas un interrogatoire en bloc) |
| **C — Écoute passive** ⭐ | l'agent **repère dans tes échanges** ce qui peut remplir un artefact, **propose**, demande validation **sauf si c'est évident** (sinon `[À confirmer]` + source) |

## Gates de phase (PM²)
`Lancement → RfP → Planification → RfE → Exécution → RfC → Clôture`, avec **Suivi & Contrôle** sur toutes les phases. **Un gate bloque la phase suivante** : la checklist de sortie PM2-27 doit être verte avant de passer.

## Connexions (optionnelles, par projet)

**Actuellement implémentées** :
- **SuperProductivity** : 1 WP = 1 tâche (tag `pm2`, frontmatter `sp_id`)
- **OpenProject** : artefacts = docs à importer ; WPS = packages de travail (plus tard : lecture/écriture MCP)
- **GitHub Issues / GitLab Issues** : les WPs du backlog (`_meta/backlog/`, 1 fichier = 1 WP) sont transformables en tickets (`op_id` / `sp_id` en frontmatter)

**Idées de connexions (non implémentées)** — à proposer dans l'issue :
- **Notion** : les artefacts PM² (fiches, PV, rapports) en pages Notion pour une équipe non-Obsidian
- **MCP** (Model Context Protocol) : lecture/écriture directe des outils connectés depuis l'agent (OpenProject déjà ciblé, v. 17.9)
- **Jira / Azure DevOps** : export des WPs vers un ticketing d'entreprise
- **Calendrier (ICS)** : les jalons PM2-15 / dates de gates en invitations de réunion
- **CSV / Excel** : export du tableau d'avancement (section 3 de `projet.md`) pour un reporting managé
- **API Obsidian Local REST** : requêtes directes sur le vault depuis l'agent

> 📬 **Une idée de connexion ? Propose-la** : [issue de suggestions →](https://github.com/Moosh-be/assistant-projet-pm2/issues/1) (outil, usage PM², direction import/export/bidirectionnel, lien API/SDK).

## Forks
- **Ce repo = l'original PUBLIC** (contribution PM² générique, pas de données entreprise).
- **Fork RTBF (privé, GitLab)** : adapte chaque template aux templates Word RTBF v3.0.1 (traduits FR) + rôles/processus RTBF.

## Contribution
PM²-friendly : garde les templates **génériques** (pas de données entreprise dans le repo public). Langue : les templates sont en **français** (la langue de contribution ici) — des variantes en anglais sont les bienvenues.

## Licence
CC BY-SA 4.0 (contenu) · MIT (`tools/`).
