# assistant-projet-pm2 (nom provisoire)

**Une plateforme Markdown souveraine, résiliente et interopérable pour gérer des objets métier et des activités, avec PM² comme première méthode de gouvernance implémentée.**

> **Le projet a commencé comme un assistant de constitution de projets PM². Il devient progressivement quelque chose de plus général : une couche indépendante entre tes activités, tes méthodes et les outils qui les hébergent.**
>
> Un projet, une action, un package de travail, un risque ou une décision ne devrait pas cesser d'exister parce qu'on change d'outil. L'objectif est donc de représenter ces **objets métier sous une forme durable, lisible par un humain et exploitable par une machine**, puis de laisser les méthodes, les outils externes et l'IA travailler autour de cette représentation.
>
> **Le principe de base est volontairement simple : 1 fichier Markdown = 1 objet métier.**

Chaque objet associe :

- un **frontmatter structuré**, qui porte les propriétés nécessaires pour identifier, relier, filtrer, transformer ou synchroniser l'objet ;
- un **corps Markdown libre**, destiné aux humains : contexte, explications, décisions, notes, historique, références...

Par exemple :

```text
---
type: work-package
id: WP-0027
status: in-progress
project: assistant-projet-pm2
---

# WP-0027

Pourquoi ce travail existe, ce qui a été décidé,
les éléments utiles pour le comprendre, les notes de travail...
```

Cette convention volontairement légère constitue le socle du projet.

## Pourquoi faire ça ?

Parce que nos activités finissent rapidement dispersées entre des outils qui possèdent chacun leur représentation du travail :

**Jira, Microsoft Planner, Microsoft To Do, OpenProject, SuperProductivity, GitHub/GitLab Issues, Ivanti, Excel, SharePoint...**

L'objectif n'est pas de fabriquer **encore un outil qui remplacerait tous les autres**.

L'objectif est de disposer d'une **représentation indépendante des objets métier** sur laquelle peuvent venir se brancher :

- des méthodes de gouvernance ;
- des outils de gestion ;
- des connecteurs d'import/export ou de synchronisation ;
- des vues et du reporting ;
- des automatisations ;
- des assistants humains ou IA.

Autrement dit :

**les fichiers portent les objets métier ; les outils viennent les exploiter.**

PM² est aujourd'hui la première méthode réellement implémentée parce que c'est le besoin qui a fait naître le projet. **PM² n'est cependant pas destiné à devenir une limite de l'architecture.**

## Quatre principes structurants

### 🛟 Résilient : les données survivent à l'outillage

Le niveau minimal du système est un ensemble de **fichiers Markdown ordinaires**.

L'IA peut disparaître.  
OpenCode peut disparaître.  
Obsidian peut disparaître.  
Les scripts peuvent disparaître.  
Le bundle lui-même peut temporairement être indisponible.

Il reste des fichiers lisibles et modifiables avec un simple éditeur de texte.

On descend donc progressivement :

**IA → automatisation native → fichiers**

On perd des capacités, **jamais les données**.

La résilience recherchée n'est pas seulement une stratégie de sauvegarde : c'est la capacité du système à **se dégrader sans enfermer l'information dans la couche technique qui l'exploitait**.

### 🔐 Souverain : tes objets sont dans l'espace de fichiers que tu choisis

Le projet n'impose pas un serveur ou une base de données propriétaire pour que tes objets métier existent.

Ils peuvent vivre dans l'espace de fichiers adapté à ton contexte :

- un dossier local ;
- un disque externe ;
- Git ;
- un NAS ;
- OneDrive ;
- un espace synchronisé ;
- ou toute autre solution capable d'héberger des fichiers.

L'emplacement n'est pas le principe.

**Le principe est que le stockage reste sous le contrôle de son propriétaire et qu'il puisse être utilisé indépendamment de l'application qui l'exploite.**

Le projet ne demande pas non plus de réorganiser un environnement existant en un coffre monolithique : plusieurs **racines d'activités ou de projets** peuvent être déclarées et conservées telles quelles.

### 🌍 Universel : les méthodes enrichissent le modèle, elles ne l'enferment pas

Le projet part volontairement de ce qui est utilisé aujourd'hui.

