---
wp_id: WP-0021
titre: "Commande remark : journal des remarques au vol depuis un projet"
statut: en-cours
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 04/11/2026 — verbatim : 'il faut ajouter un journal des remarques au vol pour remonter dans le projet assistant les améliorations à y faire'"
créé: 2026-11-04
mis_a_jour: 2026-11-04
---

# WP-0021 — `remark` : journal des remarques au vol

## Contexte

La première utilisation réelle du kit (03/11) fait remonter des améliorations **de vive voix**
dans les sessions opencode — rien n'en reste tracé côté projet. Il faut un canal **au vol** :
une commande simple, sans IA, pour noter une remarque pendant qu'on travaille.

## Décision

**`assistant remark <texte>`** se lance **depuis le projet** (dossier courant) :
1. Écrase la remarque dans **`_meta/registry/remarques.md`** (1 fichier = 1 journal) :
   - 1ʳᵉ entrée : header markdown (titre + consigne) créé automatiquement ;
   - chaque remarque = 1 ligne `- [AAAA-MM-JJ] <texte>`.
2. L'agent (à la session suivante) **propose de remonter au projet assistant** les entrées
   marquées `[pour l'assistant]` — le marquage est fait par l'utilisateur à l'écriture.
3. **Gardes-fous** : pas dans un projet → message (relancer depuis le dossier d'un projet) ;
   pas de message → usage.

## Périmètre

- [x] `assistant.ps1` : `Cmd-Remarque` + dispatch `^remark$` + menu + header
- [x] `assistant.sh` : `cmd_remark` + dispatch + menu + header
- [x] Note « Prochain pas » (new/add) : la commande `remark` est annoncée (découverte immédiate)
- [x] Tests sandbox PS (7 cas) + bash (7 cas) : vert
- [x] `decisions.md` : 1 ligne
- [ ] Validation terrain : 1ʳᵉ vraie remarque notée avec la commande (projet `2ndb-toolbox`)

## Notes

- Le fichier `remarques.md` est **donnée du projet** : `update` ne le touchera jamais
  (zéro écrasement) — il vit dans `_meta/registry/` comme `connexions.md`.
- Pas de tri/dedup v1 : un journal linéaire daté suffit.

## Implémentation (04/11)

- **PS** : `Cmd-Remarque([string]$msg)` (~L254) : garde-fous projet → `mkdir -p registry` →
  header si absent → `AppendAllText` de la ligne datée.
- **bash** : `cmd_remark` (~L515) : même logique, `date +%F`, `printf >> file`.
- Les 2 scripts : ligne menu + ligne header (`#   remark <texte> ...`).
