#!/usr/bin/env bash
# assistant.sh — assistant-projet-pm2 : ENTRY-POINT NATIF (déterministe, sans IA, sans dépendance)
# Principe : tout ce qui est faisable sans IA se fait sans IA.
#   - l'IA (l'agent opencode) n'intervient QUE pour : conduire (mode B), écouter (mode C), décider (add-ons).
#   - le reste (trouver les projets, classer, lire le frontmatter, déployer) est déterministe → ici.
#
# ARCHITECTURE (WP-0025) : le projet est MINCE.
#   - la data = projet.md, 01..05, _meta (le fruit du travail) — elle voyage (sync chez un tiers).
#   - l'outillage = ce repo (le « bundle ») : moteur, protocole, templates, checklists, harness opencode.
#   - la config de connexion = _meta/registry/connexions.md (partagée, voyage) + connexions.local.md (machine).
#   - le bootstrap (bootstrap.sh, dans le projet) rétablit le bundle SANS IA : pointer/chercher/installer,
#     en annonçant + confirmant avant chaque action, puis propose le harness opencode.
#
# Usage : ./assistant.sh <cmd> [args]      (Windows : .\assistant.ps1 <cmd> [args])
#   scan               liste les projets des racines (assistés / pourraient / sans signal)
#   statut <projet>    phase + gate + avancement d'un projet (sans argument : le projet courant, ou la liste)
#   liste              les projets (nom + phase + gate) - depuis le kit ou les racines
#   new <nom> [racine] crée un projet MINCE (data + config + lanceur mince + bootstrap)
#   add <dossier>      ajoute l'assistant (mince) à un projet existant (jamais d'écrasement)
#   sync [--force-harness]  (depuis un projet) vérifie le bundle (version) + le harness opencode (remplace update)
#   bootstrap          (depuis un projet) (ré)installe le bundle : pointer / chercher / installer + harness
#   remark <texte>     (depuis un projet) journal des remarques au vol (remontée au projet assistant)
#   commence <nom>     → l'agent : ouvre opencode dans le projet (handoff)
#   menu / ?           ce menu
#
# La logique de scan/statut vit ICI (source unique) : les commandes opencode /ap-scan-projets /ap-statut-projet l'appellent.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# conf_path <p> : chemin au format lisible par les 2 moteurs (Windows : C:/... ; POSIX : tel quel).
# Sur Git Bash, pwd retourne /c/... ou /tmp/... (MSYS) ; cygpath -w donne C:\... -> normalisé en /.
# Les chemins écrits dans connexions.local.md / opencode.json DOIVENT être dans ce format :
# le lanceur PS, le lanceur bash et opencode doivent tous les lire sur la même machine.
conf_path() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) cygpath -w "$1" 2>/dev/null | tr '\\' '/' ;;
    *) printf '%s' "$1" ;;
  esac
}
REG_DIR="$ROOT/_meta/registry"
OLD_CONN="$REG_DIR/connexions.md"   # registre ANCIEN (fallback de transition)

# Config machine à la racine du kit (WP-0017) : 1er des 3 noms qui existe.
CONFIG=""
for c in .assistant.config assistant.config assistant.config.md; do
  [ -f "$ROOT/$c" ] && { CONFIG="$ROOT/$c"; break; }
done

# Nom du dossier méta (défaut _meta) — lu de la config s'il existe.
get_meta_folder() {
  if [ -n "$CONFIG" ] && [ -f "$CONFIG" ]; then
    local v
    v="$(grep -m1 '^[[:space:]]*meta_folder[[:space:]]*=' "$CONFIG" 2>/dev/null | sed -E 's/^[[:space:]]*meta_folder[[:space:]]*=[[:space:]]*//' | sed 's/[[:space:]]*$//')"
    [ -n "$v" ] && { printf '%s' "$v"; return; }
  fi
  printf '_meta'
}
META="$(get_meta_folder)"

# ── Helpers ─────────────────────────────────────────────────────────────────
get_racines() {
  local line=""
  # Source principale : la config (racines = ...)
  if [ -n "$CONFIG" ]; then
    line="$(grep -m1 '^[[:space:]]*racines[[:space:]]*=' "$CONFIG" 2>/dev/null | sed -E 's/^[[:space:]]*racines[[:space:]]*=[[:space:]]*//')"
  fi
  # Fallback de transition : le registre ancien (- racines: ...)
  if [ -z "$line" ] && [ -f "$OLD_CONN" ]; then
    line="$(grep -m1 '^\s*- racines:' "$OLD_CONN" 2>/dev/null | sed -E 's/^[[:space:]]*- racines:[[:space:]]*//')"
  fi
  [ -z "$line" ] && { echo ""; return; }
  [ "$line" = "aucune" ] && { echo ""; return; }
  # Chaque entrée : "<chemin> (<qualificatif>)" ; le chemin ne contient pas de "(".
  printf '%s' "$line" | grep -oE '(^|; )[^()]* \(' | sed -E 's/^; //; s/ \($//' | sed 's/^ *//; s/ *$//' | grep -v '^$'
}

get_signaux() { # get_signaux <dir> → un signal par ligne
  local d="$1"
  [ -d "$d/.git" ] && echo ".git"
  for f in package.json pyproject.toml requirements.txt pom.xml build.gradle go.mod Cargo.toml Dockerfile README.md; do
    [ -f "$d/$f" ] && echo "$f"
  done
  [ -d "$d/src" ] && echo "src/"
  [ -d "$d/$META" ] && echo "$META/"
  return 0
}

