# versions/ — les versions du bundle (rétro-compat, WP-0025)

Politique de versionnage (décision 04/11) :
- **Pas de breaking change** : la mise à jour du bundle est systématiquement additive.
- **Si un breaking change est inévitable** : une copie de la version concernée vit ici,
  dans `versions/<version>/` (marqueur `.assistant.version` + moteur complet). Les
  anciennes versions deviennent, avec le temps, des **add-ons de rétro-compatibilité**.
- **Routage** : la config partagée du projet (`_meta/registry/connexions.md`) porte
  `assistant_ref: latest` (défaut = racine du bundle) ou `assistant_ref: <version>`
  (→ `versions/<version>/`). Chaque projet migre **quand il le sent** : changer
  `assistant_ref` suffit.

Pour l'instant : aucune version figée (le bundle est en 1.0.0, `latest`).
