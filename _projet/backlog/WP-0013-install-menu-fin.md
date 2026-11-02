---
wp_id: WP-0013
titre: "Install = config transversale, se termine par le menu de l'agent + conseil (scan / créer un projet)"
statut: fait
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "décision utilisateur du 01/11/2026 — « l'install = initialisation de la config transversale ; elle se finit en présentant le menu et en conseillant scan (projets existants) ou création d'un premier projet »"
créé: 2026-11-01
mis_a_jour: 2026-11-01
---

# WP-0013 — Install : menu de fin + conseil

## Objectif

Clarifier la **frontière** du wizard : l'install = **initialisation de la config transversale** (env + opencode + racines + connexions — tout ce qui est machine-wide, 1×). Elle **se termine** en présentant le **menu de l'agent** et un **conseil** : commence par `/scan` si des projets existants, sinon crée un premier projet. Le « monde projet » (découverte, adoption, add-ons par projet) est du côté de l'agent, pas du script.

## Critères de réalisation

- [x] Fin d'install réécrite (`install.ps1` + `install.sh`) : récap config transversale → **menu** (`/scan`, `/statut`, « commence le projet <Nom> », « crée un projet <Nom> ») → **conseil conditionnel** (racines définies ? scan : créer / définir des racines)
- [x] Agent : point 8 ajouté — « crée un projet » = copier les fichiers du kit dans le dossier cible + `projet.md` vierge (phase Lancement), jamais d'écrasement (pour que la promesse du menu soit tenable)
- [x] README fr/en : démarrage rapide aligné (menu + conseil)
- [ ] Validation terrain : relancer l'install, vérifier la fin

## Notes

- **Décision de design (discussion 01/11)** : la **pertinence d'un add-on est une connaissance de projet, pas de machine** → proposer « les add-ons pertinents » à l'install, c'est deviner ; à l'activation du projet, c'est observer (signaux du projet). C'est le fil rouge qui a fait émerger ce découpage (voir WP-0014).
- L'install ne propose **plus** d'« ajouter le kit » (c'est le rôle de `/scan` + activation) — cohérent avec la phrase « l'install ne s'occupe pas des projets ».