La première implémentation est donc fortement structurée autour de **PM² v3.0.1** et de ses phases, artefacts, rôles et gates.

Mais l'architecture n'a pas vocation à décréter que toute activité est un projet PM².

D'autres pratiques et méthodes doivent pouvoir enrichir les objets et les processus sans remettre en cause le socle :

- PfM² ;
- Scrum ;
- Kanban ;
- Lean ;
- ITIL ;
- méthodes internes ;
- ou simplement une activité ne suivant aucun framework formalisé.

**Le cœur reste ouvert ; la gouvernance est une couche.**

### 🔌 Interopérable : Markdown comme format pivot

Markdown est suffisamment simple pour l'humain et suffisamment structurable pour la machine.

Le frontmatter permet de convertir les propriétés d'un ensemble d'objets vers des représentations plus structurées :

**Markdown ⇄ JSON / CSV / listes / API / tickets / bases tabulaires**

et le corps du document conserve l'information qui résiste mal à la réduction en colonnes : contexte, raisonnement, décisions, explications, notes...

Cela ouvre la voie aux connecteurs avec les outils réellement utilisés par les personnes et les organisations, sans leur demander de migrer vers un outil unique.

**L'interopérabilité ne consiste donc pas à imposer un nouvel endroit où travailler. Elle consiste à pouvoir échanger et transformer les objets entre les endroits où le travail existe déjà.**

---

## Et l'assistant dans tout ça ?

Il reste important, mais il n'est plus nécessaire de considérer **l'assistant comme le cœur du système**.

L'assistance est une manière d'interagir avec ces objets.

Aujourd'hui, l'assistant sait notamment accompagner la constitution et la conduite d'un projet PM² :

- il **pose les questions** correspondant aux artefacts et aux phases ;
- il remplit progressivement la documentation avec toi ;
- il peut **écouter tes échanges** et proposer ce qui mérite d'être reporté dans les objets appropriés ;
- il utilise les scripts natifs pour tout ce qui ne nécessite aucun raisonnement.

> *Poser la question, c'est aussi t'apprendre à te la poser.*

L'IA est donc une couche facultative au-dessus des objets métier, pas une condition nécessaire à leur existence.

**Principe : tout ce qui est faisable sans IA se fait sans IA.**

Les scripts natifs (`assistant.ps1` / `assistant.sh`) assurent les opérations déterministes : scanner, classer, lire le frontmatter, créer un projet mince, contrôler son état, retrouver le bundle ou rétablir une connexion.

L'agent intervient là où raisonner ou dialoguer apporte quelque chose : **conduire, écouter, interpréter et proposer**.

---

## État actuel : PM² est le premier cas d'usage complet

Cette ambition plus large est la direction du projet.

**L'implémentation actuelle reste centrée sur la gestion de projet PM² v3.0.1.**

C'est important : le repo ne prétend pas encore fournir une plateforme universelle déjà terminée.

Aujourd'hui, il permet concrètement de :

- créer et maintenir des **projets PM² minces** ;
- gérer les phases `01..05`, gates, checklists et artefacts ;
- maintenir un backlog où **1 fichier = 1 package de travail** ;
- piloter les projets sans IA avec PowerShell/bash ;
- les accompagner avec un agent IA ;
- fonctionner sur plusieurs racines de projets ;
- connecter progressivement ces objets à des systèmes tiers.

Tu peux donc **le tester aujourd'hui comme assistant PM²**, tout en expérimentant le modèle plus général vers lequel le projet évolue.

---

## Démarrage rapide

```text
1. Lance le script d'installation à la racine du repo :

   install.ps1    Windows
   install.sh     macOS/Linux

   Il met en place la config transversale :
   - ton environnement ;
   - OpenCode ;
   - tes racines de projets (1..N dossiers) ;
   - les connexions optionnelles.

   Il ne réorganise JAMAIS les dossiers existants.

2. Utilise le menu natif, sans IA :

   assistant.ps1     Windows
   assistant.sh      macOS/Linux

   scan               → liste les projets existants
   statut <projet>    → phase + gate + avancement
   new <nom>          → crée un projet MINCE
   add <dossier>      → ajoute l'assistant à un projet existant
   sync               → vérifie bundle + harness OpenCode
   bootstrap          → (ré)installe ou retrouve le bundle
   commence <nom>     → ouvre OpenCode dans le projet

3. Ou passe par l'agent :

   /ap-scan-projets
   /ap-statut-projet
   « commence le projet <Nom> »
   « crée un projet <Nom> »

4. Tu as déjà des projets ?

   Commence par : scan

   Tu pars de zéro ?

   Crée ton premier projet.
```

