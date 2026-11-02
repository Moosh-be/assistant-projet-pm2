---
description: Scan des racines de projets — liste les projets en 3 buckets (assistés / pourraient / sans signal) + signaux légers, annonce la phase des projets connus, propose l'ajout du kit.
agent: assistant-projet
---

Lance le **scan des racines de projets** (WP-0005).

> **Source unique (WP-0016)** : la logique de scan est déterministe → elle vit **dans le script natif** `assistant.ps1` / `assistant.sh`. Cette commande l'**appelle** : l'IA ne re-développe PAS la logique de scan, elle présente le résultat et conduit.

## 1. Exécuter le script natif

Selon l'OS (le kit = le dossier courant) :

- Windows : `powershell -NoProfile -ExecutionPolicy Bypass -File .\assistant.ps1 scan`
- macOS / Linux : `./assistant.sh scan`

→ le script lit les racines de la config machine à la racine du kit (`.assistant.config`, WP-0017) et affiche :
- par racine : 4 buckets — **Assistés** (kit complet : `projet.md` + `AGENT-projet.md`, avec phase + gate), **À compléter** (kit partiel), **Pourraient** (signaux légers : `.git`, `package.json`, `src/`, …), **Sans signal** ;
- le résumé par racine + le total global.

Si le script signale « Aucune racine définie » → demander de relancer l'install (`install.ps1` / `install.sh`) pour définir les racines, et s'arrêter là.

## 2. Conduire (le rôle de l'agent)

Sur le résultat du script :

1. **Assistés** → rien à faire : annoncer la phase + le gate, proposer la reprise (`assistant commence <nom>` — ou « commence le projet <nom> »).
2. **À compléter** → annoncer ce qui manque (projet.md ou AGENT-projet.md), proposer de compléter via `add`.
3. **Pourraient** → proposer d'ajouter le kit, **au dossier**, sans déplacer ni réécrire : `assistant add <dossier>`. **Jamais** écraser un fichier pré-existant (le script le garantit et l'affiche) ; si `projet.md` ou `_projet/` existe → le script l'ignore et le signale, l'utilisateur tranche.
4. **Sans signal** → lister seulement, **ne pas pousser** l'ajout du kit. Le « pourrait » est indicatif : 1 signal ≠ projet certain.

## 3. Contraintes

- Ne **jamais** : déplacer, renommer, supprimer ni réécrire un fichier pré-existant.
- Ne **jamais** remplir un template au passage : le scan identifie et propose, l'assistant remplit ensuite en mode B.
- Proposer **un seul** projet à traiter à la fois (règle du kit) : commencer par les *à compléter*, puis les *pourraient* que l'utilisateur veut adopter.
- L'inversement de la question : **c'est la racine qui contient les projets, pas le projet qui vit dans le kit.**

$ARGUMENTS
