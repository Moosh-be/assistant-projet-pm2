---
wp_id: WP-0008
titre: "Wizard 1/3 : proposer le dossier parent (et ancêtres) du kit comme racines, pas seulement les dossiers à côté"
statut: en-cours
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "test utilisateur du 01/11/2026 — « je veux qu'il me propose le rep parent, celui qui contient les repos projets »"
créé: 2026-11-01
mis_a_jour: 2026-11-01
---

# WP-0008 — Candidats de racines : inclure le parent du kit

## Objectif

Le wizard proposait comme racines uniquement les **dossiers à côté du kit**. Quand le kit est cloné *dans* le dossier de projets (cas fréquent : `code/github/assistant-projet-pm2`), les candidats proposés sont **les projets eux-mêmes** — pas le dossier qui les contient. L'utilisateur doit pouvoir désigner **le parent** (ex. `code/github`) par numéro.

## Critères de réalisation

- [x] Candidats = **dossier du kit + 2 niveaux au-dessus** (annotés « dossier du kit » / « 1 niveau au-dessus… ») **+ les dossiers à côté** (max 5, comme avant)
- [x] Ligne d'explication affichée : « Une racine = un dossier qui CONTIENT des projets (1 projet = 1 sous-dossier) »
- [x] Index de sélection aligné sur la liste affichée (8 candidats max) — bug intermédiaire trouvé au code-review : le plafond restait à 5 (choix 6+ ignorés en silence)
- [x] `install.ps1` (ASCII) + `install.sh` alignés (même logique, mêmes labels de sens)
- [x] `docs/install.md` §4 à jour
- [x] Syntaxe des deux scripts validée (parse AST PS + `bash -n`)
- [x] Test de la logique de candidats sur la machine réelle : liste attendue produite (1) = parent du kit)
- [ ] Validation terrain : relancer `.\install.ps1`, choisir le parent par numéro (ex. `1`)

## Notes

- `A` (chemin libre) reste le plan B pour un niveau plus haut (3+ niveaux au-dessus).
- Si le parent est choisi comme racine, le kit lui-même est un sous-dossier de la racine → `/scan` le classe « kit » et l'annonce avec sa phase (comportement attendu, pas un conflit).
- Décision de design : **2 niveaux d'ancêtres max** = compromis lisibilité/couverture ; au-delà, `A`.
- Suite directe du test utilisateur qui a aussi donné WP-0007 (affichage).
