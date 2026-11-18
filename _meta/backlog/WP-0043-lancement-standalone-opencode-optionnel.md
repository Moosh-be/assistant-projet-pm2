---
wp_id: WP-0043
titre: "Lancement standalone : proposer l'installation OPTIONNELLE d'opencode (doc avantages/inconvénients + menu de rattrapage)"
type: livrable
statut: a-faire
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 18/11/2026 — verbatim : 'on va devoir rendre l'assistant démarrable en standalone ou en lançant opencode à la racine. En cas de démarrage standalone, il va proposer l'install optionnelle de opencode, en affichant le contenu du fichier de documentation \"Avantage et inconvénient de l'utilisation de opencode\", ensuite il propose \"installer\", \"ne pas installer\". Si je choisis de pas installer, je rappelle qu'il y a une option dans le menu pour si changement d'avis plus tard.'"
créé: 2026-11-18
mis_a_jour: 2026-11-18
---

# WP-0043 — Lancement standalone + opencode optionnel

## Objectif

L'assistant démarre **standalone** (sans IA) ou **en lançant opencode à la racine du repo**. Au
démarrage standalone, l'assistant propose l'**installation optionnelle d'opencode** — jamais
imposée — avec une doc de choix informée.

## Critères de réalisation

- [ ] Nouveau fichier de doc dans le repo : **« Avantages et inconvénients de l'utilisation d'opencode »** (affiché tel quel au moment du choix)
- [ ] Démarrage standalone (`assistant.ps1` / `assistant.sh` à la racine) : proposer opencode (optionnel) → **afficher le contenu de la doc** → choisir **installer** / **ne pas installer**
- [ ] « installer » → lancer l'installation (réutiliser le mécanisme existant du wizard)
- [ ] « ne pas installer » → **rappel : il existe une option dans le menu** pour changer d'avis plus tard (+ l'option `opencode` dans le menu natif)
- [ ] Parité PS + bash, fichiers en LF, tests sandbox

## Notes

- Aujourd'hui : `install.ps1`/`install.sh` configure opencode (pile par défaut) **sans ce choix
  explicite ni cette doc** — le WP ajoute le choix, la doc et le menu de rattrapage.
- Étape 3 du flux onboarding `docs/comment-commencer.md` (WP-0042).
