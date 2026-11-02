---
wp_id: WP-0006
titre: "README multilingue (fr/en) + router de langue dans README.md"
statut: fait
priorite: moyenne
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 01/11/2026 — demande utilisateur « un README.en.md et un README.fr.md, le .md présente un texte pour indiquer d'aller lire dans la bonne langue »"
créé: 2026-11-01
mis_a_jour: 2026-11-01
---

# WP-0006 — README multilingue (fr/en)

## Objectif

Rendre la doc d'accès lisible **en français et en anglais** en suivant les standards des forges, sans dupliquer un contenu de maintenance.

## Contrainte forge (vérifiée 01/11)

- **GitHub/GitLab n'affichent automatiquement que `README.md`** sur la page d'accueil du repo.
- Un `README.<lang>.md` est un **fichier lié ordinaire**, jamais auto-affiché selon la langue du visiteur.
- La demande de « switch natif par langue du navigateur » est une *feature request* **ouverte** sur GitHub (discussion #179316), sans réponse → on ne peut pas compter dessus.
- Convention W3C de nommage : `README.<lang>.md` (ici `README.fr.md` / `README.en.md`).

## Choix retenu

| Fichier | Rôle |
|---|---|
| `README.md` | **Router bilingue** (seul auto-affiché) : titre + « Choisis ta langue / Choose your language » + liens vers `.fr.` / `.en.` + explication courte du pourquoi |
| `README.fr.md` | Doc **complète** en français (contenu de l'ancien README.md, adapté aux racines multi + /scan) |
| `README.en.md` | Doc **complète** en anglais (même contenu) |
| Sélecteur | Identique en haut de `.fr.` / `.en.` (lien retour + lien croisé) — `README.md` porte le routeur complet |

## Critères de réalisation

- [x] `README.md` = router (plus de doc complète) ; explication du comportement forge en 2 langues
- [x] `README.fr.md` = contenu complet FR, à jour (install + racines + /scan + inception)
- [x] `README.en.md` = contenu complet EN, à jour (même structure)
- [x] Sélecteur de langue identique en haut de chaque version complète
- [x] Liens relatifs cohérents (`./README.fr.md`, `./README.en.md`, `docs/…`)

## Réalisé le 01/11/2026

- Contenu FR reprenant l'état du kit **après** WP-0004/0005 (install multi-racines + `/scan`).
- Le « pourquoi cette page » est documenté dans le router (utile au prochain mainteneur de ne pas « simplifier » en fusionnant).
- Note : les **templates** (`referentiel-templates-PM2.md`, `docs/…`) restent **uniquement en FR** (langue de contribution du kit) — seuls les README sont doublés. [À confirmer] si l'utilisateur veut aussi un `docs/` EN.

## Notes

- Lien WP-0005 : le contenu README reflète le modèle multi-racines.
- Si le nombre de langues augmente (>=3), passer à un bloc `<p align="center">` de liens plutôt que le routeur plein (convention communautaire).
