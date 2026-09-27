# assistant-projet-pm2 — PM² project setup assistant (Markdown kit)

> **What this is** : a **Markdown kit + AI-agent protocol** that helps you **set up and run a project following PM²** (v3.0.1). One project = one folder, one AI-readable routing note, one template per PM² artefact, one checklist per phase gate.
>
> **The idea** : the assistant **asks you the questions** (phase by phase) so the PM² artefacts get filled — and, over time, **listens to your exchanges** (mails, meetings, conversations) to **propose** what to put where. *Asking is also a way to teach you to ask yourself the question.*
>
> **Default stack** : any AI agent that reads a folder (**opencode** by default — "the hammer") + any Markdown vault manager (**Obsidian** by default — "the vault").

## Quick start
```
1. Clone this repo → it becomes your TEMPLATE (don't fill it here).
2. Copy it to a new project folder :  <your-vault>/projects/<Project>/
3. Open the vault in Obsidian, point your agent (opencode) at the project folder.
4. Ask : « start the project <Project> » — the assistant reads AGENT-projet.md and begins.
```
Full walkthrough → [`docs/prise-en-main.md`](docs/prise-en-main.md)

## The kit (folder layout)
```
AGENT-projet.md      ← THE AI routing note (read first). Phase, due artefacts, checklists, connections.
projet.md            ← project sheet / master file (machine frontmatter + phase status)
01 Lancement/        ← PM2-01/02/03 (→ gate RfP)
02 Planification/    ← PM2-04 … PM2-16 (→ gate RfE)
03 Exécution/        ← PM2-18 + deliverables
04 Suivi-Controle/   ← PM2-19/21/22 + PM2-27 phase-exit checklists
05 Cloture/          ← PM2-33 (→ gate RfC)
checklists/          ← per gate (RfP/RfE/RfC) and per role (sponsor/BM/CP)
tools/               ← gen_templates.py (regenerate the artefact skeletons)
docs/                ← onboarding + install (hammer / vault)
```
> ⚠️ **Naming rule** : the AI routing note is deliberately named `AGENT-projet.md`, **never `AGENTS.md`** — in agent-tool ecosystems an `AGENTS.md` is auto-loaded and would hijack whatever global context you have. The skill/protocol reads `AGENT-projet.md` explicitly.

## The 3 feeding modes
| Mode | What happens |
|---|---|
| **A — Direct** | you fill the Markdown yourself |
| **B — Interview** | the agent asks the template's questions and fills **as the data arrives** (not an interrogation block) |
| **C — Passive listening** ⭐ | the agent **spots in your exchanges** what could fill an artefact, **proposes** it, asks for validation **unless it's obvious** (otherwise `[À confirmer]` + source) |

## Phase gates (PM²)
`Lancement → RfP → Planification → RfE → Exécution → RfC → Clôture`, with **Suivi & Contrôle** across all phases. **A gate blocks the next phase** : the PM2-27 exit checklist must be green before moving on.

## Connections (optional, per project)
- **SuperProductivity** : 1 work package = 1 task (tag `pm2`, `sp_id` frontmatter)
- **OpenProject** : artefacts = documents to import ; WBS = work packages (later: MCP read/write)

## Forks
- **This repo = the PUBLIC original** (generic PM² contribution, no company data).
- **RTBF fork (private, GitLab)** : adapts each template to the RTBF Word templates v3.0.1 (translated FR) + RTBF roles/processes.

## Contributing
PM²-friendly : keep the templates **generic** (no company data in the public repo). Language : templates are in **French** (the contribution language here) — English variants welcome.

## License
CC BY-SA 4.0 (content) · MIT (`tools/`).
