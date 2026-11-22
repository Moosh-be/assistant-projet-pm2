---
referentiel: "Doc"
lang: "fr"
statut: en cours
date_maj: "2026-11-22"
source: "WP-0055 (22/11) — verbatim utilisateur 22/11 : la doc du produit = livrable, séparée par audience ; la doc du projet reste un artefact du projet"
---

# Référentiel — Doc du produit (livrables par audience)

> **1 dossier `methode/<M>/<lang>/` = 1 méthode/langue soutenue** (WP-0040/0045). Ce
> référentiel porte le **catalogue** (5 colonnes) — `tools/gen_skills.py` en génère
> **1 skill par document** (WP-0050). Les skills sont régénérées, jamais éditées à la main.

## 1. Position

- **La distinction** : la **doc du produit est un livrable** — elle vit **avec le produit**,
  **par audience** (chaque public a sa doc : utilisateur, admin, intégrateur, décideur…).
  La **doc du projet est un artefact du projet** (les PM2-XX, les PV, le suivi de phase) —
  elle est **hors de cet espace** (elle est couverte par les espaces de méthode, ex. PM²).
- **Le principe** : séparation **par audience** — 1 public = 1 document (champ `audience:`
  dans le frontmatter de chaque template = le critère de séparation). La **redondance entre
  docs est acceptée** côté auteur : l'IA assiste l'auteur, la redondance coûte peu — chaque
  doc doit rester **autonome** pour son lecteur.
- **La pièce maîtresse** : la **doc des docs** (DOC-05) — le **méta** : elle **catalogue le
  jeu de docs du produit par audience** (type, audience, statut, liens), porte les règles
  de séparation et la politique de redondance, et sert de **point d'entrée** au lecteur.

## 2. Catalogue

| Code | Artefact | Phase | Gate | Fichier |
|---|---|---|---|---|
| DOC-01.P | Doc technique | Transverse | — | `01 Livrables/DOC-01.P-doc-technique.md` |
| DOC-02.P | Mode d'emploi | Transverse | — | `01 Livrables/DOC-02.P-mode-demploi.md` |
| DOC-03.P | Installation & maintenance | Transverse | — | `01 Livrables/DOC-03.P-installation-maintenance.md` |
| DOC-04.P | Doc pour un rôle R (générique, paramétrée) | Transverse | — | `01 Livrables/DOC-04.P-doc-pour-un-role.md` |
| DOC-05.P | Doc des docs (catalogue du jeu de docs) | Transverse | — | `01 Livrables/DOC-05.P-doc-des-docs.md` |
| DOC-06.P | Prise en main | Transverse | — | `01 Livrables/DOC-06.P-prise-en-main.md` |
| DOC-07.P | Spécialisations | Transverse | — | `01 Livrables/DOC-07.P-specialisations.md` |
| DOC-08.P | Compétences utiles à l'utilisation | Transverse | — | `01 Livrables/DOC-08.P-competences-utilites.md` |
| DOC-09.P | Philosophie & valeurs | Transverse | — | `01 Livrables/DOC-09.P-philosophie-valeurs.md` |
| DOC-10.P | Intégration | Transverse | — | `01 Livrables/DOC-10.P-integration.md` |
| DOC-11.P | Comparaison avec la concurrence | Transverse | — | `01 Livrables/DOC-11.P-comparaison-concurrence.md` |

## 3. Conventions

- 1 document = 1 template : `## 1. Contenu` (sections + `[À remplir]`) +
  `## 2. Questions de l'assistant` (bullets `- [ ]` — lus par le générateur) +
  `## 3. Statut de remplissage`.
- `audience:` dans le frontmatter = **qui lit cette doc** — le critère de séparation
  entre les docs d'un même produit.
- **DOC-04** (rôle R) : **un seul template générique paramétré par rôle** — dans un
  produit, on en fait **une copie par rôle** : `DOC-04.P-doc-pour-<role>.md` (frontmatter
  `role:` rempli). Pas de démultiplication de templates dans le bundle.
- Dans un **projet** : la doc du produit est un **livrable** — elle vit dans le dossier
  livrables du projet (PM² : `03 Exécution/`) `[À confirmer] : convention du dossier`.
  Quand le **produit est le repo lui-même** (ex. ce kit), la doc vit à la racine du repo
  du produit.
- Les skills `ap-doc-NN-<slug>` sont **générées** par `tools/gen_skills.py` (WP-0050).
- Licence du contenu : **CC BY-SA 4.0** (licence contenu du kit).