> Tes projets sont déjà organisés, par exemple dans `code/github/…` et `code/gitlab/…` ?
>
> **Garde-les ainsi.** L'assistant travaille sur plusieurs racines et ne demande pas de déplacer les projets dans un coffre centralisé.

Parcours complet → [`docs/prise-en-main.md`](docs/prise-en-main.md)  
Installation détaillée → [`docs/install.md`](docs/install.md)

---

## Le principe du « projet mince »

Le projet ne doit pas embarquer l'outil nécessaire pour le gérer.

Le **projet porte ses données**.  
Le **bundle porte l'outillage**.

Un projet créé par l'assistant contient donc essentiellement :

- `projet.md` ;
- les phases `01..05` ;
- `_meta/` ;
- sa configuration de connexion ;
- un lanceur mince ;
- un bootstrap.

Templates, checklists, protocole et harness d'agent restent dans ce repo : **le bundle**.

Cela permet notamment de synchroniser ou remettre un projet à un tiers sans embarquer toute l'usine autour de lui.

Le projet reste lisible par lui-même.

> Le bootstrap peut, **sans IA**, rétablir le lien entre un projet et son bundle : pointer vers un bundle connu, le chercher ou l'installer. Les actions sont annoncées et confirmées.

### Versionnage

Le principe est de ne pas introduire de breaking change.

Si un changement cassant devient inévitable, le bundle peut conserver plusieurs versions :

`versions/<ref>/`

Chaque projet indique la version qu'il utilise avec :

`assistant_ref: <version>`

Un ancien projet peut donc continuer à fonctionner et migrer lorsqu'on le décide plutôt que lorsque l'outil l'impose.

---

## Le bundle

```text
assistant.ps1 / assistant.sh
    ← moteur natif : scan, statut, new, add, sync, bootstrap, commence

install.ps1 / install.sh
    ← installation et configuration transversale

.assistant.version
    ← version du bundle

versions/
    ← versions figées et rétrocompatibilité

AGENT-projet.md
    ← protocole de routage IA

projet.md
    ← template de la fiche projet

01..05/
    ← phases PM²

checklists/
    ← gates et rôles PM²

referentiel-templates-PM2.md
    ← mapping des templates PM²

tools/
    ← gabarits des projets minces + outils

docs/
    ← prise en main et installation

_meta/
    ← ce repo géré comme son propre projet
```

> ⚠️ La note de routage IA s'appelle volontairement `AGENT-projet.md`, **jamais `AGENTS.md`**.
>
> Dans plusieurs écosystèmes d'agents, `AGENTS.md` peut être chargé automatiquement et capturer un contexte global. Ici, le protocole charge explicitement `AGENT-projet.md`.

---

## Inception : le projet s'utilise lui-même

Ce bundle constitue également un exemple réel de son modèle.

Le dossier `_meta/` contient l'état du repo lorsqu'il est considéré lui-même comme une activité/projet :

- `fiche.md` — propriétés structurantes du repo ;
- `backlog/` — **1 fichier = 1 package de travail** ;
- `logs/` — journal des sessions ;
- `report/` — rapports périodiques ;
- `registry/` — registres.

Le projet remplit donc sa propre documentation en l'utilisant.

**Ce n'est pas une maquette de démonstration : son propre développement est un cas d'utilisation.**

---

## Les 3 niveaux de fonctionnement : dégradation résiliente

Chaque niveau reste fonctionnel seul.

| Niveau | Nécessite | Capacités |
|---|---|---|
| **1 — Fichier** | Un espace de fichiers | Lire et modifier directement les objets Markdown |
| **2 — Natif** | Bundle + PowerShell/bash | Scanner, créer, contrôler, connecter, bootstrapper... sans IA ni Internet |
| **3 — IA** | Un agent capable de lire le dossier | Conduire les entretiens, interpréter, écouter et proposer |

