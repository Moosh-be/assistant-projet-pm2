---
wp_id: WP-0025
titre: "Le projet mince : séparation data/outillage + bootstrap (le projet se repose sur le repo assistant)"
statut: fait
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 04/11/2026 — verbatim : 'on a un repo pour l'assistant connecté ou pas à github. Cet assistant se déploie dans d'autres dossiers, en vue de les rendre autonomes mais pouvant se reposer sur le repo assistant : l'assistant déploie dans chaque projet la doc du projet et la config de connexion à l'assistant. Si un répertoire de projet est synchronisé chez un autre utilisateur, il a la doc + la config de l'assistant, mais pas forcément l'assistant : la config s'accompagne d'un script d'install qui, si l'assistant n'est pas détecté, le cherche (local, puis distant sur le repo git) sans IA, en expliquant tout à l'utilisateur tiers ; une fois installé, il propose la même opération pour le harness opencode'"
créé: 2026-11-04
mis_a_jour: 2026-11-05 (fait : implémentation PS + bash complète, tests T1-T7 verts PS+bash, docs à jour — voir section Livraison)
---

# WP-0025 — Le projet mince : data portable + outillage dans le repo assistant

## Contexte

Le kit d'aujourd'hui (WP-0016 → 0024) : un projet = **copie complète du kit** (scripts,
protocole, templates, checklists, `.opencode/`). `update` resync ces copies (ajout de
fichiers seulement). Limite : la **copie se fige et dérive** (les scripts du projet ne se
mettent pas à jour de contenu), et ce qui voyage avec le projet est **l'outillage entier**
alors que seul le **fruit du travail** devrait voyager.

Le scénario déclencheur : un dossier de projet **sync chez un autre utilisateur** (qui n'a
pas l'assistant) — il hérite de la doc du projet + de la config, mais pas de l'outillage.
Il faut que l'outillage soit **rétabli proprement** par le projet lui-même.

## Décision (validée utilisateur, 04/11 — 3 tranches)

### 1. Ce qui reste dans le projet (= ce qui sync chez un tiers)

- La **doc du projet** : `projet.md`, `01 Lancement/` → `05 Cloture/`, `_meta/`
  (fiche, backlog, logs, registry) — le fruit du travail.
- La **config de connexion** à l'assistant : évolue du `connexions.md` / `kit_source`
  (WP-0020) — **chemin local de l'assistant + URL git** (les deux, fallback local → distant).
- Le **bootstrap** (natif, sans IA) : le script qui rétablit l'assistant (voir 3).
- Le **lanceur mince** : le `assistant.ps1`/`.sh` du projet devient un **délégateur** —
  il trouve l'assistant central via la config et délègue. `.\assistant.ps1 statut`
  continue de marcher depuis le projet (comportement identique pour l'utilisateur).

**Ce qui sort du projet** (ne vit que dans le repo assistant) : `AGENT-projet.md`,
`referentiel-templates-PM2.md`, `opencode.json`, `checklists/`, `docs/`, `tools/`,
`.opencode/` (agent + command), les scripts natifs complets.

### 2. La config de connexion

Chemin **local** + **URL git**. Dans **les deux cas** (local et distant) le bootstrap
**annonce et demande confirmation** avant de procéder.

### 3. Le bootstrap (garde-fous utilisateurs)

- **Détecte** (lecture seule, pas de confirmation) : assistant présent ? (chemin local de
  la config valide → recherche sur disque).
- **Avant TOUTE action il annonce + explique + demande confirmation** — pointer
  l'emplacement, chercher sur disque, cloner : rien ne se fait silencieusement.
- Texte d'annonce au tiers : *« Cet espace projet fonctionne avec l'assistant de gestion
  de projet. Pour utiliser ses fonctionnalités, il faut l'installer. Si c'est déjà fait :
  pointer son emplacement / le chercher sur mon disque. Sinon : l'installer (clone du
  repo). »*
- Une fois l'assistant en place → **propose la même opération pour le harness opencode**
  (la couche IA) : détecter / pointer / installer, avec confirmation.
- **Zéro écrasement** (règle absolue du kit) : le bootstrap n'écrase jamais la doc du
  projet ni les fichiers existants.

### Conséquences / supersession

- **Remplace** la chaîne « le projet = copie complète du kit » (WP-0016/0020) — la copie
  du kit par `new`/`add` n'existe plus ; `new`/`add` déposent : doc + config + bootstrap +
  lanceur mince.
- **`update` change de sens** : plus de copie locale à resync → il devient la vérif de
  config / version de l'assistant central (le contenu des commandes suit le repo, pas une
  copie).
