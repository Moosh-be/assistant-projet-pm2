# Session 2026-11-12 — fil opencode (thème / onglets / contexte) + routage des transcripts

## Fil opencode TUI (12/11)
- **Thème par onglet** : non — `theme` est global dans
  `~/.config/opencode/cli.json` ; le groupe `tabs` ne gère que
  `mode` / `scope` / `layout` / `indicators`. Contournements : 2e
  instance avec `OPENCODE_CLI_CONFIG_CONTENT='{"theme":{"name":"..."}}'`,
  ou `theme.mode: system` + apparence claire/sombre par fenêtre.
- **Transférer un onglet d'une instance à une autre** : **non**
  documenté — mais superflu : l'onglet = vue TUI d'une session possédée
  par le **service de fond partagé** ; toute instance peut ouvrir
  n'importe quelle session (`session.list` = `Ctrl+X`+`L`, `Ctrl+O`
  récentes, sidebar `Ctrl+X`+`B`) ; fermer l'onglet côté source
  (`session.tab.close` = `Ctrl+X`+`W`) = vrai transfert. Vigilance :
  `session.move` existe mais déplace vers un **worktree** (dossier),
  pas vers une instance. Deux instances sur la même session en même
  temps : pas documenté → `[À vérifier]`. Sources : doc opencode v2
  (cli, cli/config, cli/keybinds).
- **TUI** (Terminal User Interface) ajoutée au registre
  `abreviations.md` (non assimilée) — commit `3ff530b`.

## Feedback 2 (candidat — à valider après le test utilisateur)
- **Besoin** (12/11) : « il faudrait que ma session remarque dans quel
  **contexte** elle est, et si j'évoque un autre contexte, il faut me le
  dire pour basculer dans une autre **instance** » (l'utilisateur a
  observé que relancer opencode dans un autre terminal réaffiche les
  mêmes onglets via le service partagé — le choix du contexte se fait
  au démarrage).
- **Preuve n°1 du besoin (12/11)** : l'ingest des transcripts de la
  conférence Audeon/PrismeOne (« Décuplez votre levier avec IA »
  Jour 1 + Jour 2, `C:\Users\ctg\Downloads`) a été demandé **dans ce
  contexte** (assistant-projet-pm2) — l'utilisateur l'a **routé vers
  la bonne instance** le jour même. L'assistant aurait dû signaler le
  doute de contexte à la demande initiale (ça n'a pas été fait).
  Prompt d'ingest autonome fourni ici-bas pour la cible.
- Décision + règle globale : **après le test de l'utilisateur**.

## Ingest des transcripts — routé hors de ce contexte (12/11)
- Demande retirée de la file en attente de ce projet (« oublie ici »).
- Prompt fourni (ci-dessous) pour la bonne instance.
- Rappel : transcripts = contenu **tiers** — ne pas committer sur une
  forge publique sans validation explicite (contrainte du repo
  assistant-projet-pm2, public).

### Prompt fourni (pour coller dans la bonne instance)

> Ingeste des transcripts de la conférence Audeon/PrismeOne « Décuplez
> votre levier avec IA » (2 jours).
>
> Fichiers : `C:\Users\ctg\Downloads` — « Décuplez votre levier avec IA
> Jour 1 transcript.txt » et le « Jour 2 » (noms approximatifs — liste
> le dossier et repère les deux fichiers `.txt` qui matchent
> *transcript* / *levier* avant de commencer).
>
> À faire :
> 1. Inspecter : taille, encodage, ordre de grandeur (lignes). Signale
>    tes trouvailles.
> 2. Lire les deux transcripts complets (avec le bon encodage — ne
>    réécris pas les fichiers bruts).
> 3. Produire un digest structuré (nouveau fichier, **zéro
>    écrasement**) : résumé 2-3 paragraphes par jour · idées clés et
>    pratiques concrètes · outils/méthodes cités · citations marquantes
>    · lien vers les fichiers bruts (chemin, pas de copie si lourds).
> 4. Avant tout commit : contenu **tiers** (conférence) — ne rien
>    committer sur une forge publique sans ma validation explicite ;
>    stockage local d'abord, je tranche.
>
> Avant de commencer : demande-moi l'**objectif** — simple archive ?
> extraction d'idées pour un projet précis ?
