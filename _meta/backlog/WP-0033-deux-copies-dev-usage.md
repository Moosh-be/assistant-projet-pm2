---
wp_id: WP-0033
titre: "2 copies du repo : dev (inception) / usage (bundle stable)"
statut: fait
priorite: moyenne
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 09/11 — question utilisateur : « est-ce que ça serait plus simple d'avoir 2 copie du repo, l'une pour les activités de développement de celui-ci et un pour les activités d'utilisation de celui-ci ? » — avis « pour » annoncé, go utilisateur (« go »)"
créé: 2026-11-09
mis_a_jour: 2026-11-09 (fait : clone + configs machine + décision + meta)
---

# WP-0033 — 2 copies du repo : dev / usage

> Renumé WP-0029 → **WP-0033** le 09/11 : collision de numéro avec la série
> « portefeuille » tracée en parallèle (WP-0028→0032, dont un WP-0029).

## Contexte
Le repo joue deux rôles à la fois : **projet en développement** (inception :
WPs, RfP, commits, working tree sale) et **logiciel installé** (le bundle que
les projets minces pointent via `assistant_local`). Deux checkouts du même
repo séparent les rôles : le working tree de dev (sale, en mouvement) ne peut
plus casser le moteur que les projets actifs délèguent, et la politique de
versionnage (`versions/<ref>/`, « le projet migre quand il le sent ») devient
concrète (une copie stable à pointer, voire épingler sur un tag).

## Périmètre (fait le 09/11)
- [x] Avis « pour » annoncé + go utilisateur (session 09/11).
- [x] Clone de la copie d'usage : `C:/Users/ctg/SynologyDrive/code/github/assistant-projet-pm2-bundle`
      (clonée du **remote GitHub** — scénario « copie bare », origin = la forge ;
      indépendante du checkout de dev).
- [x] **Configs machine de la copie d'usage** : le moteur cherche
      `.assistant.config` à SA racine (`assistant.ps1` ligne 37) et le fichier
      est gitignoré (WP-0017) → une clone fraîche n'a pas de config. Copie de
      `.assistant.config` + `.assistant-projet.env` depuis la dev, et
      `openproject_token_file` répointé sur le `.assistant-projet.env` **local**
      (la copie d'usage est autonome, pas couplée au chemin de la dev).
- [x] Ligne `decisions.md` du 09/11 (la convention dev/usage).
- [x] Méta : fiche v22 + ce ticket + log.

## Convention
- **Copie de dev** (`assistant-projet-pm2`) : dirty OK, branches, WPs, `_meta/`
  inception (le projet PM² vit ici).
- **Copie d'usage** (`assistant-projet-pm2-bundle`) : **master seul, clean**,
  **refresh délibéré** — `git pull` quand un merge doit se propager, ou épinglée
  sur un tag / `versions/<ref>/` si un projet veut une version figée.

## À faire au prochain projet connecté (sur cette machine)
- Pointage `assistant_local` → copie d'usage (1 ligne dans
  `connexions.local.md` + `sync` qui régénère le harness vers la
  `AGENT-projet.md` de la copie d'usage).
- Aucun projet n'est encore connecté sur cette machine (commandschool = layout
  ancien `kit_source`, 2ndb-toolbox = re-`add` en attente) → mise en place à
  coût zéro aujourd'hui.
