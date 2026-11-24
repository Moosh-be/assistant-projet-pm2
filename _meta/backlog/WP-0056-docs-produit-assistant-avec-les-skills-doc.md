---
wp_id: WP-0056
titre: "Créer les docs du produit assistant AVEC les skills DOC (test des skills + jeu de docs par audience)"
type: livrable
statut: a-faire
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 22/11/2026 — verbatim : 'je voulais le faire avec le skill doc à préparer. Et puis utiliser le skill pour le tester et créer ces rep. (on va le faire comme ca et il va constater que certains sont déjà fait, pas de problèe ca renforce la résilience au mélange d'action spontanée et d'action assistées de l'utilisateur)'"
créé: 2026-11-22
mis_a_jour: 2026-11-22
---

# WP-0056 — Les docs du produit assistant, créées avec les skills DOC

## Objectif

Utiliser les **skills `ap-doc-*`** (WP-0055) pour **créer les docs du produit assistant**
(ce kit) — double rôle : **tester les skills** en conditions réelles + **produire le jeu
de docs par audience** du produit (verbatim 22/11).

## Périmètre

- **Le jeu de docs du produit** (dans le **git du produit** = ce repo, décision WP-0055) :
  la **home** (DOC-DOCHS), doc technique, mode d'emploi, prise en main, … — doc par doc
  avec l'utilisateur (mode B, 1 doc à la fois).
- **L'existant à respecter** (déjà créé « spontanément ») : `README.fr.md` (sommaire +
  accroche), `docs/guide.md`, `docs/prise-en-main.md`,
  `docs/du-resilient-rudimentaire-au-confort.md` — les skills doivent **constater
  l'existant et compléter sans écraser** (zéro écrasement) ; la home catalogue ce qui
  existe déjà.

## Critères de réalisation

- [ ] Les skills `ap-doc-*` invoquées **depuis la session** (test terrain — comme
      WP-0050 pour `ap-pm2-03-charte-du-projet`).
- [ ] La **home** du jeu de docs (DOC-DOCHS) créée : catalogue par audience + règles de
      séparation + politique de redondance, pointant l'existant.
- [ ] Les docs par audience remplies mode B (au fil de l'eau, 1 doc à la fois).
- [ ] **Zéro écrasement** de l'existant (vérifié).
- [ ] `docs/guide.md` §6 : l'espace Doc documenté (rattrapage WP-0055).

## Note

Le mélange « action spontanée » (docs déjà créées) + « action assistée » (skills) est un
**cas de test de résilience** du kit : la skill qui trouve un doc existant doit le
compléter, jamais le réécrire (discipline du kit, WP-0050 §protocole : « présent → on
complète, jamais d'écrasement »).
