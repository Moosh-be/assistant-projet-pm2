# Comment commencer

> Ce document raconte le **premier contact** avec l'assistant — **comme si tu partais d'une machine
> neuve** : rien d'installé, aucun projet existant, tu découvres l'outil.
>
> Chaque étape est taguée : ✅ = dispo aujourd'hui · 🔜 = à venir (tracé en `WP-NNNN` dans
> `_meta/backlog/`). Rien d'inventé : le 🔜 est du tracé, pas de la promesse.
>
> Vocabulaire : un **chantier** = un projet (ou un contenant de projets) que l'assistant aide à conduire.

## La trame

1. Récupérer le repo et le mettre « quelque part » — **§1**
2. Démarrer l'assistant (standalone, ou en lançant opencode à la racine) — **§2**
3. Décider d'opencode (optionnel) — avantages et inconvénients — **§3**
4. Choisir l'endroit de **l'inventaire local** (les infos sur tous les chantiers à assister) — **§4**
5. Activer les **méthodes** — **§5**
6. Choisir les **outils d'interface** — **§6**
7. Lancer un **premier scan** → classer les trouvailles — **§7**
8. Changer de « root » → l'assistant du chantier prend le relais — **§8**
9. Note : l'espace disque — un cœur, pas N copies — **§9**

## 1. Récupérer le repo et le mettre « quelque part »

✅ `git clone <url>` dans un emplacement stable (ex. `dev/assistant-projet-pm2`).

Le repo = **le cœur de l'assistant** : le moteur (`assistant.ps1` / `assistant.sh`), les méthodes
(`methode/`), l'outillage (templates, checklists, protocole, harness). C'est **une copie par
ordinateur**, pas par projet (→ §9).

## 2. Démarrer l'assistant

✅ Deux façons, toutes deux fonctionnelles seules :

- **Standalone** (sans IA, sans internet) : à la racine du repo, `.\assistant.ps1` (Windows) ou
  `./assistant.sh` (macOS/Linux) → le menu natif (`scan`, `statut`, `new`, `add`, `sync`, `bootstrap`,
  `commence`, `remark`, …).
- **Via opencode** : `opencode` à la racine du repo → l'agent lit le protocole (`AGENT-projet.md`)
  et prend le relais (conduite mode B/C).

## 3. Décider d'opencode (optionnel)

🔜 **WP-0043** — au démarrage standalone, l'assistant proposera l'**installation optionnelle
d'opencode** :

1. il **affiche le contenu du fichier de doc « Avantages et inconvénients de l'utilisation d'opencode »**
   (nouveau fichier du repo, créé avec le WP) ;
2. il propose : **installer** / **ne pas installer** ;
3. si « ne pas installer » : il rappelle qu'il existe **une option dans le menu** pour changer
   d'avis plus tard.

> Aujourd'hui, le wizard `install.ps1` / `install.sh` configure opencode (pile par défaut) mais sans
> ce choix explicite ni cette doc — c'est ce que le WP-0043 ajoute.

## 4. L'inventaire local — l'endroit des infos sur tous les chantiers à assister

🔜 **WP-0044** (lien **WP-0037**) — une fois le point opencode réglé, on te propose de **choisir un
endroit où placer les infos sur tous les projets à assister** : c'est **l'inventaire local**.

- Ce **n'est pas un portefeuille** : c'est l'endroit qui centralise les informations (emplacement,
  signaux, classement) des chantiers à assister.
- **Format conseillé** : un **répertoire** avec **un fichier `.md` par chantier repéré** — chaque
  fichier porte la **fiche mémoire du chantier** : **une copie de la fiche qui est aussi à la
  racine du chantier** (son `projet.md`).
- Mais il sera possible de **proposer un portefeuille** (méthode PfM² — §5) **qui reprend les
  éléments de cet inventaire**.

## 5. Les méthodes à activer

🔜 **WP-0045** — l'assistant propose les **méthodes à activer**. De base, il connaît :

