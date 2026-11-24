---
wp_id: WP-0055
titre: "Espace « Doc » — la doc du produit : livrables par audience (11 templates + skills)"
type: livrable
statut: en-cours
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 22/11/2026 — verbatim : « La doc du projet VS la doc du produit. 1° JE vois la doc du produit comme un des livrables et la doc du projet comme un artefact du projet. 2° il y a plusieurs docs du produit : la doc technique, le mode d'emploi, la doc d'install et maintenance, la doc pour chaque \"rôle\" dans le produit, la doc des doc, la doc de prise en main, la doc des spécialisation, la doc des compétences utile pour l'utilisation, la doc \"philosophie et valeurs\", la doc d'intégration, la doc de la comparaison avec la concurrence ... toutes ces docs peuvent exister. Un skill spécialisé dans la doc aidera à la création et distinction de celles-ci, et on va le créer et l'utiliser pour ce produit assistant. Je veux séparer ces documentations, \"par audience\" tant pis s'il y a redondance (pour l'auteur) car ia assiste l'auteur. »"
créé: 2026-11-22
mis_a_jour: 2026-11-22
---

# WP-0055 — Espace « Doc » : la doc du produit, livrables par audience

## Contexte

Le verbatim pose deux choses : (1) la **doc du produit** VS la **doc du projet** — une
distinction à poser net ; (2) la doc du produit est **plurielle** (11 types cités) et se
sépare **par audience** — la redondance entre docs est acceptée, car **l'IA assiste l'auteur**.

## La distinction (cœur du WP)

| | Doc du **produit** | Doc du **projet** |
|---|---|---|
| **Nature** | un **livrable** — elle vit avec le produit | un **artefact du projet** — elle vit avec le projet |
| **Audience** | chaque public du produit (utilisateur, admin, intégrateur, décideur…) | les rôles du projet (sponsor, bm, cp…) |
| **Exemples** | doc technique, mode d'emploi, prise en main, comparaison concurrence… | les PM2-XX, les PV, le suivi de phase |
| **Espace du kit** | **cet espace `Doc`** | les espaces de méthode (PM²…) — **hors de cet espace** |

## Le principe

- **Séparation par audience** : 1 public = 1 document ; chaque template porte un champ
  `audience:` dans son frontmatter (le critère de séparation).
- **Redondance acceptée** côté auteur : l'IA assiste l'auteur → la redondance coûte peu ;
  la clarté par public prime. Chaque doc doit rester **autonome** pour son lecteur.

## Périmètre

- `methode/Doc/fr/referentiel-doc.md` — catalogue 5 colonnes, codes `DOC-<ABR5>.P`
  (abrégés 5 lettres, sans numéro), Phase « Transverse », Gate « — ».
- `methode/Doc/fr/01 Livrables/` — **1 template par type (11)**, légers (squelettes type GIH) :
  frontmatter (+ `audience:`) · `## 1. Contenu` (sections + `[À remplir]`) ·
  `## 2. Questions de l'assistant` (bullets `- [ ]`) · `## 3. Statut de remplissage`.
- **Les 11 types** — **codes = abrégés 5 lettres, sans numéro** (décision 22/11 : « il n'y
  a pas d'ordre pour la doc ») ; **DOC-DOCHS = la home** (point d'entrée, en tête) :
  - DOC-DOCHS.P — Doc des docs (**la home** : catalogue du jeu de docs par audience +
    règles de séparation + politique de redondance)
  - DOC-TECHN.P — Doc technique · DOC-EMPLO.P — Mode d'emploi · DOC-INSTA.P — Installation
    & maintenance · DOC-ROLES.P — Doc pour un rôle R (**générique, paramétrée**) ·
    DOC-PRISE.P — Prise en main · DOC-SPECI.P — Spécialisations · DOC-COMPS.P — Compétences
    utiles · DOC-PHILO.P — Philosophie & valeurs · DOC-INTEG.P — Intégration ·
    DOC-COMPA.P — Comparaison avec la concurrence