La dégradation fonctionne ainsi :

**IA → natif → fichier**

À chaque cran, on perd des commodités.

**On ne perd jamais les objets métier.**

Et le `bootstrap` permet ensuite de remonter l'échelle en rétablissant la connexion avec le bundle.

---

## Dans le mode IA : agent, command, skill

| Concept | Rôle | Exemple |
|---|---|---|
| **agent** | Qui dialogue et porte le rôle d'assistance | `assistant-projet` |
| **command** | Action explicitement déclenchée, notamment vers le moteur natif | `/ap-scan-projets`, `/ap-statut-projet` |
| **skill** | Procédure spécialisée chargée lorsque le contexte le nécessite | à venir |

La pile par défaut utilise actuellement :

- **OpenCode** comme agent capable de lire et travailler sur le dossier, « le marteau » ;
- **Obsidian** comme environnement de consultation et d'édition Markdown, « le coffre ».

Ils sont des **choix par défaut, pas des dépendances conceptuelles**.

Tout agent capable de travailler sur les fichiers peut potentiellement remplacer OpenCode.

Tout environnement capable d'éditer du Markdown peut remplacer Obsidian.

---

## Les 3 modes d'alimentation

À ne pas confondre avec les trois niveaux de fonctionnement précédents.

Ils répondent à une autre question : **comment l'information entre-t-elle dans les objets ?**

| Mode | Fonctionnement |
|---|---|
| **A — Direct** | Tu modifies directement le Markdown |
| **B — Entretien** | L'agent pose progressivement les questions pertinentes et alimente les objets |
| **C — Écoute passive** ⭐ | L'agent repère dans les échanges les informations potentiellement pertinentes et propose leur intégration |

En mode C, l'assistant demande validation lorsque nécessaire. Une information encore incertaine peut être enregistrée comme `[À confirmer]` avec sa source plutôt que transformée prématurément en fait.

---

## Gouvernance PM² actuellement implémentée

Le parcours actuel suit PM² :

**Lancement → RfP → Planification → RfE → Exécution → RfC → Clôture**

avec **Suivi & Contrôle** pendant l'ensemble du cycle.

Un gate conditionne la phase suivante : la checklist de sortie correspondante doit être validée avant le passage.

Cette logique appartient à la **couche PM²** du projet.

Elle ne doit pas devenir une contrainte universelle imposée à tous les futurs types d'activité.

---

## Connexions

Les connecteurs matérialisent progressivement le principe selon lequel **les objets métier existent indépendamment des outils qui les consomment**.

### Actuellement implémentées

- **SuperProductivity** : 1 WP = 1 tâche, avec tag `pm2` et `sp_id` en frontmatter ;
- **OpenProject** : artefacts importables comme documents, WPs comme packages de travail ; lecture/écriture MCP envisagée ;
- **GitHub Issues / GitLab Issues** : les WPs Markdown de `_meta/backlog/` peuvent être transformés en tickets.

### Connexions envisagées

- **Notion** — publication des artefacts sous forme de pages ;
- **MCP (Model Context Protocol)** — lecture/écriture directe vers des systèmes connectés ;
- **Jira / Azure DevOps** — synchronisation avec le ticketing d'entreprise ;
- **Ivanti** — intégration des objets issus de la gestion de services et d'activités ;
- **Microsoft Planner / Microsoft To Do** — tâches et actions ;
- **Calendrier / ICS** — jalons et gates ;
- **CSV / Excel** — tableaux d'avancement et reporting ;
- **SharePoint / listes structurées** — exposition des propriétés des objets ;
- **Obsidian Local REST API** — requêtes directes sur un espace Obsidian.

L'objectif à terme n'est cependant pas d'accumuler des intégrations spécifiques.

C'est d'établir un **modèle d'échange suffisamment simple pour qu'un nouvel outil puisse devenir un producteur, un consommateur ou un synchronisateur d'objets métier.**

