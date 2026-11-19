---
wp_id: WP-0048
titre: "Espace des normes — les templates des objets métiers gérés, basés sur des normes (à l'instar des méthodes)"
type: livrable
statut: a-faire
priorite: moyenne
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 18/11/2026 — verbatim : 'les objets métiers gérés ont eux aussi leur templaters basés sur des normes (donc à l'instar des \"methodes\") on va retrouver un espace avec toutes les normes à soutenir dans les chantiers. je dois encore creuser : * Gouvernance et management de projet ISO 21500 / ISO 21502, PMBOK, PRINCE2 * Chantier / ouvrage construit ISO 19650, IFC (ISO 16739), ISO 12006-3, ISO 23387 — Informations du projet, objets physiques, propriétés, classifications et échanges BIM * Description structurée d'objets et attributs ISO/IEC 11179, RDF/OWL, JSON-LD * Processus et flux entre acteurs BPMN, UML' + 'ces \"normes\" vont définir les informations attendues dans chaque markdown ; on aura aussi un outil de validation' + 'je vois 2 types de métadonnées celles qui sont \"rassemblées au début\" et celle qui sont \"inline\". le markdown reste au départ un texte \"brut\" avec un formatage simple. Mais on peut y placer une notation plus structurée. l'objectif de la résilience c'est qu'un document ne doit jamais être \"cassé\". un parser doit pouvoir \"réparer\" (au pire en demandant une confirmation de réparation)'"
créé: 2026-11-18
mis_a_jour: 2026-11-18
---

# WP-0048 — L'espace des normes (objets métiers gérés)

## Objectif

Les **objets métiers gérés** ont eux aussi leurs **templates**, basés sur des **normes** — donc, à
l'instar des « méthodes » (WP-0045), **un espace avec toutes les normes à soutenir dans les
chantiers**.

> **À creuser par l'utilisateur** (verbatim : « je dois encore creuser ») — le ticket trace la
> direction et les questions ouvertes, **pas un design final**.

## Les catégories d'exemples (18/11, verbatim)

| Domaine | Normes citées | Contenu |
|---|---|---|
| **Gouvernance et management de projet** | ISO 21500 / ISO 21502 | — · (PMBOK · PRINCE2 → **méthodes**, exemples seulement — journal 001, traité 18/11) |
| **Chantier / ouvrage construit** | ISO 19650 · IFC (ISO 16739) · ISO 12006-3 · ISO 23387 | Informations du projet, objets physiques, propriétés, classifications et échanges BIM |
| **Description structurée d'objets et attributs** | ISO/IEC 11179 · RDF/OWL · JSON-LD | — |
| **Processus et flux entre acteurs** | BPMN · UML | — |

## Le rôle des normes (18/11, verbatim)

- **Une norme définit les informations attendues dans chaque Markdown** (objet métier) : ce qui
  doit y figurer (champs / sections / attributs).
- **Un outil de validation** accompagne : il vérifie qu'un Markdown porte bien les **informations
  attendues par la norme** (rapport des manquants / écarts).

## Principes de format et de résilience (18/11, verbatim)

- **2 types de métadonnées** : celles « **rassemblées au début** » (frontmatter) et celles
  « **inline** » (dans le texte).
- **Le Markdown reste au départ un texte « brut » avec un formatage simple** — mais on peut y
  placer une **notation plus structurée**.
- **L'objectif de la résilience** : un document ne doit **jamais** être « cassé ».
- **Un parser doit pouvoir « réparer »** — au pire **en demandant une confirmation de réparation**.

## Réponses du journal (traitées le 18/11 — journal 001–003)

> 3 des 5 questions « à creuser » étaient taguées **prêt** dans `_meta/registry/journal-echanges.md`
> à l'ouverture de session du 18/11 → traitées **comme si elles avaient été dans le prompt de
> l'époque** (mécanisme WP-0049, 1ʳᵉ validation terrain). Tags passés à **traité**.

- **Frontière méthode / norme** (journal 001) : « ce sont des méthodes, et elles seront
  présentées à titre d'exemple mais pour le moment elles ne m'intéressent pas (surtout qu'elles
  ne sont pas "libres") » → **PMBOK et PRINCE2 = méthodes** (exemples seulement, pas à
  développer ; critère retenu : pas « libres »). Ils ne figurent plus en normes ci-dessus.
