# assistant-projet-pm2 — assistant de constitution de projet PM² (kit Markdown)

> **Ce que c'est** : un **kit Markdown + protocole d'agent IA** qui t'aide à **constituer et mener un projet selon PM²** (v3.0.1). Un projet = un dossier, une note de routage lisible par IA, un template par artefact PM², une checklist par gate de phase.
>
> **L'idée** : l'assistant **te pose les questions** (phase par phase) pour que les artefacts PM² se remplissent — et, au fil du temps, **écoute tes échanges** (mails, réunions, conversations) pour **proposer** quoi mettre où. *Poser la question, c'est aussi t'apprendre à te la poser.*
>
> **Pile par défaut** : n'importe quel agent IA qui lit un dossier (**opencode** par défaut — « le marteau ») + n'importe quel gestionnaire de notes Markdown (**Obsidian** par défaut — « le coffre »).
>
> **Principe** : *tout ce qui est faisable sans IA, se fait sans IA.* Le script natif (`assistant.ps1` / `assistant.sh`) fait le travail déterministe (scanner, classer, lire le frontmatter, copier le kit) ; l'agent ne raisonne que là où c'est nécessaire : **conduire** (mode B), **écouter** (mode C), **décider** (add-ons).

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
     scan               → tes projets existants : liste en 3 buckets (assistés / pourraient / sans signal)
     statut <projet>    → où en est un projet (phase + gate + avancement)
     new <nom>          → créer un projet (kit + _projet neuf)
     add <dossier>      → ajouter le kit à un projet existant (jamais d'écrasement)
     commence <nom>     → L'AGENT : ouvre opencode dans le projet (conduite, mode B/C)
3. Dans l'agent (opencode) :
     /scan                        → le scan natif, présenté et conduit par l'agent
     « commence le projet <Nom> » → démarrer / reprendre un projet PM²
     « crée un projet <Nom> »     → nouveau projet (kit + phase Lancement)
4. Conseil : des projets existants ? commence par scan. Sinon : crée ton premier projet.
```
> Tes projets sont déjà organisés (ex. `code/github/…` + `code/gitlab/…`) ? Garde-les ainsi :
> le kit travaille sur des **racines de projets** (plusieurs dossiers), il ne demande pas de coffre monolithe.

Parcours complet → [`docs/prise-en-main.md`](docs/prise-en-main.md) · détails d'installation → [`docs/install.md`](docs/install.md)

## Le kit (arborescence)
```
assistant.ps1          ← entry-point NATIF (sans IA, sans dépendance) : scan, statut, new, add, commence
assistant.sh           ← équivalent macOS / Linux
install.ps1 / install.sh ← wizard d'installation (1×) : config transversale (env, opencode, racines, connexions)
AGENT-projet.md        ← LA note de routage IA (à lire en premier). Phase, artefacts dus, checklists, connexions.
projet.md              ← fiche projet / fichier maître (frontmatter machine + état de phase)
01 Lancement/          ← PM2-01/02/03 (→ gate RfP)
02 Planification/      ← PM2-04 … PM2-16 (→ gate RfE)
03 Exécution/          ← PM2-18 + livrables
04 Suivi-Controle/     ← PM2-19/21/22 + PM2-27 checklists de sortie de phase
05 Cloture/            ← PM2-33 (→ gate RfC)
checklists/            ← par gate (RfP/RfE/RfC) et par rôle (sponsor/BM/CP)
tools/                 ← gen_templates.py (régénère les squelettes d'artefacts)
docs/                  ← prise en main + installation (marteau / coffre)
_projet/               ← INCEPTION : le repo mené comme son propre projet PM²
                         (fiche.md + backlog/ 1 fichier = 1 WP → exportable
                         vers SuperProductivity / OpenProject, logs/, report/, registry/)
```
> Préfixe `_` = artefact « méta » du repo, pas un dossier de phase PM².
> ⚠️ **Règle de nom** : la note de routage IA s'appelle délibérément `AGENT-projet.md`, **jamais `AGENTS.md`** — dans les écosystèmes d'outils agent, un `AGENTS.md` est auto-chargé et capturerait tout ton contexte global. Le skill/protocole lit `AGENT-projet.md` explicitement.

## La couche inception (`_projet/`)
> ⭐ **Ce kit s'utilise lui-même** (inception). Dans `_projet/` vous retrouvez **exactement ce qui se passe quand on utilise l'assistant sur un projet** : la fiche, le backlog (1 fichier = 1 WP), le journal des sessions, les registres. C'est le kit qui remplit sa propre documentation — un exemple réel, pas une maquette.

`_projet/` tient l'état du repo vu comme projet :
- `fiche.md` — fiche du repo (frontmatter = vérité pour la couche méta)
- `backlog/` — **1 fichier = 1 package de travail** (frontmatter universel, transformable en ticket — voir `_projet/backlog/README.md`)
- `logs/` · `report/` · `registry/` — journal de session, rapports périodiques, registres

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
- **GitHub Issues / GitLab Issues** : les WPs du backlog (`_projet/backlog/`, 1 fichier = 1 WP) sont transformables en tickets (`op_id` / `sp_id` en frontmatter)

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
