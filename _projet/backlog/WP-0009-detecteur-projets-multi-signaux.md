---
wp_id: WP-0009
titre: "Détecteur de projets multi-signaux (scoring, imbriqués, nature du projet)"
statut: a-faire
priorite: moyenne
phase: Lancement
roles: [cp]
sp_id: ""
op_id: ""
source: "échange du 01/11/2026 — spec détaillée multi-signaux fournie par l'utilisateur (5 familles, scoring, imbriqués)"
créé: 2026-11-01
mis_a_jour: 2026-11-01
---

# WP-0009 — Détecteur de projets multi-signaux

## Objectif

Reconnaître un dossier qui **EST** un projet (et donc, par inverse, un dossier qui **CONTIENT** des projets) sans dépendre du kit PM² : détecteur à **signaux multiples + scoring**, plutôt qu'une règle binaire sur 2 fichiers. C'est le **niveau 2** de la détection — le niveau 1 (signaux observés affichés dans `/scan`, sans scoring, sans récursion) en est découplé.

## La spec (d'après l'échange du 01/11 — texte intégral dans la conversation)

### 5 familles de signaux

1. **SCM / outils** : `.git`, `.svn`, `.hg`, `.vscode`, `.idea`, `*.sln`, `.devcontainer`, `.editorconfig`, `.github/`, `.gitlab-ci.yml`
2. **Build / langage** : `package.json`, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `go.mod`, `pom.xml`, `build.gradle`, `Makefile`, `CMakeLists.txt`, `composer.json`, `Gemfile`, `*.csproj`
3. **Infra / déploiement** : `Dockerfile`, `docker-compose.yml`, `*.tf`, `Vagrantfile`, `.github/workflows/`
4. **Structure** : `src/`, `source/`, `lib/`, `app/`, `tests/`, `docs/`, `scripts/`, `config/` — **combinatoire** (un `src/` seul ne suffit pas)
5. **Sémantique / statistique** : `README`, `CHANGELOG`, `LICENSE`, `charte*`, `backlog*`, `roadmap*` ; profil d'extensions (ex. 46 `.py` → projet Python) ; cohérence temporelle des fichiers ; concentration de fichiers sources cohérents (cas « ancien projet sans marqueur »)

### Scoring (tableau fourni)

| Signal | Score |
|---|---|
| `.git` / `.svn` / `.hg` | +50 |
| `*.sln` | +40 |
| `package.json` / `pyproject.toml` / `pom.xml` | +35 |
| `.idea` | +20 |
| `.vscode` / `Dockerfile` | +15 |
| `README` / `src/` / `tests/` | +5 à +10 |
| plusieurs fichiers sources | +10 |
| seulement images/documents | −10 |

Seuils : **≥50** quasi certain · **30–49** probable · **15–29** possible · **<15** répertoire ordinaire.
Exclure la descente : `node_modules/`, `.venv/`, intérieur de `.git/`.

### Les 2 problèmes à résoudre

- **Projets imbriqués** : `app/` (`.git`) contient `app/backend/` (`pom.xml`) et `app/frontend/` (`package.json`) → distinguer **racine dépôt/workspace** vs **module/sous-projet**, sans éliminer les sous-modules.
- **Racines vs projets** : noms du type `Projects/`, `GitHub/`, `Sources/`, `Development/` = **conteneurs** de projets, pas des projets.

### Sortie cible

Par dossier : `confidence` + `type` (Git repo / Python / Docker / Legacy…) + `signals` (liste) + `probable_root` (bool). Ex. : `D:\dev\foo — 96 · Git+Python+Docker · probable_root: oui`.

## Critères de réalisation

- [ ] Décider l'implémentation : outil standalone (`tools/`) ? commande `/detect` ? enrichissement `/scan` ?
- [ ] Tests sur les dossiers réels de la machine — cas imbriqués obligatoires
- [ ] Sortie lisible (tableau) + exploitable (frontmatter / fichier) à trancher

## Notes

- **Positionnement** : c'est un détecteur de disque (archéologie), au-delà de l'intention actuelle du kit : l'utilisateur **déclare** ses racines (wizard), `/scan` **observe** (classement). Décision à trancher avant implémentation : niveau 1 seul ? niveau 2 en outil séparé ?
- La valeur ajoutée réelle du kit se joue sur la **famille 5** (vieux projets sans marqueurs) — pas sur les `.git`, que tout le monde voit déjà.