- **Arbo de l'espace + format** (journal 002) : « ce sont des Markdown avec un frontmatter qui
  contient l'info. L'arborescence est juste pour rendre le truc plus facile quand on travaille à
  la main » → **le frontmatter porte l'info** ; l'arbo (ex. `normes/<NORME>/<version>/<lang>/`)
  est **une aide au travail à la main**, pas une contrainte. Provenance : « je me demande aussi
  comment gérer ce qui vient du repo et ce qui est "local", j'ai l'impression que je vais devoir
  faire plusieurs repos, et l'installeur va faire un checkout de chaque méthode et norme
  demandée » → **direction : plusieurs repos, l'installeur fait le checkout de chaque méthode et
  norme demandée** (mécanisme repo/local encore à définir).
- **Ce qu'est un « objet métier »** (journal 003) : « objet métier c'est justement le terme
  neutre pour tout ça, et ce sont les propriétés activées qui définissent le type » →
  **terme neutre** (livrable, artefact, objet BIM, …) ; **les propriétés activées définissent le
  type**. L'explication existe déjà — vérifiée le 18/11 :
  [Moosh-be/unofficial-work-structure-dictionary](https://github.com/Moosh-be/unofficial-work-structure-dictionary/)
  (« Work Structure Dictionary » : *pas une méthode, pas un framework, un langage commun*) —
  **41 objets métier** (1 dossier par objet : `README.md` = rôle + principaux champs typés ·
  `schema.md`), **6 troncs communs** réutilisables (EntitéVie, EvenementTemporalise, Acteur,
  Artefact, Financier, Gouvernance), normes communes transverses (statuts, priorités, rôles,
  catégories, liens croisés).

## Points à creuser (questions ouvertes)

- [x] **Frontière méthode / norme** — **résolu 18/11** (journal 001) : PMBOK/PRINCE2 = **méthodes** (présentées à titre d'exemple, pas à développer — « ne sont pas "libres" »). ISO 21500/21502 restent des normes.
- [x] **Arbo de l'espace** (partiellement) — 18/11 (journal 002) : **le frontmatter porte l'info** ; l'arbo est **une aide au travail à la main** (pas de contrainte rigide). Restent : **versions** et « **présence dans l'espace = soutenue** » (logique de découverte WP-0045) à valider.
- [x] **Définition « objet métier »** — **résolu 18/11** (journal 003) : **terme neutre** (livrable / artefact / objet BIM / …) ; **les propriétés activées définissent le type**. Référentiel existant : **Work Structure Dictionary** (Moosh-be — 41 objets, `README`+`schema`, 6 troncs communs). → **Conséquence ouverte** : le kit **référencera-t-il ce repo** (provenance : repo de projet, comme WP-0045) plutôt que de recréer les templates d'objets ? (à trancher par l'utilisateur)
- [x] **Format** — **confirmé 18/11** (journal 002) : **Markdown + frontmatter** (le frontmatter contient l'info).
- [ ] **Syntaxe de la notation structurée inline** : comment la placer dans le texte « brut » sans le casser (les 2 types de métadonnées : « rassemblées au début » / « inline »)
- [ ] **Sémantique de la réparation** : quels dégâts sont réparables (métadonnées ? structure ?), le flux de **confirmation de réparation** (rappel : le kit annonce + confirme avant d'agir — bootstrap)
- [ ] Le **validateur de normes** est-il aussi le **répair** (défaut détecté → proposer la réparation) ?
- [ ] **Provenance** : normes du kit vs normes de repos de projet (par analogie WP-0045) — à trancher. **Direction** (journal 002) : **plusieurs repos, l'installeur fait le checkout de chaque méthode et norme demandée** ; gestion repo/local à définir (journal 005 = draft).

## Notes

- **Analogie directe avec WP-0045** (méthodes) : découverte par présence dans l'espace, versions
  multiples possibles, provenance mixte (kit / repos de projet), format Markdown.
- Le **scan v2** (WP-0047) classe les chantiers — « chantier / ouvrage construit » (BIM) est un
  cas de figure à soutenir.
- **Référentiel objets métier existant** (vérifié 18/11) :
  [Moosh-be/unofficial-work-structure-dictionary](https://github.com/Moosh-be/unofficial-work-structure-dictionary/)
  — standard de structure de données générique pour les unités de travail, agnostique
  outils/méthodes (« un langage commun »).
