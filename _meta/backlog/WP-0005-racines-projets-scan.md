---
wp_id: WP-0005
titre: "Racines de projets multi-répertoires + commande scan + résilience aux projets existants"
statut: fait
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 01/11/2026 — retour utilisateur post-installation (2 bugs wizard + concept de racines + tolérance au pré-existant)"
créé: 2026-11-01
mis_a_jour: 2026-11-01
---

# WP-0005 — Racines de projets (multi-répertoires) + commande `scan`

## Objectif

L'utilisateur qui découvre le kit **a déjà ses dossiers de projets** (souvent organisés par plateforme : `code/github/...`, `code/gitlab/...`). Le kit ne lui demande **pas de tout réorganiser** : il s'ajoute aux racines existantes (manifeste + `_projet/`), et l'install **assiste à l'identification** de ces racines.

## Contexte (constats de la session du 01/11/2026)

- L'installation v1 (WP-0004) posait une question « vault » monorépertoire → inadaptée au cas multi-répertoires (ex. `C:\...\code` contenant `github/` et `gitlab/`, qui contiennent les projets).
- Bugs v1 confirmés par test : (a) répondre « non » à une connexion → les champs de détail étaient demandés quand même, et le récap affichait « oui » (le script ne relisait pas la réponse) ; (b) le défaut « créer le dossier » s'exécutait sans nouvelle confirmation → un dossier parasite pouvait être créé.
- Décision conceptuelle de l'utilisateur : le concept de « vault monolithe » disparaît au profit de **racines de projets** (1 à N). Dans chaque projet (kit ou non), le kit s'appuie sur le **manifeste** (frontmatter de `projet.md`) + le dossier **`_projet/` (par défaut)**.

## Critères de réalisation

### A. Wizard d'installation (install.ps1 / install.sh — corrigé)
- [x] **Bug « non »** : répondre « non » (ou laisser vide avec défaut `n`) à une connexion → **aucune** question de détail n'est posée, statut `non`, récap honnête *(testé 01/11 — scénario A)*
- [x] **Bug « création »** : création de tout dossier = confirmation explicite préalable + le chemin par défaut « créer si absent » est **non** auto-exécuté *(testé — scénarios D/E)*
- [x] Le wizard est relançable sans polluer l'arborescence (zéro dossier parasite) *(testé — les 5 scénarios A..E)*

### B. Question 1 du wizard — identification des racines (assistée)
- [x] La question n'est plus « où est TON vault » mais « **où vivent tes projets** ? (1 ou plusieurs racines) »
- [x] **Détection proactive** : le script liste les dossiers enfants du parent du kit (et leurs sous-dossiers) et propose d'en choisir (1..n) comme racines ; chaque choix validé est affiché
- [x] **Si une racine candidate n'est pas vide** (contient déjà des dossiers) : le wizard **propose de la lister** et d'identifier les dossiers-projets à l'intérieur (« je te montre, tu valides »), sans rien déplacer ni réorganiser
- [x] **Racine vide** : le wizard propose de la créer / de l'utiliser telle quelle (confirmation explicite avant création)
- [x] Les racines retenues sont écrites dans le registre (`_projet/registry/connexions.md`) : `- racines: <liste>` + statut de chacune (`vide` / `déjà rempli` / `ABSENT`)

### C. Commande `scan` (`.opencode/command/scan.md`)
- [x] Lit les racines du registre ; pour chaque racine, **scanne les dossiers enfants**
- [x] Classe chaque dossier : `kit` (a `projet.md` + `AGENT-projet.md`) / `partiel` (a l'un des deux) / `plain` (aucun)
- [x] Pour chaque `plain` : propose **l'ajout du kit** (copie du kit) OU « laisser tel quel » — le dossier existant est respecté (jamais déplacé, jamais réécrit)
- [x] Pour chaque `kit` : annonce la phase courante (frontmatter `projet.md`) + le gate suivant → « le projet est déjà connu »
- [x] **Résumé** final : N dossiers scannés / X kit / Y partiel / Z plain — et l'inversement de la question : **c'est la racine qui contient le projet, pas le projet qui vit dans le kit** *(testé sur 2 racines réelles : 2 kit / 24 plain)*

### D. Tolérance au pré-existant (règle du kit)
- [x] Dans chaque projet (kit ou non), la couche du kit = **manifeste** (`projet.md`, frontmatter source de vérité) + dossier **`_projet/` (par défaut)** — documenté dans `docs/install.md` §4 + `README.md`
- [x] Ajouter le kit à un dossier existant = **copie des fichiers du kit seulement** ; aucun fichier pré-existant n'est modifié, déplacé ni supprimé *(règle codée dans `scan.md`)*
- [x] Si `projet.md` ou `_projet/` existe déjà dans la cible : **conflit signalé**, rien d'écrasé (l'utilisateur tranche) *(règle codée dans `scan.md`)*

### E. Docs
- [x] `docs/install.md` : nouvelle section « projets déjà organisés (multi-racines) » (§4)
- [x] `README.md` : le « vault » monolithe n'est plus l'unique configuration décrite (Quick start réécrit)
- [x] `docs/prise-en-main.md` : §1-3 alignés (les « racines » remplacent le « coffre » monolithe)

## Réalisé le 01/11/2026

- `install.ps1` / `install.sh` : question 1 = **racines 1..N** (détectées, choix par numéro / `A` ajouter un chemin / `V` passer) ; `Yn` renvoie un booléen (bug « non » corrigé) ; création de dossier = confirmation explicite ; registre `connexions.md` : ligne `- racines:` remplace `- vault:`.
- `.opencode/command/scan.md` : nouvelle commande `/scan` (classe kit / partiel / plain, annonce phase + gate, propose l'ajout du kit sans jamais déplacer).
- Testé sur deux racines réelles : `code/github` (24 dossiers) + `code/gitlab` (2 dossiers) → **2 kit** (le kit public + un fork, phase Lancement / gate RfP) + 24 plain, rien déplacé ni réécrit.
- `[À confirmer]` — décision structurante : le nom de la couche par défaut `_projet/` (vs `_kit/` ou autre) → à consigner dans `_projet/registry/decisions.md`.

## Notes

- **Lien WP-0004** : la section B (racines) modifie la question 1 du wizard — implémentée en même temps que les corrections de bugs (A), même fichier.
- Le `scan` est un **outil d'orientation** : il ne remplit jamais un template (règle du wizard WP-0004), il identifie et propose.
- **Cas de test local** : un dossier `code/` (racine multi, enfants `github/` + `gitlab/` pleins de projets) — validé sans rien toucher.
- Piège PowerShell documenté : un tableau retourné par une fonction et **pipé** (`| ForEach-Object`) est stringifié (`"p1 p2"` = 1 seul élément) → `install.ps1` retourne un `string[]` simple.
- Piège test documenté : sous `bash` WSL piloté par un pipe PowerShell, chaque réponse arrive en CRLF → `install.sh` strippe le `\r` (`${x%$'\r'}`) sur chaque lecture, ce qui rend le script robuste en test CI **et** au terminal.
