---
projet: assistant-projet-pm2
methode: PM2
phase: Lancement
gate_suivant: RfP
sponsor: ""
bm: ""
cp: ""
moe: ""
sp_project: ""
op_id: ""
créé: 2026-10-26
mis_a_jour: "2026-11-18 (v27e : **WP-0049 — hook `journal-watch` EN PRODUCTION** : watcher natif PS+bash (pidfile partagé = PID Windows réel via token+WMI, nohup `</dev/null`, tasklist/taskkill cross-session) · **preuve terrain** : journal touché 19:09:23 → Notepad++Portable ouvert 19:09:24 · **sync GitHub** : fetch du README en avance (54bee88, +483 lignes « plateforme Markdown souveraine ») → commit `8e02550` rebasé dessus → **poussé** · **fix bug préexistant** dispatch `?` (`"\?")` → `\?)` · moteurs validés **en CRLF** (état naturel, autocrlf) · 31 WPs ouverts, 59 [À confirmer] · v27d : **WP-0042→0047 tracés** — flux onboarding « Comment commencer » (machine neuve, hors 2ndb) : `docs/comment-commencer.md` créée (WP-0042 **en-cours** : validation + 2 [À confirmer] restants — PgM², liste méthodes) + pointeurs guide §2 / README.fr + décision 18/11 ; 8 WPs : 0042 doc · 0043 standalone + opencode optionnel · 0044 inventaire local (répertoire, 1 .md/chantier, fiche mémoire = copie de la fiche racine) · 0045 méthodes (présence = existe, versions, provenance git, Markdown) · 0046 outils d'interface · 0047 scan v2 · 0048 espace des normes (objets métiers — à creuser) · 0049 **journal des échanges** (réponses différées draft/prêt/traité/complété — en-cours : règle §3.4 + fichier + 5 entrées seed) · v27c : **WP-0041 tracé** — README trop gros : guide 6 chapitres `docs/guide.md` (exemples d'utilisation, installation et mise en place, perspectives d'évolution, personnalisation, connexions, méthodes) créé + pointeurs README/AGENT-projet ; le **dégrossissement du README** suit la validation de la doc par l'utilisateur · v27b : **WP-0039 en-cours** (pas fait — test terrain opencode + sync restants) : 18/11 parité PS/bash du `menu` vérifiée item par item + 2 bugs fixés (PS `-like '0[0-9] '` matche la chaîne entière → `'0[0-9] *'` ; awk bash frontmatter inerte sur fichiers CRLF → `{sub(/\r$/,"")}` sur les 22 awk) ; WP-0040 → fait) · 2026-11-17 (v27 : **WP-0039 fait** — commande `menu` natives PS+bash (dans un projet : état + actions à envisager au vu de l'état ; hors projet : portefeuille + projets à pousser) + slash `/assistant-menu` (pont mince, nom explicite utilisateur = exception au schéma `/ap-`) + champ `type` des tickets (livrable/amelioration/fix) · **WP-0040 fait** — arbo multi-méthodes `methode/<M>/<lang>/` : `01..05` + `checklists/` + `referentiel` → `methode/PM2/fr/` (git mv, histoire conservée) ; moteur PS+bash + gen_templates + refs (AGENT-projet, READMEs, prise-en-main, .opencode) alignés ; les projets minces intouchés · v26 : usage + 2 WPs tracés — **WP-0037** (scan → registre d'inventaire machine : `scan` stateless aujourd'hui, l'agent s'attend à un registre lisible des espaces) + **WP-0038** (règle forge : espace git → MCP de la forge github/gitlab ; MCP GitLab absent : binaire + token à prévoir) ; session d'usage : config MCP par arbre (HA jamais dans un espace projet — override d'ancêtre `code\github` + `code\gitlab` ; github MCP global) + **registre d'inventaire machine créé** `C:\Users\ctg\.assistant\inventaire.md` (26 espaces, forge par remote) + racine `code\gitlab` ajoutée à `.assistant.config` · v25 : WP-0036 tracé — commande « ajouter un projet au portefeuille » : existant via scan OU création (choix de racine) + initialisation (nom : `/as-pf-add-project` verbatim, `/ap-add-projet` recommandé — convention WP-0023 ; lien série portefeuille WP-0028/0029/0030) · v24 : feedback 1 — fil pédagogique des abréviations : décision 10/11 + WP-0035 tracé + registre `abreviations.md` initialisé (RfP/WP/IA assimilées `[À confirmer]` — comptage à valider) · entretien RfP lancé, thème ① rôles en cours · v23 : GO formel RfP consigné (sponsor ctg) + WP-0033 fait — 2 copies dev/usage (clone `assistant-projet-pm2-bundle` ; renummé de 0029, collision série portefeuille) + WP-0034 tracé — contrainte protectrice « cumul de rôles » (casquette obligatoire, séparer les personnes physiques au plus vite ; cumul = charge mentale, pas de charge de travail) · v22 : WP-0028→0032 tracés — série « portefeuille » : scope multi-niveaux (pf/pgm/prj/prd/srv/vs), attributs + flag « assisté », connecteurs de synchro, portabilité OpenProject, rapprochement 2ndB « assistant d'organisation » · v21 : WP-0026 fait à 100 % (docs 09/11) · WP-0027 tracé (brouillon v0) ; reste RfP : ① rôles (entrevue en cours) · ② demandeur du mandat (PM2-01 §5) · ③ dates comités (PM2-03 §4) · ④ réponse aux risques (PM2-03 §5) · ⑤ MOE · ⑥ valeur chiffrée)"
---

