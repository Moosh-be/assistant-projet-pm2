---
wp_id: WP-0047
titre: "Scan v2 — indicateurs d'objets métiers, mémorisation dans l'inventaire, classement, chantiers + propriétés + manifeste"
type: livrable
statut: a-faire
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 18/11/2026 — verbatim : 'on propose de lancer un premier scan. 1° on cherche des répertoires qui contiennent des indicateurs de présence d'objet métiers d'un chantier projet : .git, .obsidian, .vcscode, … 2° on propose la liste des trouvailles, ça sera mémorisé dans le dépôt d'inventaire. Pour chaque dossier on pourra choisir entre \"projet\", \"projet assisté\", \"portefeuille\", \"dossier\" (contenant plusieurs chantiers), produit, programme … Dans cette liste on va afficher les chantiers trouvés et leur propriété (les fichiers config à la racine) dont surtout celui de l'assistant — chaque projet qui est gouverné par l'assistant a son propre manifeste. Si on change de \"root\" pour se placer dans un chantier alors l'assistant du chantier prend le relais.'"
créé: 2026-11-18
mis_a_jour: 2026-11-18
---

# WP-0047 — Le premier scan v2

## Objectif

Proposer de **lancer un premier scan** : trouver les chantiers sur la machine, les mémoriser dans
l'inventaire (WP-0044), les classer, et afficher leurs propriétés — dont **le manifeste de
l'assistant** (chaque chantier gouverné a le sien).

## Critères de réalisation

- [ ] **1° Recherche** : des répertoires contenant des **indicateurs de présence d'objets métiers d'un chantier projet** : `.git`, `.obsidian`, `.vscode` (sic « .vcscode »), …
- [ ] **2° Proposition** : la liste des trouvailles — **mémorisée dans le dépôt d'inventaire** (WP-0044)
- [ ] **3° Classement** : pour chaque dossier, choisir entre `projet` · `projet assisté` · `portefeuille` · `dossier` (contenant plusieurs chantiers) · `produit` · `programme` · …
- [ ] **4° Affichage** : les **chantiers trouvés + leurs propriétés** (les fichiers de config à la racine) — et **surtout celui de l'assistant** : chaque chantier gouverné a **son propre manifeste** (aujourd'hui : `projet.md` à la racine = le signal « projet assisté »)
- [ ] **Changement de « root »** : entrer dans un chantier → **l'assistant du chantier prend le relais** (déjà ✅ : `commence <nom>` + l'`opencode.json` du projet pointe le protocole du bundle)
- [ ] Parité PS + bash, fichiers en LF, tests sandbox

## Notes

- Le `scan` actuel (WP-0012, ✅) **le préfigure** : 3 buckets — assistés mince/copie complète ·
  pourraient · sans signal. La v2 = indicateurs métier élargis + mémorisation + classement + propriétés.
- Étape 7 du flux onboarding `docs/comment-commencer.md` (WP-0042) ; le §8 (relais du chantier)
  est déjà couvert par `commence` (WP-0024/0025).
