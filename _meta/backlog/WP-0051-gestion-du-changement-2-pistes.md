---
wp_id: WP-0051
titre: "Gestion du changement (le côté « humain » de l'activité) — 2 pistes : marque blanche CC BY-SA (développée) + slot licence Prosci (non développée)"
type: livrable
statut: fait
priorite: haute
phase: Planification
roles: [cp]
sp_id: ""
op_id: ""
source: "session du 20/11/2026 — verbatim : 'hier j'ai eu une formation prosci (c) pour la gestion du changement, j'aimerai ajouter des skills de la gestion \"humaine\" de l'activité, mais prosci est (c) il faut donc prévoir un truc pour ne pas être dans l'illégalité. d'une part en proposant des skills en marque blanche/Creative commons et d'autre part \"avec licence\" (mais ca moi je développe pas)' — formation Prosci (C) du 19/11"
créé: 2026-11-20
mis_a_jour: 2026-11-20
---

# WP-0051 — Gestion du changement : le côté « humain » de l'activité (2 pistes)

## Contexte

L'utilisateur a suivi une **formation Prosci (C)** (19/11) et veut que le kit couvre le
**côté humain** de l'activité (gestion du changement, adoption). Le contenu Prosci est
**© + marques déposées** (ADKAR®, Prosci Model of Change, CBST®) — un repo public =
redistribution → **pas de contenu / nom Prosci dans le kit**. Deux pistes pour couvrir le
besoin sans illégalité (décision utilisateur, 20/11).

## La ligne légale (position assistant — `[À confirmer]` par l'utilisateur ; légal si usage RTBF)

| Pistes | Contenu | Licence | Poussé ? |
|---|---|---|---|
| **A — marque blanche** | connaissance **générale** de la gestion du changement (aucun nom/modèle Prosci) | **CC BY-SA 4.0** (licence contenu déjà posée par le kit, README) | ✅ public |
| **B — « avec licence »** | notes de formation **de l'utilisateur** / templates Prosci autorisés | la licence qu'il détient (usage interne) | ❌ local uniquement (gitignoré) |

- **Piste A** : les concepts généraux (parties prenantes, adoption, communication,
  formation, résistance, sponsors/champions, bénéfices) sont des connaissances publiques —
  publisables, **à condition qu'aucun nom Prosci et aucune structure de modèle Prosci
  n'y figure** (ni ADKAR, ni « 5 Cs », ni CBST, ni « Prosci Model of Change »).
- **Piste B** : le kit **ne développe rien** — il n'offre que le **slot** (dossier +
  README d'avertissement). Des notes personnelles utilisées en local = usage personnel ;
  jamais poussées dans le repo public.

## Périmètre

### Piste A (développée) — l'espace marque blanche
- Dossier `methode/<NOM>/fr/` — `<NOM>` `[À confirmer]` (proposition assistant :
  `Changement`).
- `referentiel-<nom>.md` (catalogue 5 colonnes) + 1 template par document, chacun avec sa
  section « ## 2. Questions de l'assistant » → **skills générées par `tools/gen_skills.py`**
  (WP-0050, zéro code : `sid = ap-<methode>-<NN>-<slug>`).
- **Liste première des documents** `[À confirmer]` :
  1. Plan de gestion du changement (côté humain — se distingue de PM2-09 Plan de transition
     qui est côté opérationnel)
  2. Analyse des parties prenantes du changement (impact / position / influence)
  3. Plan de communication du changement
  4. Plan d'adoption et de formation
  5. Gestion des résistances (détection, réponses)
  6. Sponsors et champions (réseau du changement)
  7. Bénéfices post-changement et consolidation
- **Critère d'exclusion** : aucun nom / marque / structure de modèle Prosci (vérification
  explicite à la génération).

### Piste B (slot, non développée)
- `methode/prosci/` : **README** (avertissement légal + comment remplir le slot : sous-dossier
  `fr/` avec `referentiel*.md` + templates de l'utilisateur → skills générées **localement**,
  zéro code) + **`.gitignore`** (`*` sauf README et .gitignore) → le contenu n'est **jamais**
  poussé.

## Décisions (20/11 — utilisateur)

1. **Nom** de l'espace marque blanche : **`GestionImpactHumain`**.
2. **Liste des documents** : les **7** proposés — OK.
3. **Piste B** : `methode/prosci/` local-only — OK, et **peut contenir une notice** (→ le
   README du slot **est** cette notice : ce que c'est, comment remplir, limite).
4. Ligne légale : `[À confirmer]` valider avec le légal si le fork est utilisé à la RTBF.

## Critères de réalisation

- [x] Piste A : `methode/GestionImpactHumain/fr/` créé — referentiel + 7 templates (section
      questions), **7 skills `ap-gestionimpacthumain-01…07`** générées par `gen_skills.py`
      (29 au total ; les 22 PM² **inchangées**, vérifié par hash 20/11).
- [x] Piste A : **aucun modèle propriétaire nommé** dans les 7 templates (vérifié par grep :
      ADKAR / CBST / 5 Cs / Prosci absents des templates — la seule mention Prosci du
      référentiel = la note légale de la piste B).
- [x] Piste B : `methode/prosci/README.md` (**notice** + how-to) + `.gitignore`
      (contenu local-only) — vérifié : `git add -n` ne retient que le README et le .gitignore.
- [x] `docs/guide.md` (chapitre méthodes) : les 2 pistes documentées (§6.1 + §6.4).
- [x] `fiche.md` + ce WP : état vert.

## Note

Les 7 templates sont des **squelettes en connaissance générale** (marque blanche) — leur
statut propre reste `en cours` : le **remplissage mode B** est la suite naturelle (source
idéale : la formation du 19/11 — contenu *à toi*, sans aucun nom de modèle Prosci).
