---
wp_id: WP-0026
titre: "Doc : les 3 modes d'utilisation (fichier / natif / IA) + dégradation résiliente"
statut: fait
priorite: moyenne
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 08/11 — résumé utilisateur verbatim : « on se retrouve avec 3 modes d'utilisations qui peuvent se faire en concurrence avec résilience. Mode Fichier : je ne fais que manipuler des fichiers que je copie de mon espace template à mon espace projet… ça marche même sur un drive. Mode Exécution standalone : je ne fais qu'exécuter que des scripts en local, ça marche sans ia, sans internet. Mode IA : dans une session opencode… synchrone (dans un chat) ou asynchrone (en demandant de traiter des prompts écrits dans des fichiers texte du projet) »"
créé: 2026-11-08
mis_a_jour: 2026-11-09 (fait : décision consignée le 08/11 + sections README fr/en + prise-en-main rédigées le 09/11)
---

# WP-0026 — Doc : les 3 modes d'utilisation + dégradation résiliente

## Contexte
Le résumé de l'utilisateur du 08/11 clarifie l'architecture post-WP-0025 en **3 modes
d'utilisation qui dégradent en résilience** : fichier → natif → IA. La décision est
consignée (`decisions.md` 08/11) ; il restait à la rendre explicite dans les docs —
aujourd'hui « tout ce qui est faisable sans IA se fait sans IA » n'est qu'un principe en
intro, pas un modèle d'usage.

## Périmètre (fait le 08/11)
- [x] Ligne `decisions.md` du 08/11 (la décision structurante).
- [x] Section « Les 3 modes d'utilisation (dégradation résiliente) » dans `README.fr.md`
      + `README.en.md` : table mode / a besoin de / ce que ça fait + l'échelle de
      résilience (on perd des capacités, jamais les données ; le bootstrap remonte
      l'échelle depuis une copie bare).
- [x] Sous-section « Dans le mode IA — agent, command, skill » (qui / quoi / comment) —
      la différence agent vs skill pas encore maîtrisée côté utilisateur.
- [x] Version compacte dans `docs/prise-en-main.md` (§0, après le principe en une phrase).
- Attention au nommage : « 3 modes d'**utilisation** » (fichier/natif/IA) ≠
  « 3 modes d'**alimentation** » (A/B/C) déjà existant dans les README — conservé tel quel.

## Ouvert
- Vocabulaire : le « **relai** » de l'utilisateur = le « lanceur mince (+ bootstrap) » du
  code — la doc utilise les deux (« le lanceur mince (le « relai ») »). À trancher
  éventuellement un terme unique.
