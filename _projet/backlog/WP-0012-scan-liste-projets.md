---
wp_id: WP-0012
titre: "/scan : lister les projets en 3 buckets (assistés / pourraient / sans signal) + signaux légers"
statut: fait
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "demande utilisateur du 01/11/2026 — « une fois qu'on a les projets, une commande pour lister, montrer ceux qui n'ont pas encore l'assistance, ceux qui pourraient »"
créé: 2026-11-01
mis_a_jour: 2026-11-01
---

# WP-0012 — /scan : liste des projets avec « qui a l'assistance / qui pourrait »

## Objectif

Restructurer la sortie de `/scan` autour de la question utilisateur : **qui a déjà l'assistance (le kit), qui n'a pas mais pourrait l'avoir**. Le « pourrait » = présence de **signaux légers** de projet (marqueurs observés, **sans scoring** — c'est le niveau 1 du WP-0009, validé par cette demande).

## Critères de réalisation

- [x] `/scan` affiche par racine **3 buckets** : `Assistés` (kit, + phase/gate) · `Pourraient` (non-kit avec ≥1 signal) · `Sans signal` (non-kit sans marqueur)
- [x] Liste des signaux légers (niveau 1, ~10 marqueurs) : `.git` · `package.json` · `pyproject.toml` · `requirements.txt` · `pom.xml` · `build.gradle` · `go.mod` · `Cargo.toml` · `Dockerfile` · `README*` · `src/` — affichés par dossier concerné (max 4 + `…`)
- [x] Proposition d'ajout du kit **uniquement** pour les dossiers avec ≥1 signal (pas de push sur un dossier sans signe de projet)
- [x] `partiel` reste un bucket dédié (à compléter) — ni assisté, ni « pourrait »
- [x] Résumé final par racine + global conservé, reformulé en buckets
- [ ] Validation terrain : lancer `/scan` sur les racines réelles

## Notes

- **Décision** : extension de `/scan` plutôt qu'une nouvelle commande `/projets` — une seule source de lecture des racines, pas de duplication. La liste *est* le scan.
- Le « pourrait » reste **indicatif** (1 signal ≠ projet certain) : l'agent annonce, l'utilisateur tranche. Le scoring (niveau 2, WP-0009) affinera plus tard si besoin.
- Lien WP-0009 : ce WP **enclenche le niveau 1** de la spec ; le niveau 2 (scoring + imbriqués + nature) reste `a-faire` et découplé.