# assistant-projet-pm2 — le repo vu comme projet

> **Méthode** : PM² · **Phase courante** : Lancement · **Gate suivant** : RfP
> Fiche du **repo lui-même** (inception) : le kit tient ici sa propre documentation d'avancement. Les artefacts PM² de phases vivent dans le bundle sous `methode/PM2/fr/` (WP-0040) ; ici seul l'**état** du projet et les **WPs** (`backlog/`) sont tenus.

## 1. Résumé
- **Pourquoi** : fournir un kit Markdown + protocole agent pour constituer et mener un projet selon PM².
- **Le résultat attendu** : un kit clonable (1 projet = 1 folder) + un projet de démonstration mené de bout en bout avec le kit.
- **Le périmètre** : templates PM², checklists, agent, tools. **Hors périmètre** : le fork RTBF privé.
- **Les contraintes majeures** : repo public → pas de données entreprise ; templates génériques ; langue FR.

## 2. Les 4 rôles piliers
| Rôle | Qui (login) | Identifié + actif ? |
|---|---|---|
| Sponsor | | ☐ |
| Business Manager | | ☐ |
| Chef de projet / Gestionnaire | | ☐ |
| MOE / Fournisseur | | ☐ |

## 3. État de la phase (couche méta — les WPs sont dans `backlog/`)
| Phase | WPs dus (backlog/) | Fait | Check du gate |
|---|---|---|---|
| **Lancement** | WP-0001 → 0024 (24) | 14/24 | ☐ RfP |
| **Planification** | WP-0025 → 0049 (25) | 4/25 | ☐ RfE |
| **Exécution** | — | 0 | — |
| **Clôture** | — | 0 | ☐ RfC |

> Artefacts PM² de la phase Lancement (bundle : `methode/PM2/fr/01 Lancement/`) : **PM2-01/02/03 = 3/3 en cours** — pré-remplis en mode A le 05/11 depuis `fiche.md` + `decisions.md`, avec `[À confirmer]` + source sur les champs présumés. Le check RfP passe après validation des `[À confirmer]`.

