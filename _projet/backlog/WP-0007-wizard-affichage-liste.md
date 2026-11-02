---
wp_id: WP-0007
titre: "Fix install.ps1 : la liste des dossiers détectés s'affiche sur une seule ligne (Write-Host tableau)"
statut: fait
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "rapport utilisateur du 01/11/2026 — test d'installation, étape « liste des dossiers détectés »"
créé: 2026-11-01
mis_a_jour: 2026-11-01
---

# WP-0007 — Fix wizard : liste des dossiers détectés sur une seule ligne

## Objectif

La question 1 du wizard (`install.ps1`) affichait la liste des dossiers détectés **en queue leu leu** (toutes les lignes jointes par des espaces, sans retour à la ligne) → illisible, impossible de lire les numéros de choix.

## Critères de réalisation

- [x] Reproduction isolée du bug (`Write-Host $array -NoNewline` joint par **espaces** — comportement PowerShell documenté)
- [x] Correction : `Write-Host ($lines -join "`n") -NoNewline` (ligne 69 de `install.ps1`)
- [x] Vérification de la syntaxe du script corrigé (parse AST = 0 erreur)
- [x] `install.sh` vérifiée : non concernée (bash, `echo` ligne à ligne)
- [x] Pas d'autre occurrence du même anti-pattern dans le repo (grep `Write-Host $var`)
- [x] Relance complète de `.\install.ps1` par l'utilisateur (validation terrain — 01/11 : « c'est beaucoup plus lisible »)

## Notes

- Le reste du wizard (questions 2/3, récapitulatif) n'est pas concerné — seul le bloc « Dossiers détectés » passait par un tableau → `Write-Host`.
- C'est le **second** bug de `install.ps1` rapporté lors du test utilisateur (le premier : « non » → questions de détail quand même, corrigé 01/11 et noté dans WP-0004). La validation terrain complète du wizard reste à faire.
- Le test d'installation a aussi révélé des données dans le registre local (`registry/connexions.md`) : à vérifier si cohérent avec la machine (repo GitHub = `moosh_be` ?).
