---
wp_id: WP-0022
titre: "Pédagogie PM2 : expliquer les 4 phases au début, signaler les phases sautées dans statut"
statut: en-cours
priorite: haute
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 04/11/2026 — verbatim : 'il faut être plus pédagogique au début, l'utilisateur ne connait pas l'assistant et connait mal PM²'"
créé: 2026-11-04
mis_a_jour: 2026-11-04
---

# WP-0022 — Pédagogie : les 4 phases, et les phases sautées sont signalées

## Contexte

L'utilisateur qui découvre le kit ne connaît ni l'assistant, ni PM². Aujourd'hui, rien ne lui
explique la trajectoire (4 phases, 4 gates), et rien ne dit qu'il a **sauté** une phase en cours
de route — on avance par inertié, pas par maîtrise.

## Décision

1. **Expliquer au début** : après `new` et `add`, 2 lignes — les 4 phases (Lancement →
   Planification → Exécution → Clôture, chacune clôturée par un gate = 1 checklist), on attaque
   par la Lancement, une phase **peut** être sautée mais le statut le signalera ensuite
   (« à faire par maîtrise ou curiosité »). + 1 ligne fixe au menu.
2. **Signaler les sauts** : `statut` détecte les phases antérieures à la phase courante dont le
   gate n'est pas vert → ligne
   `Sautees : X, Y   (gate non vert - a combler par maitrise, pas par dehabitude)`.
   - **Source de vérité = la table d'avancement** (section « État de la phase » de `projet.md`
     ou `_meta/fiche.md`) — PAS le frontmatter (pas de clés par phase).
   - Gate « vert » = contient ☑ (U+2611) ou ✅ (U+2705) ; gate `—` (U+2014) = pas de gate sur
     cette phase → non traqué.
   - Rang de la phase courante par **préfixe ASCII** (`Lan`/`Pla`/`Ex`/`Cl`) : les noms réels
     de la table sont accentués (`Exécution`, `Clôture`) → on compare sur le préfixe.

## Périmètre

- [x] `assistant.ps1` : bloc « Sautees » dans `Cmd-Statut` (1 passe sur la table, pattern
      `$in3 -match '^## 3\.' -continue`) + lignes pédagogiques `new`/`add` + ligne menu
- [x] `assistant.sh` : idem (`awk` sur la section 3 + `case` gate ☑/✅/—)
- [x] Code mort retiré : `phase_welcome` (bash) — la pédagogie est inline dans new/add
- [x] Tests sandbox PS (7 cas) + bash (7 cas) : vert — `Sautees : Lancement, Planification`
      quand `phase: Exécution` sans clôture
- [x] `decisions.md` : 1 ligne
- [ ] Validation terrain : voir la ligne `Sautees` dans le 1ᵉʳ projet réel

## Notes

- Bug corrigé en cours de session : 1ʳᵉ version PS avec `if ($done3) { break }` en tête de
  boucle = passe morte (break immédiat après `## 3.`) → réécrit en 1 passe unique.
- Codepoints en dur via `[char]0x2611` / `[char]0x2705` / `[char]0x2014` (PS) et littéraux
  UTF-8 dans le bash : le `.ps1` reste **ASCII pur** (0 byte non-ASCII exigé).
