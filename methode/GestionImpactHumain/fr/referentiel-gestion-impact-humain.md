---
referentiel: "GestionImpactHumain"
lang: "fr"
statut: en cours
date_maj: "2026-11-20"
source: "WP-0051 (20/11) — décision utilisateur 20/11 (nom, liste des 7 documents, piste B) ; inspiration des sujets : formation du 19/11 (contenu volontairement en marque blanche)"
---

# Référentiel — Gestion de l'impact humain du changement

> **1 dossier `methode/<M>/<lang>/` = 1 méthode/langue soutenue** (WP-0040/0045). Ce
> référentiel porte le **catalogue** (5 colonnes) — `tools/gen_skills.py` en génère
> **1 skill par document** (WP-0050). Les skills sont régénérées, jamais éditées à la main.

## 1. Position

- **Ce que c'est** : la **gestion du côté humain** d'un changement dans un projet ou une
  activité — qui est touché, comment on l'accompagne, comment l'adoption se fait, ce qui la
  consolide. **Transverse** : applicable dans n'importe quelle phase, quelle que soit la
  méthode du projet (PM², Scrum, …).
- **Ce que c'est pas** : la migration **opérationnelle** (en PM² : PM2-09 Plan de transition) ;
  la méthodologie projet en elle-même.
- **Deuxième piste — « avec licence »** : les méthodes de gestion du changement **sous
  licence** (ex. Prosci, ©) n'entrent **pas** dans ce repo public — voir le slot
  `methode/prosci/README.md` (notice + contenu local-only, jamais poussé).

## 2. Licence (marque blanche)

**CC BY-SA 4.0** (licence contenu du kit). Contenu en **connaissance générale** de la gestion
du changement : **aucun modèle propriétaire nommé** (méthode Prosci comprise — elle relève de
la piste locale `methode/prosci/`). Si un document veut citer un modèle propriétaire → il
relève de la **piste licence**, pas de ce référentiel.

## 3. Catalogue

| Code | Artefact | Phase | Gate | Fichier |
|---|---|---|---|---|
| GIH-01.P | Plan de gestion du changement | Transverse | — | `01 Impact humain/GIH-01.P-plan-de-gestion-du-changement.md` |
| GIH-02.P | Analyse des parties prenantes du changement | Transverse | — | `01 Impact humain/GIH-02.P-analyse-des-parties-prenantes-du-changement.md` |
| GIH-03.P | Plan de communication du changement | Transverse | — | `01 Impact humain/GIH-03.P-plan-de-communication-du-changement.md` |
| GIH-04.P | Plan d'adoption et de formation | Transverse | — | `01 Impact humain/GIH-04.P-plan-dadoption-et-de-formation.md` |
| GIH-05.P | Gestion des résistances | Transverse | — | `01 Impact humain/GIH-05.P-gestion-des-resistances.md` |
| GIH-06.P | Sponsors et champions (réseau du changement) | Transverse | — | `01 Impact humain/GIH-06.P-sponsors-et-champions.md` |
| GIH-07.P | Bénéfices post-changement et consolidation | Transverse | — | `01 Impact humain/GIH-07.P-benefices-post-changement-et-consolidation.md` |

## 4. Conventions

- 1 document = 1 template : `## 1. Contenu` + `## 2. Questions de l'assistant` (bullets
  `- [ ]` — lus par le générateur) + `## 3. Statut de remplissage`.
- Dans un projet : le document vit dans un dossier `06 Impact humain/` de la racine du projet
  (à côté des `01..05` de la méthode) — `[À confirmer]` : convention de nom du dossier projet.
- Les skills `ap-gestionimpacthumain-NN-<slug>` sont **générées** par `tools/gen_skills.py`.
