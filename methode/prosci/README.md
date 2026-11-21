# methode/prosci/ — slot « avec licence » (notice)

> **WP-0051 (20/11) — notice du slot de méthode sous licence.**

## Ce que c'est

Ce dossier est le **slot** d'une **méthode de gestion du changement sous licence**
(Prosci — © Prosci : contenu, modèles et noms déposés, **non redistribuables** dans un
repo public).

- **Ce repo ne contient aucun contenu Prosci** et n'en distribue pas — la redistribution
  publique serait une illégalité (© + marques déposées).
- Les **sujets** de la gestion du changement, en **connaissance générale** (marque
  blanche, CC BY-SA 4.0), vivent dans `methode/GestionImpactHumain/fr/`.

## Comment utiliser ce slot (si tu détiens une licence)

1. Crée le sous-dossier `fr/` ici, avec un `referentiel*.md` (catalogue 5 colonnes) + tes
   templates — **à partir de tes notes de formation** ou de documents dont tu as le droit
   d'usage (usage interne / personnel).
2. `python tools/gen_skills.py` → les skills `ap-prosci-NN-<slug>` sont générées
   **automatiquement** (zéro code — WP-0040/0050).
3. **Ne jamais pousser ce contenu** : le `.gitignore` de ce dossier l'empêche — vérifier
   que `git status` reste propre après ajout.

## Limite

- Contenu **local / usage interne uniquement** — jamais de commit, jamais de fork public.
- Si un jour Prosci (ou un autre éditeur) fournit un pack de templates **distribuable**, il
  pourra remplacer ce slot avec sa propre licence — même mécanique (referentiel + templates
  → skills).
