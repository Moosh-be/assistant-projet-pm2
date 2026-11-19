---
wp_id: WP-0050
titre: "Un skill opencode par document de méthode (premier cas PM² : 22 skills `ap-pm2-XX`) — générateur agnostique + pointeur"
type: livrable
statut: en-cours
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 18/11/2026 — verbatim : 'créer un skill spécifique à chaque document de pm²' ; précision 19/11 : 'ca aurait pu être \"skill par document méthodo ou pratique ou norme\"' + 'les skills peuvent être dans le repo du coeur d'agent … qu'y a-t-il à sync ?' + 'que faire pour ceux qui utilisent l'assistant sans I.A.'"
créé: 2026-11-18
mis_a_jour: 2026-11-19
---

# WP-0050 — Un skill par document de méthode (premier cas : PM²)

## Objectif

Chaque **document de méthode / pratique / norme** du kit a **son skill opencode dédié** —
PM² est le premier cas (22 artefacts du référentiel) : quand on travaille ce document dans
un projet assisté, le skill se charge (détection par `description`) et porte le
**protocole de remplissage spécifique** — position dans le cycle, questions d'entretien
(du template), discipline `[À confirmer]` + source, mises à jour (frontmatter + phase),
lien gate. Le **template** reste la source de vérité du contenu (structure / champs) ; le
skill est **mince** (protocole), le template est **plein**.

**Précision 19/11** : le principe n'est pas « 1 skill par document PM² » mais
« 1 skill par document de méthodo / pratique / norme » — le générateur est donc
**agnostique de la méthode** (découverte `methode/<M>/<lang>/`, WP-0045).

## Critères de réalisation

- [x] **22 skills PM²** : `.opencode/skills/ap-pm2-<NN>-<slug>/SKILL.md` (bundle) — 1 par
  artefact du référentiel ; id = `ap-` (espace réservé assistant-projet, WP-0023) + numéro
  du code + slug du fichier template (source unique, pas de décision éditoriale par skill).
- [x] **Générateur agnostique de méthode** : `tools/gen_skills.py` — découvre
  `methode/<M>/<lang>/` (présence d'un `referentiel*.md` = méthode/langue soutenue), lit le
  catalogue (tableau 5 colonnes | Code | Artefact | Phase | Gate | Fichier |) + la section
  « ## 2. Questions de l'assistant » de chaque template → régénère tous les SKILL.md.
  Une nouvelle méthode = **un nouveau dossier**, pas de code à changer. La généralisation
  n'a pas modifié les 22 skills PM² (vérifié par hash avant/après).
- [x] **Déploiement projet = POINTEUR, pas copie** : l'`opencode.json` du projet porte
  `"skills": ["<bundle>/.opencode/skills"]` (chemin absolu, même motif qu'`"instructions"`
  → `AGENT-projet.md`) ; `Deploy-Harness` (PS) / `deploy_harness` (bash) ne copient
  **plus** `.opencode/skills` (seuls `agent` + `command`, zéro écrasement). Parité PS+bash,
  syntaxe validée les deux (19/11), JSON du nouveau `opencode.json` validé (2 chemins remplis).
- [x] **Validation terrain** : 1 skill **pointé** chargé dans une session projet
  (description → le modèle l'invoque de lui-même) — **fait 19/11** (preuve : Notes).
  Reste la **validation du format par l'utilisateur** (`[À confirmer]` à la prochaine session).

## Notes

- **Pourquoi des skills** (et pas juste le protocole `AGENT-projet.md`) : l'agent générique
  connaît le flux ; le skill porte la **spécificité du document** (ses questions, son gate,
  ses cas particuliers) et se charge à la demande, sans gonfler le prompt de base. C'est
  aussi une brique de **portabilité** (série WP-0031) : un skill = réutilisable sans
  l'assistant complet.
- **Format** (docs opencode V2, vérifié 18/11 + 19/11) : `.opencode/skills/<id>/SKILL.md` ;
  frontmatter `name` (affichage) + `description` (détection par le modèle — sans
  description, le skill n'est pas annoncé) ; **id = nom du dossier** (kebab-case, sensible
  à la casse).
- **Pivot du déploiement (19/11)** : d'abord câblé en **copie** par `sync` /
  `--force-harness` (comme `agent` / `command`) — corrigé en **pointeur** après la
  précision « les skills peuvent être dans le repo du coeur d'agent, qu'y a-t-il à sync ? » :
  **rien à sync** — une copie devient stale dès la prochaine régénération (même classe de
  défaillance qu'un buffer d'éditeur resauvé par-dessus) ; un pointeur est **toujours
  frais**, zéro sync, projet mince (WP-0025). Support natif opencode (docs, vérifié 19/11) :
  champ `skills` (array) dans `opencode.json`, chemin absolu « used as written », entrées
  combinées entre les configs (pas de remplacement).
- **Sans IA** : le skill est la **face IA** du template (chargé par le modèle). La
  **face humaine** existe déjà et reste intacte : le template avec ses « Questions de
  l'assistant » (entretien mené à la main) + le natif `menu` / `statut` (WP-0039 : ce qui
  est dû, le gate, quoi remplir). Rien à construire côté skill pour le mode natif — la
  séparation 100 % tient si le natif porte les mêmes décisions.
- **Convention de découverte** (pour une méthode / pratique / norme future) : 1 dossier
  `methode/<M>/<lang>/` + un `referentiel*.md` portant le catalogue 5 colonnes + des
  templates avec une section « ## 2. Questions de l'assistant » (bullets `- [ ]`).
- **Cas particuliers encodés** : PM2-27 (le pilote des gates — 1 checklist par gate) ·
  plans de gestion PM2-07→16 (anti-surcharge : proposer envisagé / utilisé / ignoré).
- **Validation terrain (19/11, `opencode run --auto --archived` dans `test-skill-pointeur`)** :
  le modèle a **invoqué de lui-même** le skill `ap-pm2-03-charte-du-projet` (tool `skill`,
  contenu chargé depuis le **chemin du bundle** → le pointeur fonctionne), a suivi le
  protocole (annonce de session phase/gate/dû, création du squelette
  `01 Lancement/PM2-03.I-*.md` depuis le template du bundle avec discipline `[À confirmer]`,
  1re question d'entretien posée). L'`opencode.json` généré (fix ci-dessous) est du JSON
  valide — vérifié par parseur.
- **Anomalie PS de la machine (découverte pendant ce WP, 19/11)** : sur cette machine, les
  deux engines PS (5.1 10.0.26100.9711 + pwsh 7.7.0) **cassent un `+` entre deux éléments
  d'un array multi-éléments `@(...)`** — le fichier source est sain (vérifié en octets),
  repro sans fichier via `-Command` ; le JSON généré devenait invalide (LF aux frontières
  de concat). **Règle moteur** : pré-calculer toute concat en état 1-ligne (variable) avant
  de la mettre dans un array. Appliqué dans `assistant.ps1` (Deploy-Kit + Deploy-Harness)
  et `tools/templates/bootstrap-assistant.ps1` (où la ligne `skills` manquait aussi —
  ajoutée, parité avec le pivot). `install.ps1` L322-332 audité = pattern sûr (concat au
  niveau statement, pas dans le littéral d'array). Parité bash : `bootstrap-assistant.sh`
  aligné sur la ligne `skills`, `bash -n` OK.
