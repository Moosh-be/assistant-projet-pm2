---
wp_id: WP-0052
titre: "Sommaire (table des matières) du README.fr.md — insertion en tête, ancres Markdown standard GitHub-style"
type: amelioration
statut: fait
priorite: moyenne
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 22/11/2026 — verbatim : 'j'ai commencé à relire le readme. fr, c'est génial. Mais c'est gros. Ca me ressemble \"tout vouloir dire d'un coup\". Je suis partisant de l'ajout d'une table des matières.'"
créé: 2026-11-22
mis_a_jour: 2026-11-22
---

# WP-0052 — Sommaire (table des matières) du README.fr.md

## Objectif

`README.fr.md` est gros ; l'utilisateur (22/11) veut une **table des matières** pour
naviguer au lieu de tout lire d'un coup. Insertion d'un bloc **`## Sommaire`** en tête
(après le titre + le chapeau, avant le premier contenu de fond `## Pourquoi faire ça ?`).

Décision 22/11 : **ancres Markdown standard** `[texte](#ancre)` — pas de wikilinks
Obsidian `[[...]]` (compatibles GitHub + lecture Obsidian + VS Code) ; **insertion seule**
(aucun titre existant modifié) ; bloc **compact** (la taille du README est le motif du besoin).

## Périmètre

- `README.fr.md` : bloc `## Sommaire` = **20 entrées** — les **16 h2** de la partie
  supérieure + les **4 h3** sous « Quatre principes structurants » (niveau 3 là où ça aide
  vraiment : 4 blocs autonomes). Autres h3 de la partie (Versionnage, Actuellement
  implémentées, Connexions envisagées, En une phrase) : non indexés (sous-sections mineures
  / phrase de clôture).
- **Miroirs — décision (22/11, utilisateur)** : `README.md` = **juste la présentation des
  différentes versions** (switcher 🇫🇷/🇬🇧) — **le texte actuel est très bien, tel quel**
  (pas de Sommaire ni d'accroche à y ajouter). `README.en.md` : **rien pour l'instant**
  (pas de Sommaire/accroche tant que le texte EN n'existe pas).

## Critères de réalisation

- [x] Bloc `## Sommaire` inséré entre la fin du chapeau (« Cette convention volontairement
      légère constitue le socle du projet. ») et `## Pourquoi faire ça ?` — **+22 lignes,
      zéro modification du contenu existant** (insertion seule).
- [x] Les **20 ancres vérifiées contre le rendu GitHub réel** de ce fichier poussé (master)
      : les 37 `id="user-content-…"` de la page blob servent de vérité ; chaque ancre du
      Sommaire y figure. Algorithme GitHub observé : minuscules ; ponctuation, guillemets,
      emojis et `²` **retirés sans replacement** ; chaque espace → tiret, **sans collapse ni
      trim** (d'où `#pourquoi-faire-ça-`, `#état-actuel--pm-est-le-premier-cas-dusage-complet`,
      `#-résilient--les-données-…`) ; titres en double → suffixe `-1` (hors Sommaire : voir Notes).
- [x] Style : liste simple 2 niveaux, 1 ancre par section ; pas de backlinks ajoutés (le
      Sommaire est déjà en tête — un « retour en haut » n'aurait pas de sens, et le fichier
      doit rester léger).
- [x] Frontmatter : `statut: fait`, `source` = session du 22/11 + verbatim.

## Notes

- **⚠️ Point d'attention — PARKING (22/11, utilisateur)** : `README.fr.md` contient
  **deux README** — le nouveau (en tête, h1 « (nom provisoire) ») et l'ancien (après la rule
  `-----…`, avec son propre h1 + le switch 🇫🇷/🇬🇧). **5 h2 en double** entre les deux parties
  (Démarrage rapide · Les 3 modes d'alimentation · Forks · Contribution · Licence) → GitHub
  les désambiguise en `-1` dans la partie basse (ex. `#démarrage-rapide-1`).
  **Décision utilisateur (verbatim) : « probablement fusionner élaguer mais parking »** →
  la fusion/élagage est **mise en attente** : aucune action pour l'instant ; le Sommaire
  indexe la partie supérieure uniquement (choix robuste dans les deux cas). À relancer par
  un WP dédié quand on le souhaite.
- Les ancres « atypiques » (tirets doubles / final, tiret en tête des 4 h3 🛟/🔐/🌍/🔌) sont
  le **rendu GitHub réel** du fichier — ce sont les `id` effectifs, pas une approximation.
  Compatibilité lecture Obsidian / preview VS Code sur ces cas = au mieux-effort (leurs
  sluggers sont proches de GitHub mais non garantis sur ces cas-là).
- `fiche.md` (§3 « WPs ouverts ») **non mis à jour** par ce WP (fichier hors périmètre de
  la session) — à rattraper par la session principale.