### WPs ouverts (a-faire / en-cours)
| WP | Statut | Priorité |
|---|---|---|
| [WP-0002](backlog/WP-0002-commande-demo.md) — commande démo | a-faire | haute |
| [WP-0003](backlog/WP-0003-backup-restore-gzip.md) — backup/restore gzip | a-faire | moyenne |
| [WP-0008](backlog/WP-0008-candidats-racines-parent.md) — wizard : proposer le parent du kit comme racine | **fait** (validé terrain 02/11) | haute |
| [WP-0009](backlog/WP-0009-detecteur-projets-multi-signaux.md) — détecteur multi-signaux (spec) | a-faire | moyenne |
| [WP-0010](backlog/WP-0010-op-token-lien-env.md) — wizard OP : lien clé API + fichier d'env | **fait** (validé terrain 02/11) | moyenne |
| [WP-0011](backlog/WP-0011-wizard-oui-o.md) — fix wizard : accepter « o » (oui) | **fait** | haute |
| [WP-0012](backlog/WP-0012-scan-liste-projets.md) — /scan : 3 buckets (assistés / pourraient / sans signal) | **fait** (validé terrain 02/11) | haute |
| [WP-0013](backlog/WP-0013-install-menu-fin.md) — install : menu de fin + conseil | **fait** (validé terrain 02/11) | haute |
| [WP-0014](backlog/WP-0014-activation-projet-addons.md) — activation : add-ons pertinents par signaux | a-faire | moyenne |
| [WP-0016](backlog/WP-0016-assistant-entry-point.md) — entry-point natif assistant.ps1/.sh (scan/statut/new/add sans IA) | **fait** (validé terrain 02/11) | haute |
| [WP-0017](backlog/WP-0017-config-machine-env.md) — config machine `.assistant.config` (racine du kit) + secrets `.assistant-projet.env` | **fait** (validé terrain 02/11) | haute |
| [WP-0019](backlog/WP-0019-projet-sans-code.md) — projet sans code : un repo peut ne contenir que `_meta` (fiche = source de vérité, `new -doc`) | **en-cours** (code fait, tests sandbox verts) | haute |
| [WP-0020](backlog/WP-0020-update-kit-depuis-le-projet.md) — `update` : le projet resync son kit depuis le projet (zéro écrasement, `kit_source` automatique) | **en-cours** (code fait, tests sandbox verts) | haute |
| [WP-0021](backlog/WP-0021-remark-journal-remarques-au-vol.md) — `remark` : journal des remarques au vol (depuis le projet → `_meta/registry/remarques.md`, remontée au projet assistant) | **en-cours** (code fait, tests sandbox PS+bash verts) | haute |
| [WP-0022](backlog/WP-0022-pedagogie-phases-sautees.md) — pédagogie PM2 : 4 phases expliquées dans new/add + phases sautées signalées par `statut` | **en-cours** (code fait, tests sandbox PS+bash verts) | haute |
| [WP-0023](backlog/WP-0023-prefixe-ap-commandes-opencode.md) — préfixe `/ap-` sur les slash-commands (espace de nommage réservé assistant-projet ; natives inchangées) | **en-cours** (renoms + refs faits, test terrain à faire : relancer opencode) | haute |
| [WP-0024](backlog/WP-0024-liste-projets-menu-2-blocs.md) — `liste` + `statut` (introuvable/hors projet → liste) + menu en 2 blocs (Gérer les projets / Dans un projet) | **en-cours** (code fait, tests sandbox PS+bash verts) | haute |
| [WP-0025](backlog/WP-0025-projet-mince-bootstrap.md) — le projet mince : séparation data/outillage + bootstrap (annonce + confirmation, local → disque → clone, puis opencode) | **fait** (05/11 : code PS+bash + docs, tests T1-T7 verts ; mergé vers master le 07/11) | haute |
| [WP-0026](backlog/WP-0026-trois-modes-utilisation.md) — doc : les 3 modes d'utilisation (fichier / natif / IA) + dégradation résiliente + agent/command/skill | **fait** (08/11 : décision + docs README fr/en + prise-en-main) | moyenne |
| [WP-0027](backlog/WP-0027-mode-asynchrone-notes-discussions.md) — mode asynchrone : espace de notes (listes de points, marqueur de séparation) découpé en discussions isolées (split standalone + session opencode par item) | a-faire (brouillon v0 à raffiner) | moyenne |
| [WP-0028](backlog/WP-0028-scope-portefeuille-multi-niveaux.md) — scope multi-niveaux : niveau **portefeuille (pf)** + pgm/prj/prd/srv/vs (identifier, pas gérer) | a-faire | moyenne |
| [WP-0029](backlog/WP-0029-attributs-portefeuille-flag-assiste.md) — portefeuille : attributs (multiples, méthode, position, master) + **flag « assisté »** par projet | a-faire | **haute** |
| [WP-0030](backlog/WP-0030-connecteurs-synchro-portefeuille.md) — connecteurs de **synchronisation** avec le portefeuille (lieu master) | a-faire | basse |
| [WP-0031](backlog/WP-0031-portabilite-openproject-skills-agents.md) — **portabilité OpenProject** : skills/agents réutilisables sans l'assistant | a-faire | moyenne |
| [WP-0032](backlog/WP-0032-rapprochement-assistant-organisation-2ndb.md) — **rapprochement** avec le projet 2ndB « assistant d'organisation » | a-faire | basse |
| [WP-0033](backlog/WP-0033-deux-copies-dev-usage.md) — 2 copies du repo : dev (inception, dirty OK) / usage (bundle stable que les projets pointent, refresh délibéré) | **fait** (09/11 : clone `assistant-projet-pm2-bundle` + configs machine + décision ; renummé de WP-0029 — collision série portefeuille) | moyenne |
| [WP-0034](backlog/WP-0034-contrainte-protectrice-cumul-roles.md) — contrainte protectrice cumul de rôles : casquette obligatoire (clarifier ou confirmer la déduction) + séparer les personnes physiques au plus vite | a-faire (brouillon à raffiner) | haute |
| [WP-0035](backlog/WP-0035-fil-pedagogique-abreviations.md) — fil pédagogique des abréviations : nom complet (abréviation) à la 1re occurrence + registre d'assimilation (3 usages de l'interlocuteur ou demande explicite) | a-faire (brouillon) | moyenne |
| [WP-0036](backlog/WP-0036-add-projet-portefeuille.md) — commande « ajouter un projet au portefeuille » : existant via scan OU création (choix de racine) + initialisation — slash-commande orchestrateur (scan/liste/add/new natifs) | a-faire (nom de la commande à trancher) | haute |
| [WP-0037](backlog/WP-0037-scan-registre-inventaire-machine.md) — scan → registre d'inventaire **machine** (persistant, lisible par l'agent : chemins, git, forge, état assistant) — le scan actuel est stateless | a-faire (brouillon) | haute |
| [WP-0038](backlog/WP-0038-regle-forge-mcp-gitlab.md) — règle forge : espace git → MCP de la forge (github global ✅ / gitlab **absent** : binaire + token gitlab.rtbf.be) ; config auto par arbre | a-faire (brouillon, token à fournir) | haute |
| [WP-0039](backlog/WP-0039-assistant-menu-v1.md) — « assistant menu » v1 : les actions à envisager AU VU DE L'ÉTAT (natives PS+bash) + slash `/assistant-menu` (pont mince) | **en-cours** (17/11 : code PS+bash + commande opencode + refs ; 18/11 : parité PS/bash vérifiée — `[À confirmer]` 59/59, WPs 23/23, git 47/47, fixes : `-like` PS + awk CRLF ; **restant** : test terrain opencode + sync bundle) | haute |
| [WP-0040](backlog/WP-0040-arbo-methode-multi-methodes.md) — arbo multi-méthodes `methode/<M>/<lang>/` : 01..05 + checklists + referentiel PM2 FR → `methode/PM2/fr/` | **fait** (17/11 : git mv + moteur PS+bash + gen_templates + refs) | haute |
| [WP-0041](backlog/WP-0041-guide-doc-6-chapitres.md) — guide 6 chapitres (`docs/guide.md` : exemples, installation, perspectives, personnalisation, connexions, méthodes) → dégrossir le README | **en-cours** (18/11 : guide + pointeurs faits ; dégrossissement README après validation de la doc) | moyenne |
| [WP-0042](backlog/WP-0042-doc-comment-commencer.md) — doc « Comment commencer » (onboarding machine neuve, hors 2ndb) — doc + pointeurs faits ; validation + 2 [À confirmer] restants (PgM², liste méthodes) | **en-cours** (18/11) | moyenne |
| [WP-0043](backlog/WP-0043-lancement-standalone-opencode-optionnel.md) — lancement standalone : opencode **optionnel** (doc avantages/inconvénients affichée, installer / ne pas installer, option menu de rattrapage) | a-faire | haute |
| [WP-0044](backlog/WP-0044-inventaire-local.md) — **inventaire local** : **répertoire, 1 `.md` par chantier repéré** (fiche mémoire = **copie de la fiche à la racine du chantier**) ; ≠ portefeuille ; lien WP-0037 | a-faire | haute |
| [WP-0045](backlog/WP-0045-activation-methodes.md) — activation des méthodes : **découverte par présence dans l'arbo** (méthodes maison, versions ex. ITIL v3/v4/v5, provenance repo git de projet, format Markdown) | a-faire | moyenne |
| [WP-0046](backlog/WP-0046-outils-interface.md) — liste des outils d'interface (JIRA, OpenProject, SuperProductivity, Ivanti, …) | a-faire | moyenne |
| [WP-0047](backlog/WP-0047-scan-v2-classification.md) — **scan v2** : indicateurs (.git/.obsidian/.vscode), trouvailles → inventaire, classement (projet/assisté/portefeuille/dossier/produit/programme), chantiers + propriétés + **manifeste** | a-faire | haute |
| [WP-0048](backlog/WP-0048-normes-objets-metiers.md) — **espace des normes** : une norme = **les informations attendues dans chaque Markdown** (objet métier) + **outil de validation** (4 domaines d'exemples) ; format : 2 métadonnées (début/inline), Markdown brut + notation structurée, **résilience** (un doc ne doit jamais être cassé — parser répare, confirmation au pire) — à l'instar des méthodes (WP-0045) | a-faire (**à creuser** par l'utilisateur) | moyenne |
| [WP-0049](backlog/WP-0049-journal-echanges-reponses-differees.md) — **journal des échanges** : les questions de la discussion → `_meta/registry/journal-echanges.md` (contexte + question + zone réponse + tag **draft/prêt/traité/complété**) + flag `journal_notepad` | **en-cours** (18/11 : règle §3.4 AGENT-projet + fichier + 5 entrées seed = les questions WP-0048 + **hook `journal-watch` en production** (preuve terrain 19:09) + **config** `journal_notepad = oui` + Notepad++ (dev + bundle) ; restant : moteur (menu : entrées à traiter + compteurs par tag) + 1ʳᵉ réponse terrain) | haute |

## 4. Les plans de gestion envisagés (anti-surcharge)
| Document | Statut : envisagé / utilisé / ignoré | Pourquoi |
|---|---|---|
| Risques | envisagé | petit projet solo, tenue légère |
| Décisions | envisagé | `registry/decisions.md` à la 1re décision structurante |
| Communication | ignoré | pas d'équipe pour l'instant |

## 5. Connexions
| Outil | Id | État |
|---|---|---|
| SuperProductivity | `sp_project:` | ☐ (export `backlog/` à prévoir) |
| OpenProject | `op_id:` | ☐ (export `backlog/` à prévoir) |

## Liens
- [[README|Le kit]] · `backlog/` (WPs) · `logs/` · `report/` · `registry/`
