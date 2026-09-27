# Prise en main — assistant-projet-pm2

> Le guide humain : de zéro à un projet PM² en cours, avec le kit Markdown + l'agent IA.
> **Pile par défaut** : **opencode** (l'agent — « le marteau ») + **Obsidian** (le coffre). Les deux sont interchangeables (tout agent qui lit des Markdown / tout gestionnaire de notes qui lit des Markdown).

## 0. Le principe en une phrase
**Un projet = un dossier cloné du kit + sa note de routage IA (`AGENT-projet.md`)** ; l'agent lit cette note, voit **la phase courante**, et **interroge** pour remplir les artefacts du template PM² **un par un**, dans l'ordre des gates.

## 1. Les 3 rôles
| Rôle | Qui | Fait quoi |
|---|---|---|
| **Le kit** | ce repo | fournit les templates + les checklists + le protocole (réutilisable pour TOUS les projets) |
| **Le coffre** | ton vault Obsidian (ou autre) | **contient** les projets (`<vault>/projects/<Projet>/`) |
| **Le marteau** | ton agent IA (opencode par défaut) | **lit** `AGENT-projet.md`, **interroge**, **remplit**, **gère les gates** |

## 2. Installation (une fois)
→ voir [`install.md`](install.md) : installer **opencode** + **Obsidian** + cloner le kit.

## 3. Créer un projet (la prise en main)
1. **Cloner le kit** dans le coffre :
   ```
   cp -r <chemin>/assistant-projet-pm2  <vault>/projects/Mon-Projet
   ```
   (ou « Nouveau projet » si ton coffre a un bouton ; le kit est un **template Obsidian** — voir §6)
2. **Renommer / pré-remplir** `projet.md` : nom, méthode (`PM2`), les 4 rôles (Sponsor, BM, CP, MOE — logins ou noms).
3. **Ouvrir la session agent** dans `<vault>/projects/Mon-Projet/` :
   ```
   opencode            # dans le dossier projet
   > commence le projet Mon-Projet
   ```
4. **L'agent** lit `AGENT-projet.md` → annonce : *« Phase Lancement, gate suivant RfP. Le PM2-01 Demande de lancement est vide. On le remplit ? »* → puis **les questions** du template, **une à une, au fil de l'eau**.
5. **À chaque gate** : l'agent passe la **checklist** (`checklists/gate-RfP.md` = transposition du PM2-27) → verte → passage de phase (frontmatter `phase:` + `gate_suivant:`).

## 4. Le quotidien (le mode C — l'écoute passive) ⭐
C'est la valeur ajoutée : en cours de session (réunion, mail, discussion), **l'agent repère** ce qui peut servir un artefact et **propose** :
> *« J'ai noté que la date de livraison est le 15/12 (mail de BLEC du 26/09) → ça remplit « Jalons prévisionnels » de la Charte (PM2-03). C'est bon ? »*

Règles : **valider sauf si c'est évident** · sinon `[À confirmer]` + `source:` · **poser la question = éduquer à se poser la question**.

## 5. Les connexions (optionnelles, par projet)
| Outil | Branchement | Quand |
|---|---|---|
| **SuperProductivity** | 1 WP = 1 tâche (tag `pm2`, `sp_id`) | si tu pilotes les tâches dans Sprod |
| **OpenProject** | artefacts → docs importés ; WBS → work packages | si le projet est visible en entreprise |
| **OpenProject MCP** | lecture/écriture directe par l'IA | après release 17.9 (add-on Enterprise) |

## 6. Astuce Obsidian — le kit comme TEMPLATE de coffre
Copie le kit dans le **dossier templates Obsidian** de ton coffre. Alors « nouveau projet » = bouton → dossier pré-structuré → tu n'as qu'à renommer + ouvrir l'agent. (Le kit est volontairement **plat et portable** : aucun plugin requis, juste du Markdown + frontmatter.)

## 7. Ce que l'agent ne fait JAMAIS
- sauter un gate (la checklist bloque)
- remplir un artefact de la phase N+1
- supprimer un artefact (statut `annulé` si abandon)
- insérer une donnée non validée sans `[À confirmer]` + source
- confondre MOE (fournisseur) et gestionnaire