find_project() { # find_project <nom> → chemin du projet (projet.md OU <meta>/fiche.md) ou rien
  local name="$1" c
  c="$ROOT/$name"; { [ -f "$c/projet.md" ] || [ -f "$c/$META/fiche.md" ]; } && { cd "$c" && pwd; return; }
  c="$(pwd)/$name"; { [ -f "$c/projet.md" ] || [ -f "$c/$META/fiche.md" ]; } && { cd "$c" && pwd; return; }
  local r
  while IFS= read -r r; do
    [ -z "$r" ] && continue
    c="$r/$name"
    { [ -f "$c/projet.md" ] || [ -f "$c/$META/fiche.md" ]; } && { cd "$c" && pwd; return; }
  done < <(get_racines)
  return 1
}

# Dépôt MINCE du projet (WP-0025) : la data + la config de connexion + le lanceur mince + le bootstrap.
# L'outillage (protocole, templates, checklists, docs, tools, .opencode) NE PART PAS : il vit
# dans le bundle (ce repo), pointé par la config. $nom = nom du projet. $skipfile = fichier de sortie.
# (un fichier et pas une variable : deploy_kit est appelé via $(...) = sous-shell, les variables globales y sont perdues)
# Jamais d'écrasement : un fichier/dossier pré-existant est signalé et ignoré.
deploy_kit() {
  local target="$1" nom="$2" skipfile="$3"
  local date; date="$(date +%F)"
  local copied=0; local skipped=()

  # 1) projet.md : copie du template avec pré-remplissage (nom + date), sans écraser
  #    (sed simple et déterministe — même logique que le .ps1 : projet, créé, titre, <AAAA-MM-JJ>)
  if [ -e "$target/projet.md" ]; then skipped+=("projet.md")
  else
    nomsed="$(printf '%s' "$nom" | sed -e 's/[\/&\\]/\\&/g')"   # sécurise / & \
    sed -e "s/^projet: \"\"/projet: \"${nomsed}\"/" \
        -e "s/^créé: \"\"/créé: ${date}/" \
        -e "s/^# <Nom du projet>$/# ${nomsed}/" \
        -e "s/<AAAA-MM-JJ>/${date}/g" \
        "$ROOT/projet.md" > "$target/projet.md"
    copied=$((copied+1))
  fi

  # 2) Dossiers de phases (01..05) VIDES : la data s'y écrit, l'outillage n'y vit plus.
  local d base t
  for d in "$ROOT"/*; do
    [ -d "$d" ] || continue
    base="$(basename "$d")"
    case "$base" in
      0*) ;;  # dossier de phase "01 Lancement" etc.
      *) continue ;;
    esac
    t="$target/$base"
    if [ -e "$t" ]; then skipped+=("$base/")
    else
      mkdir -p "$t"
      : > "$t/.gitkeep"
      copied=$((copied+1))
    fi
  done

  # 3) dossier méta NEUF (pas celui du kit) + la config de connexion (partagée + machine)
  local meta="$META"
  if [ -e "$target/$meta" ]; then
    skipped+=("$meta/ (pré-existant, non touché)")
  else
    mkdir -p "$target/$meta/backlog" "$target/$meta/logs" "$target/$meta/report" "$target/$meta/registry"
    sed -e "s/{{NOM}}/$nom/g" -e "s/{{DATE}}/$date/g" \
      "$ROOT/tools/templates/fiche-projet.md" > "$target/$meta/fiche.md"
    [ -f "$ROOT/$meta/backlog/README.md" ] && cp "$ROOT/$meta/backlog/README.md" "$target/$meta/backlog/README.md"
    [ -f "$ROOT/$meta/registry/README.md" ] && cp "$ROOT/$meta/registry/README.md" "$target/$meta/registry/README.md"
    # config de connexion PARTAGÉE (voyage avec le projet)
    local git_url
    git_url="$(git -C "$ROOT" remote get-url origin 2>/dev/null | head -n1 || true)"
    {
      echo "# registry/connexions.md - config de connexion PARTAGÉE (voyage avec le projet - WP-0025)"
      echo "# assistant_git : le repo assistant (pour le bootstrap : installer)"
      echo "# assistant_ref : latest = la dernière version du bundle (ou <version> -> versions/<version>/)"
      echo "assistant_git: $git_url"
      echo "assistant_ref: latest"
      echo "meta_folder: $meta"
    } > "$target/$meta/registry/connexions.md"
    # config de connexion MACHINE (gitignorée, écrite par le bootstrap - pré-remplie : le bundle est sur CETTE machine)
    {
      echo "# registry/connexions.local.md - config de connexion MACHINE (gitignorée, écrite par le bootstrap)"
      echo "assistant_local: $(conf_path "$ROOT")"
    } > "$target/$meta/registry/connexions.local.md"
    : > "$target/$meta/logs/.gitkeep"
    : > "$target/$meta/report/.gitkeep"
    copied=$((copied+1))
  fi

  # 4) .gitignore (template projet : gitignore la partie machine de la config + le harness)
  if [ -e "$target/.gitignore" ]; then skipped+=(".gitignore")
  else cp "$ROOT/tools/templates/gitignore-projet.md" "$target/.gitignore"; copied=$((copied+1)); fi

  # 5) Lanceur mince + bootstrap (les 2 : PS + bash, un par OS)
  local pair dstname srcname
  for pair in "assistant.ps1 lanceur-assistant.ps1" "assistant.sh lanceur-assistant.sh" "bootstrap.ps1 bootstrap-assistant.ps1" "bootstrap.sh bootstrap-assistant.sh"; do
    dstname="${pair%% *}"
    srcname="${pair#* }"
    if [ -e "$target/$dstname" ]; then skipped+=("$dstname")
    else cp "$ROOT/tools/templates/$srcname" "$target/$dstname"; copied=$((copied+1)); fi
  done

  # 6) opencode.json : le harness pointe le protocole DANS LE BUNDLE (chemin absolu, en /)
  if [ -e "$target/opencode.json" ]; then skipped+=("opencode.json")
  else
    printf '{\n  "$schema": "https://opencode.ai/config.json",\n  "default_agent": "assistant-projet",\n  "instructions": ["%s/AGENT-projet.md", "projet.md"]\n}\n' "$(conf_path "$ROOT")" > "$target/opencode.json"
    copied=$((copied+1))
  fi

  if [ ${#skipped[@]} -gt 0 ]; then printf '%s\n' "${skipped[@]}" > "$skipfile"; else : > "$skipfile"; fi
  echo "$copied"
}

# ── Commandes ───────────────────────────────────────────────────────────────
# Resync du HARNESS opencode (remplace le resync du kit - WP-0025) :
# zéro écrasement, seuls les fichiers ABSENTS du projet sont ajoutés.
# deploy_harness <projet> <bundle> <meta> → un chemin ajouté par ligne (relatif au projet)
deploy_harness() {
  local target="$1" bundle="$2" meta="$3"
  local sub src dst rel mdir
  # 1) .opencode/agent + command (fichiers manquants, récursif)
  for sub in agent command; do
    src="$bundle/.opencode/$sub"
    [ -d "$src" ] || continue
    dst="$target/.opencode/$sub"
    mkdir -p "$dst"
    local sl="${src%/}"
    find "$src" -type f | while IFS= read -r m; do
      rel="${m#"$sl"/}"
      if [ ! -e "$dst/$rel" ]; then
        mdir="$(dirname "$dst/$rel")"
        mkdir -p "$mdir"
        cp "$m" "$dst/$rel"
        printf '.opencode/%s/%s\n' "$sub" "$rel"
      fi
    done
  done
  # 2) opencode.json (créé si absent - JAMAIS écrasé : il pointe le bundle de CETTE machine)
  local oc="$target/opencode.json"
  if [ ! -e "$oc" ]; then
    printf '{\n  "$schema": "https://opencode.ai/config.json",\n  "default_agent": "assistant-projet",\n  "instructions": ["%s/AGENT-projet.md", "projet.md"]\n}\n' "$(conf_path "$bundle")" > "$oc"
    printf 'opencode.json\n'
  fi
  # 3) .gitignore : les lignes machine (append, jamais d'écrasement)
  local gi="$target/.gitignore"
  if [ ! -e "$gi" ]; then
    if [ -f "$bundle/tools/templates/gitignore-projet.md" ]; then
      cp "$bundle/tools/templates/gitignore-projet.md" "$gi"
      printf '.gitignore\n'
    fi
  else
    local added=""
    grep -qE '^[[:space:]]*\.opencode/' "$gi" || added="${added}.opencode/
"
    grep -qF "$meta/registry/connexions.local.md" "$gi" || added="${added}${meta}/registry/connexions.local.md
"
    if [ -n "$added" ]; then
      printf '%s' "$added" >> "$gi"
      printf '.gitignore (append)\n'
    fi
  fi
  return 0
}

# cmd_sync (WP-0025 - remplace update) : le projet est MINCE - il n'y a plus de copie locale
# de l'outillage à resynchroniser. sync vérifie : le bundle (référence + version + arrière
# local git, best effort), la présence du lanceur mince + du bootstrap (ajout des absents),
# et le harness opencode (ajout des manquants ; --force-harness pour régénérer).
cmd_sync() {
  local force="${1:-}"
  local p; p="$(pwd)"
  if [ ! -f "$p/projet.md" ] && [ ! -f "$p/$META/fiche.md" ]; then
    echo "Tu n'es pas dans un projet (relancer depuis le dossier d'un projet — avec projet.md ou $META/)."
    return
  fi
  # Config de connexion du projet (partagée + machine) - même logique que le lanceur mince.
  local meta="$META"
  local shared="$p/$meta/registry/connexions.md"
  local localf="$p/$meta/registry/connexions.local.md"
  local mfcfg; mfcfg="$(grep -m1 -E '^[[:space:]]*meta_folder:' "$shared" 2>/dev/null | sed -E 's/^[[:space:]]*meta_folder:[[:space:]]*//')"
  if [ -n "$mfcfg" ]; then
    meta="$mfcfg"
    shared="$p/$meta/registry/connexions.md"
    localf="$p/$meta/registry/connexions.local.md"
  fi
  local ref; ref="$(grep -m1 -E '^[[:space:]]*assistant_ref:' "$shared" 2>/dev/null | sed -E 's/^[[:space:]]*assistant_ref:[[:space:]]*//')"
  [ -z "$ref" ] && ref="latest"
  local b; b="$(grep -m1 -E '^[[:space:]]*assistant_local:' "$localf" 2>/dev/null | sed -E 's/^[[:space:]]*assistant_local:[[:space:]]*//')"
  if [ "$ref" != "latest" ] && [ -n "$b" ] && [ -d "$b/versions" ]; then b="$b/versions/$ref"; fi
  if [ -z "$b" ] || [ ! -f "$b/assistant.sh" ] || [ ! -f "$b/.assistant.version" ]; then
    echo ""
    if [ -n "$b" ]; then echo "Pas de bundle valide sur cette machine (assistant_local : $b)."
    else echo "Pas de bundle valide sur cette machine (assistant_local : (non défini))."; fi
    echo "  -> lancer le bootstrap :  ./bootstrap.sh   (pointer / chercher / installer)"
    return
  fi
  echo ""
  echo "sync - projet : $p"
  echo "  Bundle  : $b"
  local ver; ver="$(head -n1 "$b/.assistant.version" 2>/dev/null)"
  printf '  Version : %s   (référence : %s)\n' "${ver:-?}" "$ref"
  # Si le bundle est un repo git local : arrière local vs upstream (sans réseau, best effort).
  if [ -d "$b/.git" ]; then
    local behind
    behind="$(git -C "$b" rev-list --count "HEAD..@{u}" 2>/dev/null | head -n1 || true)"
    case "$behind" in
      ''|*[!0-9]*) : ;;
      0) : ;;
      *) echo "  NB : le bundle est $behind commit(s) arrière de son upstream local (git pull possible - c'est à toi de le faire)." ;;
    esac
  fi
  # 2) Présence du lanceur mince + du bootstrap (ajout des absents seulement).
  local f src addedfiles=""
  for f in assistant.ps1 assistant.sh bootstrap.ps1 bootstrap.sh; do
    case "$f" in
      assistant.ps1) src="lanceur-assistant.ps1" ;;
      assistant.sh) src="lanceur-assistant.sh" ;;
      bootstrap.ps1) src="bootstrap-assistant.ps1" ;;
      bootstrap.sh) src="bootstrap-assistant.sh" ;;
    esac
    if [ -f "$b/tools/templates/$src" ] && [ ! -e "$p/$f" ]; then
      cp "$b/tools/templates/$src" "$p/$f"
      addedfiles="${addedfiles}${addedfiles:+, }$f"
    fi
  done
  [ -n "$addedfiles" ] && echo "  Lanceur : ajoutés (absents) - $addedfiles"
  # 3) Le harness opencode
  local ocagent="$p/.opencode/agent/assistant-projet.md"
  local ocjson="$p/opencode.json"
  local need=0
  { [ ! -f "$ocagent" ] || [ ! -f "$ocjson" ]; } && need=1
  if [ "$force" = "--force-harness" ]; then
    echo "  Harness : --force-harness -> régénération depuis le bundle (remplace .opencode/agent+command + opencode.json)."
    printf '  Confirmer ? (o/n) '
    local a; IFS= read -r a || a=""
    case "$a" in
      o|O|oui|Oui|yes|YES|y|Y)
        rm -rf "$p/.opencode/agent" "$p/.opencode/command" "$ocjson"
        local out; out="$(deploy_harness "$p" "$b" "$meta")"
        if [ -n "$out" ]; then
          while IFS= read -r x; do [ -n "$x" ] && printf '    + %s\n' "$x"; done <<< "$out"
        fi
        ;;
      *) echo "  Annulé." ;;
    esac
  elif [ $need -eq 1 ]; then
    echo "  Harness : incomplet/absent (à ajouter, zéro écrasement) :"
    [ -f "$ocagent" ] || echo "    + .opencode/agent/ + .opencode/command/  (copies du bundle)"
    [ -f "$ocjson" ] || echo "    + opencode.json  (instructions -> AGENT-projet.md du bundle + projet.md)"
    echo "    + .gitignore  (lignes machine, en append)"
    printf '  Déployer ? (o/n) '
    local a2; IFS= read -r a2 || a2=""
    case "$a2" in
      o|O|oui|Oui|yes|YES|y|Y)
        local out2; out2="$(deploy_harness "$p" "$b" "$meta")"
        if [ -n "$out2" ]; then
          while IFS= read -r x; do [ -n "$x" ] && printf '    + %s\n' "$x"; done <<< "$out2"
        fi
        ;;
      *) echo "  Passé - à refaire :  ./assistant.sh sync" ;;
    esac
  else
    echo "  Harness : déployé."
  fi
  echo ""
  echo "  sync OK."
  if [ "$ref" = "latest" ]; then
    echo "  (Pour figer une version : assistant_ref: <version> dans $shared - le projet migre quand il le sent.)"
  fi
}

