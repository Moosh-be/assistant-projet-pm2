# Session 2026-11-05 — WP-0025 : le projet mince (implémentation complète)

Implémentation du WP-0025 (design validé 04/11) dans le **worktree `wp-0025`** (branche
`wp-0025` depuis `6e4d98b`) — **master laissé stable** : l'utilisateur y fait le RfP du
méta-projet (PM2-01/02/03 pré-remplis en mode A, non commités).

## Ce qui a été construit

- **Moteur PS réécrit** (`assistant.ps1`, 766 lignes, ASCII pur, 0 erreur parse) :
  `Read-ConfLine`, `Deploy-Kit` (thin), `Deploy-Harness`, `Cmd-Sync`, `Cmd-Bootstrap`,
  `Cmd-Scan` (mince/legacy), menu + dispatch (`sync`, `update` alias, `bootstrap`).
- **Moteur bash réécrit + testé** (`assistant.sh`, CRLF, `bash -n` OK) : même surface,
  incluant le hotfix NUL (453 NUL en fin de fichier de la version master).
- **Bootstraps** (`tools/templates/bootstrap-assistant.ps1` 342 lignes ASCII pur /
  `.sh` `bash -n` OK) : sous-commandes `pointer` / `chercher` / `installer` / `opencode`,
  menu interactif avec état détecté (lecture seule), `Propose-Opencode` après chaque
  réussite, **annonce + confirmation avant chaque action**.
- **Lanceurs minces** (`tools/templates/lanceur-assistant.ps1` / `.sh`, ~53 lignes) :
  localisent le bundle via la config, délèguent toutes les commandes au moteur du bundle,
  sinon lancent le bootstrap.
- **Templates projet mince** : `gitignore-projet.md` (lignes machine, append, zéro
  écrasement), `.assistant.version` (1.0.0), `versions/README.md` (politique de
  versionnage : `assistant_ref: <version>` → `versions/<version>/`, rétro-compat).
- **Docs** : README (.fr/.en/md) « bundle » + note projet mince + versionnage ·
  `docs/install.md` (tableau des commandes, scénario tiers, tests de fumée) ·
  `docs/prise-en-main.md` (principe mince, création via `assistant new`, harness,
  Obsidian) · `AGENT-projet.md` (note « Projet mince » + table de routage « dans le
  bundle » + ligne connexion) · `.opencode/agent/assistant-projet.md` (règle 8 =
  `assistant new` mince + bootstrap) · `referentiel-templates-PM2.md` (terminologie).

## Décisions de la session

- **Convention de chemin inter-moteurs** : tout chemin écrit dans
  `connexions.local.md` / `opencode.json` / la config machine = **`C:/...` (barres
  obliques)** sur Windows — lisible par le lanceur PS, le lanceur bash (MSYS) et opencode.
  (Le moteur bash écrivait des chemins MSYS `/tmp/...` illisibles par PS/opencode — bug
  corrigé : `conf_path()` bash + `-replace '\\','/'` PS.)
- **EOL des `.sh` du working tree = CRLF** (convention `autocrlf=true`, comme
  `install.sh`) ; Git Bash tolère le CRLF (vérifié empiriquement : `bash -n` + exécution
  d'un script CRLF avec if/then/fi).
- **Recherche disque du bootstrap** : l'utilisateur indique les dossiers à chercher
  (marqueur `.assistant.version`), pas de scan de tout le disque.

## Tests sandbox (PS + bash, T1 → T7, tous verts)

T1 `new` → layout mince 13 éléments (vérifié sur disque : SANS `AGENT-projet.md`,
`checklists/`, `tools/`, `.opencode/`) · T2 délégation lanceur → moteur (PS + bash) ·
T3 bootstrap pointer pipé (**`Read-Host` lit le stdin redirigé** — souci levé) ·
T4 **scénario tiers complet** (copie sans config machine → lanceur → bootstrap menu pipé
→ pointer écrit `C:/...` → délégation au bundle) · T5 scan « (mince) » les 2 moteurs ·
T6 sync idempotent + harness déployé au 1er `o` · T7 `assistant_ref: 1.0.0` →
`versions/1.0.0/` résolu · cross-moteurs (PS écrit / bash lit `C:/...` et inversement) ·
`statut` bash ✓.

## Méta

- Ticket WP-0025 → **fait** (périmètre complet cochés, section Livraison ajoutée).
- `decisions.md` : 2 lignes (chemin inter-moteurs + implémentation sync/bootstrap).
- Fiche **v19** : WP-0025 fait (Planification 1/1).

## À faire côté utilisateur

1. **Le merge worktree → master** : bloqué par le travail RfP non commité de master
   (PM2-01/02/03, `projet.md`, `_meta/fiche.md`). Après commit du RfP : merge +
   résolution d'un conflit textuel (ligne `mis_a_jour` de `fiche.md`) + push.
2. `2ndb-toolbox` : kit d'avant « projet autonome » + pas de `kit_source` → **re-`add`**
   (zéro écrasement) avec le nouveau moteur.
3. Test terrain WP-0023 : relancer opencode dans un projet → `/ap-statut-projet` doit
   apparaître.
