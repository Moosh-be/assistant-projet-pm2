---
wp_id: WP-0044
titre: "Inventaire local — répertoire, 1 fichier .md par chantier (fiche mémoire = copie de la fiche à la racine du chantier)"
type: livrable
statut: a-faire
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 18/11/2026 — verbatim 1 : 'on va proposer de choisir un endroit où placer les infos sur tous les projets à assister. c'est l'inventaire local, ce n'est pas un portefeuille mais il sera possible de proposer un portefeuille qui reprendra les éléments de cet inventaire.' + verbatim 2 (scénario conseillé) : 'commencer par se créer un inventaire local, c'est un répertoire avec une liste de fichiers .md qui reprend tous les \"chantiers\" repérés, et dans ce document on trouve la fiche mémoire du chantier. c'est une copie de la fiche qui se trouve aussi à la racine du chantier.'"
créé: 2026-11-18
mis_a_jour: 2026-11-18
---

# WP-0044 — L'inventaire local

## Objectif

Une fois le point opencode réglé (WP-0043), l'assistant propose de **choisir un endroit où placer
les infos sur tous les projets à assister** : **l'inventaire local** — persistant, lisible par
l'agent, dépôt des trouvailles du scan (WP-0047).

## Scénario conseillé (18/11, verbatim)

Commencer par se créer un **inventaire local** : c'est un **répertoire** avec une **liste de
fichiers `.md`** qui reprend tous les **« chantiers » repérés** — et dans ce document on trouve
la **fiche mémoire du chantier**. C'est **une copie de la fiche qui se trouve aussi à la racine
du chantier** (le `projet.md` du chantier assisté).

## Critères de réalisation

- [ ] À l'onboarding : **proposer un endroit** pour l'inventaire local (choix utilisateur, par défaut à définir)
- [ ] **Format : un répertoire — 1 fichier `.md` par chantier** repéré (ex. `<nom-chantier>.md`)
- [ ] Chaque fichier = la **fiche mémoire du chantier** : **copie de la fiche à la racine du chantier** (`projet.md`) [À confirmer — pour un chantier SANS `projet.md` (non assisté), la fiche mémoire = une notice avec les propriétés détectées (fichiers de config à la racine) ?]
- [ ] Les **trouvailles du scan** (WP-0047) sont **mémorisées** dans cet inventaire (1 fichier par trouvaille)
- [ ] **Lien WP-0037** (registre d'inventaire machine `C:/Users/ctg/.assistant/inventaire.md`, **1 seul fichier**, créé le 17/11 : 26 espaces) : la cible = **ce répertoire par chantier** — le fichier unique actuel à remplacer / migrer, à trancher avec l'utilisateur
- [ ] Parité PS + bash, fichiers en LF, tests sandbox

## Notes

- **Ce n'est pas un portefeuille** : c'est l'endroit qui centralise les **informations**
  (emplacement, signaux, classement, fiche mémoire) des chantiers à assister.
- Mais il sera possible de **proposer un portefeuille** (méthode PfM², série WP-0028…0032)
  **qui reprend les éléments de cet inventaire**.
- Étape 4 du flux onboarding `docs/comment-commencer.md` (WP-0042).
