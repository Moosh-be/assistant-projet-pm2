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
mis_a_jour: 2026-11-01
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
| **Lancement** | WP-0001 · 0002 · 0003 · 0004 · 0005 · 0006 | 4/6 | ☐ RfP |
| **Planification** | — | 0 | ☐ RfE |
| **Exécution** | — | 0 | — |
| **Clôture** | — | 0 | ☐ RfC |

### WPs ouverts
| WP | Statut | Priorité | Phase |
|---|---|---|---|
| [WP-0002](backlog/WP-0002-commande-demo.md) — commande démo | a-faire | haute | Lancement |
| [WP-0003](backlog/WP-0003-backup-restore-gzip.md) — backup/restore gzip | a-faire | moyenne | Lancement |
| [WP-0004](backlog/WP-0004-installation-espace.md) — wizard d'installation | fait | haute | Lancement |
| [WP-0005](backlog/WP-0005-racines-projets-scan.md) — racines multi + scan | fait | haute | Lancement |
| [WP-0006](backlog/WP-0006-readme-multilingue.md) — README multilingue fr/en | fait | moyenne | Lancement |

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