# cmd_bootstrap (WP-0025) : lance le bootstrap DU PROJET (rétablit le bundle sans IA :
# pointer / chercher / installer + le harness opencode).
cmd_bootstrap() {
  local p; p="$(pwd)"
  if [ ! -f "$p/projet.md" ] && [ ! -f "$p/$META/fiche.md" ]; then
    echo "Tu n'es pas dans un projet (relancer depuis le dossier d'un projet)."
    return
  fi
  if [ -f "$p/bootstrap.sh" ]; then
    bash "$p/bootstrap.sh" "$@"
  else
    echo "bootstrap.sh absent dans $p (projet incomplet - relancer l'add sur ce dossier)."
  fi
}

cmd_scan() {
  local roots
  roots="$(get_racines)"
  if [ -z "$(echo "$roots" | tr -d '[:space:]')" ]; then
    echo "Aucune racine définie."
    echo "  -> relancer l'install (install.sh) pour définir les racines, puis relancer le scan."
    return
  fi
  local tk=0 tp=0 tpo=0 tpl=0 r
  while IFS= read -r r; do
    [ -z "$r" ] && continue
    echo ""; echo "=== $r ==="
    if [ ! -d "$r" ]; then echo "  (racine absente)"; continue; fi
    local mi_n=0 le_n=0 p_n=0 po_n=0 pl_n=0
    local mince="" legacy="" parts="" pourrs="" plain=""
    local d
    while IFS= read -r d; do
      [ -z "$d" ] && continue
      local n; n="$(basename "$d")"
      local hasP=0 hasA=0 hasM=0
      [ -f "$d/projet.md" ] && hasP=1
      [ -f "$d/AGENT-projet.md" ] && hasA=1
      [ -d "$d/$META" ] && hasM=1
      if [ $hasP -eq 1 ] && [ $hasM -eq 1 ]; then
        # Assiste (WP-0025) : data (projet.md) + meta.
        # "mince" = l'outillage est dans le bundle ; "copie complete" = legacy (pre-WP-0025).
        if [ $hasA -eq 1 ]; then
          legacy="${legacy}${n}
"; le_n=$((le_n+1))
        else
          mince="${mince}${n}
"; mi_n=$((mi_n+1))
        fi
      elif [ $hasP -eq 1 ] || [ $hasA -eq 1 ] || [ $hasM -eq 1 ]; then
        parts="${parts}${n}
"; p_n=$((p_n+1))
      else
        local sig; sig="$(get_signaux "$d" | tr '\n' ' ')"
        if [ -n "$sig" ]; then
          local s4; s4="$(echo "$sig" | awk '{cnt=NF; if(cnt>4)cnt=4; for(i=1;i<=cnt;i++) printf "%s%s", $i, (i<cnt?", ":""); print ""}')"
          pourrs="${pourrs}${n} :: ${s4}
"; po_n=$((po_n+1))
        else
          plain="${plain}${n}
"; pl_n=$((pl_n+1))
        fi
      fi
    done < <(find "$r" -mindepth 1 -maxdepth 1 -type d ! -name '.*' 2>/dev/null | sort)

    if [ $((mi_n+le_n)) -gt 0 ]; then
      echo "  [Assistés]"
      while IFS= read -r n; do
        [ -z "$n" ] && continue
        local fm_phase fm_gate
        fm_phase="$(awk '/^---$/{c++;next} c==1{if(/^phase:/){sub(/^phase:[ \t]*/,""); gsub(/^"|"$/,""); print; exit}}' "$r/$n/projet.md")"
        fm_gate="$(awk '/^---$/{c++;next} c==1{if(/^gate_suivant:/){sub(/^gate_suivant:[ \t]*/,""); gsub(/^"|"$/,""); print; exit}}' "$r/$n/projet.md")"
        printf '    + %s  -  phase %s, gate %s   (mince)\n' "$n" "${fm_phase:-?}" "${fm_gate:-?}"
      done <<< "$mince"
      while IFS= read -r n; do
        [ -z "$n" ] && continue
        local fm_phase fm_gate
        fm_phase="$(awk '/^---$/{c++;next} c==1{if(/^phase:/){sub(/^phase:[ \t]*/,""); gsub(/^"|"$/,""); print; exit}}' "$r/$n/projet.md")"
        fm_gate="$(awk '/^---$/{c++;next} c==1{if(/^gate_suivant:/){sub(/^gate_suivant:[ \t]*/,""); gsub(/^"|"$/,""); print; exit}}' "$r/$n/projet.md")"
        printf '    + %s  -  phase %s, gate %s   (copie complete, pre-WP-0025)\n' "$n" "${fm_phase:-?}" "${fm_gate:-?}"
      done <<< "$legacy"
    fi
    if [ $p_n -gt 0 ]; then
      echo "  [À compléter]"
      while IFS= read -r n; do
        [ -z "$n" ] && continue
        local hP=0 hA=0 hM=0
        [ -f "$r/$n/projet.md" ] && hP=1
        [ -f "$r/$n/AGENT-projet.md" ] && hA=1
        [ -d "$r/$n/$META" ] && hM=1
        local detail="partiel (projet.md + $META/ attendus)"
        if [ $hM -eq 1 ] && [ $hP -eq 0 ]; then detail="projet sans code (ne contient que $META) -> assistant add"
        elif [ $hP -eq 1 ] && [ $hM -eq 0 ]; then detail="manque $META/ -> assistant add"
        elif [ $hA -eq 1 ] && [ $hP -eq 0 ]; then detail="copie du kit sans projet.md -> assistant add"
        fi
        printf '    ~ %s  -  %s\n' "$n" "$detail"
      done <<< "$parts"
    fi
    if [ $po_n -gt 0 ]; then
      echo "  [Pourraient (signaux)]"
      while IFS= read -r line; do
        [ -z "$line" ] && continue
        local nn ss; nn="${line%% :: *}"; ss="${line##* :: }"
        printf '    ? %s  -  %s\n' "$nn" "$ss"
      done <<< "$pourrs"
    fi
    if [ $pl_n -gt 0 ]; then
      echo "  [Sans signal]"
      while IFS= read -r n; do [ -n "$n" ] && printf '    . %s\n' "$n"; done <<< "$plain"
    fi
    local total=$((mi_n+le_n+p_n+po_n+pl_n))
    printf '  -> %d dossiers : %d assistés, %d à compléter, %d pourraient, %d sans signal\n' "$total" "$((mi_n+le_n))" "$p_n" "$po_n" "$pl_n"
    tk=$((tk+mi_n+le_n)); tp=$((tp+p_n)); tpo=$((tpo+po_n)); tpl=$((tpl+pl_n))
  done <<< "$roots"
  echo ""
  printf 'Total : %d dossiers - %d assistés, %d à compléter, %d pourraient, %d sans signal\n' "$((tk+tp+tpo+tpl))" "$tk" "$tp" "$tpo" "$tpl"
  echo "Travailler sur un projet :  assistant commence <nom>   (ou, dans opencode : « commence le projet <nom> »)"
  echo "Ajouter l'assistant (mince) à un dossier :  assistant add <dossier>   (jamais d'écrasement)"
}

