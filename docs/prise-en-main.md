# Prise en main — assistant-projet-pm2

> Le guide humain : de zéro à un projet PM² en cours, avec l'assistant (le bundle) + l'agent IA.
> **Pile par défaut** : **opencode** (l'agent — « le marteau ») + **Obsidian** (le coffre). Les deux sont interchangeables (tout agent qui lit des Markdown / tout gestionnaire de notes qui lit des Markdown).

## 0. Le principe en une phrase
**Un projet MINCE = sa data** (`projet.md`, les phases `01..05`, `_meta/`) **+ un pointeur vers le bundle** (l'outillage : templates, checklists, protocole, `AGENT-projet.md`) via `_meta/registry/connexions.md` ; l'agent lit la note de routage **dans le bundle** (pointée par le `opencode.json` du projet), voit **la phase courante**, et **interroge** pour remplir les artefacts du template PM² **un par un**, dans l'ordre des gates.

## 1. Les 3 rôles
| Rôle | Qui | Fait quoi |
|---|---|---|
| **Le bundle (l'assistant)** | ce repo | fournit les templates + les checklists + le protocole + le moteur natif (réutilisable pour TOUS les projets) — **l'outillage ne se copie pas** : il reste ici, pointé par la config du projet |
| **Les racines** | tes dossiers de projets (1..N, ex. `code/github/…` + `code/gitlab/…`) | **contiennent** les projets (`<racine>/<Projet>/`) — Obsidian ou autre, peu importe |
| **Le marteau** | ton agent IA (opencode par défaut) | **lit** `AGENT-projet.md`, **interroge**, **remplit**, **gère les gates** |

> Tu n'as **pas** besoin d'un coffre unique : l'assistant s'appuie sur des **racines de projets** (1 ou plusieurs). Si tu as déjà tes projets organisés, ils le restent — l'assistant s'ajoute, il ne réorganise pas.

## 2. Installation (une fois)
→ voir [`install.md`](install.md) : `install.ps1` / `install.sh` détectent l'environnement, te font pointer tes **racines** (1..N), et proposent opencode + les connexions.

## 3. Créer un projet (la prise en main)
1. **Créer le projet mince** dans une racine, à côté de tes projets :
   ```
   # depuis le bundle (Windows) :
   .\assistant.ps1 new Mon-Projet <racine>
   # (macOS/Linux : ./assistant.sh new Mon-Projet <racine>)
   # OU exister déjà : laisser le dossier tel quel, l'agent (via /ap-scan-projets) ajoutera l'assistant (mince) si tu le veux
   ```
   Le moteur crée le **layout mince** : `projet.md` pré-rempli (nom + date) + `01..05/` + `_meta/` (fiche, backlog, **config de connexion**) + le lanceur mince + le bootstrap. L'outillage **reste dans le bundle**.
2. **Compléter** `projet.md` : méthode (`PM2`), les 4 rôles (Sponsor, BM, CP, MOE — logins ou noms).
3. **Vérifier le bundle + déployer le harness** (une fois, dans `<vault>/projects/Mon-Projet/`) :
   ```
   ./assistant.sh sync        # (ou .\assistant.ps1 sync) — idempotent
   ```
   Le harness = la copie machine de `.opencode/` du bundle + le `opencode.json` du projet (instructions → `AGENT-projet.md` **du bundle** par chemin absolu + `projet.md`).
4. **Ouvrir la session agent** :
   ```
   opencode            # dans le dossier projet
   > commence le projet Mon-Projet
   ```
5. **L'agent** lit la note de routage **dans le bundle** → annonce : *« Phase Lancement, gate suivant RfP. Le PM2-01 Demande de lancement est vide. On le remplit ? »* → puis **les questions** du template, **une à une, au fil de l'eau**.
6. **À chaque gate** : l'agent passe la **checklist** (`checklists/gate-RfP.md` = transposition du PM2-27, **dans le bundle**) → verte → passage de phase (frontmatter `phase:` + `gate_suivant:`).
7. **Chez un tiers / sur une autre machine** : le projet sync porte la doc + la config partagée. Si le bundle n'est pas local, le **lanceur mince** lance le **bootstrap** (pointer / chercher / installer — sans IA, annonce + confirmation à chaque action) puis propose le harness.

## 4. Le quotidien (le mode C — l'écoute passive) ⭐
C'est la valeur ajoutée : en cours de session (réunion, mail, discussion), **l'agent repère** ce qui peut servir un artefact et **propose** :
> *« J'ai noté que la date de livraison est le 15/12 (mail de BLEC du 26/09) → ça remplit « Jalons prévisionnels » de la Charte (PM2-03). C'est bon ? »*

Règles : **valider sauf si c'est évident** · sinon `[À confirmer]` + `source:` · **poser la question = éduquer à se poser la question**.

## 5. Les connexions (optionnelles, par projet)
| Connexion | Branchement | Quand |
|---|---|---|
| **Le bundle** *(obligatoire)* | `_meta/registry/connexions.md` (partagée, voyage : `assistant_git`, `assistant_ref`) + `connexions.local.md` (machine, gitignorée : `assistant_local`) | toujours — c'est le lien projet ↔ outillage ; le bootstrap le retablit sans IA |
| **SuperProductivity** | 1 WP = 1 tâche (tag `pm2`, `sp_id`) | si tu pilotes les tâches dans Sprod |
| **OpenProject** | artefacts → docs importés ; WBS → work packages | si le projet est visible en entreprise |
| **OpenProject MCP** | lecture/écriture directe par l'IA | après release 17.9 (add-on Enterprise) |

## 6. Astuce Obsidian — le projet mince comme TEMPLATE de coffre
Mets le **squelette d'un projet mince** (un `projet.md` vierge + `01..05/` + `_meta/`) dans le **dossier templates Obsidian** de ton coffre. Alors « nouveau projet » = bouton → dossier pré-structuré → `assistant add <dossier>` (ou `sync`) pour y brancher l'assistant → ouvrir l'agent. (Le projet mince est volontairement **plat et portable** : aucun plugin requis, juste du Markdown + frontmatter — et le reste est dans le bundle.)

## 7. Ce que l'agent ne fait JAMAIS
- sauter un gate (la checklist bloque)
- remplir un artefact de la phase N+1
- supprimer un artefact (statut `annulé` si abandon)
- insérer une donnée non validée sans `[À confirmer]` + source
- confondre MOE (fournisseur) et gestionnaire
