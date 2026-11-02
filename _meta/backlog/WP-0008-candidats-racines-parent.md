---
wp_id: WP-0008
titre: "Wizard 1/3 : proposer le dossier parent (et ancÃªtres) du kit comme racines, pas seulement les dossiers Ã  cÃ´tÃ©"
statut: fait
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "test utilisateur du 01/11/2026 â€” Â« je veux qu'il me propose le rep parent, celui qui contient les repos projets Â»"
crÃ©Ã©: 2026-11-01
mis_a_jour: 2026-11-01
---

# WP-0008 â€” Candidats de racines : inclure le parent du kit

## Objectif

Le wizard proposait comme racines uniquement les **dossiers Ã  cÃ´tÃ© du kit**. Quand le kit est clonÃ© *dans* le dossier de projets (cas frÃ©quent : `code/github/assistant-projet-pm2`), les candidats proposÃ©s sont **les projets eux-mÃªmes** â€” pas le dossier qui les contient. L'utilisateur doit pouvoir dÃ©signer **le parent** (ex. `code/github`) par numÃ©ro.

## CritÃ¨res de rÃ©alisation

- [x] Candidats = **dossier du kit + 2 niveaux au-dessus** (annotÃ©s Â« dossier du kit Â» / Â« 1 niveau au-dessusâ€¦ Â») **+ les dossiers Ã  cÃ´tÃ©** (max 5, comme avant)
- [x] Ligne d'explication affichÃ©e : Â« Une racine = un dossier qui CONTIENT des projets (1 projet = 1 sous-dossier) Â»
- [x] Index de sÃ©lection alignÃ© sur la liste affichÃ©e (8 candidats max) â€” bug intermÃ©diaire trouvÃ© au code-review : le plafond restait Ã  5 (choix 6+ ignorÃ©s en silence)
- [x] `install.ps1` (ASCII) + `install.sh` alignÃ©s (mÃªme logique, mÃªmes labels de sens)
- [x] `docs/install.md` Â§4 Ã  jour
- [x] Syntaxe des deux scripts validÃ©e (parse AST PS + `bash -n`)
- [x] Test de la logique de candidats sur la machine rÃ©elle : liste attendue produite (1) = parent du kit)
- [ ] Validation terrain : relancer `.\install.ps1`, choisir le parent par numÃ©ro (ex. `1`)

## Notes

- `A` (chemin libre) reste le plan B pour un niveau plus haut (3+ niveaux au-dessus).
- Si le parent est choisi comme racine, le kit lui-mÃªme est un sous-dossier de la racine â†’ `/scan` le classe Â« kit Â» et l'annonce avec sa phase (comportement attendu, pas un conflit).
- DÃ©cision de design : **2 niveaux d'ancÃªtres max** = compromis lisibilitÃ©/couverture ; au-delÃ , `A`.
- Suite directe du test utilisateur qui a aussi donnÃ© WP-0007 (affichage).