# liste_projects : la liste des projets (nom + phase + gate) - WP-0024.
liste_projects() {
  local seen="" rows=""
  local r d src fm ph gt nom
  while IFS= read -r r; do
    [ -n "$r" ] || continue
    [ -d "$r" ] || continue
    for d in "$r"/*/; do
      [ -d "$d" ] || continue
      d="${d%/}"
      { [ -f "$d/projet.md" ] || [ -f "$d/$META/fiche.md" ]; } || continue
      case "$seen" in *"|$d|"*) continue ;; esac
      seen="$seen|$d|"
      src="$d/projet.md"; [ -f "$src" ] || src="$d/$META/fiche.md"
      ph="$(awk '/^---$/{c++;next} c==1{if(/^phase:/){sub(/^phase:[ \t]*/,""); gsub(/^"|"$/,""); print; exit}}' "$src")"
      gt="$(awk '/^---$/{c++;next} c==1{if(/^gate_suivant:/){sub(/^gate_suivant:[ \t]*/,""); gsub(/^"|"$/,""); print; exit}}' "$src")"
      nom="$(basename "$d")"
      rows="$rows$(printf '    %-28s  [%s / %s]\n' "$nom" "$ph" "$gt")
"
    done
  done < <(get_racines)
  echo ""
  if [ -z "$rows" ]; then echo "Aucun projet trouvé dans les racines."; return; fi
  local n=0 line
  while IFS= read -r line; do [ -n "$line" ] && n=$((n+1)); done <<< "$rows"
  printf '  Projets (%d) :  statut <nom>  (le nom = le nom du dossier)\n' "$n"
  printf '%s' "$rows"
}

