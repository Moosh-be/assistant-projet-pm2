---
wp_id: WP-0034
titre: "Contrainte protectrice cumul de rôles : l'assistant oblige la clarification de casquette"
statut: a-faire
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 09/11 — plaidoyer utilisateur (verbatim) : « si je cumule ces différents rôles, je suis "obligé" de clarifier à chaque fois avec quelle casquette je parle. (ou de confirmer ce qui a été déduit.) ce "je" rends la chose ambigue. c'est pas "je me sens obligé" mais "je veux que le gestionnaire qui cumule soit obligé de le faire. Et c'est une contrainte "protectrice". Je suis convaincu qu'il faut arriver au plus vite à séparer les personnes physique qui assume ces responsabilités, même si la charge est faible. Eviter d'être juge et partie. le cumul de rôle est un probleme de charge mentale, pas de charge de travail. »"
créé: 2026-11-09
mis_a_jour: 2026-11-09 (tracé — brouillon à raffiner avec l'utilisateur)
---

# WP-0034 — Contrainte protectrice : casquette obligatoire en cas de cumul de rôles

## Contexte
Plaidoyer utilisateur (09/11 — son cas perso, qu'il veut que l'assistant
**accompagne**) : quand une même personne cumule les rôles (sponsor / BM / CP),
le « je » est **ambigu**. La règle n'est pas un confort personnel
(« je me sens obligé ») : c'est une **contrainte protectrice** du projet —
**le gestionnaire qui cumule est obligé de clarifier sa casquette** (ou de
confirmer la casquette déduite par l'assistant), pour éviter d'être
**juge et partie**. Direction associée : **séparer au plus vite les personnes
physiques** qui assument ces responsabilités, même si la charge est faible.
Rappel du plaidoyer : le cumul de rôles est un problème de **charge mentale**,
pas de charge de travail.

La décision est consignée (`decisions.md` 09/11) ; ce WP = l'implémentation
dans le **protocole** (valable pour tous les projets du bundle, pas seulement
le méta).

## Brouillon de périmètre (à raffiner)
- [ ] Règle dans `AGENT-projet.md` (protocole §3) : si le locuteur cumule les
      rôles et qu'un énoncé alimente un artefact → l'assistant (a) demande la
      **casquette**, ou (b) **attribue la casquette déduite** et la marque
      `[À confirmer: casquette]` + source — jamais d'attribution silencieuse.
- [ ] Traçabilité : la casquette (déclarée ou déduite) est notée dans la
      `source` de l'artefact concerné.
- [ ] `fiche.md` / `projet.md` : les 4 rôles piliers remplis avec les **noms**
      des personnes (pas seulement « assume pour l'instant ») → la séparation
      physique devient visible dans la doc.
- [ ] Cas du solo assumé : comment la contrainte s'applique quand toutes les
      casquettes sont la même personne (clarification aux décisions
      structurantes, pas à chaque phrase — à trancher).

## Ouvert (à trancher avec l'utilisateur)
- **Fréquence** : clarification demandée à **chaque énoncé qui alimente un
  artefact**, ou aux **décisions structurantes** (go, gates, rôles) ?
- **Format de marquage** : `[À confirmer: casquette]` ?
- Le `_meta/registry/roles.md` (mentionné PM2-03 §3) : créer maintenant avec
  la contrainte, ou attendre les rôles confirmés ?
