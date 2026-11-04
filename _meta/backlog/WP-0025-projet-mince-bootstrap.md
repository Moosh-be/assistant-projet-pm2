---
wp_id: WP-0025
titre: "Le projet mince : séparation data/outillage + bootstrap (le projet se repose sur le repo assistant)"
statut: a-faire
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 04/11/2026 — verbatim : 'on a un repo pour l'assistant connecté ou pas à github. Cet assistant se déploie dans d'autres dossiers, en vue de les rendre autonomes mais pouvant se reposer sur le repo assistant : l'assistant déploie dans chaque projet la doc du projet et la config de connexion à l'assistant. Si un répertoire de projet est synchronisé chez un autre utilisateur, il a la doc + la config de l'assistant, mais pas forcément l'assistant : la config s'accompagne d'un script d'install qui, si l'assistant n'est pas détecté, le cherche (local, puis distant sur le repo git) sans IA, en expliquant tout à l'utilisateur tiers ; une fois installé, il propose la même opération pour le harness opencode'"
créé: 2026-11-04
mis_a_jour: 2026-11-04 (politique de versionnage tranchée : pas de breaking change, bundle cumulatif, migration au rythme du projet)
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

- [ ] Design du lanceur mince : ce qu'il délègue, comment il résout l'assistant
      (config → recherche → message si absent) + **le routage par version** (la
      référence du projet → la version du bundle qui le sert, rétro-compat inclusive)
- [ ] Design du bootstrap : la séquence détecter → pointer → chercher → installer +
      l'étape opencode + les textes d'annonce (FR/EN)
- [ ] Le format de la config de connexion (évolue `connexions.md` : `assistant_local:`
      + `assistant_git:` en plus de l'existant)
- [ ] Réécriture de `new`/`add` (dépôt mince) + `update` (vérif config/version)
- [ ] `statut`/`liste`/`scan`/`remark` : comportement inchangé vu par l'utilisateur
      (le lanceur mince délègue) — à vérifier cas par cas
- [ ] Tests sandbox PS + bash : projet mince sur machine « sans assistant » (bootstrap
      complet), projet mince avec assistant local, tiers qui sync le projet
- [ ] `decisions.md` : la ligne structurante

## Ouvert (à trancher à l'implémentation)

- ~~Version minimale du kit requise par un projet mince~~ → **tranché** : pas de breaking
  change + bundle cumulatif (toutes les versions, les anciennes = add-ons de rétro-compat)
  → un projet mince fonctionne toujours ; migration « quand le projet le sent ».
- Le lanceur mince : 1 fichier ou les 2 (PS + bash) comme aujourd'hui ? (tendance : les 2,
  un par OS, ~20 lignes chacun)
- La recherche sur disque : racines candidates = les racines de la config machine +
  `code/github`/`code/gitlab` ? (pas de scan de tout le disque)
