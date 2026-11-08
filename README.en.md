# assistant-projet-pm2 — PM² project setup assistant (the bundle — thin projects)

> **What this is** : a **Markdown assistant + AI-agent protocol** that helps you **set up and run a project following PM²** (v3.0.1). **The project is THIN** : the project = the **data** (one folder : `projet.md`, the `01..05` phases, `_meta`) ; the **tooling** (templates, checklists, protocol, agent harness) = **this repo, the « bundle »**, pointed to by the project's connection config. A project synced to a third party carries only the docs + the config + a thin launcher + a bootstrap that re-establishes the link to the bundle **without AI** (point / search / install, announcing + confirming every action).
>
> **The idea** : the assistant **asks you the questions** (phase by phase) so the PM² artefacts get filled — and, over time, **listens to your exchanges** (mails, meetings, conversations) to **propose** what to put where. *Asking is also a way to teach you to ask yourself the question.*
>
> **Default stack** : any AI agent that reads a folder (**opencode** by default — "the hammer") + any Markdown vault manager (**Obsidian** by default — "the vault").
>
> **Principle** : *whatever can be done without AI is done without AI.* The native script (`assistant.ps1` / `assistant.sh`) does the deterministic work (scanning, classifying, reading frontmatter, **deploying the thin project**, pointing to the bundle) ; the agent only reasons where it truly matters : **driving** (mode B), **listening** (mode C), **deciding** (add-ons).

<p align="center">
🇫🇷 <a href="./README.fr.md">Français</a> &nbsp;|&nbsp; 🇬🇧 <b>English</b>
</p>

## Quick start
```
1. Run the installer at the repo root :  install.ps1 (Windows) · install.sh (macOS/Linux)
   → it sets up the cross-cutting config : your environment, opencode, your project roots (1..N folders),
     and optional connections (OpenProject, SuperProductivity, GitHub/GitLab Issues).
   It NEVER reorganizes existing folders. At the end, it shows the native menu + a tip.
2. The native menu (no AI : fast, free) :  assistant.ps1 (Windows) · assistant.sh (macOS/Linux)
     scan               → your existing projects : list in 3 buckets (assisted / could be / no signal)
     statut <project>   → where a project stands (phase + gate + progress)
     new <name>         → create a THIN project (docs + connection config + launcher + bootstrap)
     add <folder>       → add the assistant (thin) to an existing project (never overwrites)
     sync               → (from a project) check the bundle (version) + the opencode harness (replaces update)
     bootstrap          → (from a project) (re)install the bundle : point / search / install + harness
     commence <name>    → THE AGENT : opens opencode in the project (driving, mode B/C)
3. In the agent (opencode) :
     /ap-scan-projets                 → the native scan, presented and driven by the agent
     /ap-statut-projet                → native status (phase + gate + progress)
     "start the project <Name>"  → start / resume a PM² project
     "create a project <Name>"   → new THIN project (docs + Lancement phase ; the tooling stays in the bundle)
4. Tip : existing projects ? start with scan. Otherwise : create your first project.
```
> Already organized your projects (e.g. `code/github/…` + `code/gitlab/…`)? Keep it that way :
> the assistant works on **project roots** (multiple folders), it does not ask for a monolithic vault.

Full walkthrough → [`docs/prise-en-main.md`](docs/prise-en-main.md) · install details → [`docs/install.md`](docs/install.md)

## The bundle (folder layout)
```
assistant.ps1 / assistant.sh ← THE NATIVE ENGINE of the bundle (no AI, no dependency) : scan, statut, new, add, sync, bootstrap, commence
install.ps1 / install.sh     ← install wizard (1×) : cross-cutting config (env, opencode, roots, connections)
.assistant.version           ← the bundle version (the marker the bootstrap searches for on disk)
versions/                    ← pinned bundle versions (assistant_ref: <version> → versions/<version>/)
AGENT-projet.md              ← THE AI routing note — the thin project points to it via its opencode.json
projet.md                    ← the project-sheet template (pre-filled at creation : name + date)
01..05/                      ← the PM² phases (here : the meta-project data ; in a created project : empty, the data is written there)
checklists/                  ← per gate (RfP/RfE/RfC) and per role (sponsor/BM/CP)
referentiel-templates-PM2.md ← the PM² templates mapping
tools/                       ← templates/ (the thin-project skeletons : launcher, bootstrap, gitignore, sheet) + gen_templates.py
docs/                        ← onboarding + install (hammer / vault)
_meta/                       ← INCEPTION : the repo developed as its own PM² project
```
> ⭐ **The project is THIN** : `assistant new` creates a project containing only the **docs** (`projet.md`, `01..05`, `_meta`), the **connection config** (`_meta/registry/connexions.md` shared + `connexions.local.md` machine), the **thin launcher** (`assistant.ps1/.sh`) and the **bootstrap** (`bootstrap.ps1/.sh`). Everything else — templates, checklists, protocol, `.opencode/` harness — **stays in the bundle**. That's why a project synced to a third party stays readable, and that's why the bootstrap exists : **without AI**, it re-establishes the link to the bundle (point / search / install), **announcing + confirming every action**, then proposes the opencode harness.
> **Versioning** : no breaking changes. If a breaking change is ever unavoidable, the bundle carries **all** versions (`versions/<ref>/`, the old ones = retro-compatible) and each project migrates **when it feels ready** (`assistant_ref: <version>` in its shared config).
> `_` prefix = "meta" artefact of the repo, not a PM² phase folder.
> ⚠️ **Naming rule** : the AI routing note is deliberately named `AGENT-projet.md`, **never `AGENTS.md`** — in agent-tool ecosystems an `AGENTS.md` is auto-loaded and would hijack whatever global context you have. The skill/protocol reads `AGENT-projet.md` explicitly.

