---
wp_id: WP-0054
titre: "« Phases = pointeurs de flux » — convention flux (phase = pointeur, nom préfixé, répertoire du flux, historique en frontmatter)"
type: livrable
statut: a-faire
priorite: moyenne
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 22/11/2026 — verbatim : 'la doc parle de \"phases\" 01 à 05. autant phase c'est un concept classique, autant 01 à 05 c'est propre à \"une méthode\", donc il faut faire attention de ne pas s'enfermer. Ce que j'imagine c'est qu'une phase est un pointeur vers un emplacement dans un flux. chaque élément peut dans son frontmatter afficher son historique de progression et donc en ce compris sa place actuelle. l'important c'est de ne pas laisser croire que ca sera toujours 01-05, je pense donc qu'on doit préfixe le nom de phase par le nom du flux, et rassembler le tout dans un rep au nom de ce flux. on peut considérer qu'il y a toujours un flux. et s'il n'y en a pas, on aura juste \"une phase\"'"
créé: 2026-11-22
mis_a_jour: 2026-11-22
---

# WP-0054 — Phases = pointeurs de flux (convention « flux »)

## Contexte

L'utilisateur (22/11) signale un risque d'**enfermement** : la doc et le moteur parlent
« phases 01 à 05 » — or **phase** est un concept générique, **01→05** est propre à PM². La
notion doit rester ouverte : n'importe quelle méthode = n'importe quel flux, n'importe
quel nombre de phases.

**État vérifié le 22/11** (sources lues pour ce WP) :

- `new`/`add` lisent les noms des dossiers de phase dans `methode/PM2/fr/` (filtre
  `^0[0-9] `) et les créent **à la racine du projet** : `01 Lancement/ … 05 Cloture/`
  + `.gitkeep` (PS : `Deploy-Kit` étape 2, ~L176 ; bash : `deploy_kit` étape 2, ~L154).
- `projet.md` : frontmatter `methode: PM2` · `phase: Lancement` · `gate_suivant: RfP` ;
  le **tableau §3** = source de vérité d'avancement ; `statut`/`menu` reconnaissent la
  position par préfixe ASCII (`Lan`/`Pla`/`Ex`/`Cl`) — le nom **sans** numéro.
- Deux formes de nom coexistent déjà : les **templates** du bundle ont
  `phase: "01 Lancement"` (numéroté), les **projets** ont `phase: Lancement` (non
  numéroté). Le numéro = **indice d'ordre dans le flux**, pas partie du nom de la position.
- **Collision existante** : un projet PM² utilisant GIH (transverse) porte à sa racine
  `01 Lancement/ … 05 Cloture/` **et** `01 Impact humain/` — deux dossiers « 01 »,
  rien ne les désambiguise. Le préfixe flux résout ce cas précis.
- **Projets existants** : `2ndb-toolbox`, `commandschool` (les deux : `methode: PM2`,
  `phase: Lancement`, `01..05` à la racine) — vérifié 22/11.
- Le kit lui-même n'a pas de `01..05` à sa racine (ses artefacts PM² vivent dans
  `methode/PM2/fr/` — WP-0040) : cas particulier « le projet est la méthode ».

## 1. Le concept (reformulé)

- **Un flux** = une trame **ordonnée de positions**, avec ses gates / checklists. Le flux
  est **défini**, pas instancié : le flux d'une méthode vit dans le bundle
  (`methode/<M>/<lang>/` : positions = les dossiers `0N <nom>/`, le `referentiel`, les
  `checklists`) ; un projet peut aussi **définir son propre flux** (v2).
- **Une phase** (dans un projet) = un **pointeur vers un emplacement dans un flux**. La
  phase n'est pas un conteneur à remplir, c'est une *référence* : « PM² / Lancement » =
  « la position 1 du flux PM² ». Le pointeur bouge (on change de position) ; le
  conteneur, lui, est le répertoire.