- **Skills** : mécanique WP-0050 (1 document = 1 skill, zéro code) → **11 skills**
  `ap-doc-technique`, `ap-doc-mode-demploi`, … `ap-doc-comparaison-concurrence` (pas de
  numéro dans l'id — codes en lettres), générées par `tools/gen_skills.py`.

## Critères de réalisation

- [x] Ce WP créé (statut `en-cours`).
- [x] `methode/Doc/fr/referentiel-doc.md` — catalogue 5 colonnes conforme à la mécanique
      de `tools/gen_skills.py` (codes `DOC-<ABR5>.P`, fichiers réels, 1 correspondance
      exacte par glob).
- [x] 11 templates dans `methode/Doc/fr/01 Livrables/` (frontmatter + `audience:` +
      section 2 en bullets `- [ ]`).
- [x] 11 skills `ap-doc-<slug>` générées par `tools/gen_skills.py` (22/11 — le générateur
      a été **généralisé** : codes en lettres au lieu de numéros ; les 29 skills
      PM²/GIH inchangées par hash, 40 au total).
- [ ] `docs/guide.md` (chapitre méthodes) : l'espace Doc documenté — **hors tâche**
      (à reprendre dans la passe de mise à jour du guide).

## Décisions (22/11 — utilisateur)

1. **Numérotation → abrégés 5 caractères, sans numéro** : « je trouve qu'il n'y a pas
   d'ordre pour la doc, donc une abréviation en 5 caractères serait mieux » — exception :
   la **doc des docs = la home** (point d'entrée, listée en tête du catalogue). Codes
   appliqués : DOCHS · TECHN · EMPLO · INSTA · ROLES · PRISE · SPECI · COMPS · PHILO ·
   INTEG · COMPA.
2. **Audiences validées** (« ok, c'est bien pour valider le skill ») — les 11 squelettes
   **ouverts dans Notepad++** par l'utilisateur (22/11) pour valider les skills.
3. **Où vivent les docs du produit** : « vu que c'est dans git, il faut distinguer ce qui
   est sur le **git du produit** 'assistant' quand je l'utilise, et sur le git du
   **projet** (quand je le développe) » → les docs du produit vivent dans le **repo du
   produit** ; le projet de développement les référence et les suit comme **livrables**
   (remplace la proposition `03 Exécution/`).
4. **Méthode de création** : les docs du produit assistant seront créées **avec les
   skills DOC** (« je voulais le faire avec le skill doc à préparer… utiliser le skill
   pour le tester et créer ces rep. ») ; le skill constatera que certains docs existent
   déjà → **zéro écrasement** (« ça renforce la résilience au mélange d'action
   spontanée et d'action assistées de l'utilisateur ») → **WP-0056**.
5. « un peu vite mais c'est pas grave **on garde** » — les 11 templates créés sont gardés.

**Impact générateur** (22/11) : `tools/gen_skills.py` **généralisé** — le code du
catalogue accepte des abrégés en lettres (`[A-Za-z0-9]+-[A-Za-z0-9]+\.[A-Z]+`) ; l'id de
la skill n'a de numéro (`-NN-`) que si le code en porte un (les 29 skills PM²/GIH
inchangées par hash — 40 au total).

## Suite

- **WP-0056** (tracé 22/11) : **créer les docs du produit assistant avec les skills DOC**
  (test des skills en conditions réelles + production du jeu de docs par audience).
- `docs/guide.md` (chapitre méthodes) : l'espace Doc documenté — rattrapage (à reprendre
  dans la passe de mise à jour du guide).

## Note

Les 11 templates sont des **squelettes** (structure des sections + bonnes questions) —
leur statut propre reste `en cours` ; le remplissage mode B se fait **par produit** :
chaque produit a son jeu de docs, catalogué dans sa **DOC-DOCHS** (la home).
