---
wp_id: WP-0011
titre: "Fix wizard : les questions oui/non ne reconnaissent pas « o » (oui) — seul « y » passait"
statut: fait
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "test utilisateur du 01/11/2026 — « y, o, Y et O = Oui » ; l'utilisateur a répondu O aux 4 connexions, tout est passé NON"
créé: 2026-11-01
mis_a_jour: 2026-11-01
---

# WP-0011 — Accepter « o » (oui) dans les questions du wizard

## Objectif

Le wizard est **en français** mais ses questions oui/non n'acceptaient que `y`/`Y` (*yes*). Répondre `O` (pour *oui*) était lu comme **non** → lors du test, les 4 connexions (OpenProject, SuperProductivity, GitHub, GitLab) sont passées `non` dans le registre alors que l'utilisateur voulait les activer.

## Critères de réalisation

- [x] `Yn` (PS) + `yn` (sh) acceptent `o`/`O` ET `y`/`Y`
- [x] Prompt aligné sur la langue : `(o/n)` au lieu de `[n]` (le défaut « non » si rien n'est tapé est conservé)
- [x] Les 7 appels (création de racine absente, install opencode, OpenProject, fichier d'env, SP, GitHub, GitLab) sont concernés par le même fix (function unique)
- [x] Logique testée : `o` `O` `y` `Y` → OUI · `non` → NON · vide → NON (défaut)
- [x] Syntaxe PS + bash re-validée
- [ ] Validation terrain : relancer l'install, répondre `O`, voir les connexions bien branchées

## Notes

- Conséquence du test à annuler : le registre local a enregistré `openproject/superproductivity/github_issue/gitlab_issue: non` → **relancer l'install** avec la version corrigée régénère le bloc (idempotent).
- 3ᵉ bug de l'internationalisation du wizard trouvée au test utilisateur (1ᵉʳ : « non » → questions de détail, WP-0004 ; 2ᵉ : affichage, WP-0007 ; 3ᵉ : celui-ci). Le script PS étant en ASCII pur, l'accent n'était pas le sujet — c'était bien le *caractère* attendu.
- Généralisation possible (note) : les autres scripts du kit qui poseront des questions oui/non devront accepter `o`.
