---
wp_id: WP-0045
titre: "Activation des méthodes — découverte par présence dans l'arbo (méthodes maison, versions, provenance git, Markdown)"
type: livrable
statut: a-faire
priorite: moyenne
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 18/11/2026 — verbatim 1 : 'on propose ensuite les méthodes à activer. De base l'assistant connait PfM² pour la gestion de portefeuille, PM² pour la gestion de projet, PgM² pour les projets, Scrum pour la gestion de produit, ITIL pour la gestion ITSM (ESM).' + verbatim 2 : 'pour la partie méthode, il faudra permettre les méthodes maison, donc c'est la présence d'une méthode dans l'espace méthode qui fait qu'elle existe, il peut aussi y avoir plusieurs version de la même méthode (ITIL v3, 4, v5) ; certaines méthodes viennent du repo git de mon projet, d'autres pas. Toutes les méthodes sont fournies au format markdown.'"
créé: 2026-11-18
mis_a_jour: 2026-11-18
---

# WP-0045 — Activer les méthodes

## Objectif

L'assistant propose les **méthodes à activer**. Ce qui existe = **ce qui est présent dans
l'espace `methode/`** : la découverte est **dynamique** (pas de liste codée) — les « méthodes
maison » sont donc prises en compte naturellement.

## Les contraintes (18/11, verbatim)

1. **Méthodes maison** : c'est la **présence d'une méthode dans l'espace `methode/`** qui fait
   qu'elle existe.
2. **Plusieurs versions d'une même méthode** (ex. **ITIL v3, v4, v5**).
3. **Provenance mixte** : certaines méthodes **viennent du repo git de mon projet**, d'autres
   (du kit) pas.
4. **Format** : toutes les méthodes sont fournies **au format Markdown**.

## Les méthodes « de base » connues

| Méthode | Usage |
|---|---|
| **PfM²** | gestion de **portefeuille** |
| **PM²** | gestion de **projet** (v3.0.1 — la seule implémentée aujourd'hui : `methode/PM2/fr/`) |
| **PgM²** | gestion de **programmes** [À confirmer — verbatim 1 : « pour les projets »] |
| **Scrum** | gestion de **produit** |
| **ITIL** | gestion **ITSM (ESM)** — à plusieurs versions (v3, v4, v5) |

> La liste « de base » ≠ une liste figée : l'arbo peut contenir d'autres méthodes (maison,
> versions, repos de projet).

## Critères de réalisation

- [ ] À l'onboarding : **proposer les méthodes à activer** (sélection persistée dans la config)
- [ ] **Découverte dynamique** : une méthode = un dossier dans l'espace `methode/` → la liste est **lue**, jamais codée
- [ ] **Versions** : support de plusieurs versions d'une même méthode (ITIL v3/v4/v5) — **arbo à trancher** (ex. `methode/ITIL/v4/fr/` vs `methode/ITIL/fr/` + champ de version)
- [ ] **Provenance** : certaines méthodes vivent **dans un repo git d'un projet**, d'autres dans le kit — **mécanisme de déclaration à définir** (manifeste du projet ? config machine ?)
- [ ] **Format Markdown** pour toutes les méthodes (contrainte de lecture : aucun format binaire)
- [ ] [À confirmer] liste « à venir » : la liste historique (PMFLEX, SAFe, PRINCE2, PMP, Lean, Lean6Sigma — décision 17/11, WP-0040) est-elle **maintenue en places réservées** ou **remplacée** ?
- [ ] Parité PS + bash, fichiers en LF, tests sandbox

## Notes

- Aujourd'hui : l'arbo `methode/<M>/<lang>/` (WP-0040) porte **PM2/fr** — aucune version et une
  seule provenance (le kit). Le WP étend l'arbo aux versions + aux méthodes de repos de projet.
- Étape 5 du flux onboarding `docs/comment-commencer.md` (WP-0042).