## The inception layer (`_meta/`)
> ⭐ **This bundle uses itself** (inception). In `_meta/` you find **exactly what happens when the assistant is used on a project** : the sheet, the backlog (1 file = 1 work package), the session journal, the registries. The bundle filling its own documentation — a real example, not a mockup.

`_meta/` holds the state of the repo as a project:
- `fiche.md` — project sheet of the repo (frontmatter = truth for the meta layer)
- `backlog/` — **1 file = 1 work package** (universal frontmatter, transformable into a ticket — see `_meta/backlog/README.md`)
- `logs/` · `report/` · `registry/` — session journal, periodic reports, registers

## The 3 usage modes (resilient degradation)
The assistant is driven at **3 levels**, **each working standalone** — you lose capabilities going down, **never the data** :

| Mode | Needs | What it does |
|---|---|---|
| **1 — File** | nothing (a plain drive works) | data only : bundle templates copied by hand, `projet.md` / `01..05` / `_meta` filled by hand |
| **2 — Native execution** | the bundle + PowerShell/bash (**no AI, no internet**) | the project's thin launcher (the « relay ») delegates to the bundle engine : `scan`, `statut`, `liste`, `new`, `add`, `sync`, `remark`, `bootstrap` |
| **3 — AI** | opencode (or any agent that reads the folder) | the agent session applies the `AGENT-projet.md` protocol — **synchronous** (chat) or **asynchronous** (notes as text files → isolated discussions, WP-0027) |

- **The scale** : AI → native → file. AI unavailable → native level ; bundle unavailable → file level. The data stays readable and editable at every level.
- **Climbing back up** : the project's `bootstrap` (e.g. at a third party, from a bare copy) re-establishes the link to the bundle — point / search / install — **without AI**, announcing + confirming every action.

> Do not confuse with the « 3 feeding modes » (A/B/C, below) : those say **how data gets into** the artefacts ; these say **at which level you drive the assistant**.

### In the AI mode — agent, command, skill
| | What it is | Example |
|---|---|---|
| **agent** | **who talks** : the AI's identity and role — the `AGENT-projet.md` protocol is loaded as primary | `assistant-projet` |
| **command** | **what you trigger** by name (slash-command) — a bridge to the native engine when it can run without AI | `/ap-scan-projets`, `/ap-statut-projet` |
| **skill** | **how to do X well** : a procedure module loaded on demand when the task matches it | (coming) |

## The 3 feeding modes
| Mode | What happens |
|---|---|
| **A — Direct** | you fill the Markdown yourself |
| **B — Interview** | the agent asks the template's questions and fills **as the data arrives** (not an interrogation block) |
| **C — Passive listening** ⭐ | the agent **spots in your exchanges** what could fill an artefact, **proposes** it, asks for validation **unless it's obvious** (otherwise `[À confirmer]` + source) |

## Phase gates (PM²)
`Lancement → RfP → Planification → RfE → Exécution → RfC → Clôture`, with **Suivi & Contrôle** across all phases. **A gate blocks the next phase** : the PM2-27 exit checklist must be green before moving on.

## Connections (optional, per project)

**Currently implemented** :
- **SuperProductivity** : 1 work package = 1 task (tag `pm2`, `sp_id` frontmatter)
- **OpenProject** : artefacts = documents to import ; WPS = work packages (later: MCP read/write)
- **GitHub Issues / GitLab Issues** : backlog WPs (`_meta/backlog/`, 1 file = 1 WP) are transformable into tickets (`op_id` / `sp_id` frontmatter)

**Connection ideas (not implemented)** — suggest them in the issue:
- **Notion** : PM² artefacts (sheets, minutes, reports) as Notion pages for a non-Obsidian team
- **MCP** (Model Context Protocol) : direct read/write of connected tools from the agent (OpenProject already targeted, v. 17.9)
- **Jira / Azure DevOps** : export WPs to enterprise ticketing
- **Calendar (ICS)** : PM2-15 milestones / gate dates as meeting invites
- **CSV / Excel** : export of the progress table (`projet.md` section 3) for manager reporting
- **Obsidian Local REST API** : direct queries on the vault from the agent

> 📬 **A connection idea? Suggest it** : [suggestions issue →](https://github.com/Moosh-be/assistant-projet-pm2/issues/1) (tool, PM² use, import/export/bidirectional, API/SDK link).

## Forks
- **This repo = the PUBLIC original** (generic PM² contribution, no company data).
- **RTBF fork (private, GitLab)** : adapts each template to the RTBF Word templates v3.0.1 (translated FR) + RTBF roles/processes.

## Contributing
PM²-friendly : keep the templates **generic** (no company data in the public repo). Language : templates are in **French** (the contribution language here) — English variants welcome.

## License
CC BY-SA 4.0 (content) · MIT (`tools/`).