| Méthode | Usage |
|---|---|
| **PfM²** | gestion de **portefeuille** |
| **PM²** | gestion de **projet** (v3.0.1 — la seule implémentée aujourd'hui dans `methode/PM2/fr/`) |
| **PgM²** | gestion de **programmes** [À confirmer — verbatim 18/11 : « pour les projets »] |
| **Scrum** | gestion de **produit** |
| **ITIL** | gestion **ITSM (ESM)** |

Aujourd'hui, l'arbo `methode/<M>/<lang>/` porte PM2/fr ; les places des autres méthodes sont
réservées.

> **Et c'est l'arbo qui décide** : une méthode existe si elle est **présente dans l'espace
> `methode/`** (les méthodes maison comptent), **plusieurs versions** d'une même méthode sont
> possibles (ITIL v3, v4, v5…), certaines viennent **du repo git d'un projet**, d'autres du kit —
> **toutes au format Markdown**.

[À confirmer — le listage « à venir » historique (PMFLEX, SAFe, PRINCE2, PMP, Lean,
Lean6Sigma) est-il maintenu en places réservées, ou remplacé par cette liste ?]

## 6. Les outils d'interface

🔜 **WP-0046** — l'outil propose la **liste des outils avec lesquels il peut s'interfacer** :
**JIRA · OpenProject · SuperProductivity · Ivanti** · GitHub/GitLab Issues · …

✅ déjà implémentés : SuperProductivity (1 WP = 1 tâche, `sp_id`), OpenProject (artefacts = docs à
importer, WPs = packages de travail, `op_id`), GitHub/GitLab Issues (ticketisation du backlog).
→ détails : [guide §5](guide.md#5-connexions).

## 7. Le premier scan

🔜 **WP-0047** (le `scan` actuel ✅ le préfigure : 3 buckets — assistés mince/copie complète ·
pourraient · sans signal) — enfin, on propose de **lancer un premier scan** :

1. **Recherche** : des répertoires qui contiennent des **indicateurs de présence d'objets métiers
   d'un chantier projet** : `.git`, `.obsidian`, `.vscode`, …
2. **Proposition** : la liste des trouvailles — **mémorisée dans le dépôt d'inventaire**
   (l'endroit choisi au §4).
3. **Classement** : pour chaque dossier, on peut choisir entre : `projet` · `projet assisté` ·
   `portefeuille` · `dossier` (contenant plusieurs chantiers) · `produit` · `programme` · …
4. **Affichage** : dans cette liste, les **chantiers trouvés et leurs propriétés** (les fichiers de
   config à la racine) — et surtout **celui de l'assistant** : chaque chantier gouverné par
   l'assistant a **son propre manifeste** (aujourd'hui : le `projet.md` à la racine du chantier —
   c'est le signal « projet assisté »).

## 8. Changer de « root » → l'assistant du chantier prend le relais

✅ On entre dans un chantier (`commence <nom>` depuis la racine, ou ouvrir opencode dans le
dossier du chantier) : **l'assistant du chantier prend le relais**. Le chantier est gouverné par
**son propre assistant** — son `opencode.json` pointe sur le protocole du bundle (chemin absolu) +
son manifeste (`projet.md`). On passe du niveau « racine / inventaire » au niveau « chantier »
sans rien réinstaller.

## 9. Note — l'espace disque : un cœur, pas N copies

> Pour ne pas exploser l'espace disque : il y a toujours **« un endroit » avec le cœur de
> l'assistant** et tout ses plugins et méthodes — et **chaque chantier précise, via son manifeste,
> ce qu'il utilise**. **On ne duplique pas l'assistant sur chaque projet, mais dans chaque
> ordinateur.**
>
> En revanche, **dans chaque projet il y a le bootstrap** pour (ré)créer le cœur de l'assistant :
> si tu récupères un chantier **sur un autre ordinateur** et que tu tentes d'utiliser l'assistant,
> il aura besoin du cœur — le bootstrap le retablit : **pointer / chercher / installer**, sans IA,
> annonce + confirmation à chaque action, puis propose le harness opencode.

## Récapitulatif aujourd'hui / à venir

| Étape | État |
|---|---|
| Récupérer le repo, le mettre quelque part | ✅ |
| Démarrer standalone / opencode à la racine | ✅ |
| opencode optionnel (doc avantages/inconvénients + choix + menu de rattrapage) | 🔜 WP-0043 |
| Inventaire local (choix d'endroit, ≠ portefeuille, dépôt des trouvailles) | 🔜 WP-0044 (lien WP-0037) |
| Activation des méthodes (PfM² · PM² · PgM² · Scrum · ITIL) | 🔜 WP-0045 |
| Liste des outils d'interface (JIRA, OpenProject, SuperProductivity, Ivanti, …) | 🔜 WP-0046 |
| Premier scan v2 (indicateurs, dépôt d'inventaire, classement, chantiers + propriétés + manifeste) | 🔜 WP-0047 (`scan` actuel ✅) |
| Changer de root → l'assistant du chantier prend le relais | ✅ (`commence`) |
| Un cœur par ordinateur + bootstrap par chantier | ✅ (architecture des projets minces, WP-0025) |
