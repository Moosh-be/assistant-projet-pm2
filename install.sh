#!/usr/bin/env bash
# install.sh — INSTALLATION de l'espace de travail assistant-projet-pm2
# Sans dépendance externe : bash natif (macOS / Linux / Git-Bash).
# Idempotent : relançable, re-écrit son bloc de config sans écraser le reste.
# Windows : lancer .\install.ps1 (logique identique).
#
# Principe racines (WP-0005) : pas de « vault » monolithe. Le kit s'appuie sur les
# RACINES de projets (1..N). Il ne demande JAMAIS de réorganiser des dossiers
# existants : il les liste, tu valides, et il n'ajoute que manifeste + _meta/.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REG_DIR="$ROOT/_meta/registry"
OLD_CONN="$REG_DIR/connexions.md"   # bloc wizard ANCIEN (migration WP-0017)
os="$(uname -s)"

# ── Config machine (WP-0017) ─────────────────────────────────────────────
# Fichier de config à la RACINE du kit (gitignored) — entièrement wizard-généré
# (régénéré à chaque installation, ne pas éditer à la main). 3 noms possibles,
# le code lit/écrit le 1er qui existe (défaut : .assistant.config) :
#   .assistant.config  (défaut, caché)  |  assistant.config  |  assistant.config.md
for c in .assistant.config assistant.config assistant.config.md; do
  [ -f "$ROOT/$c" ] && { CONFIG="$ROOT/$c"; break; }
done
[ -z "${CONFIG:-}" ] && CONFIG="$ROOT/.assistant.config"
ENV_FILE="$ROOT/.assistant-projet.env"   # secrets (gitignored) — par défaut

env_upsert() { # env_upsert <fichier-env> <VARIABLE> <valeur> — sans jamais afficher la valeur
  local file="$1" var="$2" val="$3"
  if [ ! -f "$file" ]; then
    printf '# Assistant-projet — secrets (généré par install — gitignored, ne JAMAIS commit)\n' > "$file"
  fi
  # Réécriture ligne à ligne (robuste : aucune valeur n'a de caractère « spécial » à échapper)
  local found=0 out="" line
  while IFS= read -r line || [ -n "$line" ]; do
    if printf '%s' "$line" | grep -qE "^[[:space:]]*${var}[[:space:]]*="; then
      out="${out}${var}=${val}"$'\n'; found=1
    else
      out="${out}${line}"$'\n'
    fi
  done < "$file"
  [ $found -eq 0 ] && out="${out}${var}=${val}"$'\n'
  printf '%s' "$out" > "$file"
}

# ── Migration WP-0017 : le bloc wizard de l'ancien registre (connexions.md) a déménagé ──
if [ -f "$OLD_CONN" ] && grep -q 'wizard:start' "$OLD_CONN"; then
  # 1) le token posé dans token_env (valeur longue, pas un nom de variable court) → migré dans le .env
  old_tok="$(sed -nE 's/.*token_env:[[:space:]]*([A-Za-z0-9_-]+).*/\1/p' "$OLD_CONN" | head -n1)"
  if [ -n "$old_tok" ] && printf '%s' "$old_tok" | grep -qE '^[A-Za-z0-9_-]{32,}$'; then
    env_upsert "$ENV_FILE" "OP_API_TOKEN" "$old_tok"
    echo " Migration : le token de l'ancien registre est déplacé dans .assistant-projet.env (variable OP_API_TOKEN)."
  fi
  # 2) le registre ne garde que le registre de projet (le bloc wizard → config à la racine,
  #    régénérée plus bas dans cette même installation à partir des réponses)
  printf '# _meta/registry/connexions.md — registres des connexions DU PROJET (ids sp_project / op_id / MCP)\n# La config machine (racines, connexions transversales) vit dans %s à la racine du kit (WP-0017).\n' "$(basename "$CONFIG")" > "$OLD_CONN"
  echo " Migration : le bloc wizard de l'ancien registre est remplacé par la config à la racine du kit ($CONFIG)."
  echo "             Les réponses de cette installation le remplissent (les anciens choix sont ré-proposés)."