- **Migration : pas de rétroactivité** (règle WP-0018) : les projets existants gardent
  leur copie ; ils migrent quand l'utilisateur le décide (bootstrap idempotent).
- Le **kit lui-même** (inception) devient le cas d'école : son repo = l'assistant, sa
  doc = `_meta/`, sa config pointe sur lui-même.

### Versionnage / compatibilité (tranché, 04/11)

- **Pas de breaking change**, mise à jour systématique (additive) du repo assistant.
- **Si jamais un breaking change est inévitable : le bundle assistant contient toutes
  les versions** — les anciennes deviennent, avec le temps, des **add-ons de
  rétro-compatibilité**. Un projet mince fonctionne **toujours** avec le bundle installé.
- **Chaque projet migre « quand il le sent »** (au rythme qui lui convient, jamais
  imposé) : la config de connexion porte la référence de version/compatibilité, le
  lanceur mince délègue à la version correspondante du bundle.

## Périmètre (à dérouler)

- [x] Design du lanceur mince : ce qu'il délègue, comment il résout l'assistant
      (config → recherche → message si absent) + **le routage par version** (la
      référence du projet → la version du bundle qui le sert, rétro-compat inclusive)
- [x] Design du bootstrap : la séquence détecter → pointer → chercher → installer +
      l'étape opencode + les textes d'annonce (FR/EN)
