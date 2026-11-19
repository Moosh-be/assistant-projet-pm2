# _meta/registry/journal-echanges.md — Journal des échanges (réponses différées)

> **Règle** (18/11, WP-0049) : quand **une question est posée en discussion**, l'assistant la
> **copie dans ce journal** — 1 entrée par question, **jamais d'écrasement** (on ajoute, on
> n'édite pas le passé). **Devant chaque question**, le **contexte** est reprécisé, éventuellement
> les **réponses précédentes**.
>
> **Tag de statut** par entrée :
>
> | Tag | Sémantique |
> |---|---|
> | **draft** (statut initial) | la réponse est **à ignorer** pour le moment |
> | **prêt** | considérer la réponse **comme si elle avait été mise dans le prompt de l'époque** |
> | **traité** | la réponse a été traitée par l'IA — **c'est l'IA qui change ce tag** (après traitement d'un prêt / complété) |
> | **complété / amendé** | comme **prêt**, sauf qu'on est **déjà passé par l'état traité** : c'est un **complément** d'une réponse passée — **ne pas ignorer le passé** (le traitement d'origine reste valable) |
>
> **À l'ouverture d'une session** : l'assistant lit ce journal — les entrées **prêt** ou
> **complété** sont à traiter (leur réponse s'injecte dans le travail comme si elle avait été dans
> le prompt de l'époque) ; une fois traitées, **l'IA passe le tag à traité**.
>
> **Flag de config** : `journal_notepad` — si activé, **un Notepad ouvre le fichier chaque fois
> qu'il est modifié** (l'utilisateur voit l'entrée apparaître). [À implémenter — WP-0049]
>
> Format d'une entrée :
>
> ```
> ### NNN — <sujet court>
> - **Contexte** : <reprécision du contexte de la question, réponses précédentes le cas échéant>
> - **Question** : <verbatim>
> - **Source** : session du JJ/MM/AAAA
> - **Tag** : draft
> - **Réponse** :
>   >
> ```

---

### 001 — WP-0048 : frontière méthode / norme
- **Contexte** : WP-0048 (espace des normes, à creuser) — PMBOK et PRINCE2 figurent dans la liste des *méthodes* « à venir » (décision 17/11, WP-0040) **et** en *normes* de gouvernance (18/11).
- **Question** : qu'est-ce qui fait qu'un référentiel est une **méthode** vs une **norme** ?
- **Source** : session du 18/11/2026
- **Tag** : traité
- **Réponse** :
  > ce sont des méthodes, et elle seront présentée à titre d'exemple mais  pour le moment elle ne m'intéressent pas (surtout qu'elles ne sont pas "libres"  

### 002 — WP-0048 : arbo de l'espace normes/ (+ versions)
- **Contexte** : WP-0048 — par analogie avec `methode/<M>/<lang>/` + versions (WP-0045).
- **Question** : quelle **arbo** pour l'espace `normes/` (et le traitement des **versions**) ?
- **Source** : session du 18/11/2026
- **Tag** : traité
- **Réponse** : 
  > je réfléchi encore,   ce sont des Markdown avec un frontmatter qui contient l'info. L'arborescence est juste pour rendre le truc plus facile quand on travaille à la main. je me demande aussi comment gérer ce qui vient du repo et ce qui est "local", j'ai l'impression que je vais devoir faire plusieurs repos, et l'installeur   va faire un checkout de chaque méthode, et norme demandée
 

### 003 — WP-0048 : ce qu'est un « objet métier » dans le kit
- **Contexte** : WP-0048 — les normes définissent les informations attendues de chaque Markdown (objet métier).
- **Question** : qu'est-ce qu'un **« objet métier »** dans le kit (un **livrable** ? un **artefact** ? un **objet BIM** ?)
- **Source** : session du 18/11/2026
- **Tag** : traité
- **Réponse** : 
  >objet  métier c'est justement le terme neutre pour tout ca, et ce sont les propriétés activées qui définissent le type. J'ai déjà expliqué ca mais c'est peut-être dans mon 2ndB ou dans le projet https://github.com/Moosh-be/unofficial-work-structure-dictionary/

### 004 — WP-0048 : format des normes
- **Contexte** : WP-0048 — la norme doit être **lisible par la machine** pour l'outil de validation (position assistant, 18/11 : un template qui *déclare* les informations attendues).
- **Question** : quel **format pour les normes** (déclaration lisible machine des informations attendues ?) + **Markdown confirmé** ?
- **Source** : session du 18/11/2026
- **Tag** : draft
- **Réponse** :
  >

### 005 — WP-0048 : provenance
- **Contexte** : WP-0048 — par analogie avec WP-0045 (méthodes : kit vs repos de projet, déclaration dans le manifeste du projet — position assistant).
- **Question** : **provenance** des normes : kit vs **repo git de projet** — quel mécanisme de déclaration ?
- **Source** : session du 18/11/2026
- **Tag** : draft
- **Réponse** :
  >

