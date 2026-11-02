# Session 2026-11-01 — installation multi-racines, /scan, README multilingue, préparation au push

- **WP-0004** → `fait` : wizard d'installation (`install.ps1` / `install.sh`). Bugs corrigés : « non » ne pose plus les questions de détail ; création de dossier sur confirmation seule (plus de dossier parasite).
- **WP-0005** → `fait` : question 1 du wizard = **racines de projets (1..N)** (détection, choix par numéro / `A` / `V`) ; commande **`/scan`** (classe kit / partiel / plain, annonce phase + gate, propose l'ajout du kit sans jamais déplacer) ; docs `install.md` §4 + `prise-en-main.md` §1-3.
- **WP-0006** → `fait` : README multilingue — `README.md` = **router de langue** (seul auto-affiché par la forge), `README.fr.md` + `README.en.md` = contenu complet. Sélecteur identique en haut de chaque version.
- **Décision** : `_projet/registry/connexions.md` = état **local machine** (généré par l'install) → **gitignored** (comme un `.env`) ; jamais de données entreprise dans le repo public.
- **Préparation au push** : historique réparti en **commits WP-alisés** (pas de « sale commit ») ; sanitisation des données personnelles (chemins locaux, nom de fork) dans les WP.
- **Ouvert** : WP-0002 (commande démo), WP-0003 (backup gzip).

## Session bis — test utilisateur de l'installation + bug wizard

- **Bug rapporté** (test utilisateur) : à l'étape « liste des dossiers détectés » du wizard, tout est **à la queue leu leu, sans retour à la ligne** → illisible.
- **WP-0007** créé → `fait` (code) : cause = `Write-Host $lines -NoNewline` joint un tableau par **espaces** (PS 5.1/pwsh) → corrigé en `Write-Host ($lines -join "`n") -NoNewline` ; syntaxe vérifiée (parse AST) ; `install.sh` non concernée ; pas d'autre occurrence dans le repo. **Reste : validation terrain par l'utilisateur.**
- **Mode C — résolu** : le registre local indiquait `github_issue: oui - repo: moosh_be`. Clarifié avec l'utilisateur : `Moosh-be` = son compte GitHub (owner, avec un tiret), le repo public y vit. Le champ attend le format `compte/nom-du-repo` (utilisé par `gh issue`) → corrigé en `repo: Moosh-be/assistant-projet-pm2` (01/11). Cause probable : saisie manuelle du compte seul, la valeur par défaut du wizard (extraite du remote `origin`) n'a pas été utilisée.
- **Observation** : le wizard propose par défaut le remote `origin` de la racine du kit pour le champ GitHub — cohérent ici, mais rien n'empêche l'utilisateur de saisir autre chose.

## Session ter — wizard 1/3 : le parent du kit doit être proposé comme racine (WP-0008)

- **WP-0007 validé terrain** : « c'est beaucoup plus lisible » → WP clos (`fait`).
- **Nouveau besoin (verbatim du test)** : « les repos qui me sont proposés là ce sont les repos des projets, mais moi je veux qu'il me propose le rep parent, à tout ceux-là ». Cause : le wizard proposait les **dossiers à côté du kit** ; kit cloné dans `code/github/` → les projets eux-mêmes apparaissaient comme candidats, pas `code/github`.
- **Fix (WP-0008, en-cours)** : candidats = **dossier du kit + 2 niveaux au-dessus** (annotés « dossier du kit » / « 1 niveau au-dessus… ») + dossiers à côté (max 5) ; index aligné sur la liste (max 8) ; ligne « Une racine = un dossier qui CONTIENT des projets (1 projet = 1 sous-dossier) ». `install.ps1` + `install.sh` alignés + `docs/install.md` §4. `A` reste le plan B pour 3+ niveaux.
- **Bug intermédiaire (code-review)** : le plafond de l'index de sélection restait **5** dans la nouvelle logique (choix 6–8 ignorés en silence) → corrigé (`-lt $shown`).
- **Tests** : syntaxe PS (parse AST) + `bash -n` OK ; logique de candidats testée sur la machine réelle → liste attendue (`1) code\github (dossier du kit)`, `2) code`, `3) SynologyDrive`, `4–8) fratrie du kit`).
- **Reste** : **validation terrain : relancer l'install et choisir le parent par numéro**.
- **Lisibilité prompt (feedback 01/11)** : la ligne « Choix : … » et le prompt « Racines: » **se collaient sur la même ligne** (héritage du `-NoNewline`), et « numéros séparés par espace » ne disait pas *les numéros de quoi*. Corrigé : prompt sur sa propre ligne (suppression du `-NoNewline` sur le bloc d'aide) + texte clarifié « numéros **des dossiers à retenir** » + exemple `(ex : 1, A, V)`. `install.ps1` + `install.sh` alignés, syntaxe des deux re-validée.

## Session quater — question de conception : reconnaître un dossier « projet » (WP-0009 tracé)

- **Question posée** : « à quoi on reconnaît un rep qui contient un projet ? plusieurs indicateurs ? l'install doit-ils les demander avant ? »
- **Réponse / position** : distinction **déclarer** (racines = connaissance de l'utilisateur → wizard propose, humain valide) vs **détecter** (un dossier EST un projet = heuristique → `/scan` observe). L'install **ne doit pas** demander d'indicateurs : ça coûterait à l'utilisateur une connaissance qu'il n'a pas ; la détection est read-only et appartient au scan.
- **Spec multi-signaux fournie par l'utilisateur** (5 familles : SCM/outils, build/langage, infra, structure, sémantique/stat ; scoring avec seuils ; projets imbriqués ; racines vs projets ; sortie confidence/type/signals) → **tracée en WP-0009** (`a-faire`).
- **Décision à trancher** : niveau 1 (signaux observés affichés dans `/scan`, sans scoring — ~10 lignes) vs niveau 2 (WP-0009 complet, outil séparé) vs rien pour l'instant.

## Session quinq — wizard 3/3 OpenProject : lien de clé + fichier d'env (WP-0010)

- **Proposition utilisateur** : après l'URL de l'instance, le wizard peut (1) afficher le **lien de fabrication de la clé API** (`<url>/openproject/api/access` — section « API access »), (2) demander **s'il y a un fichier d'env** qui contient déjà le token → il en liste les variables `*token*` (**valeurs jamais affichées**) et pré-remplit le nom de variable.
- **Implémentation (WP-0010, en-cours)** : `install.ps1` + `install.sh` alignés ; `token_file` persisté dans le bloc wizard du registre (traçabilité, token toujours hors repo) ; syntaxe des deux validée ; parse testé sur un fichier d'env factice (bash + PS : `OP_API_TOKEN`, `GITLAB_TOKEN`, `OTHER_TOKEN2` détectés, valeurs masquées) ; lien gère URL avec ou sans `/openproject`.
- **Reste** : validation terrain (relancer l'install, brancher OpenProject).
- **À trancher** : généraliser à GitHub/GitLab (pages de tokens analogues) ?

## Session sex — clarification du champ `repo:` GitHub (mode C clos)

- **Point mode C levé** : le registre local indiquait `github_issue: oui - repo: moosh_be`. L'utilisateur a précisé que **`Moosh-be` est son compte GitHub** (owner, avec un tiret) où vit le repo public `assistant-projet-pm2`.
- **Nuance portée** : le champ `repo:` attend le **chemin complet `compte/nom-du-repo`** (format `gh issue`), pas juste le compte. → corrigé en `repo: Moosh-be/assistant-projet-pm2` (01/11, registre local / gitignored).
- **Enseignement** : le wizard extrait `owner/name` du remote `origin` comme valeur par défaut — c'est exactement cette valeur qu'il aurait dû retenir, pas le compte seul saisi à la main.

## Session sept — bug oui/non : « o » (oui) non reconnu (WP-0011)

- **Bug (test utilisateur)** : les questions `[n]` du wizard n'acceptaient que `y`/`Y` (anglais *yes*). L'utilisateur a répondu **`O`** aux 4 connexions (OpenProject, SuperProductivity, GitHub, GitLab) → tout est passé **NON** dans le registre (`genere_le: 2026-11-01_17:56`).
- **Fix (WP-0011, fait)** : `Yn`/`yn` acceptent `o`/`O`/`y`/`Y` ; prompt changé `[n]` → `(o/n)` (défaut « non » si rien tapé conservé) ; les 7 appels passent par la même function. Logique testée (`o`/`O`/`y`/`Y` → OUI, `non`/vide → NON), syntaxe PS + bash OK.
- **Effet à annuler** : le registre a `openproject/superproductivity/github_issue/gitlab_issue: non` → la relance de l'install (idempotent) régénérera le bloc avec les bonnes réponses.
- **Note récurrente** : 3ᵉ bug du wizard trouvé au test utilisateur (WP-0004 détail-connexions, WP-0007 affichage, WP-0011 oui/non). Le test terrain paie — envisager une passe de relecture « internationalisation » sur les prochains scripts (les questions de `/scan` et des futures commandes).

## Session oct — /scan : la liste des projets (WP-0012)

- **Demande utilisateur** : « une fois qu'on a les projets, une commande pour lister les projets, montrer ceux qui n'ont pas encore l'assistance, ceux qui pourraient ».
- **Décision** : pas de nouvelle commande — **extension de `/scan`** (il lit déjà les racines, pas de duplication). La liste *est* le scan.
- **Implémentation (WP-0012, fait)** : `/scan` reformulé en **3 buckets** par racine — `✅ Assistés (kit)` (+ phase/gate) · `💡 Pourraient` (≥1 signal léger) · `⚪ Sans signal` — + `🛠 À compléter (partiel)` dédié. **Signaux légers** (niveau 1 de WP-0009, **sans scoring**) : `.git` · `package.json` · `pyproject.toml` · `requirements.txt` · `pom.xml` · `build.gradle` · `go.mod` · `Cargo.toml` · `Dockerfile` · `src/` · `README*` (max 4 affichés). Proposition d'ajout du kit **uniquement** sur les dossiers avec ≥1 signal — pas de push sur un dossier muet.
- **Reste** : validation terrain (lancer `/scan` sur les racines réelles).

## Session non — découpage install / activation (WP-0013 + WP-0014)

- **Fil rouge** : « je me perd » + « l'install ne devrait peut-être pas s'occuper des projets » + « je me pressais de découvrir les projets pour proposer les add-ons pertinents à l'install, mais ça pourrait se faire à l'activation d'un projet ».
- **Décision (verbatim)** : « **install = initialisation de la config transversale. L'install se finit en présentant le menu et en conseillant de commencer par un scan si on a des projets existants, ou par la création d'un premier projet.** »
- **Principe** : la **pertinence d'un add-on est une connaissance de projet, pas de machine** → l'install (transversal, 1×) ne devine rien ; l'activation du projet (projet-aware) observe les signaux de CE projet et propose les connexions ciblées.
- **WP-0013 (fait)** : fin d'install réécrite (`install.ps1` + `install.sh`) → récap config transversale + **menu agent** (`/scan`, `/statut`, « commence le projet <Nom> », « crée un projet <Nom> ») + **conseil conditionnel** (racines définies ? scan : créer). Agent : point 8 « crée un projet » (copie du kit, `projet.md` vierge, jamais d'écrasement). README fr/en alignés.
- **WP-0014 (a-faire)** : à l'activation, l'agent propose les add-ons **pertinents** d'après les signaux du projet (ex. `.git`+remote GitHub → GitHub Issue avec `owner/name` pré-rempli ; OpenProject → n° de projet → `op_id`), et remplit le frontmatter du projet (`op_id` / `sp_project`). La mécanique WP-0010 (lien de clé + fichier d'env) se réutilise ici.
- **Effet sur les WPs précédents** : rien n'est annulé — racines (WP-0008), connexions (WP-0010/0011), buckets (WP-0012) **changent de lieu** (install → activation) ou restent là où ils sont déjà (racines/connexions restent dans l'install car **transversales**).

## Session dix — erreur YAML sur GitHub : frontmatter de l'agent (WP-0015)

- **Signal** : sur GitHub, badge d'erreur sur `assistant-projet.md` → `Error in user YAML: mapping values are not allowed in this context at line 1 column 87`.
- **Cause** : la valeur `description:` du frontmatter contenait ` : ` (deux-points + espace, « dans ce projet : lit AGENT-projet.md ») **sans guillemets** → invalide en YAML.
- **Fix (WP-0015, fait)** : `description` quotée ; + même pattern corrigé dans `_projet/fiche.md` (`mis_a_jour`, introduit par mes propres edits v2-v8 — c'est moi qui l'avais cassé).
- **Audit complet** : script ad-hoc (parser YAML du repo, 58 fichiers MD) → 0 frontmatter en erreur après fix.
- **À trancher** : fixer ce checker en `tools/frontmatter_check.js` (CI / pré-push) pour qu'un frontmatter cassé ne parte plus en production.