fi

have() { command -v "$1" >/dev/null 2>&1; }

ask() { # ask "<question>" [défaut]
  local q="$1" d="${2:-}" ans=""
  if [ -n "$d" ]; then read -r -p "$q [$d]: " ans; printf '%s\n' "${ans:-$d}"
  else read -r -p "$q: " ans; printf '%s\n' "$ans"; fi
}

yn() { # yn <défaut y|n> "<question>" → renvoie 0 (oui) / 1 (non)
  # Script en français : affiche (o/n) et accepte "o" (oui) ET "y" (yes) ;
  # si rien n'est tapé, c'est le défaut (ici "non") qui s'applique.
  local d="$1" q="$2" ans=""
  read -r -p "$q (o/n) : " ans
  ans="${ans%$'\r'}"   # pipe CRLF (test / CI) : on ne garde pas le \r
  ans="${ans:-$d}"
  case "$ans" in [yYoO]*) return 0 ;; *) return 1 ;; esac
}

echo "================================================"
echo " INSTALLATION — assistant-projet-pm2"
echo "================================================"
echo " OS       : $os"
echo " Kit      : $ROOT"
have git      && echo " git      : $(git --version)"
have node     && echo " node     : $(node --version)"
if have opencode; then echo " opencode : $(opencode --version 2>/dev/null | head -1)"; else echo " opencode : NON détecté"; fi
echo

# ── 1/3 — Racines de projets (1..N dossiers) ──────────────────────────
roots=()
parent="$(dirname "$ROOT")"
cands=()
if [ -n "$parent" ]; then
  # Candidats 1..3 : le dossier du kit + 2 niveaux au-dessus.
  # Cas fréquent : le kit est cloné DANS le dossier de projets
  # → c'est le PARENT qu'il faut comme racine, pas les projets à côté.
  cands=(); notes=()
  up="$parent"; depth=0
  upnotes=("dossier du kit" "1 niveau au-dessus du kit" "2 niveaux au-dessus du kit")
  while [ $depth -le 2 ]; do
    cands+=("$up"); notes+=("${upnotes[$depth]}")
    upn="$(dirname "$up")"
    [ -z "$upn" ] || [ "$upn" = "$up" ] && break
    up="$upn"; depth=$((depth+1))
  done
  # Candidats suivants : les dossiers à côté du kit (max 5, comme avant).
  sib=0
  while IFS= read -r d; do
    [ $sib -ge 5 ] && break
    cands+=("$d"); notes+=(""); sib=$((sib+1))
  done < <(find "$parent" -mindepth 1 -maxdepth 1 -type d ! -name '.*' 2>/dev/null | sort)
