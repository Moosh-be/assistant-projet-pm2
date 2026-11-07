#!/usr/bin/env bash
# bootstrap.sh - BOOTSTRAP (WP-0025) - NATIF (sans IA, sans dépendance)
# Cet espace projet fonctionne avec l'"assistant de gestion de projet" (PM2).
# Si l'assistant (le bundle = le repo assistant) n'est pas détecté sur cette machine,
# ce script :
#   - explique tout à l'utilisateur et demande confirmation AVANT chaque action,
#   - propose : pointer <chemin> | chercher <dossier...> | installer (git clone de la config partagée),
#   - puis propose la même opération pour le harness opencode (la couche IA).
# L'emplacement de l'assistant est écrit dans _meta/registry/connexions.local.md (machine, gitignoré).
# Jamais d'écrasement : seules la ligne assistant_local de la config machine (et les fichiers
# ABSENTS du harness) sont écrits.
set -u
proj="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# conf_path <p> : chemin au format lisible par les 2 moteurs (Windows : C:/... ; POSIX : tel quel).
# Sur Git Bash, les chemins sont en MSYS (/c/..., /tmp/...) ; on les normalise en C:/...
# pour que connexions.local.md / opencode.json soient lisés par le lanceur PS, le lanceur
# bash et opencode sur la même machine.
conf_path() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) cygpath -w "$1" 2>/dev/null | tr '\\' '/' ;;
    *) printf '%s' "$1" ;;
  esac
}

# --- Helpers ─────────────────────────────────────────────────────────────────
read_conf() { # read_conf <fichier> <clé> → valeur (ou vide)
  local f="$1" k="$2"
  [ -f "$f" ] || return 0
  sed -nE "s/^[[:space:]]*$k[[:space:]]*:[[:space:]]*//p" "$f" | head -n1 | sed 's/[[:space:]]*$//'
}

# Écrit/remplace la ligne "key: value" (zéro écrasement : les autres lignes intactes).
set_conf_line() { # set_conf_line <fichier> <clé> <valeur>
  local f="$1" k="$2" v="$3"
  if [ -f "$f" ] && grep -qE "^[[:space:]]*${k}[[:space:]]*:" "$f"; then
    local tmp; tmp="$(mktemp)"
    sed -E "s|^[[:space:]]*${k}[[:space:]]*:.*|${k}: ${v}|" "$f" > "$tmp" && cat "$tmp" > "$f"
    rm -f "$tmp"
  else
    [ -f "$f" ] || printf '# connexions.local.md - config machine (gitignorée, écrite par le bootstrap)\n' > "$f"
    printf '%s: %s\n' "$k" "$v" >> "$f"
  fi
}

# Annonce + confirmation (o/n). Retourne 0 si oui.
confirm() { # confirm <texte>
  echo ""
  echo "Action à effectuer : $1"
  printf '  procéder ? (o/n) '
  local a
  IFS= read -r a || a=""
  case "$a" in
    o|O|oui|Oui|yes|YES|y|Y) return 0 ;;
    *) return 1 ;;
  esac
}

# --- État (détection, lecture seule) ─────────────────────────────────────────
mf="_meta"
shared="$proj/$mf/registry/connexions.md"
localf="$proj/$mf/registry/connexions.local.md"
mfcfg="$(read_conf "$shared" meta_folder)"
if [ -n "$mfcfg" ]; then
  shared="$proj/$mfcfg/registry/connexions.md"
  localf="$proj/$mfcfg/registry/connexions.local.md"
fi
git_url="$(read_conf "$shared" assistant_git)"
ref="$(read_conf "$shared" assistant_ref)"
[ -z "$ref" ] && ref="latest"
local_path="$(read_conf "$localf" assistant_local)"

# Un bundle valide = un dossier avec assistant.sh (ou .ps1) + le marqueur .assistant.version.
bundle_valid() { # bundle_valid <chemin>
  [ -n "${1:-}" ] && { [ -f "$1/assistant.sh" ] || [ -f "$1/assistant.ps1" ]; } && [ -f "$1/.assistant.version" ]
}

