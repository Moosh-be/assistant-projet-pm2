---
wp_id: WP-0038
titre: "Règle forge : espace git → MCP de la forge (github/gitlab) + provisioning du MCP GitLab"
statut: a-faire
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 17/11/2026 — verbatim : 'Dès qu'il y a git il y a lieu d'y activer les mcp git, + celui de la forge utilisée (github/gitlab)'"
créé: 2026-11-17
mis_a_jour: 2026-11-17
---

# WP-0038 — Règle forge (MCP par forge) + MCP GitLab

## La règle (utilisateur, 17/11)

Un espace **avec git** → activer les MCP git **+ celui de la forge utilisée** (github /
gitlab). Complément de la règle HA (jamais HA dans un espace projet — déjà implémenté par
override d'ancêtre par arbre, 17/11).

## État actuel (17/11)

- **github MCP** : global, connecté (46 tools) — actif dans tous les espaces. ✅
- **gitlab MCP** : **installé le 17/11** — `@zereight/mcp-gitlab` 2.3.28 (npm global,
  entrée `build/index.js`), configuré dans l'ancêtre `code\gitlab\opencode.json`
  (`GITLAB_PERSONAL_ACCESS_TOKEN_FILE=C:/Users/ctg/.gl-token`,
  `GITLAB_API_URL=https://gitlab.rtbf.be/api/v4`), PAT scope `api`. **Testé E2E**
  (session réelle dans `assistant-projet-pm2-rtbf` : 20 projets listés sur
  gitlab.rtbf.be). Le MCP **officiel** de l'instance (`/api/v4/mcp`, GA depuis 19.5)
  **existe** (401 sans auth) mais est **bloqué** (403 avec token) — l'admin de
  l'instance doit l'activer ; une fois actif, basculer la config en 1 ligne
  (zéro maintenance locale).
- Espace concerné aujourd'hui : `code\gitlab\assistant-projet-pm2-rtbf` (git local,
  **pas de remote origin** — le fork RTBF privé n'est pas poussé/cloné d'un remote ici).

## Ouvert (à trancher avant implémentation)

- [x] **Token GitLab** : fourni le 17/11 → `C:/Users/ctg/.gl-token` (1 ligne, scope `api` ;
      préfixe sans `glpat-` = préfixe personnalisé par l'admin de l'instance — valide).
- [x] **Serveur** : `@zereight/mcp-gitlab` 2.3.28 (npm global) — le binaire Go officiel
      n'est plus publiquement accessible (projet déplacé ; le MCP officiel vit maintenant
      **dans l'instance** `/api/v4/mcp`, bloqué 403 sur rtbf), zereight couvre
      issues/MR/wiki/repos (288 tools, 38 par défaut + `discover_tools`).
- [x] **Placement** : ancêtre d'arbre `code\gitlab\opencode.json` (symétrie avec la règle HA).
- [x] **« MCP git » générique : NON** (OK utilisateur 17/11, « pas compris pourquoi contre
      mais ok ») — les forges (github/gitlab) + le git natif via shell suffisent ; un 3ᵉ MCP
      « git » dupliquerait l'un ou l'autre sans rien ajouter.
- [ ] **Remote du fork RTBF** : `assistant-projet-pm2-rtbf` (git local, sans remote) doit
      pointer sur **gitlab.rtbf.be en privé** (politique unidirectionnelle — voir
      `decisions.md` 17/11). Constat 17/11 : **aucun projet d'accueil n'existe** sur
      l'instance (20+ projets listés via MCP, aucun `assistant-projet*`/`pm2`). **GO donné
      le 17/11** (créer privé + remote + push). Constat : `POST /api/v4/projects` = **403**
      (corps vide ; `/api/v4/user` et `/version` aussi 403, mais `GET /api/v4/projects` =
      200) → blocage **côté instance** (proxy/admin), pas le token (lecture OK). → **création
      manuelle par l'utilisateur dans l'UI** (privé, sans README), puis remote + push par
      l'assistant (à vérifier : git-over-HTTP peut être bloqué aussi).

## Périmètre (prévu)

- [ ] Provisionning : binaire MCP GitLab + token + config dans l'ancêtre `code\gitlab\`.
- [ ] Kit : `add` / `new` / `scan` → détecter la forge (remote origin) → écrire/vérifier la
      config MCP correspondante (zéro écrasement ; l'ancêtre d'arbre = le point d'écriture
      si l'espace est sous un arbre configuré).
- [ ] Registre d'inventaire (WP-0037) : colonne « forge » + état MCP.
- [ ] `decisions.md` : 1 ligne (règle forge).

## Notes

- **Forge n°3 découverte le 17/11 (recherche profondeur 5)** : `codeberg.org`
  (`sp-obsidian\sp-obsidian`, plugin Obsidian SuperProductivity). La règle forge n'a de
  MCP que pour github (global) et gitlab (à prévoir) ; codeberg = à trancher
  (MCP Codeberg existe en communautaire — à ne créer que si demandé).
- 2 dépôts **imbriqués** trouvés sous `code\github` (sp-obsidian, Traducteurs Agiles) —
  couverts par l'ancêtre de l'arbre ; la colonne forge de l'inventaire (WP-0037) devra
  descendre aux dépôts imbriqués (option profondeur).
- Dépend partiellement de WP-0037 (la colonne forge de l'inventaire alimente la règle).
- La règle s'applique aux espaces EXISTANTS (rétro) et aux futurs (`new`/`add` l'appliquent
  à la création) — comme la règle HA.
