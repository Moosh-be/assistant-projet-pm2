# Guide — assistant-projet-pm2

> Le `README` est la **porte d'entrée** (ce que c'est, démarrage rapide, principes). Cette doc est le
> **guide détaillé** en 6 chapitres :
> 1. [Exemples d'utilisation](#1-exemples-dutilisation)
> 2. [Installation et mise en place](#2-installation-et-mise-en-place)
> 3. [Perspectives d'évolution](#3-perspectives-dévolution)
> 4. [Personnalisation](#4-personnalisation)
> 5. [Connexions](#5-connexions)
> 6. [Méthodes](#6-méthodes)
>
> **Sources de vérité** : le code du moteur (`assistant.ps1` / `assistant.sh`), le protocole
> (`AGENT-projet.md`) et la config machine — cette doc les résume, elle ne les remplace pas.

## 1. Exemples d'utilisation

### 1.1 Découvrir mes projets existants

Depuis le bundle ou l'une des racines de projets :

- `.\assistant.ps1 scan` (Windows) · `./assistant.sh scan` (macOS/Linux)
  → les projets des racines, classés en 3 buckets : **assistés** (mince / copie complète) ·
  **pourraient** (signal PM²) · **sans signal**.
- `assistant menu` **hors projet** → la **vue portefeuille** : tous les projets + l'état du gate
  de chacun + les projets « à pousser » (gate non vert).
- `assistant statut <projet>` → où en est un projet par son nom (phase + gate + avancement).

### 1.2 Créer un projet et le mener

1. `assistant new Mon-Projet` → crée un projet **MINCE** : la doc (`projet.md` + `01..05` + `_meta/`
   neuf), la config de connexion, le lanceur mince, le bootstrap. L'outillage reste dans le bundle.
2. `assistant commence Mon-Projet` (ou ouvrir opencode dans le dossier) → l'agent annonce la
   **phase Lancement** + le **gate RfP** et propose le premier artefact dû (PM2-01).
3. **Entretien (mode B)** : l'agent pose les questions du template **au fil de l'eau** (pas un
   interrogatoire en bloc) — chaque réponse remplit un champ. Toute donnée non validée est marquée
   `[À confirmer]` + sa source.
4. **Écoute passive (mode C)** : au fil des échanges (mails, réunions, conversations), l'agent
   **repère** ce qui peut remplir un artefact et **propose** l'inscription (validation sauf si évident).
5. **Gate** : la checklist de sortie (PM2-27) doit être verte pour passer de phase.
   `assistant menu` **dans le projet** → l'état + les actions à envisager au vu de l'état.

### 1.3 Les 3 modes d'utilisation (dégradation résiliente)

L'assistant se pilote à **3 niveaux**, chacun fonctionnel seul — on perd des capacités à chaque cran
vers le bas, **jamais les données** :

| Mode | A besoin de | Ce que ça fait |
|---|---|---|
| **1 — Fichier** | rien (un simple drive suffit) | la data seule : templates du bundle copiés à la main, `projet.md` / `01..05` / `_meta` remplis à la main |
| **2 — Exécution natif** | le bundle + PowerShell/bash (**sans IA, sans internet**) | le lanceur mince du projet délègue au moteur du bundle : `scan`, `statut`, `menu`, `liste`, `new`, `add`, `sync`, `remark`, `bootstrap` |
| **3 — IA** | opencode (ou tout agent qui lit le dossier) | la session agent applique le protocole `AGENT-projet.md` — **synchrone** (chat) ou **asynchrone** (notes en fichiers texte → discussions isolées, WP-0027) |

- **L'échelle** : IA → natif → fichier. L'IA indisponible → cran natif ; le bundle indisponible →
  cran fichier. Les données restent lisibles et modifiables à chaque cran.
- **Remonter l'échelle** : le `bootstrap` d'un projet (ex. chez un tiers, depuis une copie bare)
  retablit le lien vers le bundle — pointer / chercher / installer — **sans IA**, annonce +
  confirmation à chaque action, puis propose le harness opencode.

### 1.4 Les 3 modes d'alimentation

| Mode | Ce qui se passe |
|---|---|
| **A — Direct** | tu remplis le Markdown toi-même |
| **B — Entretien** | l'agent pose les questions du template et remplit **au fil des données** |
| **C — Écoute passive** ⭐ | l'agent **repère dans tes échanges** ce qui peut remplir un artefact, **propose**, demande validation **sauf si c'est évident** (sinon `[À confirmer]` + source) |

### 1.5 Dans le mode IA — agent, command, skill

| | C'est quoi | Exemple |
|---|---|---|
| **agent** | **qui parle** : l'identité et le rôle de l'IA — le protocole `AGENT-projet.md` est chargé comme primary | `assistant-projet` |
| **command** | **ce qu'on déclenche** par nom (slash-commande) — pont vers le moteur natif quand c'est faisable sans IA | `/ap-scan-projets`, `/ap-statut-projet`, `/assistant-menu` |
| **skill** | **comment faire X bien** : un module de procédure chargé à la demande quand la tâche y correspond | (à venir) |

### 1.6 Au fil de l'eau, sans ouvrir de session

- `assistant remark '<texte>'` (depuis un projet) → journal des remarques au vol
  (`_meta/registry/remarques.md`) — à remonter au projet assistant si marqué `[pour l'assistant]`.
- `assistant sync` (depuis un projet) → vérifie le bundle (version) + le harness opencode.

## 2. Installation et mise en place

**Pile par défaut** : **opencode** (« le marteau ») + **Obsidian** (« le coffre ») — les deux sont
interchangeables : n'importe quel **agent qui lit un dossier Markdown** + n'importe quel
**gestionnaire de notes Markdown**. Détails complets → [`install.md`](install.md).

> **Premier contact, machine neuve** → [`comment-commencer.md`](comment-commencer.md) : le parcours
> étape par étape (repo → démarrage → opencode optionnel → inventaire → méthodes → outils → scan →
> changement de root), chaque étape taguée ✅ aujourd'hui / 🔜 à venir (WP).

### 2.1 Le coffre — Obsidian

1. Installer [Obsidian](https://obsidian.md) (gratuit pour usage perso).
2. Créer un vault (« Open folder as vault ») → le dossier qui contiendra tes projets.
3. Aucun plugin requis (tout est Markdown + frontmatter). Optionnel recommandé : Templater /
   Core Templates (cloner un squelette en un clic).
4. Recommandé : vault sous git → chaque projet versionné.

### 2.2 Le marteau — opencode

1. Prérequis : **Node.js ≥ 18**.
2. `npm install -g opencode-ai` puis `opencode --version` pour vérifier.
3. Première fois : `opencode /login` (ou configurer provider/LLM).
4. Lancer dans un projet : `cd <projet>` puis `opencode`.

> **Pourquoi « le marteau » ?** L'agent ne contient pas la connaissance du projet — c'est le
> **dossier projet (la data) + le bundle (l'outillage)** qui la contiennent. Changer de marteau
> ne change rien au projet.

### 2.3 Le bundle — wizard + config machine

1. À la racine du repo : `install.ps1` (Windows) · `install.sh` (macOS/Linux).
   → **config transversale** : environnement, opencode, **racines de projets** (1..N dossiers),
   connexions optionnelles. Il **ne réorganise JAMAIS** les dossiers existants ; à la fin :
   menu natif + un conseil.
2. **Config machine** : `.assistant.config` à la racine du kit (gitignorée) — `meta_folder`
   (défaut `_meta`), les racines, les connexions.
3. **Dans chaque projet** (créé par `new`/`add`) : lanceur mince (`assistant.ps1`/`.sh`),
   bootstrap, `opencode.json` pointant sur l'`AGENT-projet.md` **du bundle** + les **skills**
   du bundle (`.opencode/skills`, chemin absolu — **pointées, jamais copiées** : WP-0050)
   + copie machine du harness (`.opencode/agent` + `.opencode/command`, créée par `sync` /
   `bootstrap`). Le projet ne porte pas lui-même le protocole.

### 2.4 Versionnement du bundle

Pas de breaking change. Si un changement cassant est inévitable, le bundle porte **toutes** les
versions (`versions/<ref>/`, les anciennes = rétro-compat) et chaque projet migre **quand il le
sent** (`assistant_ref: <version>` dans sa config partagée).

## 3. Perspectives d'évolution

> Ancré dans du tracé (WPs) ou déjà annoncé — jamais du futur présenté comme présent.

### 3.1 Méthodes (→ §6)

- **PfM2** (gestion du portefeuille) : première méthode à joindre PM2 — série WP-0028→0032
  (scope multi-niveaux, attributs, connecteurs de synchro) + WP-0036 (ajouter un projet) +
  WP-0037 (registre d'inventaire machine dans la vue portefeuille).
- **PMFLEX**, SAFe, Scrum, PRINCE2, PMP, Lean, Lean6Sigma : **places réservées** dans `methode/`.
- **v2 des méthodes** : descripteur par dossier (`methode/<M>/<lang>/methode.md`) + le frontmatter
  `methode:` du projet pilote `new` / `statut` / `menu` (aujourd'hui PM2-FR est la seule méthode
  et le défaut).

### 3.2 Moteur et menu (WP-0039 v2)

- **État du gate réel** : `menu` lira la checklist du bundle (items verts/rouges) au lieu du
  seul check de la table d'avancement.
- Factoriser la lecture d'état entre `statut` et `menu`.
- Registre d'inventaire machine (WP-0037) dans la vue portefeuille.

### 3.3 Connexions (→ §5)

- **OpenProject MCP (17.9)** : lecture/écriture directe des outils connectés depuis l'agent.
- Export automatique du backlog : `tools/backlog_to_sp.py` / `backlog_to_op.py` (à venir).
- **Idées non implémentées** (à proposer dans l'issue) : Notion, Jira / Azure DevOps,
  calendrier ICS (jalons + dates de gates), CSV/Excel (tableau d'avancement),
  API Obsidian Local REST.

### 3.4 Forge et IA (WP-0038)

- **Règle forge** : un espace git → le MCP de sa forge (GitHub déjà global ; GitLab : binaire +
  token à prévoir sur la machine).
- **Skills opencode** : modules de procédure chargés à la demande (la case « skill » du §1.5
  est « à venir »).

### 3.5 Fork RTBF (privé, GitLab)

Adaptation de chaque template aux templates Word RTBF v3.0.1 (traduits FR) + rôles/processus
RTBF. Politique **one-way** : les customisations RTBF ne reviennent pas dans le public GitHub.

## 4. Personnalisation

### 4.1 La config machine (`.assistant.config`)

À la racine du kit (gitignorée, wizard-générée) : les **racines de projets** (1..N dossiers),
`meta_folder` (défaut `_meta`), les **connexions**. Réinitialisable : `install.ps1` / `install.sh`.

### 4.2 Le protocole et le harness

- **`AGENT-projet.md`** (racine du bundle) : la note de routage IA. Délibérément **jamais
  `AGENTS.md`** — dans les écosystèmes d'outils agent, un `AGENTS.md` est auto-chargé et
  capturerait tout le contexte global ; ici c'est le protocole qui la lit explicitement.
- **Harness par projet** : `.opencode/` (agent `assistant-projet` + slash-commandes) — déployé
  par `sync` / `bootstrap`, pointé par l'`opencode.json` du projet. Les **skills** (`ap-pm2-*`)
  ne se copient pas : l'`opencode.json` du projet les **pointe** dans le bundle
  (`"skills": ["<bundle>/.opencode/skills"]`) — une copie deviendrait stale à chaque
  régénération ; pointée, elle est toujours fraîche (WP-0050).
- **Convention des noms** : noms ASCII (`04 Suivi-Controle`, `05 Cloture`, `methode`),
  frontmatter YAML machine + corps lisible, `[À confirmer]` + source sur toute donnée non validée.

### 4.3 Une méthode = un dossier (→ §6)

`methode/<M>/<lang>/` : les templates de phases, les checklists (gates + rôles), le referentiel.
Ajouter une méthode = créer le dossier + son contenu (le hook `methode:` du projet viendra en v2).

### 4.4 Forks et langues

- **Repo public** = la contribution PM² **générique** (pas de données entreprise).
- **Fork RTBF** (privé) = l'adaptation entreprise (Word v3.0.1, rôles/processus RTBF).
- Langue : les templates sont en **français** (langue de contribution) — variantes en anglais
  bienvenues (README.fr / README.en).

## 5. Connexions

> Optionnelles, **par projet** : la config de connexion vit dans `_meta/registry/connexions.md`
> (partagée, voyage avec le projet) + `connexions.local.md` (machine, gitignorée :
> `assistant_local` = le bundle sur CETTE machine, `assistant_ref`, `assistant_git`).

### 5.1 Implémentées

| Outil | Usage |
|---|---|
| **SuperProductivity** | 1 WP / tâche du plan de travail = 1 tâche (tag `pm2`, `sp_id` dans le frontmatter) |
| **OpenProject** | l'artefact MD = **doc à importer** ; le WP = package de travail (`op_id`) — plus tard : lecture/écriture directe via MCP (17.9) |
| **GitHub / GitLab Issues** | les WPs du backlog (`_meta/backlog/`, 1 fichier = 1 WP) sont transformables en tickets |

**Règle forge (WP-0038)** : un espace git → le MCP de sa forge (GitHub global ; GitLab :
binaire + token à prévoir). HA (Home Assistant) : jamais dans un espace projet.

### 5.2 Idées (non implémentées — à proposer dans l'issue)

- **Notion** : les artefacts PM² (fiches, PV, rapports) en pages Notion pour une équipe non-Obsidian
- **MCP** (Model Context Protocol) : lecture/écriture directe des outils connectés depuis l'agent
  (OpenProject déjà ciblé, v. 17.9)
- **Jira / Azure DevOps** : export des WPs vers un ticketing d'entreprise
- **Calendrier (ICS)** : les jalons / dates de gates en invitations de réunion
- **CSV / Excel** : export du tableau d'avancement (section 3 de `projet.md`) pour un reporting managé
- **API Obsidian Local REST** : requêtes directes sur le vault depuis l'agent

> 📬 **Une idée de connexion ? Propose-la** : [issue de suggestions →](https://github.com/Moosh-be/assistant-projet-pm2/issues/1)
> (outil, usage PM², direction import/export/bidirectionnel, lien API/SDK).

## 6. Méthodes

> **Une méthode** = la trame de la data d'un projet (les dossiers de phase, les gates, les
> checklists de rôles, les templates d'artefacts) + l'outillage qui va avec. Le frontmatter
> `methode:` du projet (ex. `PM2`) est le hook.

### 6.1 L'arborescence

```
methode/
├── PM2/fr/            ← PM² français (aujourd'hui, la seule méthode)
│   ├── 01 Lancement/ … 05 Cloture/   (templates PM2-01…33)
│   ├── checklists/          (gate-RfP/RfE/RfC, role-*)
│   └── referentiel-templates-PM2.md
├── PfM2/fr/           ← à venir : gestion du portefeuille
├── PMFLEX/fr/         ← à venir
└── (SAFe, Scrum, PRINCE2, PMP, Lean, Lean6Sigma…) ← places réservées
```

### 6.2 PM² (v3.0.1) en une ligne

`Lancement → RfP → Planification → RfE → Exécution → RfC → Clôture`, avec **Suivi & Contrôle**
sur toutes les phases. **Un gate bloque la phase suivante** : la checklist de sortie PM2-27 doit
être verte avant de passer. 4 rôles piliers : sponsor · Business Manager · Chef de projet /
Gestionnaire · MOE / Fournisseur.

### 6.3 Projet mince et méthodes

Les projets **minces** gardent leurs `01..05` **à leur racine** (c'est leur data, selon leur
méthode) : `new` / `add` créent ces dossiers **vides** à partir des **noms** lus dans
`methode/PM2/fr/` (source unique des noms de phases). L'outillage de la méthode reste dans le
bundle — c'est pour ça que le projet sync chez un tiers reste lisible.