- [x] Le format de la config de connexion (évolue `connexions.md` : `assistant_local:`
      + `assistant_git:` en plus de l'existant)
- [x] Réécriture de `new`/`add` (dépôt mince) + `update` (→ `sync` : vérif config/version)
- [x] `statut`/`liste`/`scan`/`remark` : comportement inchangé vu par l'utilisateur
      (le lanceur mince délègue) — vérifié cas par cas (T1-T7)
- [x] Tests sandbox PS + bash : projet mince sur machine « sans assistant » (bootstrap
      complet), projet mince avec assistant local, tiers qui sync le projet
- [x] `decisions.md` : les lignes structurantes (chemin inter-moteurs + implémentation)

## Ouvert (tranché à l'implémentation)

- ~~Version minimale du kit requise par un projet mince~~ → **tranché** : pas de breaking
  change + bundle cumulatif (toutes les versions, les anciennes = add-ons de rétro-compat)
  → un projet mince fonctionne toujours ; migration « quand le projet le sent ».
- ~~Le lanceur mince : 1 fichier ou les 2 (PS + bash) ?~~ → **tranché** : les 2, un par OS
  — `lanceur-assistant.ps1` / `lanceur-assistant.sh` (53 / 52 lignes), déposés dans le
  projet par `new`/`add`/`sync` (absents seulement, zéro écrasement).
- ~~La recherche sur disque : racines candidates ?~~ → **tranché** : l'utilisateur indique
  les dossiers à chercher (`bootstrap chercher <dossier...>`) ; la recherche = le marqueur
  `.assistant.version` dans ces dossiers — **pas de scan de tout le disque**.

## Livraison (05/11/2026)

Implémenté dans le worktree `wp-0025` (master stable — RfP du méta-projet en cours).

### Le layout mince (13 éléments, `new`/`add`)

`projet.md` (pré-rempli nom + date) · `01 Lancement/` → `05 Cloture/` (vides) · `_meta/`
(fiche, backlog, registry) · `assistant.ps1`/`assistant.sh` (**lanceur mince** — délègue
au bundle, sinon lance le bootstrap) · `bootstrap.ps1`/`bootstrap.sh` · `opencode.json`
(instructions → `AGENT-projet.md` **du bundle** par chemin absolu + `projet.md`) ·
`.gitignore` (lignes machine). **Absents** : `AGENT-projet.md`, `referentiel`,
`checklists/`, `tools/`, `docs/`, `.opencode/` (le harness est déployé à la demande
par `sync` — zéro écrasement).

### La config de connexion (2 fichiers)

- `_meta/registry/connexions.md` — **partagée** (voyage avec le projet) : `assistant_git`
  (URL du repo), `assistant_ref` (`latest` ou `<version>` → `versions/<version>/`),
  `meta_folder`.
- `_meta/registry/connexions.local.md` — **machine** (gitignorée, écrite par le bootstrap) :
  `assistant_local` = le bundle sur cette machine.
- **Convention de chemin inter-moteurs** (décision 05/11) : `C:/...` (barres obliques) sur
  Windows — lisible par le lanceur PS, le lanceur bash (MSYS) et opencode. Implémenté :
  `conf_path()` bash (`cygpath -w | tr '\\' '/'`) + `-replace '\\','/'` PS.

### Les commandes

- `sync` (**remplace `update`**, alias conservé avec message) : depuis le projet, vérifie
  le bundle (présence + version `.assistant.version` + `assistant_ref`) et déploie le
  harness opencode (`.opencode/agent|command` en copie machine + `opencode.json` du projet)
  — **zéro écrasement, idempotent**, `--force-harness` pour redéployer.
- `bootstrap` : (ré)installe le bundle sur cette machine — **détecter** (lecture seule :
  état de la config, assistant présent ? opencode ? harness ?) → **pointer** / **chercher**
  / **installer** (git clone du `assistant_git`) — **annonce + confirmation avant chaque
  action**, puis **propose le harness opencode**. Sans IA.
- `scan` : les « assistés » = `projet.md` + `_meta/` ; suffixe **(mince)** ou
  **(copie complète, pré-WP-0025)** (présence `AGENT-projet.md` = legacy).
- `new`/`add` : textes « projet mince » + prochain pas (`sync`).

### Versionnage

`.assistant.version` (1.0.0) à la racine du bundle + `versions/README.md` (la politique :
routage `assistant_ref: <version>` → `versions/<version>/`, add-ons de rétro-compat).
Testé : `assistant_ref: 1.0.0` → le bundle est résolu dans `versions/1.0.0/`.

### Docs à jour

README (.fr/.en/md) · `docs/install.md` · `docs/prise-en-main.md` · `AGENT-projet.md`
(note « projet mince » + table de routage bundle) · `.opencode/agent/assistant-projet.md`
(règle 8 = `assistant new` mince + bootstrap) · `referentiel-templates-PM2.md`
(terminologie kit → bundle).

### Tests sandbox (PS + bash, tous verts — T1 → T7)

T1 `new` → layout mince 13 éléments (vérifié sur disque, SANS l'outillage) · T2 délégation
lanceur → moteur · T3 `bootstrap pointer` pipé (Read-Host lit le stdin redirigé) ·
T4 **scénario tiers complet** (copie sans config machine → lanceur → bootstrap → pointer →
délégation au bundle) · T5 `scan` « (mince) » · T6 `sync` idempotent + harness au 1er `o` ·
T7 `assistant_ref` figée → `versions/1.0.0/`. Cross-moteurs : PS écrit / bash lit (et
inversement) la config `C:/...`.

### Incidents

- **Hotfix NUL** : `assistant.sh` de master contenait 453 NUL en fin de fichier (28683
  octets) — tronqué à 28230, `bash -n` OK. Le fix part avec le merge.
- **Bug inter-moteurs** : le moteur bash écrivait des chemins MSYS (`/tmp/...`) dans la
  config → illisibles par PS/opencode. Corrigé (`conf_path()` + normalisation PS).
- **EOL** : les `.sh` du working tree = CRLF (convention `autocrlf=true`, comme
  `install.sh`) ; Git Bash tolère le CRLF (vérifié empiriquement : `bash -n` + exécution).

### État

Code + docs + méta prêts. **Merge vers master en attente** : le working tree de master
porte le travail RfP non commité (PM2-01/02/03, `projet.md`, `_meta/fiche.md`) — le merge
s'effectuera après ce commit (conflit textuel prévu : la ligne `mis_a_jour` de `fiche.md`).