cmd_statut() {
  local name="$1"
  local p=""
  if [ -z "$name" ]; then
    # Sans argument : le projet du dossier courant (si c'en est un) — pour le /ap-statut-projet depuis le projet.
    # Hors projet : la liste des projets (WP-0024).
    if [ -f "$(pwd)/projet.md" ] || [ -f "$(pwd)/$META/fiche.md" ]; then p="$(pwd)"
    else liste_projects; return; fi
  else
    p="$(find_project "$name")"
    if [ -z "$p" ]; then
      echo "Projet '$name' introuvable (cherche dans le kit, le dossier courant et les racines)."
      liste_projects
      return
    fi
  fi
  # Source de vérité : projet.md sinon <meta>/fiche.md (projet sans code — WP-0019).
  local src="$p/projet.md"
  [ -f "$src" ] || src="$p/$META/fiche.md"
  echo ""; echo "=== Statut : $(basename "$p") ==="
  echo "  (source : $(basename "$src"))"
  local phase gate sp op spon bm cp moe
  phase="$(awk '/^---$/{c++;next} c==1{if(/^phase:/){sub(/^phase:[ \t]*/,""); gsub(/^"|"$/,""); print; exit}}' "$src")"
  gate="$(awk '/^---$/{c++;next} c==1{if(/^gate_suivant:/){sub(/^gate_suivant:[ \t]*/,""); gsub(/^"|"$/,""); print; exit}}' "$src")"
  printf '  Phase : %s   |   Gate suivant : %s\n' "${phase:-?}" "${gate:-?}"
  # Pédagogie (WP-0022) : phases sautées = signalées (la table d'avancement = source de vérité).
  local curp="Lan"
  case "$phase" in Plan*) curp="Pla";; Ex*) curp="Ex";; Cl*) curp="Cl";; esac
  local rows; rows="$(awk -F'|' '/^## 3\./{in3=1;next} in3 && /^## /{exit} in3 {
      n=split($0, cc, "|");
      if (n < 6) next;
      name=cc[2]; gate=cc[5];
      gsub(/[*]/, "", name); gsub(/^ +| +$/, "", name);
      gsub(/^ +| +$/, "", gate);
      if (name == "Phase" || name ~ /^-+$/) next;
      if (gate != "") print name "\t" gate
    }' "$src")"
  local idx=0 k=0 name gate
  while IFS=$'\t' read -r name gate; do
    [ -n "$name" ] || continue
    k=$((k+1))
    case "$name" in ${curp}*) idx=$k ;; esac
  done <<< "$rows"
  if [ "$idx" -gt 1 ]; then
    local j=0 sautees=""
    while IFS=$'\t' read -r name gate; do
      [ -n "$name" ] || continue
      j=$((j+1))
      if [ "$j" -lt "$idx" ]; then
        case "$gate" in
          "☑"*|✅*) : ;;
          "—"*) : ;;
          *) sautees="${sautees:+$sautees, }$name" ;;
        esac
      fi
    done <<< "$rows"
    [ -n "$sautees" ] && printf '  Sautees : %s   (gate non vert - a combler par maitrise, pas par dehabitude)\n' "$sautees"
  fi
  spon="$(awk -F': *' '/^---$/{c++;next} c==1{if(/^sponsor:/){print $2; exit}}' "$src" | sed 's/^"//;s/"$//')"
  bm="$(awk -F': *' '/^---$/{c++;next} c==1{if(/^bm:/){print $2; exit}}' "$src" | sed 's/^"//;s/"$//')"
  cp2="$(awk -F': *' '/^---$/{c++;next} c==1{if(/^cp:/){print $2; exit}}' "$src" | sed 's/^"//;s/"$//')"
  moe="$(awk -F': *' '/^---$/{c++;next} c==1{if(/^moe:/){print $2; exit}}' "$src" | sed 's/^"//;s/"$//')"
  local roles=""
  [ -n "$spon" ] && roles="sponsor: $spon"
  [ -n "$bm" ] && roles="${roles:+$roles  |  }bm: $bm"
  [ -n "$cp2" ] && roles="${roles:+$roles  |  }cp: $cp2"
  [ -n "$moe" ] && roles="${roles:+$roles  |  }moe: $moe"
  if [ -n "$roles" ]; then printf '  Rôles   : %s\n' "$roles"; else echo "  Rôles   : (non identifiés)"; fi
  sp="$(awk -F': *' '/^---$/{c++;next} c==1{if(/^sp_project:/){print $2; exit}}' "$src" | sed 's/^"//;s/"$//')"
  op="$(awk -F': *' '/^---$/{c++;next} c==1{if(/^op_id:/){print $2; exit}}' "$src" | sed 's/^"//;s/"$//')"
  local tix=""
  [ -n "$sp" ] && tix="SP: $sp"
  [ -n "$op" ] && tix="${tix:+$tix  |  }OP: $op"
  if [ -n "$tix" ]; then printf '  Tickets : %s\n' "$tix"; else echo "  Tickets : (aucune connexion active)"; fi
  echo "  Avancement :"
  awk '/^## 3\./{in3=1;next} in3 && /^## /{exit} in3 && /^[[:space:]]*\|/{print "    " $0}' "$src"
}

