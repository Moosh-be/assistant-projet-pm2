---
wp_id: WP-0037
titre: "scan → registre d'inventaire machine : la liste des espaces projets persiste et est lisible par l'agent"
statut: a-faire
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 17/11/2026 — verbatim : 'il est censé gérer un inventaire de tous les espaces projets de mon écosysteme, avec ou sans git... ce scan rempli un registre que tu peux utiliser pour trouver ces espaces'"
créé: 2026-11-17
mis_a_jour: 2026-11-17
---

# WP-0037 — scan → registre d'inventaire (machine)

## Contexte

Le `scan` actuel (Cmd-Scan, assistant.ps1/.sh) est **stateless** : il affiche les 4 buckets
des racines configurées, et ne persiste rien. L'utilisateur s'attend à un **inventaire
persistant de tous les espaces projets de l'écosystème** (avec ou sans git, pas que dans les
racines indiquées, pas que sur github) — **un registre que l'agent lit** pour trouver les
espaces et agir dessus (ex. : config MCP par espace).

## Ce qui existe déjà (17/11 — session manuelle)

- Un inventaire manuel a été créé à **`C:\Users\ctg\.assistant\inventaire.md`** (niveau
  machine, hors de tout repo) — modèle du fichier que `scan` devra maintenir.
- 2 arbres couverts : `code\github` (25 dossiers) + `code\gitlab` (1 dossier, fork RTBF).
- Racines de `.assistant.config` : `code\github` + `code\gitlab` (ajout 17/11).

## Spécification

1. **Sortie** : `scan` réécrit/rafraîchit le registre d'inventaire (chemin machine, défaut
   `~/.assistant/inventaire.md`, configurable dans `.assistant.config` : `inventaire = <chemin>`).
   Contenu : les arbres + les espaces (chemin, git oui/non, forge = remote origin, état
   assistant), idempotent, horodaté.
2. **Détection** : marqueurs (`projet.md`, `AGENT-projet.md`, `<meta>/fiche.md`) + `.git`,
   sur toutes les racines ; profondeur = 1 niveau (comme aujourd'hui) + option
   `--profondeur N` à trancher (cf. ouvert).
3. **Forge** : pour chaque repo git, `git remote get-url origin` → forge
   (github / gitlab / local / upstream public) — colonne « forge » du registre.
4. **Déterministe, sans IA** : PS + bash, zéro écrasement (seul le registre est réécrit).
5. **Agent** : `/ap-scan-projets` appelle le natif puis présente le registre ; l'agent
   utilise le fichier comme source de vérité des espaces (plus besoin de re-scan manuel).

## Ouvert (à trancher avant implémentation)

- [ ] Format exact du registre (le fichier du 17/11 = point de départ).
- [ ] Profondeur : toujours 1 niveau sous les racines, ou flag `--profondeur` ? (Le 17/11,
      la recherche SynologyDrive à profondeur 3-4 a été nécessaire parce que la racine
      `code\gitlab` n'était PAS configurée — avec la racine ajoutée, profondeur 1 suffit.)
- [ ] Emplacement du registre : `~/.assistant/` (dossier machine dédié, survit aux copies
      dev/bundle — choisi le 17/11) vs à côté de `.assistant.config` (racine du kit, mais
      1 par copie).
- [ ] Le registre reflète-t-il aussi les espaces **hors racines** (le scan ne voit que les
      racines) ? Option : un marqueur dans le registre « espaces connus hors racines » +
      suggestion d'ajouter la racine manquante.

## Périmètre (prévu)

- [ ] `Cmd-Scan` (PS + bash) : écriture du registre après l'affichage.
- [ ] `.assistant.config` : ligne `inventaire = <chemin>` (wizard : question ou défaut).
- [ ] Docs : `docs/prise-en-main.md` (1 ligne) + `decisions.md` (1 ligne).
- [ ] Validation terrain : `scan` depuis le kit → registre réécrit, contenu cohérent, 2ᵉ
      `scan` idempotent (pas de doublons).

## Notes

- Lié : WP-0012 (buckets du scan), WP-0024 (menu + liste), WP-0029 (attributs portefeuille
  + flag « assisté » — l'inventaire est la matière première du niveau pf).
- Ce WP ne crée PAS de projet : il persiste la DÉCOUVERTE (le scan détecte, l'inventaire
  mémorise, l'agent lit).
