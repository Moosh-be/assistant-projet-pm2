---
wp_id: WP-0003
titre: "Backup / restore du projet au format gzip (archive + vérification)"
statut: a-faire
priorite: moyenne
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 26/10/2026 — demande utilisateur"
créé: 2026-10-26
mis_a_jour: 2026-10-26
---

# WP-0003 — Backup / restore du projet (gzip)

## Objectif

Rendre **réversible** un état complet d'un projet : `backup` = archive `tar.gz` du dossier projet, `restore` = extraction + vérification d'intégrité. 1 projet = 1 dossier, donc 1 dossier = 1 archive : c'est tout le périmètre.

## Critères de réalisation

- [ ] **Backup** : archive `tar.gz` de tout le dossier projet (templates, `_projet/`, checklists, frontmatter, etc.)
- [ ] Nom de fichier versionné : `<nom-projet>_backup_AAAA-MM-JJ-HHMM.tar.gz` (+ checksum SHA-256 en `.sha256` à côté, ou dans l'archive)
- [ ] Exclusions explicites (documentées) : `.git/`, fichiers temporaires, dossiers d'outils générés
- [ ] **Restore** : extraction dans un dossier cible + vérification (intégrité archive + présence des fichiers clés : `projet.md`, `AGENT-projet.md`, `_projet/fiche.md`)
- [ ] Restore **jamais destructif** : extraction dans un dossier vierge ou avec conflit, jamais d'écrasement silencieux du projet courant
- [ ] Portabilité : scripts ou commandes qui tournent sans dépendance réseau (tar/gzip standards)
- [ ] Documenté dans `README.md` (section dédiée) + `docs/prise-en-main.md`
- [ ] Bonus : commande opencode `/backup [restore]` qui lance la bonne opération

## Notes

- Le format **gzip** est demandé : `tar.gz` (pas `.zip`) pour garder l'arborescence + droits.
- À décider à l'implémentation : scripts `tools/backup.sh` + `tools/restore.sh` (cross-platform Windows/PS ?) vs commande opencode qui orchestre.
- Cas d'usage : vault Obsidian multi-projets, machine de secours, partage d'un projet complet.
- Lien WP-0002 : le projet bidon de la démo est le meilleur candidat de test pour le backup/restore.
