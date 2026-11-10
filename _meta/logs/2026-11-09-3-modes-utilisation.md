# Session 2026-11-08 → 09/11 — merge wp-0025, 3 modes d'utilisation (WP-0026), WP-0027 tracé

Log tardif : couvre la session du 07/11 (merge), celle du 08/11 (décision + tickets)
et celle du 09/11 (docs) — aucun log n'avait été écrit depuis `2026-11-05-projet-mince.md`.

## 07/11 — Merge wp-0025 → master
- Commit RfP `97078df` (PM2-01/02/03 pré-remplis en mode A + `fiche.md` + `decisions.md`
  « re » du 06/11 + `projet.md`).
- Merge de `wp-0025` (commit `e70b2f3`) : conflit unique `fiche.md` `mis_a_jour`,
  résolu en fusionnant les infos (WP-0025 fait + RfP). Merge commit `48eff30`,
  push `6e4d98b..48eff30 master -> master`.
- Worktree `wp25` + branche locale `wp-0025` supprimés (le remote `origin/wp-0025`
  existe encore).

## 08/11 — Décision : 3 modes d'utilisation (WP-0026) + WP-0027 tracé
- **Décision 08/11** (`decisions.md`) : les 3 modes d'utilisation en **dégradation
  résiliente** — fichier / exécution natif / IA (sync ou async). L'échelle IA → natif
  → fichier : on perd des capacités, **jamais les données** ; le bootstrap remonte
  l'échelle depuis une copie bare.
- **Ticket WP-0026** tracé : doc des 3 modes + sous-section agent/command/skill
  (la différence agent vs skill pas encore maîtrisée côté utilisateur).
- **Ticket WP-0027** tracé (brouillon v0) : mode **asynchrone** — espace de notes
  (listes de points, marqueur de séparation d'item) découpé en **discussions isolées**
  (1 item = 1 session opencode). Pattern Moosh-2ndb (`Question-a-Moosh`), amélioré.
  Ouverts : marqueur, noms (espace/commande), sortie des résultats, contexte injecté,
  invocation.
- **WP-0028 (candidate, non approuvée)** : câblage GitHub dans le protocole — le
  MCP est branché (46 outils) mais rien ne dit quand/quoi/comment : pas de routage
  `AGENT-projet.md`, pas de champ frontmatter, pas de commande, pas de ligne dans
  la table des connexions.

## 09/11 — Docs WP-0026 (le périmètre restant)
- `README.fr.md` : section « Les 3 modes d'utilisation (dégradation résiliente) »
  (table mode / a besoin de / ce que ça fait + échelle + bootstrap) + sous-section
  « Dans le mode IA — agent, command, skill » + note de distinction avec les
  « 3 modes d'alimentation » (A/B/C).
- `README.en.md` : idem (« The 3 usage modes » / « In the AI mode »).
- `docs/prise-en-main.md` §0 : version compacte (3 modes + lien détail).
- Ticket WP-0026 : périmètre complet (docs datées 09/11). Fiche **v21**.

## À faire côté utilisateur
- **RfP** : go formel + rôle challengers → check RfP (valider les `[À confirmer]`
  de PM2-01/02/03).
- **WP-0027** : raffiner le brouillon (les 5 points ouverts du ticket).
- **WP-0028** : go / non-go.
- **Re-`add` `2ndb-toolbox`** (zéro écrasement, restera « copie complète »).
- **Test terrain WP-0023** : relancer opencode → `/ap-statut-projet`.

## Suite de la session 09/11 — GO formel RfP + 2 copies (WP-0029)
- **GO formel RfP** : prononcé par le sponsor (ctg) le 09/11, après explication
  de ce qu'est un go (acte de décision **daté et consigné** par le sponsor —
  habilitation + redevabilité + date de référence ; pas un interrupteur, le
  projet tournait déjà). Consigné : PM2-01 §7, PM2-03 §7, `decisions.md`,
  checklist `gate-RfP.md` (item « Go/no-go décidé » coché). Fiche **v22**.
- **WP-0029 — 2 copies dev/usage** : question utilisateur → avis « pour »
  annoncé → go. Clone `C:/Users/ctg/SynologyDrive/code/github/assistant-projet-pm2-bundle`
  (du remote GitHub, origin = la forge). Constat d'implémentation : le moteur
  cherche `.assistant.config` à SA racine (`assistant.ps1` ligne 37) → configs
  machine (`.assistant.config` + `.assistant-projet.env`, gitignorés) copiées
  dans la copie d'usage, `openproject_token_file` répointé en local.
  Convention : dev = dirty OK · usage = master seul, refresh délibéré.
- **Règles globales opencode** (`~/.config/opencode/AGENTS.md`, chargement
  à chaud vérifié) : rappel de la question en début de réponse + annonce
  pour/contre sur les avis.

## Suite 2 — 09/11 : plaidoyer « cumul de rôles » + collision de numérotation
- **Plaidoyer utilisateur (mémo)** : en cas de cumul de rôles, la personne qui
  cumule est **obligée** de clarifier sa casquette (ou de confirmer la
  déduction) — contrainte **protectrice** (éviter d'être juge et partie),
  **séparer les personnes physiques au plus vite** même à charge faible, le
  cumul = problème de **charge mentale**, pas de charge de travail. Mémo dans :
  `decisions.md` (ligne 09/11), PM2-03 §3, **WP-0034** tracé (protocole :
  casquette obligatoire, haute).
- **Collision de numérotation** : une session parallèle a tracé la série
  « portefeuille » **WP-0028→0032** (dont un WP-0029, prioritaire haute) →
  mon ticket « 2 copies » renummé **WP-0029 → WP-0033** (le numéro revient au
  premier réservé de la série). Fiche v23 (fusion des infos des 2 sessions,
  zéro écrasement).
- **Signalé, résolu le 10/11** : `vlc-help.txt` à la racine du repo — erreur
  de contexte (confirmé utilisateur : c'était du 2ndb, pas de l'assistant),
  fichier **vide (0 octet)** → supprimé.
