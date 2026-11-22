---
wp_id: WP-0053
titre: "Doc « du résilient rudimentaire au confort » (manifeste court : prévoir le pire comme le meilleur) + accroche README"
type: amelioration
statut: fait
priorite: moyenne
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 22/11/2026 — verbatim : 'il y a une notion importante à ajouter c'est le côté \"du résilient rudimentaire, au confort\". ca doit être un document séparé, dans la doc, et dans le readme, juste une phrase \"accroche\" qui donne envie d'aller le lire. Je veux raconter cette façon de prévoir le pire comme le meilleur, le pire c'est \"text only\" j'ai des fichiers texte et je les édite, même avec nano. ... et tout fonctionne. et le confort, c'est une interface, une ia, un harness, celui que je veux, alors que mon collaborateur en utilise un autre...'"
créé: 2026-11-22
mis_a_jour: 2026-11-22
---

# WP-0053 — Doc « du résilient rudimentaire au confort »

## Objectif

Une **doc séparée** (un **manifeste** court, pas une doc technique) qui raconte la notion
« **du résilient rudimentaire au confort** » : **prévoir le pire comme le meilleur** — le pire
= « **text only** » (des fichiers texte édités même avec `nano`, et **tout fonctionne**), le
meilleur = **le confort** (une interface, une IA, un harness — **chacun le sien**). Dans le
README, **une seule phrase d'accroche** qui donne envie d'aller la lire (à copier par
l'orchestrateur — hors périmètre de ce WP, voir « Accroche README (proposée) » en fin de WP).

## Périmètre

- `docs/du-resilient-rudimentaire-au-confort.md` — **un seul fichier nouveau**, une lecture courte :
  le pire (« text only » + les commandes natives sans IA ni interface — *le pire est une version,
  pas un accident*) · le meilleur (le confort, chacun le sien — le projet mince pointe le bundle,
  zéro sync, zéro copie → pas de conflit de confort — *le confort ne se copie pas, il s'adapte*) ·
  le fil (la même data, du brut au confort — la descente résiliente, l'ascension progressive).
- **Renvoyer, pas dupliquer** : les 3 modes (fichier / natif / IA) → le [guide §1.3](../../docs/guide.md) ;
  la prise en main → `docs/prise-en-main.md` ; le marteau / le coffre → `docs/install.md`.
- **Hors périmètre** : la modification du README (l'accroche est **proposée** en fin de WP —
  l'orchestrateur la copie) · `README.en.md` (à décider, comme les autres docs).

## Critères de réalisation

- [x] `docs/du-resilient-rudimentaire-au-confort.md` créée — manifeste court (une lecture courte),
      convention des `docs/` (titre + blockquote d'intro, **sans frontmatter** — comme
      `guide.md` / `prise-en-main.md` / `comment-commencer.md`).
- [x] Renvois en place (guide §1.3, prise-en-main, install, README « 🛟 Résilient ») — rien dupliqué.
- [x] Aucune donnée inventée : chaque concept cité existe déjà dans le kit (3 modes, projet mince,
      marteau/coffre interchangeables, skills pointées jamais copiées — WP-0050, `bootstrap`
      « sans IA, annonce + confirmation », principe « tout ce qui est faisable sans IA se fait sans IA »,
      le harness machine gitignoré `.opencode/`).
- [x] WP tracé (ce fichier) + `statut: fait`.

## Notes

- **Noms de fichiers** (doc + WP) : **ASCII** (`resilient` sans accent) — la convention de noms du
      kit (guide §4.2 : noms ASCII) ; le **titre** de la doc conserve l'accent.
- **Nom de la doc** : le nom proposé `du-resilient-rudimentaire-au-confort.md` est **conservé** —
      l'expression est celle de l'utilisateur, elle fait le titre.
- **Accroche README** : à faire par l'orchestrateur — la **seule phrase** (ci-dessous), à placer
      près de la section « Les 3 niveaux de fonctionnement : dégradation résiliente » du
      `README.fr.md`, avec le lien vers `docs/du-resilient-rudimentaire-au-confort.md`.
- Suite possible : miroir EN si le `README.en.md` suit (comme les autres docs).

## Accroche README (proposée)

**Une seule phrase** (l'orchestrateur la copie dans le README — ajuster le lien si besoin) :

> Tes projets dans des fichiers texte, édités même avec `nano`, et tout fonctionne — parce que le pire est une version du kit, pas un accident, et que le confort (ton interface, ton IA, ton harness, chacun le sien) ne se copie pas, il s'adapte : [du résilient rudimentaire au confort →](docs/du-resilient-rudimentaire-au-confort.md).
