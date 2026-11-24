---
referentiel: "Doc"
lang: "fr"
statut: en cours
date_maj: "2026-11-22"
source: "WP-0055 (22/11) — verbatim utilisateur 22/11 : la doc du produit = livrable, séparée par audience ; la doc du projet reste un artefact du projet ; 22/11 (2ᵉ passe) : codes = abrégés 5 lettres sans numéro + DOC-DOCHS = la home ; les docs du produit vivent dans le git du produit (≠ git du projet)"
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
- **La pièce maîtresse** : la **doc des docs** (DOC-DOCHS) — **la home** du jeu de docs,
  le **méta** : elle **catalogue le
  jeu de docs du produit par audience** (type, audience, statut, liens), porte les règles
  de séparation et la politique de redondance, et sert de **point d'entrée** au lecteur.

## 2. Catalogue

> **Codes = abrégés 5 caractères, sans numéro** (décision 22/11 : « il n'y a pas d'ordre
> pour la doc »). **DOC-DOCHS (doc des docs) = la home** du jeu de docs — point
> d'entrée, listée en tête.

| Code | Artefact | Phase | Gate | Fichier |
|---|---|---|---|---|
| DOC-DOCHS.P | **Doc des docs — la home** (catalogue du jeu de docs) | Transverse | — | `01 Livrables/DOC-DOCHS.P-doc-des-docs.md` |
| DOC-TECHN.P | Doc technique | Transverse | — | `01 Livrables/DOC-TECHN.P-technique.md` |
| DOC-EMPLO.P | Mode d'emploi | Transverse | — | `01 Livrables/DOC-EMPLO.P-mode-demploi.md` |
| DOC-INSTA.P | Installation & maintenance | Transverse | — | `01 Livrables/DOC-INSTA.P-installation-maintenance.md` |
| DOC-ROLES.P | Doc pour un rôle R (générique, paramétrée) | Transverse | — | `01 Livrables/DOC-ROLES.P-role.md` |
| DOC-PRISE.P | Prise en main | Transverse | — | `01 Livrables/DOC-PRISE.P-prise-en-main.md` |
| DOC-SPECI.P | Spécialisations | Transverse | — | `01 Livrables/DOC-SPECI.P-specialisations.md` |
| DOC-COMPS.P | Compétences utiles à l'utilisation | Transverse | — | `01 Livrables/DOC-COMPS.P-competences-utilites.md` |
| DOC-PHILO.P | Philosophie & valeurs | Transverse | — | `01 Livrables/DOC-PHILO.P-philosophie-valeurs.md` |
| DOC-INTEG.P | Intégration | Transverse | — | `01 Livrables/DOC-INTEG.P-integration.md` |
| DOC-COMPA.P | Comparaison avec la concurrence | Transverse | — | `01 Livrables/DOC-COMPA.P-comparaison-concurrence.md` |

## 3. Conventions

- 1 document = 1 template : `## 1. Contenu` (sections + `[À remplir]`) +
  `## 2. Questions de l'assistant` (bullets `- [ ]` — lus par le générateur) +
  `## 3. Statut de remplissage`.
- `audience:` dans le frontmatter = **qui lit cette doc** — le critère de séparation
  entre les docs d'un même produit.
- **DOC-ROLES** (rôle R) : **un seul template générique paramétré par rôle** — dans un
  produit, on en fait **une copie par rôle** : `DOC-ROLES.P-doc-pour-<role>.md` (frontmatter
  `role:` rempli). Pas de démultiplication de templates dans le bundle.
- **Où vivent les docs du produit** (décision 22/11) : dans le **git du produit** (le
  repo du produit) — à distinguer du **git du projet** (quand on développe le produit) :
  le projet les **référence** et les suit comme **livrables**, mais elles ne vivent pas
  dans un dossier du projet. Ce kit : les docs du produit assistant vivent dans le repo
  `assistant-projet-pm2` (`docs/`, README, …).
- Les skills `ap-doc-<slug>` sont **générées** par `tools/gen_skills.py` (WP-0050) — les
  codes portant des abrégés en lettres, l'id de la skill n'a pas de numéro.
- Licence du contenu : **CC BY-SA 4.0** (licence contenu du kit).