cmd_new() {
  local name="$1" rooto="$2" doc="$3"
  if [ -z "$name" ]; then echo "Usage : assistant new <nom> [racine] [-doc]"; return; fi
  local rroot="$rooto"
  if [ -z "$rroot" ]; then
    local first; first="$(get_racines | head -n1)"
    if [ -z "$first" ]; then echo "Aucune racine définie : passe une racine (assistant new <nom> <racine>) ou lance install."; return; fi
    rroot="$first"
  fi
  local target="$rroot/$name"
  if [ -e "$target" ]; then echo "'$target' existe déjà → rien n'est créé ni écrasé."; return; fi
  if [ "$doc" = "1" ]; then
    # Projet sans code (WP-0019) : SEUL le dossier méta est créé (fiche + squelette), pas le kit.
    local date; date="$(date +%F)"
    mkdir -p "$target/$META/backlog" "$target/$META/logs" "$target/$META/report" "$target/$META/registry"
    sed -e "s/{{NOM}}/$name/g" -e "s/{{DATE}}/$date/g" \
      "$ROOT/tools/templates/fiche-projet.md" > "$target/$META/fiche.md"
    : > "$target/$META/logs/.gitkeep"
    : > "$target/$META/report/.gitkeep"
    echo ""; echo "Projet documentaire créé (sans kit) : $target"
    echo "  $META/ à l'état (fiche + squelette) — le repo ne contient que la couche méta."
    echo ""; echo "  Plus tard, si le kit complet est utile : assistant add <nom>  (zéro écrasement, $META conservé)"
    echo "  Prochain pas :"
    echo "    avec l'agent : assistant add <nom>  puis  cd $target  +  opencode  (test : il annonce la phase)"
    echo "    sans l'agent : ouvrir $META/fiche.md et travailler le markdown directement"
    return
  fi
  mkdir -p "$target"
  local skipfile; skipfile="$(mktemp)"
  local copied
  copied="$(deploy_kit "$target" "$name" "$skipfile")"
  local nsk; nsk="$(grep -c . "$skipfile" 2>/dev/null || true)"
  echo ""; echo "Projet créé : $target"
  echo "  $copied éléments copiés, ${nsk:-0} ignorés."
  while IFS= read -r s; do [ -n "$s" ] && echo "  - ignoré (pré-existant) : $s"; done < "$skipfile"
  rm -f "$skipfile"
  echo ""
  echo "  Le projet est MINCE : la doc (projet.md, 01..05, _meta) + la config de connexion + le lanceur + le bootstrap."
  echo "  L'outillage (protocole, templates, checklists, harness) vit dans le bundle (le repo assistant), pointé par $META/registry/connexions.md."
  echo ""
  echo "  Méthode PM2 : 4 phases (Lancement → Planification → Exécution → Clôture), chacune clôturée par un gate (checklist)."
  echo "  On attaque par la Lancement. Une phase peut être sautée, mais le statut le signalera ensuite — à faire par maîtrise ou curiosité."
  echo ""
  echo "  Prochain pas : aller dans le projet et lancer l'agent :"
  echo "    cd $target"
  echo "    opencode   (l'agent lit le protocole via opencode.json → annonce la phase + gate : C'EST LE TEST)"
  echo "  Puis tester :  /ap-statut-projet   (phase + gate + avancement)  -  et dire : « commence le projet »"
  echo "  Vérifier le bundle + le harness :  ./assistant.sh sync   (depuis le projet)"
  echo "  Une remarque sur le kit ? Note-la :  assistant remark '...'  (depuis le projet, remonte au projet assistant)"
  echo "  (ou, sans ouvrir opencode : assistant commence ${name})"
}

