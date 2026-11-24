---
wp_id: WP-0057
titre: "Comparaison kit assistant vs agent d'initialisation des stagiaires (Copilot) — en se basant sur PM2 et PfM2"
type: livrable
statut: a-faire
priorite: moyenne
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 23/11/2026 — verbatim : « en fait il y a 2 stagiaires qui travaillent sur un agent pour l'initialisation des projets, eux ils vont faire ca en copilot. j'aurais besoin de comparer ce qui est ici avec leur travail. En se basant sur PfM2 et PM2 » puis « mémorise et ferme cette discussion »"
créé: 2026-11-23
mis_a_jour: 2026-11-23
---

# WP-0057 — Comparaison kit vs agent d'initialisation des stagiaires (Copilot)

## Objectif

Comparer **ce kit** (assistant-projet-pm2) avec l'**agent d'initialisation de projets**
développé par les **2 stagiaires** (outillage **Copilot**), **en se basant sur PM2 et PfM2**.

**Forme retenue (position assistant, 23/11, à confirmer)** : une **DOC-COMPA.P**
(comparaison avec la concurrence) produite **avec la skill `ap-doc-comparaison-concurrence`**
— double rôle : test terrain de la skill (WP-0056) + vraie doc du produit dans le
**git du produit** (décision WP-0055).

**Fait à assumer** : le kit n'initie **aujourd'hui que des projets PM2** — PfM2 n'a pas
encore de dossier de méthode dans le bundle (« à venir », WP-0028/0029/0036). Si l'agent
des stagiaires gère PfM2, c'est un point pour eux ; sinon, à égalité.

## Périmètre

- **Camp « ce kit »** — baseline de `assistant new` (vérifiée 23/11, lecture du moteur) :
  - `projet.md` pré-rempli (nom + date, frontmatter `phase: Lancement` / `gate_suivant: RfP`,
    4 rôles, état de phase)
  - `01…05` : dossiers de phases vides (noms dérivés de `methode/PM2/fr`)
  - `_meta/` neuf : fiche + backlog/registry/logs/report + `connexions.md` (partagée,
    voyage) + `connexions.local.md` (machine, gitignorée)
  - lanceur mince + bootstrap (PS + bash, 4 fichiers) — **retablit le bundle sans IA**
  - `opencode.json` : harness pointant le bundle par chemin absolu (protocole + skills)
  - `.gitignore` (partie machine) ; variante `-doc` (projet documentaire, meta seulement)
  - **protocole** au-delà du scaffold : modes A/B/C (dont écoute passive), gate PM2-27,
    `[À confirmer]` + source (zéro invention), zéro écrasement, 3 modes en dégradation
    résiliente (fichier → natif → IA)
- **Camp « agent stagiaires »** : **à fournir par l'utilisateur** (voir Blocage).

## Axes de comparaison (proposés 23/11, à valider)

1. **Couverture des méthodes** — PM2 · PfM2 · d'autres ?
2. **Ce que l'initialisation produit** — doc de projet, structure, outillage dans le
   projet ou en externe (bundle), config multi-machine
3. **Comportement au-delà du scaffold** — entretien, gates, discipline de vérité,
   protection anti-écrasement
4. **Vue PfM2** — initier *un* projet vs initier *un portefeuille* (l'ensemble des
   chantiers) : pas la même échelle
5. **Extensibilité** — ajouter une méthode / une langue
6. **Couplage à l'outil IA** — opencode vs Copilot : les données restent-elles
   portables si on change d'outil ?

## Critères de réalisation

- [ ] Travail des stagiaires **accessible** (repo / dossier local / doc / prompts) → 2ᵉ
      colonne remplie
- [ ] DOC-COMPA.P produite **avec la skill** `ap-doc-comparaison-concurrence` (mode B,
      au fil de l'eau)
- [ ] Les 6 axes (ou la forme validée par l'utilisateur) traités
- [ ] Fait « le kit = PM2 seul aujourd'hui » honnêtement reporté
- [ ] Doc dans le **git du produit** (ce repo) ; home DOC-DOCHS pointant dessus

## Blocage

- **Accès au travail des stagiaires** : à demander (repo ? dossier local ? doc ? juste
  leurs prompts/spec Copilot ?)
- **Leur périmètre** : initialisation uniquement, ou aussi le remplissage après ?
- **Méthodes ciblées** par leur agent : PM2 ? PfM2 ?

## Note

Discussion **fermée à la demande** de l'utilisateur le 23/11 (« mémorise et ferme cette
discussion ») — le besoin est mémorisé ici ; à relancer quand le travail des stagiaires
sera consultable.