# Resout le moteur effectif (racine du bundle, ou versions/<ref> si assistant_ref != latest).
resolve_engine() { # resolve_engine → chemin du moteur (ou rien)
  bundle_valid "$local_path" || return 1
  local b="$local_path"
  if [ "$ref" != "latest" ] && [ -d "$b/versions" ]; then b="$b/versions/$ref"; fi
  bundle_valid "$b" || return 1
  printf '%s' "$b"
}

show_state() {
  echo ""
  echo "État détecté (lecture seule) :"
  echo "  - config partagée : $shared"
  if [ -n "$git_url" ]; then echo "      assistant_git : $git_url"; else echo "      assistant_git : (non défini)"; fi
  echo "      assistant_ref : $ref"
  if bundle_valid "$local_path"; then
    local v; v="$(head -n1 "$local_path/.assistant.version" 2>/dev/null)"
    echo "  - assistant     : présent (version ${v:-?})"
    echo "      assistant_local : $local_path"
  else
    echo "  - assistant     : NON détecté"
    if [ -n "$local_path" ]; then echo "      assistant_local : $local_path (invalide)"
    else echo "      assistant_local : (non défini)"; fi
  fi
  if command -v opencode >/dev/null 2>&1; then echo "  - opencode      : présent"
  else echo "  - opencode      : NON détecté"; fi
  if [ -f "$proj/.opencode/agent/assistant-projet.md" ]; then echo "  - harness       : déployé (.opencode/)"
  else echo "  - harness       : absent (.opencode/)"; fi
}

# --- Actions ─────────────────────────────────────────────────────────────────

# 1) POINTER - l'utilisateur donne l'emplacement de l'assistant (validation, écriture config machine).
act_pointer() {
  local ch="${1:-}"
  if [ -z "$ch" ]; then echo "Usage : bootstrap.sh pointer <chemin>"; return; fi
  if [ ! -d "$ch" ]; then echo "Chemin inexistant : $ch"; return; fi
  if ! bundle_valid "$ch"; then
    echo "Assistant non détecté dans : $ch"
    echo "  (le dossier doit contenir assistant.sh ou assistant.ps1 + le marqueur .assistant.version)"
    return
  fi
  if confirm "Définir l'emplacement de l'assistant : $ch
  (écrit dans $localf - config machine, gitignorée)"; then
    set_conf_line "$localf" "assistant_local" "$(conf_path "$ch")"
    echo "Fait : assistant_local -> $ch"
    propose_opencode
  else
    echo "Annulé."
  fi
}

# 2) CHERCHER - recherche du marqueur .assistant.version dans les dossiers indiqués (pas de scan de disque entier).
act_chercher() {
  if [ $# -eq 0 ]; then echo "Usage : bootstrap.sh chercher <dossier...>"; return; fi
  local found=""
  local dir root m
  for dir in "$@"; do
    [ -z "$dir" ] && continue
    if [ ! -d "$dir" ]; then echo "(dossier inexistant : $dir)"; continue; fi
    while IFS= read -r m; do
      root="$(dirname "$m")"
      if bundle_valid "$root"; then
        case "$found" in
          *"$root"*) ;;
          *) found="${found}${root}
" ;;
        esac
      fi
    done < <(find "$dir" -mindepth 1 -maxdepth 3 -name ".assistant.version" -type f 2>/dev/null)
  done
  if [ -z "$found" ]; then
    echo "Rien trouvé (aucun marqueur .assistant.version dans les dossiers indiqués)."
    return
  fi
  local n; n="$(printf '%s' "$found" | grep -c .)"
  if [ "$n" -eq 1 ]; then
    act_pointer "$(printf '%s' "$found" | head -n1)"
    return
  fi
  echo ""; echo "Candidats ($n) :"
  local i=1
  while IFS= read -r root; do
    [ -z "$root" ] && continue
    printf '  %d) %s\n' "$i" "$root"
    i=$((i+1))
  done <<< "$found"
  printf '  Numéro de l'emplacement de l'assistant : '
  local c
  IFS= read -r c || c=""
  if [[ "$c" =~ ^[0-9]+$ ]] && [ "$c" -ge 1 ] && [ "$c" -le "$n" ]; then
    act_pointer "$(printf '%s' "$found" | sed -n "${c}p")"
  else
    echo "Annulé."
  fi
}

