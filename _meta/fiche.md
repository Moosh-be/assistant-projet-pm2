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
mis_a_jour: "2026-11-06 (PM2-01/02/03 affinés après validations du 06/11 — reste : go formel + rôle challengers → check RfP)"
---

# assistant-projet-pm2 — le repo vu comme projet

> **Méthode** : PM² · **Phase courante** : Lancement · **Gate suivant** : RfP
> Fiche du **repo lui-même** (inception) : le kit tient ici sa propre documentation d'avancement. Les artefacts PM² de phases restent des templates à la racine ; ici seul l'**état** du projet et les **WPs** (`backlog/`) sont tenus.

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
| **Planification** | WP-0025 (tracé) | 0/1 | ☐ RfE |
| **Exécution** | — | 0 | — |
| **Clôture** | — | 0 | ☐ RfC |

> Artefacts PM² de la phase Lancement (racine) : **PM2-01/02/03 = 3/3 en cours** — pré-remplis en mode A le 05/11 depuis `fiche.md` + `decisions.md`, avec `[À confirmer]` + source sur les champs présumés. Le check RfP passe après validation des `[À confirmer]`.

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
| [WP-0025](backlog/WP-0025-projet-mince-bootstrap.md) — le projet mince : séparation data/outillage + bootstrap (annonce + confirmation, local → disque → clone, puis opencode) | **a-faire** (design à dérouler — supersède WP-0016/0020) | haute |

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
