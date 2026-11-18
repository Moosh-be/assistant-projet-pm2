---
wp_id: WP-0049
titre: "Journal des échanges — réponses différées (tags draft / prêt / traité / complété) + flag notepad"
type: livrable
statut: en-cours
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 18/11/2026 — verbatim : 'On va ajouter une règle à l'agent. Quand on est dans une discussion et que des questions sont posées, elles sont copiées dans un fichier \"journal des échanges\", toutes les questions sont ajoutées à ce document, avec une zone dédiée à la réponse et un tag [draft-prêt-traité-complèté]. draft (statut initial) = réponse à ignorer pour le moment. prêt = considérer la réponse comme si elle avait été mise dans le prompt de l'époque. traité, une fois que la réponse a été traitée par l'ia (c'est l'ia qui change ce statut). complèté/amandé = c'est comme prêt sauf que on est déjà passé par l'état traité, c'est donc un complément, ne pas ignorer le passé. Attention devant chaque question on représise le contexte de la question, éventuellement les réponses précédentes. selon un flag de config de l'assistant un notepad ouvre le fichier chaque fois qu'il est modifié.' + 'pout moi tu peux ajouter dans le fichier config de l'assistant pour tous les projets un \"oui\" pour l'ouverture de l'editeur de note en cas de crea/modif de celle ci et y mettre notepad++'"
créé: 2026-11-18
mis_a_jour: 2026-11-18
---

# WP-0049 — Le journal des échanges (réponses différées)

## Objectif

Les questions posées en discussion **n'obligent pas une réponse immédiate** : elles sont copiées
dans un **journal des échanges** ; l'utilisateur y répond **quand il veut** et pilote quand l'IA
doit la prendre en compte, via le **tag**.

## Le mécanisme (18/11, verbatim)

- Quand **une question est posée en discussion** → elle est **copiée** dans le journal
  (`_meta/registry/journal-echanges.md`, 1 entrée par question, **jamais d'écrasement**) :
  **contexte de la question reprécisé** (éventuellement les réponses précédentes) + question
  (verbatim) + **zone dédiée à la réponse** + **tag**.
- **Tags** :
  - **draft** (statut initial) : la réponse est **à ignorer** pour le moment.
  - **prêt** : considérer la réponse **comme si elle avait été mise dans le prompt de l'époque**.
  - **traité** : la réponse a été traitée par l'IA — **c'est l'IA qui change ce tag**.
  - **complété / amendé** : comme **prêt**, sauf qu'on est **déjà passé par l'état traité** :
    c'est un **complément** — **ne pas ignorer le passé** (le traitement d'origine reste valable).
- **À l'ouverture de session** : l'IA lit le journal, traite les **prêt**/**complété** (injection
  de la réponse « comme dans le prompt de l'époque »), puis passe le tag à **traité**.
- **Flag de config** : `journal_notepad` — si activé, **un Notepad ouvre le fichier chaque fois
  qu'il est modifié**.

## Critères de réalisation

- [x] **Règle dans le protocole** : `AGENT-projet.md` §3.4 « Journal des échanges » (18/11)
- [x] **Le fichier** : `_meta/registry/journal-echanges.md` (format d'entrée + 5 entrées seed **draft** = les 5 questions « à creuser » du WP-0048)
- [ ] **Flag `journal_notepad`** : l'éditeur ouvre le fichier à chaque création/modification (automation déterministe — hook, sans IA) — **config pré-posée le 18/11 (demande utilisateur)** : `journal_notepad = oui` + `note_editor = C:\Users\ctg\PortableApps\Notepad++Portable\Notepad++Portable.exe` dans les **2 copies** (dev + bundle = tous les projets)
- [ ] **Moteur** : `menu` / `statut` affichent les entrées **à traiter** (prêt / complété) et le compteur par tag (PS + bash, parité)
- [ ] **Cycle d'usage réel** : 1ʳᵉ réponse d'utilisateur (1 des 5 entrées seed) → tag prêt → l'IA la traite et passe traité (validation terrain du mécanisme)

## Notes

- **Cas d'usage déclencheur** (18/11) : les 5 questions « à creuser » du WP-0048 à which
  l'utilisateur n'avait pas répondu — elles sont les **entrées seed** du journal.
- Cohérent avec l'échelle de résilience du kit : le journal **ajoute**, n'écrase jamais ; le passé
  (traité) n'est jamais invalidé, seulement **complété**.
- Le **répair** du parser (WP-0048 : « un document ne doit jamais être cassé ») et ce journal
  partagent le même principe : l'écriture ne détruit jamais.