# 3) INSTALLER - git clone du repo assistant (assistant_git de la config partagée), puis le définit.
act_installer() {
  local d="${1:-}"
  if [ -z "$git_url" ]; then
    echo "Pas de assistant_git dans la config partagée : $shared"
    echo "  -> utiliser pointer (si l'assistant est déjà sur cette machine) ou chercher (pour le trouver sur disque)."
    return
  fi
  if ! command -v git >/dev/null 2>&1; then
    echo "git est requis pour installer l'assistant (l'installer, ou utiliser pointer / chercher)."
    return
  fi
  if [ -z "$d" ]; then
    local parent repo
    parent="$(dirname "$proj")"
    repo="$(basename "${git_url%.git}")"
    d="$parent/$repo"
  fi
  local mode="clone"
  [ -d "$d/.git" ] && mode="mise à jour (git pull du clone existant)"
  if confirm "Installer l'assistant : git $mode
  depuis : $git_url
  vers   : $d
  puis le définir comme emplacement de l'assistant (assistant_local)"; then
    local rc=0
    if [ -d "$d/.git" ]; then git -C "$d" pull || rc=$?
    else git clone "$git_url" "$d" || rc=$?; fi
    if [ $rc -ne 0 ]; then echo "git a échoué - rien n'a été modifié dans la config."; return; fi
    if bundle_valid "$d"; then
      set_conf_line "$localf" "assistant_local" "$(conf_path "$d")"
      echo "Fait : assistant installé -> $d"
      propose_opencode
    else
      echo "Le dossier $d ne ressemble pas à un assistant (assistant.sh + .assistant.version manquants)."
    fi
  else
    echo "Annulé."
  fi
}

# Déploie le harness opencode du projet depuis le bundle (zéro écrasement).
# Un chemin ajouté par ligne (relatif au projet).
deploy_harness() { # deploy_harness <bundle>
  local bundle="$1"
  local sub f rel dst mdir
  for sub in agent command; do
    [ -d "$bundle/.opencode/$sub" ] || continue
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      rel="${f#"$bundle"/.opencode/}"
      dst="$proj/.opencode/$rel"
      if [ ! -e "$dst" ]; then
        mdir="$(dirname "$dst")"
        mkdir -p "$mdir"
        cp "$f" "$dst"
        printf '.opencode/%s\n' "$rel"
      fi
    done < <(find "$bundle/.opencode/$sub" -type f 2>/dev/null)
  done
  local oc="$proj/opencode.json"
  if [ ! -f "$oc" ]; then
    printf '{\n  "$schema": "https://opencode.ai/config.json",\n  "default_agent": "assistant-projet",\n  "instructions": ["%s/AGENT-projet.md", "projet.md"]\n}\n' "$(conf_path "$bundle")" > "$oc"
    printf 'opencode.json\n'
  fi
  local gi="$proj/.gitignore"
  if [ ! -f "$gi" ]; then
    if [ -f "$bundle/tools/templates/gitignore-projet.md" ]; then
      cp "$bundle/tools/templates/gitignore-projet.md" "$gi"
      printf '.gitignore\n'
    fi
  else
    local added=""
    grep -qF '.opencode/' "$gi" || added="${added}.opencode/
"
    grep -qF "$mf/registry/connexions.local.md" "$gi" || added="${added}${mf}/registry/connexions.local.md
"
    if [ -n "$added" ]; then
      printf '%s' "$added" >> "$gi"
      printf '.gitignore (append)\n'
    fi
  fi
  return 0
}

