---
wp_id: WP-0036
titre: "Commande « ajouter un projet au portefeuille » : existant (scan) ou création (choix de racine) + initialisation"
statut: a-faire
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 12/11/2026 — verbatim : 'on doit ajouter une commande /as-pf-add-project pour AJOUTER un projet au portefeuille, il va demander si c'est un projet trouvé lors du scan (ou trouvable si on le lance) ou si c'est un projet à créer. Si je choisis de le créer, il va demander où le mettre en montrant les racines (donc répertoire parent des répertoires qui contiennent des projets) et hop il le crée et l'initialise'"
créé: 2026-11-12
mis_a_jour: 2026-11-12
---

# WP-0036 — Ajouter un projet au portefeuille (existant via scan OU création)

## Objectif

Une **commande d'entrée unique** pour grossir le portefeuille : « tu veux ajouter un projet ? »
— soit un **projet existant** découvert par le scan (→ on l'assiste), soit un **projet neuf**
(→ on choisit la racine, on crée, on initialise). Le novice n'a plus à connaître `scan`/`new`/`add`
séparément.

## Spécification (de la demande utilisateur, 12/11)

1. **Question d'entrée** : « C'est un projet **trouvé lors du scan** (ou trouvable si on le lance),
   ou un projet **à créer** ? »
2. **Branche « existant »** → lancer/présenter le **scan** (ou `liste` si le nom est connu) →
   l'utilisateur choisit → `assistant add <dossier>` (zéro écrasement, conflit → l'utilisateur tranche).
3. **Branche « créer »** → **montrer les racines** (les répertoires parents des répertoires qui
   contiennent des projets = les racines de la config machine `.assistant.config`) → l'utilisateur
   choisit une racine + le nom → `assistant new <nom> <racine>` → **création + initialisation**
   (projet mince : `projet.md` + `01..05` + `_meta` neuf + config de connexion + lanceur mince +
   bootstrap) → proposition du prochain pas (`cd <projet>` + `opencode`, l'agent annonce la phase).

## Ouvert (à trancher avant implémentation)

- [ ] **Nom de la commande** : le verbatim est `/as-pf-add-project`. La convention WP-0023 réserve
      le préfixe **`/ap-`** (schéma 2 tokens `/ap-<nom>-<domaine>`), et « pf » = portefeuille
      existe déjà comme niveau de scope (WP-0028). Recommandé : **`/ap-add-projet`** (le portfolio
      = l'ensemble des racines ; quand WP-0028/0029 poseront le modèle pf multi-portefeuilles,
      la commande portera la notion de portefeuille cible).
- [ ] **Périmètre slash vs natif** : v1 = **slash-commande** (l'agent conduit l'entretien, les
      actions restent natives) ou aussi un choix dans le menu natif (« Gérer les projets ») ?
- [ ] **« Montrer les racines »** : réutiliser `scan` (qui les liste déjà) suffit, ou une petite
      commande native `assistant racines` ? (Tendance : réutiliser — pas de logique native en plus.)
- [ ] Cas d'edge : **aucune racine définie** → proposer `install` (définition des racines) et
      s'arrêter là (comportement du scan).

## Périmètre (prévu)

- [ ] `.opencode/command/<nom>.md` (frontmatter `description` + `agent: assistant-projet`) :
      le flow 2 branches ci-dessus, en appelant TOUJOURS le script natif (WP-0016 : la logique
      déterministe vit dans le script, l'IA présente et conduit).
- [ ] Contraintes reprises du kit : **jamais écraser** un fichier pré-existant ; un seul projet
      à la fois ; ne jamais remplir un template au passage.
- [ ] Références : header + notes des `assistant.ps1` / `assistant.sh`, `docs/prise-en-main.md`,
      `docs/install.md` (liste des slash-commands).
- [ ] `decisions.md` : 1 ligne.
- [ ] Validation terrain : depuis la racine du kit, `/ap-add-projet` (ou nom retenu) → les 2
      branches testées (création dans une racine de test + ajout d'un projet « pourrait »).

## Notes

- Le natif couvre déjà les briques : `Cmd-New(name, rootOverride, doc)` (racine par défaut = 1re
  racine, sinon `install`), `Cmd-Add(path)` (résolution cwd + racines), `scan` (4 buckets par
  racine), `liste`. Le WP = **l'orchestrateur conversationnel**, pas de nouvelle logique dure.
- Dépend du comportement actuel de `new` (**projet mince**, WP-0025 — fait) : la création ne
  copie PAS l'outillage (il vit dans le bundle, pointé par `_meta/registry/connexions.md`).
- **Série portefeuille** (09/11, WP-0028/0029/0030) : ce WP est l'**action d'entrée** « ajouter au
  portefeuille » ; le modèle pf (niveaux, attributs, flag « assisté ») est porté par 0028/0029,
  la synchro avec le lieu master par 0030. V1 de cette commande : 1 racine = 1 portefeuille.