fi
shown=${#cands[@]}
[ $shown -gt 8 ] && shown=8
echo " 1/3 — Où vivent tes projets ? (racines : 1 ou plusieurs dossiers)"
echo " Une racine = un dossier qui CONTIENT des projets (1 projet = 1 sous-dossier)."
if [ $shown -gt 0 ]; then
  echo " Dossiers proposés :"
  i=0
  for d in "${cands[@]}"; do
    i=$((i+1))
    [ $i -gt $shown ] && break
    n=0
    while IFS= read -r _; do n=$((n+1)); done < <(find "$d" -mindepth 1 -maxdepth 1 -type d ! -name '.*' 2>/dev/null)
    tag=""
    [ -f "$d/AGENT-projet.md" ] && tag="  (déjà un kit PM2)"
    note="${notes[$((i-1))]}"
    [ -n "$note" ] && note=" ($note)"
    printf '   %d) %s%s  [%d sous-dossiers%s]\n' "$i" "$d" "$note" "$n" "$tag"
  done
else
  echo " (aucun dossier détecté — saisis des chemins avec A)"
fi
echo " Choix : numéros des dossiers à retenir, séparés par espaces ou virgules — A = ajouter un chemin — V = passer"
read -r -p "  Racines (ex : 1, A, V) : " rsel
rsel="${rsel%$'\r'}"
while [ -n "$rsel" ]; do
  s=$(printf '%s' "$rsel" | tr '[:lower:]' '[:upper:]' | tr -d ' ')
  if [ "$s" = "V" ]; then break; fi
  case "$s" in
    A*)
      read -r -p "  Chemin à ajouter: " p
      p="${p%$'\r'}"
      [ -z "$p" ] && { read -r -p "  Racines (ex : 1, A, V) : " rsel; rsel="${rsel%$'\r'}"; continue; }
      p="${p%\"}"; p="${p#\"}"
      case " ${roots[*]:-} " in *" $p "*) ;; *) roots+=("$p");; esac
      read -r -p "  Racines (ex : 1, A, V) : " rsel
      rsel="${rsel%$'\r'}"
      ;;
    *)
      IFS=',; ' read -ra toks <<< "$rsel"
      for t in "${toks[@]}"; do
        if [[ "$t" =~ ^[0-9]+$ ]]; then
          idx=$((t-1))
          if [ $idx -ge 0 ] && [ $idx -lt ${#cands[@]} ]; then
            p="${cands[$idx]}"
            case " ${roots[*]:-} " in *" $p "*) ;; *) roots+=("$p");; esac
          fi
        fi
      done
      break
      ;;
  esac
done

