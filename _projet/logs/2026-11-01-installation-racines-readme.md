# Session 2026-11-01 — installation multi-racines, /scan, README multilingue, préparation au push

- **WP-0004** → `fait` : wizard d'installation (`install.ps1` / `install.sh`). Bugs corrigés : « non » ne pose plus les questions de détail ; création de dossier sur confirmation seule (plus de dossier parasite).
- **WP-0005** → `fait` : question 1 du wizard = **racines de projets (1..N)** (détection, choix par numéro / `A` / `V`) ; commande **`/scan`** (classe kit / partiel / plain, annonce phase + gate, propose l'ajout du kit sans jamais déplacer) ; docs `install.md` §4 + `prise-en-main.md` §1-3.
- **WP-0006** → `fait` : README multilingue — `README.md` = **router de langue** (seul auto-affiché par la forge), `README.fr.md` + `README.en.md` = contenu complet. Sélecteur identique en haut de chaque version.
- **Décision** : `_projet/registry/connexions.md` = état **local machine** (généré par l'install) → **gitignored** (comme un `.env`) ; jamais de données entreprise dans le repo public.
- **Préparation au push** : historique réparti en **commits WP-alisés** (pas de « sale commit ») ; sanitisation des données personnelles (chemins locaux, nom de fork) dans les WP.
- **Ouvert** : WP-0002 (commande démo), WP-0003 (backup gzip).
