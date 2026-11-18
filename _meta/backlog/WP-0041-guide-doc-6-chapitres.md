---
wp_id: WP-0041
titre: "Guide doc 6 chapitres (exemples / installation / perspectives / personnalisation / connexions / méthodes) → dégrossir le README"
type: amelioration
statut: en-cours
priorite: moyenne
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 18/11/2026 — verbatim : 'J'ai modifié le readme, il est trop gros mais pour le dégrossir plus tard on va faire une doc. 1° exemples d'utilisation, 2° Installation et mise en place, 3° perspectives d'évolution, 4° personalisation, 5° connexions, 6° Methodes'"
créé: 2026-11-18
mis_a_jour: 2026-11-18
---

# WP-0041 — Guide 6 chapitres + dégrossissement du README

## Objectif

Le README est trop gros : une **doc guide** structurée en 6 chapitres (structure décidée par l'utilisateur,
18/11) **extrait le contenu** ; ensuite le README est **dégrossi** en une vraie porte d'entrée
(après validation de la doc).

## Critères de réalisation

- [x] `docs/guide.md` : 6 chapitres — 1. exemples d'utilisation · 2. installation et mise en place · 3. perspectives d'évolution · 4. personnalisation · 5. connexions · 6. méthodes
- [x] Contenu extrait du README + `docs/install.md` + `docs/prise-en-main.md` + `AGENT-projet.md` (chaque section du README a une destination, rien d'inventé)
- [x] README : 1 ligne pointeur vers le guide (+ ligne `docs/` de l'arbre) · `AGENT-projet.md` (Liens)
- [ ] **Dégrossissement du README** (après validation de la doc par l'utilisateur) : garder « ce que c'est » + démarrage rapide + arbre + liens ; le détail part dans le guide
- [ ] README.en.md : miroir du dégrossissement (ou décision sur la langue du guide)

## Notes

- La doc est en **français** (langue du projet) — comme les `docs/` existantes.
- Les « perspectives » sont ancrées dans du tracé : WPs (0039 v2, 0036/0037/0038, série portefeuille
  0028→0032, MCP OpenProject 17.9) + idées de connexions du README + méthodes à venir — le reste est
  marqué « à venir » / « idée », jamais présenté comme existant.
- Après le dégrossissement, le README verra sa taille divisée ~2 (estimé) : la porte d'entrée garde
  l'essentiel actionnable en 1 page.
