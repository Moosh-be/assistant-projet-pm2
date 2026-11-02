---
wp_id: WP-0004
titre: "Installation / initialisation de l'espace de travail (wizard à la racine)"
statut: fait
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 26/10/2026 — scénario utilisateur (dézipper / checkout → installer)"
créé: 2026-10-26
mis_a_jour: 2026-11-01
---

# WP-0004 — Installation / initialisation de l'espace de travail

## Objectif

Après un simple dézipper / checkout du repo, **une seule action à la racine** lance une **installation guidée** : elle pose les bonnes questions, détecte l'environnement, et propose d'activer les connexions / plugins. À la fin : un espace de travail opérationnel (vault prêt + agent + connexions voulues).

## Le scénario (verbatim)

> « Je viens de dézipper (ou faire un checkout) le repo. Je lance le script à la racine qui dit "installation". L'installation pose des questions : où seront les espaces projet, propose l'installation d'opencode, propose l'installation des plugins existants (import / export / synchro OpenProject, SuperProductivity, GitHub Issue, GitLab Issue, …). »

## Critères de réalisation

- [x] Un point d'entrée **à la racine** (script `install.ps1` / `install.sh`) qui dit explicitement « installation »
- [x] Détecte l'environnement (OS, git, node, opencode) **avant** de poser quoi que ce soit
- [x] **Question 1 — espaces projet** : où vivent les projets — **1..N racines** (détectées, choisis par numéro / ajout manuel / passer) ; vérifie l'existence, liste le contenu si non vide, crée **sur confirmation seule** ; enregistre le choix *(réécrit en multi-racines par WP-0005 le 01/11)*
- [x] **Question 2 — opencode** : détecte s'il est installé ; sinon propose l'installation (npm, adapté à l'OS)
- [x] **Question 3 — plugins / connexions** : propose un par un OpenProject, SuperProductivity, GitHub Issue, GitLab Issue — liste ouverte
- [x] Chaque plugin : détecte la CLI (`op`/`gh`/`glab`), propose l'activation ou l'ignore, capture le minimum (url, repo, token_env) **sans exiger** — un « non » = aucune question de détail *(bug corrigé 01/11, testé)*
- [x] À la fin : **récapitulatif** de ce qui est installé / configuré / ignoré + prochaines étapes
- [x] Persistance : les choix sont écrits dans `_projet/registry/connexions.md` (bloc entre marqueurs)
- [x] Ré-exécutable sans danger (idempotent) : relancer « installation » = mise à jour du bloc, pas d'écrasement *(testé 6 fois sur la session)*
- [x] Documenté : `README.md` (Quick start) + `docs/install.md`

## Notes

- **Choix d'implémentation à trancher** : script shell/PowerShell classique (vrai « script à la racine », cross-platform délicat) vs **commande opencode** `/install` qui orchestre le wizard (cohérent avec le kit agent-first, mais suppose opencode déjà présent — boucle de bootstrap). Probable compromis : un script racine minimal qui, si opencode est absent, l'installe puis enchaîne sur le wizard agent.
- **Plugins « existants »** : le kit décrit déjà les connexions (README §Connections, AGENT-projet §3.3.6). Ce WP les transforme en **choix d'installation explicite** plutôt qu'en frontmatter manuel.
- Lien WP-0003 : l'installation est le moment naturel pour **proposer aussi un premier backup** de l'espace fraîchement initialisé.
- Lien WP-0002 : une fois installé, la commande démo (projet bidon) est le test de validation idéal.
- Le wizard ne **remplit jamais** le template : il initialise l'environnement (vault, agent, connexions), le projet bidon reste le rôle de WP-0002.