root_entries=()
for r in "${roots[@]}"; do
  [ -z "$r" ] && continue
  if [ ! -d "$r" ]; then
    echo " '$r' n'existe pas."
    if yn no "   Je le crée ?"; then
      mkdir -p "$r"
      root_entries+=("$r (créé, vide)")
    else
      root_entries+=("$r (ABSENT — non créé)")
    fi
    continue
  fi
  kids=()
  while IFS= read -r d; do kids+=("$d"); done < <(find "$r" -mindepth 1 -maxdepth 1 -type d ! -name '.*' 2>/dev/null)
  if [ ${#kids[@]} -eq 0 ]; then
    root_entries+=("$r (vide)")
  else
    root_entries+=("$r (${#kids[@]} sous-dossiers — déjà rempli, rien ne sera déplacé)")
    echo "   Contenu de '$r' :"
    for k in "${kids[@]}"; do echo "     - $(basename "$k")"; done
  fi
done
[ ${#root_entries[@]} -eq 0 ] && echo " Aucune racine retenue : l'installation continue sans (relance le script pour en définir)."
echo

# ── 2/3 — opencode (le marteau) ─────────────────────────────────────────
opencode_statut="non installé"
if have opencode; then
  opencode_statut="installé"
else
  echo " opencode non détecté."
  if yn no "2/3 — L'installer maintenant (npm install -g opencode-ai) ?"; then
    if have npm; then
      if npm install -g opencode-ai; then opencode_statut="installé (via npm)"; else echo " Échec de l'installation npm."; fi
    else
      echo " Node.js requis avant d'installer opencode : https://nodejs.org"
    fi
  fi
fi

# ── 3/3 — Connexions / plugins ──────────────────────────────────────────
# Règle dure : un « non » = aucune question de détail.
op_url=""; op_token_env=""; op_statut="non"; op_token_state=""
sp_statut="non"
gh_repo=""; gh_statut="non"
glab_url=""; glab_statut="non"

have op && echo " CLI OpenProject (op) détectée."
if yn no "3/3 — Connexion OpenProject ?"; then
  op_statut="oui"
  op_url="$(ask "   URL de l'instance (celle qui charge ta page d'accueil OpenProject)" "https://<instance>")"
  # Page « Mes jetons d'accès » où on fabrique la clé API.
  op_key_link="$(printf '%s' "$op_url" | sed 's#/*$##')/my/access_tokens"
  echo "   -> fabriquer la clé API : $op_key_link"
  op_token_env="$(ask "   Variable d'env du token API" "OP_API_TOKEN")"
  # Le token est une VALEUR DE CONFIG : il vit dans le .env dédié du kit (généré ici), jamais dans le repo.
  if [ -f "$ENV_FILE" ] && grep -qE "^[[:space:]]*${op_token_env}[[:space:]]*=[[:space:]]*[^[:space:]]" "$ENV_FILE"; then
    echo "   Variable ${op_token_env} déjà présente dans $(basename "$ENV_FILE") — je la mets à jour si tu saisis une nouvelle clé."
  fi
  if yn no "   Saisir la clé API maintenant ?"; then
    read -r -s -p "   Clé API (masquée, Entrée pour valider) : " op_tok_secret
    printf '\n'
    if [ -n "$op_tok_secret" ]; then
      env_upsert "$ENV_FILE" "$op_token_env" "$op_tok_secret"
      op_token_state="saisie dans $(basename "$ENV_FILE")"
      echo "   -> token écrit dans $(basename "$ENV_FILE") (gitignored — jamais dans le repo)."
    else
      env_upsert "$ENV_FILE" "$op_token_env" ""
      op_token_state="placeholder vide dans $(basename "$ENV_FILE") (à remplir)"
      echo "   -> variable ${op_token_env}= laissée vide dans $(basename "$ENV_FILE") : remplis-la plus tard."
    fi
  else
    # Pas de saisie maintenant : on s'assure que la variable existe (placeholder) pour un remplissage plus tard.
    if [ ! -f "$ENV_FILE" ] || ! grep -qE "^[[:space:]]*${op_token_env}[[:space:]]*=" "$ENV_FILE"; then
      env_upsert "$ENV_FILE" "$op_token_env" ""
    fi
    op_token_state="placeholder vide dans $(basename "$ENV_FILE") (à remplir)"
    echo "   -> à faire plus tard : coller la clé dans $(basename "$ENV_FILE") (variable ${op_token_env})."
  fi
fi

if yn no "   Connexion SuperProductivity (tâches locales) ?"; then
  sp_statut="oui"
fi

have gh && echo " CLI GitHub (gh) détectée."
if yn no "   Connexion GitHub Issue ?"; then
  gh_statut="oui"
  gh_default="$(git -C "$ROOT" remote get-url origin 2>/dev/null | sed -nE 's#^.*/github.com[:/]([^/]+/[^/.]+).*#\1#p')"
  gh_repo="$(ask "   Repo (owner/name)" "$gh_default")"
fi

have glab && echo " CLI GitLab (glab) détectée."
if yn no "   Connexion GitLab Issue ?"; then
  glab_statut="oui"
  glab_url="$(ask "   URL de l'instance GitLab" "https://gitlab.com")"
fi

# ── Persistance : config machine à la racine du kit (idempotent) ───────────
roots_str="${root_entries[*]:-aucune}"

# Lignes conditionnelles (une connexion « oui » dépliée en sous-clés)
op_line="openproject = $op_statut"
if [ "$op_statut" = "oui" ]; then
  op_line="openproject = oui
openproject_url = $op_url
openproject_token_env = $op_token_env
openproject_token_file = $ENV_FILE"
fi
gh_line="github_issue = $gh_statut"
[ "$gh_statut" = "oui" ] && gh_line="github_issue = oui
github_repo = ${gh_repo:-?}"
gl_line="gitlab_issue = $glab_statut"
[ "$glab_statut" = "oui" ] && gl_line="gitlab_issue = oui
gitlab_url = $glab_url"

# Header statique (explique les 3 noms possibles + meta_folder + env_file)
cfg_name="$(basename "$CONFIG")"
cfg_header="# $cfg_name — Config machine de l'espace assistant-projet (WP-0017)
# Généré par install.sh / install.ps1 — le bloc wizard est régénéré à chaque installation.
# Fichier local à la MACHINE : chemins/instances de l'utilisateur (jamais de données entreprise).
# Gitignored : ne part jamais sur la forge.
#
# 3 noms possibles (le wizard utilise le 1er trouvé, défaut = le 1er) :
#   .assistant.config      (défaut, caché)
#   assistant.config       (visible)
#   assistant.config.md    (lisible dans Obsidian)
#
# Les secrets (tokens) ne vivent PAS ici : ils vivent dans le fichier pointé par env_file.

# Dossier de documentation du projet (défaut _meta)
meta_folder = _meta
# Fichier des secrets (tokens, etc.)
env_file = .assistant-projet.env
"

wizard_block="<!-- wizard:start (généré par install.sh / install.ps1 — ne pas éditer) -->
généré_le = $(date +%F_%R)
os = $os
racines = $roots_str
opencode = $opencode_statut
$op_line
superproductivity = $sp_statut
$gh_line
$gl_line
<!-- wizard:end -->"

mkdir -p "$(dirname "$CONFIG")"
if [ -f "$CONFIG" ] && grep -q 'wizard:start' "$CONFIG"; then
  # Remplace uniquement le bloc wizard (conserve le header + tout contenu avant/après)
  tmp_block="$(mktemp)"
  printf '%s\n' "$wizard_block" > "$tmp_block"
  awk -v f="$tmp_block" '
    /<!-- wizard:start/ { while ((getline line < f) > 0) print line; skip = 1; next }
    /<!-- wizard:end/  { skip = 0; next }
    !skip { print }
  ' "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"
  rm -f "$tmp_block"
else
  printf '%s\n' "$cfg_header" > "$CONFIG"
  printf '%s\n' "$wizard_block" >> "$CONFIG"
fi

# ── Récapitulatif ───────────────────────────────────────────────────────
echo
echo "================================================"
echo " Installation terminée : la config transversale est en place"
echo "================================================"
echo " Racines       : $roots_str"
echo " opencode      : $opencode_statut"
echo " OpenProject   : $op_statut$( [ "$op_statut" = "oui" ] && echo "  (token : $op_token_state)" )"
echo " Sprod         : $sp_statut"
echo " GitHub Issue  : $gh_statut"
echo " GitLab Issue  : $glab_statut"
echo " Config        : $CONFIG"
echo " Secrets       : $ENV_FILE"
echo
echo " Menu natif (sans IA : rapide, gratuit) :  ./assistant.sh"
echo "   -- Gérer les projets (depuis le kit ou les racines) --"
echo "   scan                 tes projets existants : 3 buckets (assistés / pourraient / sans signal) + phase"
echo "   liste                les projets (nom + phase + gate)"
echo "   statut <projet>      où en est un projet (phase + gate + avancement)"
echo "   new <nom> [racine]   créer un projet (kit + _meta neuf)"
echo "   add <dossier>        ajouter le kit à un projet existant (jamais d'écrasement)"
echo "   -- Dans un projet (depuis le dossier du projet) --"
echo "   statut               le statut du projet courant (sans argument)"
echo "   update               resync le kit de CE projet (zéro écrasement)"
echo "   remark <texte>       journal des remarques au vol (remontée au projet assistant)"
echo "   commence <nom>       → l'AGENT : ouvre opencode dans le projet"
echo
if [ "$roots_str" != "aucune" ]; then
  echo " Conseil : tu as des projets existants ? Commence par :  ./assistant.sh scan"
  echo " Puis, pour travailler sur un projet :  ./assistant.sh commence <Nom>   (l'agent prend le relais)."
else
  echo " Conseil : aucun projet scanné pour l'instant → crée ton premier projet :"
  echo "   ./assistant.sh new <Nom>   (ou, dans l'agent : « crée un projet <Nom> »)"
  echo " ...ou relance l'install pour définir des racines."
fi
