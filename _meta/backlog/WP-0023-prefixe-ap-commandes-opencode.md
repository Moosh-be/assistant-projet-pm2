---
wp_id: WP-0023
titre: "Préfixe /ap- sur les commandes opencode (espace de nommage réservé assistant-projet)"
statut: en-cours
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 04/11/2026 — verbatim : 'le /statut devrait être /ap-statut-projet, toutes les commandes devraient commencer par /ap-' + '/ap- assurément pour se distinguer des éventuelles commandes ajoutée par le gestionnaire du projet qui voudrait lui aussi utiliser opencode'"
créé: 2026-11-04
mis_a_jour: 2026-11-04
---

# WP-0023 — Préfixe `/ap-` : l'espace slash opencode est partagé, le nôtre est réservé

## Contexte

Un projet assisté vit **avec** l'opencode de l'utilisateur : le gestionnaire du projet peut
ajouter ses propres slash-commands dans le même espace. `/statut`, `/scan` sont des noms
**génériques** → risque de collision (la sienne écrase la nôtre, ou inversement).

## Décision (validée utilisateur, proposition 1)

**Seules les commandes opencode (slash) prennent le préfixe `/ap-`** ; les commandes natives
du script (`assistant new/scan/statut/add/update/remark/commence`) **gardent leur nom** —
elles n'ont pas d'espace de nommage partagé (c'est toi qui tapes `assistant.ps1 scan` dans ton
terminal, personne ne peut créer une commande concurrente là-dedans).

- `statut` → **`/ap-statut-projet`** (nom + domaine, schéma validé par l'utilisateur)
- `scan` → **`/ap-scan-projets`** (déduction du même schéma)
- Fichiers renommés : `.opencode/command/statut.md` → `ap-statut-projet.md` ;
  `scan.md` → `ap-scan-projets.md` (commande opencode = nom du fichier).
- Les futures slash-commands suivront le schéma `/ap-<nom>-<domaine>`.
- Les **phrases** à l'agent (« commence le projet X », « crée un projet X ») sont du langage
  naturel, pas des commandes → inchangées.

## Périmètre

- [x] `git mv` des 2 fichiers de commande (R dans l'index)
- [x] Références slash mises à jour : `assistant.ps1` (header + 2 notes « Puis tester » +
      1 commentaire), `assistant.sh` (idem), `README.fr.md` + `README.en.md` (menu agent :
      `/ap-scan-projets` + ajout `/ap-statut-projet`), `docs/install.md` (3 refs),
      `docs/prise-en-main.md` (1 ref)
- [x] Vérif : aucune ref `/statut`/`/scan` restante hors `_meta/` historique (les
      tickets/logs ne sont **pas** réécrits — c'est de l'historique) ; la ref
      `docs/install.md:51` « scan/statut » sans slash = commandes natives → correcte
- [x] `decisions.md` : 1 ligne
- [ ] Validation terrain : relancer opencode dans un projet → `/ap-statut-projet` apparaît
      (les anciennes `/statut`/`/scan` n'existent plus)

## Notes

- `update` recopie les fichiers manquants de `.opencode/command` → les projets existeront
  avec les 2 noms ; les anciens fichiers `statut.md`/`scan.md` présents côté projet ne seront
  **jamais** supprimés par le kit (zéro écrasement) — ils restent morts (personne ne les
  appelle), l'utilisateur peut les ignorer ou les supprimer en main.