# 4) OPENCODE - le harness (couche IA) : le binaire + le dépôt de .opencode/ + opencode.json.
act_opencode() {
  echo ""
  echo "--- harness opencode (la couche IA) ---"
  # a) le binaire
  if ! command -v opencode >/dev/null 2>&1; then
    echo "  opencode (binaire) : NON détecté."
    if command -v npm >/dev/null 2>&1; then
      if confirm "Installer opencode : npm install -g opencode-ai"; then
        npm install -g opencode-ai
        if command -v opencode >/dev/null 2>&1; then echo "  opencode installé."
        else echo "  opencode toujours non détecté (PATH ?) - ré-exécuter cette étape après redémarrage du terminal."; fi
      fi
    else
      echo "  npm non détecté non plus : installer opencode manuellement (https://opencode.ai), puis ré-exécuter cette étape."
    fi
  else
    echo "  opencode (binaire) : présent."
  fi
  # b) l'assistant (bundle) doit être en place
  local engine
  engine="$(resolve_engine || true)"
  if [ -z "$engine" ]; then
    echo "  L'assistant n'est pas encore en place : pointer / chercher / installer d'abord."
    return
  fi
  # c) le harness
  if [ -f "$proj/.opencode/agent/assistant-projet.md" ] && [ -f "$proj/opencode.json" ]; then
    echo "  Harness : déjà déployé (.opencode/ + opencode.json) - rien à ajouter."
    return
  fi
  echo "  À déposer (zéro écrasement) :"
  [ -f "$proj/.opencode/agent/assistant-projet.md" ] || echo "    + .opencode/agent/ + .opencode/command/  (copies du bundle)"
  [ -f "$proj/opencode.json" ] || echo "    + opencode.json  (instructions -> AGENT-projet.md du bundle + projet.md)"
  echo "    + .gitignore  (lignes machine, en append)"
  if confirm "Déployer le harness opencode dans le projet"; then
    local out
    out="$(deploy_harness "$engine")"
    if [ -n "$out" ]; then
      while IFS= read -r a; do [ -n "$a" ] && printf '    + %s\n' "$a"; done <<< "$out"
    fi
    echo "  Harness déployé - la couche IA est en place (démarrer : opencode)."
  else
    echo "Annulé."
  fi
}

# Après pointer/chercher/installer : proposer la même opération pour opencode.
propose_opencode() {
  echo ""
  echo "L'assistant est en place. Déployer aussi le harness opencode (la couche IA) ?"
  printf '  (o/n) '
  local a
  IFS= read -r a || a=""
  case "$a" in
    o|O|oui|Oui|yes|YES|y|Y) act_opencode ;;
    *) echo "  Passé - à faire plus tard :  ./bootstrap.sh opencode" ;;
  esac
}

# --- Menu (défaut : sans argument) ───────────────────────────────────────────
show_menu() {
  cat <<'EOF'

================================================
 bootstrap - l'assistant de gestion de projet (sans IA)
================================================
 Cet espace projet fonctionne avec l'"assistant de gestion de projet".
 Pour utiliser ses fonctionnalités, il faut l'installer sur cette machine.

 Si c'est déjà fait : indiquez son emplacement (pointer)
 ou je peux le chercher sur votre disque (chercher).
 Sinon : l'installer (installer - git clone de la config partagée).
EOF
  show_state
  cat <<'EOF'

 Actions :
   1) pointer    - indiquer l'emplacement de l'assistant
   2) chercher   - chercher l'assistant sur le disque (dossiers à indiquer)
   3) installer  - installer l'assistant (git clone)
   4) opencode   - le harness opencode (la couche IA)
   0) quitter    - quitter (rien n'est modifié)
EOF
  while true; do
    printf '  Votre choix (0-4) : '
    local ch
    IFS= read -r ch || break
    case "$ch" in
      1)
        printf "  Emplacement de l'assistant ? "
        local p
        IFS= read -r p || p=""
        [ -n "$p" ] && act_pointer "$p"
        ;;
      2)
        printf '  Dossiers à chercher ? (séparés par espaces) '
        local s
        IFS= read -r s || s=""
        # shellcheck disable=SC2086
        [ -n "$s" ] && act_chercher $s
        ;;
      3) act_installer "" ;;
      4) act_opencode ;;
      0) break ;;
      *) : ;;
    esac
  done
}

# --- Dispatch ────────────────────────────────────────────────────────────────
c="${1:-}"
case "$c" in
  "") show_menu ;;
  pointer) act_pointer "${2:-}" ;;
  chercher) shift; act_chercher "$@" ;;
  installer)
    shift
    d=""
    while [ $# -gt 0 ]; do
      case "$1" in
        -dossier) d="${2:-}"; shift 2 ;;
        *) d="$1"; shift ;;
      esac
    done
    act_installer "$d" ;;
  opencode) act_opencode ;;
  menu) show_menu ;;
  "\?") show_menu ;;
  *) echo "Action inconnue : $c"; show_menu ;;
esac