cmd_add() {
  local path="$1"
  if [ -z "$path" ]; then echo "Usage : assistant add <dossier>"; return; fi
  local target=""
  # Résolution : chemin absolu ou relatif au dossier courant ; sinon recherche sous chaque racine.
  if [ -d "$path" ]; then
    target="$(cd "$path" && pwd)"
  else
    local r
    while IFS= read -r r; do
      [ -n "$r" ] && [ -d "$r/$path" ] && { target="$(cd "$r/$path" && pwd)"; break; }
    done < <(get_racines)
  fi
  if [ -z "$target" ]; then echo "Dossier introuvable : $path (cherche le dossier courant + les racines) — pour un projet NEUF : assistant new <nom>"; return; fi
  if [ ! -f "$target/projet.md" ] && [ ! -f "$target/AGENT-projet.md" ]; then
    echo "Aucun marqueur de kit dans '$target' : ajout du kit dans un dossier vierge (OK)."
  fi
  local skipfile; skipfile="$(mktemp)"
  local copied
  copied="$(deploy_kit "$target" "$(basename "$target")" "$skipfile")"
  local nsk; nsk="$(grep -c . "$skipfile" 2>/dev/null || true)"
  echo ""; echo "Assistant ajouté (mince) : $target"
  echo "  $copied éléments copiés, ${nsk:-0} ignorés."
  while IFS= read -r s; do [ -n "$s" ] && echo "  - ignoré (pré-existant) : $s"; done < "$skipfile"
  rm -f "$skipfile"
  echo ""
  echo "  Le projet est MINCE : la doc (projet.md, 01..05, _meta) + la config de connexion + le lanceur + le bootstrap."
  echo "  L'outillage (protocole, templates, checklists, harness) vit dans le bundle (le repo assistant), pointé par $META/registry/connexions.md."
  echo ""
  echo "  Méthode PM2 : 4 phases (Lancement → Planification → Exécution → Clôture), chacune clôturée par un gate (checklist)."
  echo "  On attaque par la Lancement. Une phase peut être sautée, mais le statut le signalera ensuite — à faire par maîtrise ou curiosité."
  echo ""
  echo "  Prochain pas : aller dans le projet et lancer l'agent :"
  echo "    cd $target"
  echo "    opencode   (l'agent lit le protocole via opencode.json → annonce la phase + gate : C'EST LE TEST)"
  echo "  Puis tester :  /ap-statut-projet   (phase + gate + avancement)  -  et dire : « commence le projet »"
  echo "  Vérifier le bundle + le harness :  ./assistant.sh sync   (depuis le projet)"
  echo "  (ou, sans ouvrir opencode : assistant commence $(basename "$target"))"
}