- **Le nom de phase est préfixé par le nom du flux** : une phase s'identifie par
  **`<flux>/<position>`** — un nom de position tout court (`Lancement`) n'a de sens
  qu'avec son flux.
- **Les phases d'un flux sont rassemblées dans un répertoire au nom de ce flux** :
  `<flux>/<position>/` (PM² : `PM2/Lancement/`, `PM2/Planification/`, …). Aujourd'hui
  elles sont à la racine du projet, ce qui présuppose silencieusement « le » flux = PM² ;
  le répertoire flux le rend explicite et libère la racine pour d'autres flux.
- **L'historique de progression vit en frontmatter** : un élément (projet / artefact)
  peut y afficher sa **place actuelle** dans le flux et son **historique** (par où il est
  passé) — l'élément est « rempli par la preuve » (source sur chaque entrée).
- **« Il y a toujours un flux »** : tout projet est dans un flux. **S'il n'y en a pas
  (d'explicite), une seule phase** — le flux dégénéré à une position : pas de gate, pas
  d'ordre. C'est l'état d'un « projet sans méthode » ; et c'est **l'état actuel** des
  layouts à racine (rétro-compatibilité : l'ancien layout = le cas dégénéré).

**Propriétés** : ajouter une méthode = ajouter un flux ; le nombre de positions n'est
jamais figé (5 pour le flux PM², 1 pour le flux dégénéré, N pour un flux projet). Le
numéro `01`…`05` = indice d'ordre **dans le flux**, propriété de la définition du flux —
pas du nom de phase du projet.

## 2. Options de forme

### 2.1 Le répertoire du flux dans le projet

| Option | Layout (PM²) | Avantages | Inconvénients |
|---|---|---|---|
| **A — rep au nom du flux, flux = nom de la méthode** | `PM2/01 Lancement/ …` | zéro nouveau vocabulaire quand flux = méthode (le cas 100 % du jour) ; changement moteur minimal (créer `<M>/<position>` au lieu de `<position>`) ; le nom du rep = le champ `flux` du frontmatter = une seule source | confond flux et méthode : un « PM² variante » (positions custom) serait mal nommé ; v1 : 1 flux déclaré par projet (hybride → question ouverte Q4) |
| **B — rep explicite `flux-<nom>/`** | `flux-pm2/01 Lancement/ …` | le flux est un concept **propre au projet**, jamais confondu avec une méthode ; plusieurs flux peuvent coexister | préfixe redondant dans le cas 1-flux ; couche de bruit pour 99 % des projets ; le moteur doit dériver le nom du rep depuis `flux:` |
| **C — nom libre, convention = A par défaut** | `PM2/01 Lancement/ …` (défaut) ou `<mon-flux>/…` (défini par le projet) | le plus expressif ; route vers la v2 (flux propres au projet, hybride) | règle de nommage + une source de définition des positions projet à décider (v2) |

**Recommandation : A en v1 (C comme extension)** — le répertoire du flux porte le nom du
flux, **défaut = le nom de la méthode** (`methode:`). Justification : tous les projets
actuels sont PM² → A est sans coût et sans confusion ; C est la généralisation (champ
`flux:` déclaré librement, positions définies par le bundle ou par le projet), à
activer le jour où un projet aura un flux qui n'est pas une méthode. B est écarté en v1 :
le préfixe `flux-` est du bruit quand flux = méthode.

### 2.2 Le « préfixe du nom de phase » : chemin ou chaîne ?

| Forme | Exemple | Avantages | Inconvénients |
|---|---|---|---|
| **Chemin** | `PM2/Lancement` | **est** le chemin du répertoire : nom = pointer = emplacement, une seule notation ; en Obsidian `[[PM2/Lancement]]` pointe sur le dossier ; aucun risque d'ambiguïté (les positions contiennent des espaces — `Suivi-Controle` — mais jamais de `/`) | valeur avec `/` dans le frontmatter : lisible, mais à ne pas confondre avec un chemin disque dans les affichages |
| **Point médian** | `PM2·Lancement` | joli en affichage | 2ᵉ notation distincte du chemin ; `·` non ASCII (convention repo : noms ASCII) ; Obsidian utilise `·` comme séparateur d'alias dans les wikilinks → source de confusion |
| **Tiret** | `PM2-Lancement` | ASCII, simple | coupure ambiguë quand la position porte des `-` (`PM2-Suivi-Controle`) ; 2ᵉ notation |

**Recommandation : le chemin** (`<flux>/<position>`) — le nom de phase **est** le chemin
dans le projet ; c'est le pointer de l'utilisateur, littéral.

**Dans le frontmatter du projet** (choix de stockage du préfixe) :

- **(i) un champ** : `phase: "PM2/Lancement"` — le nom canonique préfixé est la valeur ;
  le moteur découpe sur `/`. Fidèle au verbatim, mais le moteur doit adapter ses tests
  (`-like "*/Pla*"`) et les valeurs existantes (`phase: Lancement`) deviennent legacy.
- **(ii) deux champs** : `flux: PM2` + `phase: Lancement` — le nom canonique
  `<flux>/<phase>` est reconstitué (`$flux/$phase`), l'affichage est toujours préfixé.

**Recommandation : (ii)** — le moteur lit déjà `phase:` par préfixe ASCII
(`Lan/Pla/Ex/Cl`) : les valeurs existantes continuent de fonctionner sans migration des
frontmatters, le parser plat reste plat, et `flux:` donne au moteur/à l'IA le flux sans
parsing de chaîne. (i) reste valide et plus littéral — à trancher avec Q1.

### 2.3 Où vit l'historique de progression ?

| Option | Où | Avantages | Inconvénients |
|---|---|---|---|
| **H1 — `projet.md` seul** | frontmatter `projet.md` (+ tableau §3 existant) | un seul point de vérité de progression ; le moteur lit déjà ce fichier | l'artefact, copié hors projet, ne porte plus sa position |
| **H2 — chaque artefact** | frontmatter de chaque artefact | l'artefact est autonome | redondant avec le referentiel (artefact → position déjà défini dans le bundle) ; deux sources à tenir |
| **H3 — partagé (recommandé)** | `projet.md` = **l'historique** (traversées de positions) ; chaque artefact = **sa position courante seulement** | l'historique reste au niveau projet (une source), l'artefact devient un pointer autonome et léger | deux champs à maintenir — mais un seul travail chacun |

**Recommandation : H3.** Format concret proposé :

`projet.md` (le projet = le pointer sur sa position courante + son historique) :

```yaml
projet: "Mon-Projet"
methode: PM2
flux: PM2              # le flux (défaut = methode ; "" = pas de flux → une seule phase)
phase: Lancement       # la position courante (nom sans préfixe ; canon = flux/phase)
gate_suivant: RfP
historique:
  - "2026-11-03 Lancement (création)"
  - "2026-12-01 Planification (gate RfP vert)"
```

Artefact (template du bundle + copie projet) :

```yaml
template: "03.I"
phase: "01 Lancement"  # la position dans le flux (nom du bundle, inchangé en v1)
statut: en cours
```

Quand un artefact est retravaillé à une autre position (ex. le plan de travail revu en
Suivi-Controle), l'agent met à jour sa `phase:` — et note la traversée dans
`historique:` du projet si c'est un passage de phase.

**Note de compatibilité machine** (vérifié) : `Read-Frontmatter` (PS) et les one-liners
awk (bash) ne parsent que des lignes plates `key: value` — la **liste** `historique:` est
invisible au moteur (ignorée), ce qui est exactement le rôle voulu : l'historique est pour
l'IA et l'humain, la machine ne lit que `flux:` / `phase:` / `gate_suivant:`. Variante
plate si on veut que le moteur voie la dernière entrée :
`historique: "2026-11-03 Lancement → 2026-12-01 Planification"`.

**Exemple de layout v1** (projet PM², flux dégénéré à côté) :

```
Mon-Projet/
├── projet.md               (flux: PM2 · phase: Lancement · historique: […])
├── PM2/                    ← le répertoire du flux (nom = flux)
│   ├── 01 Lancement/       (PM2-01…03)
│   ├── 02 Planification/   (PM2-04…16)
│   ├── 03 Exécution/       (PM2-18)
│   ├── 04 Suivi-Controle/  (PM2-19/21/22/27)
│   └── 05 Cloture/         (PM2-33)
├── GestionImpactHumain/    ← 2ᵉ flux ? ou position transverse (Q4)
└── _meta/
```

## 3. Impact concret si implémentation (surfaces touchées)

| Surface | Changement |
|---|---|
| `assistant.ps1` — `Deploy-Kit` (étape 2, ~L176-188) | créer `<M>/<position>/` au lieu de `<position>/` à la racine (le filtre `^0[0-9] ` sur `methode/PM2/fr/` reste la source des noms) |
| `assistant.sh` — `deploy_kit` (étape 2, ~L154-172) | idem (globe `methode/PM2/fr/*` filtré `0*`) |
| `assistant.ps1` — `Cmd-Statut` + `Get-ProjetEtat` | scan `[À confirmer]` : `0[0-9] *` à la racine → `<flux>/0[0-9] *` (**+ lecture de l'ancien layout** pendant la transition) ; le mapping `Lan/Pla/Ex/Cl` et la lecture du tableau §3 sont **inchangés** (ils opèrent sur le nom de position) |
| `assistant.sh` — `statut_project` + `get_projet_etat` | idem |
| `assistant.ps1`/`.sh` — messages `new`/`add`/`menu`/`Show-Menu` | wording « PM2 : 4 phases … » → vocabulaire flux (5 positions ; Suivi-Controle transverse) |
| `sync` (les deux moteurs) | lit l'ancien layout (rétro-compat) ; **propose** la migration (jamais automatique — discipline zéro écrasement) `[À confirmer]` (Q3) |
| `projet.md` (template racine du kit) | frontmatter : + `flux: PM2`, + `historique:` (liste) ; la ligne « Phase courante » → « position courante (flux PM2) » |
| `tools/templates/fiche-projet.md` | mêmes champs (projet sans code) |
| `AGENT-projet.md` §1 + §2 | spécification frontmatter (`flux:`, `phase:` = position, `historique:`) ; routage « Les artefacts de la phase → `<flux>/<position>/` (dans le projet) » |
| `.opencode/skills/ap-pm2-*` (22) | la ligne « Dans le projet : `01 Lancement/PM2-…` » → `PM2/01 Lancement/PM2-…` — **régénérer** via `tools/gen_skills.py` (zéro code) |
| `.opencode/skills/ap-gestionimpacthumain-*` (7) | « Dans le projet : `01 Impact humain/GIH-…` » → à clarifier au regard de Q4 (position transverse du flux courant ?) |
| `methode/PM2/fr/referentiel-templates-PM2.md` | inchangé (il décrit le **bundle** = la définition du flux) ; au plus une note « dans le projet : `PM2/0N …/` » |
| `docs/guide.md` §1.2, §4.3, §6.1, §6.3 | l'arborescence + « les projets minces gardent leurs `01..05` à leur racine » → « sous `<flux>/` » + la définition flux/phase/position |
| `docs/prise-en-main.md` | ~5 mentions `01..05` à la racine |
| `README.md` / `README.fr.md` / `README.en.md` | inventaire des mentions au moment de l'implémentation |
| **Le kit lui-même** | pas de `01..05` à sa racine (WP-0040) → frontmatter `projet.md` : + `flux: PM2` ; ses WPs portent `phase:` = position PM² (cf. Q7) |
| **Projets existants** (2ndb-toolbox, commandschool, …) | **M1** — migration (déplacer `0N Phase/` → `PM2/0N Phase/` + frontmatter) ou **M2** — convention pour les neufs + lecture rétro-compat ; migration à la demande via `sync` `[À confirmer]` (Q3) |

**Recommandation migration : M2** — le moteur lit les deux layouts ; `sync` **propose**
le déplacement (annonce + confirmation, zéro écrasement) ; chaque projet migre quand il
le sent (même rythme que le versionnement du bundle). M1 (migration forcée en une fois)
est écarté : discipline zéro écrasement + les projets voyagent chez des tiers.

## 4. Questions ouvertes `[À confirmer]`

1. **Nom exact du répertoire du flux** : `PM2/` (= nom de la méthode, recommandé) ou
   `flux-pm2/` ? Et le numéro `0N` reste-t-il dans les dossiers de position du projet
   (`PM2/01 Lancement/` — recommandé : source unique des noms, zéro transformation) ou
   disparaît-il (`PM2/Lancement/` — plus lisible, mais le moteur doit transformer les noms) ?
2. **Préfixage des autres méthodes** : la règle `phase = <flux>/<position>` s'applique-t-elle
   à **toutes** les méthodes (PfM2, Scrum, PRINCE2, …) — i.e. « phase » devient
   systématiquement « position d'un flux » et les noms PM² (Lancement, RfP, …) restent
   les positions **du flux PM²** ? (Recommandation : oui — c'est le but de la convention.)
3. **Projets existants** : migration (M1) ou convention-neufs + rétro-compat (M2,
   recommandée) ? Lesquels (2ndb-toolbox, commandschool, le kit, …) et quand ?
4. **2 flux dans un projet** (ex. PM² + Scrum hybride) : « il y a toujours un flux » —
   un seul flux **actif** par projet (recommandé v1 : 1 `flux:` au singulier dans
   `projet.md`) ou plusieurs flux en parallèle (chacun son répertoire + sa position
   courante — v2) ? Et les documents **transverses** (GIH) : position du flux courant
   (`PM2/Planification/GIH-02…`) ou répertoire propre (`GestionImpactHumain/`) ?
5. *(secondaire)* **Cas dégénéré** (« s'il n'y en a pas, une phase ») : pas de répertoire
   (artefacts à la racine — recommandé, = l'ancien layout) ou un seul répertoire au nom
   de la position ?
6. *(secondaire)* **Stockage du préfixe** : un champ `phase: "PM2/Lancement"` (i) ou deux
   champs `flux:` + `phase:` (ii, recommandé) ?
7. *(secondaire)* La convention des **WPs** (`phase:` dans `_meta/backlog/README.md`)
   adopte-t-elle aussi le préfixe, ou reste-t-elle en position nue (flux implicite = PM²) ?

## Critères de réalisation

- [ ] Les questions Q1–Q4 (et 5–7) tranchées par l'utilisateur → décisions consignées
      (ce WP + `_meta/registry/decisions.md`)
- [ ] (implémentation, WP de suivi) les deux moteurs (PS + bash) créent le layout
      `<flux>/<position>/` et lisent l'ancien layout (rétro-compat)
- [ ] (implémentation) templates `projet.md` + `fiche-projet.md` + `AGENT-projet.md`
      mis à jour (`flux:`, `historique:`, routage)
- [ ] (implémentation) skills régénérées (`gen_skills.py`) + docs (guide §6,
      prise-en-main, READMEs)
- [ ] (implémentation) `sync` propose la migration (annonce + confirmation)
- [ ] (implémentation) projets neufs + 1 projet existant migré à la main = test
      (statut / menu / scan passent sur les deux layouts)

## Note

Ce WP est **conception (draft design)** — aucune implémentation. Il fixe la convention
conceptuelle demandée le 22/11 ; l'implémentation (moteurs + templates + docs + skills)
sera un WP de suivi qui reprend la section 3 comme checklist. À re-prioriser en `haute`
au moment où le **2ᵉ flux réel** (PfM2 / Scrum) entre dans `methode/` : c'est là que
l'enfermement signalé par l'utilisateur devient concret.
