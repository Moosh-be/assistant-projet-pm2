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

- `methode/Doc/fr/referentiel-doc.md` — catalogue 5 colonnes, codes `DOC-01.P` … `DOC-11.P`,
  Phase « Transverse », Gate « — ».
- `methode/Doc/fr/01 Livrables/` — **1 template par type (11)**, légers (squelettes type GIH) :
  frontmatter (+ `audience:`) · `## 1. Contenu` (sections + `[À remplir]`) ·
  `## 2. Questions de l'assistant` (bullets `- [ ]`) · `## 3. Statut de remplissage`.
- **Les 11 types** (ordre du verbatim) :
  1. DOC-01.P — Doc technique
  2. DOC-02.P — Mode d'emploi
  3. DOC-03.P — Installation & maintenance
  4. DOC-04.P — Doc pour un rôle R (**1 template GÉNÉRIQUE paramétré par rôle**, pas 10 copies)
  5. DOC-05.P — Doc des docs (**pièce maîtresse** : le méta — catalogue du jeu de docs par
     audience + règles de séparation + politique de redondance)
  6. DOC-06.P — Prise en main
  7. DOC-07.P — Spécialisations
  8. DOC-08.P — Compétences utiles à l'utilisation
  9. DOC-09.P — Philosophie & valeurs
  10. DOC-10.P — Intégration
  11. DOC-11.P — Comparaison avec la concurrence
- **Skills** : mécanique WP-0050 (1 document = 1 skill, zéro code) → **11 skills**
  `ap-doc-01-doc-technique` … `ap-doc-11-comparaison-concurrence`, générées par
  `tools/gen_skills.py` (lancé en fin de passe par l'orchestrateur — **pas dans cette tâche**).

## Critères de réalisation

- [x] Ce WP créé (statut `en-cours`).
- [x] `methode/Doc/fr/referentiel-doc.md` — catalogue 5 colonnes conforme à la mécanique
      de `tools/gen_skills.py` (codes `DOC-NN.P`, fichiers réels, 1 correspondance exacte
      par glob).
- [x] 11 templates dans `methode/Doc/fr/01 Livrables/` (frontmatter + `audience:` +
      section 2 en bullets `- [ ]`).
- [ ] 11 skills `ap-doc-01…11` générées par `tools/gen_skills.py` — **fin de passe**
      (l'orchestrateur lance le générateur ; ne pas le lancer dans cette tâche).
- [ ] `docs/guide.md` (chapitre méthodes) : l'espace Doc documenté — **hors tâche**
      (à reprendre dans la passe de mise à jour du guide).

## Décisions / propositions assistant

1. **Numérotation** : l'ordre du verbatim est conservé (DOC-01 = doc technique …
   DOC-11 = comparaison concurrence) ; la « doc des docs » (DOC-05) reste la **pièce
   maîtresse** sans prendre le numéro 01. `[À confirmer]`.
2. **Audiences** des 11 types (proposées, reprises dans les frontmatters) :

   | Code | Audience proposée |
   |---|---|
   | DOC-01.P | développeurs / mainteneurs du produit |
   | DOC-02.P | utilisateurs du produit (usage courant) |
   | DOC-03.P | administrateurs / équipes d'exploitation |
   | DOC-04.P | un rôle R du produit (paramétrable par copie) |
   | DOC-05.P | auteurs de la doc + toute personne qui cherche une doc |
   | DOC-06.P | nouveaux utilisateurs (premiers jours) |
   | DOC-07.P | utilisateurs avancés / spécialistes |
   | DOC-08.P | futurs utilisateurs (prérequis) + formateurs |
   | DOC-09.P | tous les publics (contributeurs, utilisateurs, décideurs) |
   | DOC-10.P | intégrateurs / auteurs d'outils connexes |
   | DOC-11.P | décideurs / utilisateurs en cours de choix d'outil |

   `[À confirmer]`.
3. **Dossier projet** : la doc du produit = livrable → elle vit dans le dossier livrables
   du projet (PM² : `03 Exécution/`) ; quand le produit est le repo lui-même (ex. ce kit),
   la doc vit à la racine du repo du produit. `[À confirmer]`.

## Suite signalée

- **Appliquer cet espace au produit assistant lui-même** : restructurer **README / guide /
  prise-en-main par audience** avec ces templates (le verbatim : « on va le créer et
  l'utiliser pour ce produit assistant ») — **WP ultérieur**, `[À confirmer]`.

## Note

Les 11 templates sont des **squelettes** (structure des sections + bonnes questions) —
leur statut propre reste `en cours` ; le remplissage mode B se fait **par produit** :
chaque produit a son jeu de docs, catalogué dans sa DOC-05.