cmd_commence() {
  local name="$1"
  if [ -z "$name" ]; then echo "Usage : assistant commence <nom>"; return; fi
  local p; p="$(find_project "$name")"
  if [ -z "$p" ]; then echo "Projet '$name' introuvable. Pour le créer : assistant new ${name}"; return; fi
  if ! command -v opencode >/dev/null 2>&1; then
    echo "opencode absent. L'installer : npm install -g opencode-ai  (puis relancer)"
    return
  fi
  echo ""; echo "Handoff vers l'agent : démarrage de '$name' dans opencode."
  echo "  (l'agent lit AGENT-projet.md ou _meta/fiche.md → annonce la phase → propose le prochain artefact)"
  ( cd "$p" && exec opencode )
}

# cmd_remark : journal des remarques au vol (WP-0021) — lancé DEPUIS le projet.
cmd_remark() {
  local msg="$1"
  local p; p="$(pwd)"
  if [ ! -f "$p/projet.md" ] && [ ! -f "$p/$META/fiche.md" ]; then
    echo "Tu n'es pas dans un projet (relancer depuis le dossier d'un projet — avec projet.md ou $META/)."
    return
  fi
  if [ -z "$msg" ]; then echo "Usage : assistant remark <ta remarque>"; return; fi
  local dir="$p/$META/registry"; mkdir -p "$dir"
  local f="$dir/remarques.md"
  local date; date="$(date +%F)"
  local line="- [$date] $msg"
  if [ -f "$f" ]; then
    printf '%s\n' "$line" >> "$f"
  else
    {
      echo "# remarques.md — journal des remarques au vol"
      echo "> Notes pendant l'usage (kit ou projet) ; l'agent propose de remonter au projet assistant les entrées marquées [pour l'assistant]."
    } > "$f"
    printf '%s\n' "$line" >> "$f"
  fi
  echo "Notée : $f"
  echo "  Pour une amélioration du kit : ajouter [pour l'assistant] dans l'entrée."
}

show_menu() {
  cat <<'EOF'

================================================
 assistant - menu  (sans IA : rapide, gratuit)
  PM2 : Lancement → Planification → Exécution → Clôture  (1 gate = 1 checklist par phase)
================================================
  -- Gérer les projets (depuis le kit ou les racines) --
  scan                 les projets des racines : assistés (mince / copie complète) / pourraient / sans signal
  liste                les projets (nom + phase + gate)
  statut <projet>      phase + gate + avancement d'un projet par son nom
  new <nom> [racine] [-doc]   créer un projet MINCE  (-doc = SEUL _meta, sans outillage : projet sans code)
  add <dossier>        ajouter l'assistant (mince) à un projet existant (jamais d'écrasement)
  install.sh           (re)initialiser la config transversale (racines, connexions)

  -- Dans un projet (depuis le dossier du projet) --
  statut               le statut du projet courant (sans argument)
  sync [--force-harness]  vérifier le bundle (version) + le harness opencode (remplace update - WP-0025)
  bootstrap          (ré)installer le bundle sur cette machine : pointer / chercher / installer + harness
  remark <texte>       journal des remarques au vol (remontée au projet assistant)
  commence <nom>       → L'AGENT : ouvre opencode dans le projet (conduite, mode B/C)
  menu / ?             ce menu

EOF
}

# ── Dispatch ────────────────────────────────────────────────────────────────
if [ $# -eq 0 ]; then show_menu; exit 0; fi
c="${1#/}"; c="${c/-/}"
case "$c" in
  scan) cmd_scan ;;
  statut) cmd_statut "${2:-}" ;;
  new)
    # arguments de new : <nom> [racine] [-doc] (l'ordre du flag importe peu)
    nname=""; nroot=""; ndoc=0
    shift
    for a in "$@"; do
      if [ "$a" = "-doc" ]; then ndoc=1; elif [ -z "$nname" ]; then nname="$a"; else nroot="$a"; fi
    done
    cmd_new "$nname" "$nroot" "$ndoc" ;;
  add) cmd_add "${2:-}" ;;
  liste) liste_projects ;;
  sync) cmd_sync "${2:-}" ;;
  update) echo "update est devenu sync (WP-0025 : projet mince - plus de copie locale à resynchroniser)"; cmd_sync "${2:-}" ;;
  bootstrap) shift; cmd_bootstrap "$@" ;;
  remark) cmd_remark "${2:-}" ;;
  commence) cmd_commence "${2:-}" ;;
  menu|"\?") show_menu ;;
  *) echo "Commande inconnue : $c"; show_menu ;;
esac