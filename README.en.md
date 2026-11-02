# assistant-projet-pm2 — PM² project setup assistant (Markdown kit)

> **What this is** : a **Markdown kit + AI-agent protocol** that helps you **set up and run a project following PM²** (v3.0.1). One project = one folder, one AI-readable routing note, one template per PM² artefact, one checklist per phase gate.
>
> **The idea** : the assistant **asks you the questions** (phase by phase) so the PM² artefacts get filled — and, over time, **listens to your exchanges** (mails, meetings, conversations) to **propose** what to put where. *Asking is also a way to teach you to ask yourself the question.*
>
> **Default stack** : any AI agent that reads a folder (**opencode** by default — "the hammer") + any Markdown vault manager (**Obsidian** by default — "the vault").
>
> **Principle** : *whatever can be done without AI is done without AI.* The native script (`assistant.ps1` / `assistant.sh`) does the deterministic work (scanning, classifying, reading frontmatter, copying the kit) ; the agent only reasons where it truly matters : **driving** (mode B), **listening** (mode C), **deciding** (add-ons).

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
     new <name>         → create a project (kit + fresh _projet)
     add <folder>       → add the kit to an existing project (never overwrites)
     commence <name>    → THE AGENT : opens opencode in the project (driving, mode B/C)
3. In the agent (opencode) :
     /scan                        → the native scan, presented and driven by the agent
     "start the project <Name>"  → start / resume a PM² project
     "create a project <Name>"   → new project (kit + Lancement phase)
4. Tip : existing projects ? start with scan. Otherwise : create your first project.
```
> Already organized your projects (e.g. `code/github/…` + `code/gitlab/…`)? Keep it that way :
> the kit works on **project roots** (multiple folders), it does not ask for a monolithic vault.

Full walkthrough → [`docs/prise-en-main.md`](docs/prise-en-main.md) · install details → [`docs/install.md`](docs/install.md)

## The kit (folder layout)
```
assistant.ps1          ← NATIVE entry point (no AI, no dependency) : scan, statut, new, add, commence
assistant.sh           ← macOS / Linux equivalent
install.ps1 / install.sh ← install wizard (1×) : cross-cutting config (env, opencode, roots, connections)
AGENT-projet.md        ← THE AI routing note (read first). Phase, due artefacts, checklists, connections.
projet.md              ← project sheet / master file (machine frontmatter + phase status)
01 Lancement/          ← PM2-01/02/03 (→ gate RfP)
02 Planification/      ← PM2-04 … PM2-16 (→ gate RfE)
03 Exécution/          ← PM2-18 + deliverables
04 Suivi-Controle/     ← PM2-19/21/22 + PM2-27 phase-exit checklists
05 Cloture/            ← PM2-33 (→ gate RfC)
checklists/            ← per gate (RfP/RfE/RfC) and per role (sponsor/BM/CP)
tools/                 ← gen_templates.py (regenerate the artefact skeletons)
docs/                  ← onboarding + install (hammer / vault)
_projet/               ← INCEPTION : the repo developed as its own PM² project
                         (fiche.md + backlog/ 1 file = 1 work package → exportable
                         to SuperProductivity / OpenProject, logs/, report/, registry/)
```
> `_` prefix = "meta" artefact of the repo, not a PM² phase folder.
> ⚠️ **Naming rule** : the AI routing note is deliberately named `AGENT-projet.md`, **never `AGENTS.md`** — in agent-tool ecosystems an `AGENTS.md` is auto-loaded and would hijack whatever global context you have. The skill/protocol reads `AGENT-projet.md` explicitly.

## The inception layer (`_projet/`)
> ⭐ **This kit uses itself** (inception). In `_projet/` you find **exactly what happens when the assistant is used on a project** : the sheet, the backlog (1 file = 1 work package), the session journal, the registries. The kit filling its own documentation — a real example, not a mockup.

`_projet/` holds the state of the repo as a project:
- `fiche.md` — project sheet of the repo (frontmatter = truth for the meta layer)
- `backlog/` — **1 file = 1 work package** (universal frontmatter, transformable into a ticket — see `_projet/backlog/README.md`)
- `logs/` · `report/` · `registry/` — session journal, periodic reports, registers

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
- **GitHub Issues / GitLab Issues** : backlog WPs (`_projet/backlog/`, 1 file = 1 WP) are transformable into tickets (`op_id` / `sp_id` frontmatter)

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