📬 Une idée de connexion ? [Propose-la dans l'issue dédiée](https://github.com/Moosh-be/assistant-projet-pm2/issues/1) en précisant l'outil, le cas d'usage, la direction souhaitée (import, export ou bidirectionnel) et, si disponible, son API/SDK.

---

## Forks

- **Ce repo est l'original public** : contribution générique, sans données d'entreprise.
- **Fork RTBF privé, GitLab** : adaptation aux templates Word RTBF PM² v3.0.1, aux traductions françaises et aux rôles/processus internes.

Cette séparation est volontaire : les spécificités d'une organisation ne doivent pas devenir des contraintes du modèle générique.

---

## Contribution

Les contributions sont les bienvenues, notamment autour de :

- nouveaux types d'objets métier ;
- nouvelles méthodes et pratiques ;
- connecteurs ;
- transformations Markdown ↔ formats structurés ;
- automatisations natives ;
- procédures/skills pour les agents ;
- amélioration de la couche PM² existante.

Pour PM², conserver des templates **génériques** et ne pas introduire de données spécifiques à une entreprise dans le repo public.

La langue principale actuelle des templates est le **français**. Les variantes anglaises sont bienvenues.

---

## Licence

**CC BY-SA 4.0** pour le contenu.  
**MIT** pour `tools/`.

---

### En une phrase

**Des objets métier en Markdown qui t'appartiennent, des méthodes pour les gouverner, des connecteurs pour les échanger, et de l'IA quand elle apporte réellement quelque chose.**

-------------------------
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
     menu               → les actions à envisager AU VU DE L'ÉTAT (projet courant, ou le portefeuille si hors projet)
3. Dans l'agent (opencode) :
     /ap-scan-projets                 → le scan natif, présenté et conduit par l'agent
     /ap-statut-projet                → le statut natif (phase + gate + avancement)
     /assistant-menu                  → le menu d'état (les actions à envisager au vu de l'état)
     « commence le projet <Nom> » → démarrer / reprendre un projet PM²
     « crée un projet <Nom> »     → nouveau projet MINCE (doc + phase Lancement ; l'outillage reste dans le bundle)
4. Conseil : des projets existants ? commence par scan. Sinon : crée ton premier projet.
```
> Tes projets sont déjà organisés (ex. `code/github/…` + `code/gitlab/…`) ? Garde-les ainsi :
> l'assistant travaille sur des **racines de projets** (plusieurs dossiers), il ne demande pas de coffre monolithe.

**Comment commencer (machine neuve, zéro contexte)** → [`docs/comment-commencer.md`](docs/comment-commencer.md) · Parcours complet → [`docs/prise-en-main.md`](docs/prise-en-main.md) · détails d'installation → [`docs/install.md`](docs/install.md) · **guide complet (6 chapitres : exemples, installation, perspectives, personnalisation, connexions, méthodes)** → [`docs/guide.md`](docs/guide.md)

## Le bundle (arborescence)
```
assistant.ps1 / assistant.sh ← LE MOTEUR natif du bundle (sans IA, sans dépendance) : scan, statut, menu, new, add, sync, bootstrap, commence
install.ps1 / install.sh     ← wizard d'installation (1×) : config transversale (env, opencode, racines, connexions)
.assistant.version           ← la version du bundle (le marqueur que le bootstrap cherche sur disque)
versions/                    ← les versions figées du bundle (assistant_ref: <version> → versions/<version>/)
AGENT-projet.md              ← LA note de routage IA — le projet mince la pointe via son opencode.json
projet.md                    ← template de la fiche projet (pré-rempli à la création : nom + date)
methode/                     ← les MÉTHODES : methode/<M>/<lang>/ — PM2/fr : les phases 01..05 (ici : la data du projet méta ; dans un projet créé : vides, la data s'y écrit) + checklists (par gate RfP/RfE/RfC et par rôle) + referentiel des templates ; à venir : PfM2, PMFLEX, SAFe, Scrum, PRINCE2, PMP, Lean, Lean6Sigma
tools/                       ← templates/ (les gabarits des projets minces : lanceur, bootstrap, gitignore, fiche) + gen_templates.py
docs/                        ← prise en main + installation (marteau / coffre) + guide (6 chapitres)
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
