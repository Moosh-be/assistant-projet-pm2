#!/usr/bin/env bash
# install.sh — INSTALLATION de l'espace de travail assistant-projet-pm2
# Sans dépendance externe : bash natif (macOS / Linux / Git-Bash).
# Idempotent : relançable, re-écrit son bloc de config sans écraser le reste.
# Windows : lancer .\install.ps1 (logique identique).
#
# Principe racines (WP-0005) : pas de « vault » monolithe. Le kit s'appuie sur les
# RACINES de projets (1..N). Il ne demande JAMAIS de réorganiser des dossiers
# existants : il les liste, tu valides, et il n'ajoute que manifeste + _projet/.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REG_DIR="$ROOT/_projet/registry"
CONN="$REG_DIR/connexions.md"
os="$(uname -s)"

have() { command -v "$1" >/dev/null 2>&1; }

ask() { # ask "<question>" [défaut]
  local q="$1" d="${2:-}" ans=""
  if [ -n "$d" ]; then read -r -p "$q [$d]: " ans; printf '%s\n' "${ans:-$d}"
  else read -r -p "$q: " ans; printf '%s\n' "$ans"; fi
}

yn() { # yn <défaut y|n> "<question>" → renvoie 0 (oui) / 1 (non)
  local d="$1" q="$2" ans=""
  read -r -p "$q [$d]: " ans
  ans="${ans%$'\r'}"   # pipe CRLF (test / CI) : on ne garde pas le \r
  ans="${ans:-$d}"
  case "$ans" in [yY]*) return 0 ;; *) return 1 ;; esac
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
if [ -d "$parent" ]; then
  while IFS= read -r d; do
    cands+=("$d")
  done < <(find "$parent" -mindepth 1 -maxdepth 1 -type d ! -name '.*' 2>/dev/null | sort)
fi

echo " 1/3 — Où vivent tes projets ? (racines : 1 ou plusieurs dossiers)"
if [ ${#cands[@]} -gt 0 ]; then
  echo " Dossiers détectés dans '$parent' :"
  i=0
  for d in "${cands[@]}"; do
    i=$((i+1))
    [ $i -gt 5 ] && break
    n=0
    while IFS= read -r _; do n=$((n+1)); done < <(find "$d" -mindepth 1 -maxdepth 1 -type d ! -name '.*' 2>/dev/null)
    tag=""
    [ -f "$d/AGENT-projet.md" ] && tag="  (déjà un kit PM2)"
    echo "   $i) $d  [$n sous-dossiers$tag]"
  done
else
  echo " (aucun dossier détecté à côté du kit — saisis des chemins)"
fi
echo " Choix : numéros séparés par espaces ou virgules — A = ajouter un chemin — V = passer"
read -r -p "  Racines: " rsel
rsel="${rsel%$'\r'}"
while [ -n "$rsel" ]; do
  s=$(printf '%s' "$rsel" | tr '[:lower:]' '[:upper:]' | tr -d ' ')
  if [ "$s" = "V" ]; then break; fi
  case "$s" in
    A*)
      read -r -p "  Chemin à ajouter: " p
      p="${p%$'\r'}"
      [ -z "$p" ] && { read -r -p "  Racines: " rsel; rsel="${rsel%$'\r'}"; continue; }
      p="${p%\"}"; p="${p#\"}"
      case " ${roots[*]:-} " in *" $p "*) ;; *) roots+=("$p");; esac
      read -r -p "  Racines: " rsel
      rsel="${rsel%$'\r'}"
      ;;
    *)
      IFS=',; ' read -ra toks <<< "$rsel"
      for t in "${toks[@]}"; do
        if [[ "$t" =~ ^[0-9]+$ ]]; then
          idx=$((t-1))
          if [ $idx -ge 0 ] && [ $idx -lt ${#cands[@]} ] && [ $idx -lt 5 ]; then
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
op_url=""; op_token_env=""; op_statut="non"
sp_statut="non"
gh_repo=""; gh_statut="non"
glab_url=""; glab_statut="non"

have op && echo " CLI OpenProject (op) détectée."
if yn no "3/3 — Connexion OpenProject ?"; then
  op_statut="oui"
  op_url="$(ask "   URL de l'instance" "https://<instance>/openproject")"
  op_token_env="$(ask "   Variable d'env du token API (ne JAMAIS écrire le token dans le repo)" "OP_API_TOKEN")"
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

# ── Persistance (idempotent : bloc entre marqueurs) ─────────────────────
roots_str="${root_entries[*]:-aucune}"
block="<!-- wizard:start (généré par install.sh / install.ps1 — régénéré à chaque installation, ne pas éditer) -->
## Configuration de l'espace de travail (wizard d'installation)
- généré_le: $(date +%F_%R)
- os: $os
- racines: $roots_str
- opencode: $opencode_statut
- openproject: $op_statut$( [ "$op_statut" = "oui" ] && echo " — url: $op_url — token_env: $op_token_env" )
- superproductivity: $sp_statut
- github_issue: $gh_statut$( [ "$gh_statut" = "oui" ] && echo " — repo: ${gh_repo:-?}" )
- gitlab_issue: $glab_statut$( [ "$glab_statut" = "oui" ] && echo " — url: $glab_url" )
<!-- wizard:end -->"

mkdir -p "$REG_DIR"
tmp_block="$(mktemp)"
printf '%s\n' "$block" > "$tmp_block"
if [ -f "$CONN" ] && grep -q 'wizard:start' "$CONN"; then
  awk -v f="$tmp_block" '
    /<!-- wizard:start/ { while ((getline line < f) > 0) print line; skip = 1; next }
    /<!-- wizard:end/  { skip = 0; next }
    !skip { print }
  ' "$CONN" > "$CONN.tmp" && mv "$CONN.tmp" "$CONN"
else
  [ -f "$CONN" ] || printf '# _projet/registry/connexions.md — registres des connexions\n' > "$CONN"
  printf '\n%s\n' "$block" >> "$CONN"
fi
rm -f "$tmp_block"

# ── Récapitulatif ───────────────────────────────────────────────────────
echo
echo "================================================"
echo " Récapitulatif de l'installation"
echo "================================================"
echo " Racines       : $roots_str"
echo " opencode      : $opencode_statut"
echo " OpenProject   : $op_statut"
echo " Sprod         : $sp_statut"
echo " GitHub Issue  : $gh_statut"
echo " GitLab Issue  : $glab_statut"
echo " Config        : $CONN"
echo
echo " Prochaines étapes :"
if [ "$roots_str" != "aucune" ]; then
  echo "  1. Ouvrir l'agent dans un projet d'une racine  →  opencode"
else
  echo "  1. Copier ce kit dans un dossier projet existant (ou un nouveau)"
fi
echo "  2. Dans l'agent : /scan  (liste les projets détectés dans les racines)"
echo "  3. Demander : « commence le projet <NomDuProjet> »"
