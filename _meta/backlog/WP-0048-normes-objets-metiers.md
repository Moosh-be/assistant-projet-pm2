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
| **Gouvernance et management de projet** | ISO 21500 / ISO 21502 · PMBOK · PRINCE2 | — |
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

## Points à creuser (questions ouvertes)

- [ ] **Frontière méthode / norme** : PMBOK et PRINCE2 figuraient dans la liste des *méthodes* « à venir » (décision 17/11, WP-0040) — ici ils sont cités en *normes* de gouvernance. Qu'est-ce qui fait qu'un référentiel est une **méthode** vs une **norme** ?
- [ ] **Arbo de l'espace** : `normes/<NORME>/<version>/<lang>/` ? (par analogie avec `methode/<M>/<lang>/` + versions, WP-0045) — la **présence dans l'espace = la norme est soutenue** (même logique de découverte que les méthodes)
- [ ] **Templates d'objets métiers** : qu'est-ce qu'un « objet métier » dans ce kit (un livrable ? un artefact ? un objet BIM ?) et où vivent ses templates (cet espace vs le projet)
- [ ] **Format** : Markdown comme les méthodes ? (à confirmer)
- [ ] **Syntaxe de la notation structurée inline** : comment la placer dans le texte « brut » sans le casser (les 2 types de métadonnées : « rassemblées au début » / « inline »)
- [ ] **Sémantique de la réparation** : quels dégâts sont réparables (métadonnées ? structure ?), le flux de **confirmation de réparation** (rappel : le kit annonce + confirme avant d'agir — bootstrap)
- [ ] Le **validateur de normes** est-il aussi le **répair** (défaut détecté → proposer la réparation) ?
- [ ] **Provenance** : normes du kit vs normes de repos de projet (par analogie WP-0045) — à trancher

## Notes

- **Analogie directe avec WP-0045** (méthodes) : découverte par présence dans l'espace, versions
  multiples possibles, provenance mixte (kit / repos de projet), format Markdown.
- Le **scan v2** (WP-0047) classe les chantiers — « chantier / ouvrage construit » (BIM) est un
  cas de figure à soutenir.
