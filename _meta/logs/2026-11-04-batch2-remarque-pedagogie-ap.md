# Session 2026-11-04 — batch2 : remarques au vol, pédagogie PM2, préfixe /ap-

1ʳᵉ utilisation réelle du kit (session 03/11) → 3 WPs répondant directement aux remarques de l'utilisateur.
Lot complet : code PS + bash, tests sandbox des deux côtés verts, couche méta écrite.

## WP-0021 — `remark` : journal des remarques au vol

Demande verbatim : « il faut ajouter un journal des remarques au vol pour remonter dans le
projet assistant les améliorations à y faire ».

- **`assistant remark <texte>`** depuis le projet → `_meta/registry/remarques.md` :
  1ʳᵉ entrée = header markdown créé auto, puis 1 ligne `- [AAAA-MM-JJ] <texte>` par remarque.
- Les entrées marquées `[pour l'assistant]` : l'agent **propose** de les remonter au projet
  assistant (la remontée reste une décision humaine, jamais auto).
- Gardes-fous : pas dans un projet → message ; pas de message → usage.
- Découverte immédiate : la note « Prochain pas » de `new`/`add` annonce la commande.

## WP-0022 — Pédagogie : 4 phases expliquées + phases sautées signalées

Demande verbatim : « il faut être plus pédagogique au début, l'utilisateur ne connait pas
l'assistant et connait mal PM² ».

- **Au début** : `new`/`add` affichent 2 lignes — 4 phases (Lancement → Planification →
  Exécution → Clôture, 1 gate = 1 checklist par phase), on attaque par la Lancement, une phase
  peut être sautée mais le statut le signalera ensuite (« à faire par maîtrise ou curiosité »).
  + 1 ligne fixe au menu.
- **En continu** : `statut` détecte les phases antérieures dont le gate n'est pas vert →
  `Sautees : X, Y   (gate non vert - a combler par maitrise, pas par dehabitude)`.
  - Source de vérité = la **table d'avancement** (section 3), pas le frontmatter.
  - Gate vert = ☑ (U+2611) ou ✅ (U+2705) ; `—` (U+2014) = pas de gate → non traqué.
  - Rang de phase par préfixe ASCII (Lan/Pla/Ex/Cl) car les noms de la table sont accentués.
- Bug corrigé : 1ʳᵉ version PS avec `if ($done3) { break }` en tête de boucle = passe morte →
  1 passe unique. Code mort `phase_welcome` (bash) retiré.

## WP-0023 — Préfixe `/ap-` sur les commandes opencode

Demande verbatim : « le /statut devrait être /ap-statut-projet, toutes les commandes
devraient commencer par /ap- » + justification : « pour se distinguer des éventuelles
commandes ajoutée par le gestionnaire du projet qui voudrait lui aussi utiliser opencode ».

- **L'espace slash opencode est partagé** (le projet peut ajouter ses propres slash-commands)
  → le nôtre est **réservé** au préfixe `/ap-` (ap = assistant-projet), schéma
  `/ap-<nom>-<domaine>` (proposition 1 validée : « la plus claire et la plus réversible »).
- `/statut` → **`/ap-statut-projet`** ; `/scan` → **`/ap-scan-projets`**
  (fichiers `git mv` : `ap-statut-projet.md`, `ap-scan-projets.md`).
- **Les commandes natives (script) gardent leur nom** : `assistant new/scan/statut/add/
  update/remark/commence` — pas d'espace de nommage partagé, pas de collision possible.
  (Explication complète des 2 familles fournie à l'utilisateur avant validation — il ne
  distinguait pas les commandes natives des slash-commands.)
- Toutes les refs slash mises à jour (scripts ×2, READMEs ×2, docs ×2) ; `_meta/` historique
  **pas réécrit**.

## Tests sandbox (PS + bash, tous verts)

7 cas de chaque côté, sandbox `selftest-batch2` (PS) / `selftest-batch2-sh` (bash) :
`new` (note pédagogique + ref /ap-statut-projet) → `remark` ×2 (remarques.md créé avec
header + 2 entrées datées) → `statut` Lancement (pas de Sautees) → `statut` Exécution
(`Sautees : Lancement, Planification`) → menu (lignes PM2 + remark) → `remark` hors projet
(message) → `remark` sans message (usage). Syntaxe : parse PS 0 erreur (586 lignes, 0
non-ASCII, 0 NUL), `bash -n` OK (580 lignes).

## Incidents (troncature n°4)

L'insertion batch dans `assistant.sh` a **tronqué** le fichier à la ligne 589 (milieu du
dispatch : `*) echo "Commande inco`) + corrompu la ligne `remark` (`cmd_remark ""` au lieu
de `cmd_remark "${2:-}"`). Réparation : 2 micro-éditions ciblées (queue du dispatch + ligne
remark), `bash -n` OK. 4ᵉ occurrence de troncature — la règle tient : après TOUTE modif de
script, vérifier la fin du fichier + `bash -n` + le diff.

## WP-0024 — `liste` + menu 2 blocs (retour terrain : le menu à la racine du kit)

Retour terrain du 04/11 : l'utilisateur lance `.\assistant.ps1` **à la racine du kit** et
repère 2 choses :
1. « `statut <projet>` — je dois donner le nom d'un projet ? sous quelle forme, comment
   obtenir la liste ? l'autocomplete fonctionne ? » → nom du dossier exact, pas de
   liste dédiée, pas d'autocomplete.
2. « on doit distinguer la commande qui lance le gestionnaire d'assistance, locale (pour
   gérer les projets), et l'assistance qu'on retrouve dans chaque projet séparément
   (mais qu'on retrouve aussi ici du coup) » → le menu mélangeait les 2 positions.

Décision validée : « 1 + 2 + une commande liste pour celui qui y pense avant ».
- `statut <nom>` introuvable → message **+ liste** des projets (nom + phase + gate).
- `statut` sans argument : dans un projet → le projet courant ; hors projet → **la liste**
  (le kit = un projet = son propre statut, pas la liste).
- Nouvelle commande **`liste`** (la flotte des racines).
- Menu + menus install restructurés en 2 blocs : **Gérer les projets** (depuis le kit ou
  les racines) / **Dans un projet** (depuis le dossier du projet). Les menus install
  gagnaient aussi `liste` + `update`/`remark` (manquants depuis WP-0020/0021).

Tests sandbox PS + bash (8 cas chacun) : verts. Bug du test : la config machine de la
sandbox bash sans qualificatif `(...)` sur `racines =` → `get_racines` vide (le format
réel est `<chemin> (<qualificatif>)`), corrigé dans le test.

## À faire côté utilisateur

1. **Relancer opencode dans un projet** pour le test terrain de WP-0023 :
   `/ap-statut-projet` doit apparaître (les anciennes `/statut`/`/scan` n'existent plus).
2. `2ndb-toolbox` : kit d'avant « projet autonome » + pas de `kit_source` → **re-`add`**
   (zéro écrasement) + ligne `kit_source:` manuelle si besoin.
3. Push des 14+ commits (demandé, non confirmé).
