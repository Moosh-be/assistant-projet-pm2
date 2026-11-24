---
template: "DOC-TECHN.P"
nom: "Doc technique"
phase: "Transverse"
gate: "—"
projet: ""
statut: en cours
date_maj: "2026-11-22"
source: "WP-0055 (22/11) — espace Doc : doc du produit = livrable, séparation par audience ; structure type, contenu à remplir mode B"
audience: "développeurs / mainteneurs du produit"
---

# Doc technique

> **Template** : DOC-TECHN.P · **Phase** : Transverse · **Gate** : — · **Audience** : développeurs / mainteneurs
> La vue **technique** du produit : comment c'est construit — pas comment l'utiliser (→ DOC-EMPLO).

## 1. Contenu

### 1. Architecture d'ensemble
- Composants principaux et leurs interactions (schéma) : [À remplir]
- Flux de données (entrée → traitement → sortie) : [À remplir]
- Choix techniques majeurs (et pourquoi) : [À remplir]

### 2. Environnement & prérequis techniques
- Stack, versions, dépendances : [À remplir]
- Environnements (dev / test / prod) : [À remplir]

### 3. Mécanismes internes
- Processus clés (ce qui se passe « sous le capot ») : [À remplir]
- Modèle de données (si pertinent) : [À remplir]

### 4. Points d'extension
- API, hooks, points d'extension : [À remplir]
- Conventions de code / structure du code : [À remplir]

### 5. Dépannage technique
- Logs, points de debug, pannes connues : [À remplir]

## 2. Questions de l'assistant

- [ ] Quelle audience technique lit cette doc (devs, mainteneurs, architectes) ? → frontmatter `audience`
- [ ] Quels sont les composants principaux et comment interagissent-ils ? → §1
- [ ] Quels choix techniques majeurs, et pourquoi (le « pourquoi » autant que le « quoi ») ? → §1
- [ ] Quels mécanismes internes méritent d'être documentés ? → §3
- [ ] Où sont les points d'extension pour un dev qui veut aller plus loin ? → §4
- [ ] Quel dépannage technique (logs, pannes connues) la doc doit-elle couvrir ? → §5

## 3. Statut de remplissage
- [ ] Sections remplies : 0/5
- [ ] Aucune donnée non validée sans `[À confirmer]`
- [ ] L'architecture décrite est alignée sur le code réel (vérifiée, pas idéalisée)
