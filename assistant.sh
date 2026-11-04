#!/usr/bin/env bash
# assistant.sh — assistant-projet-pm2 : ENTRY-POINT NATIF (déterministe, sans IA, sans dépendance)
# Principe : tout ce qui est faisable sans IA se fait sans IA.
#   - l'IA (l'agent opencode) n'intervient QUE pour : conduire (mode B), écouter (mode C), décider (add-ons).
#   - le reste (trouver les projets, classer, lire le frontmatter, ajouter le kit) est déterministe → ici.
#
# Usage : ./assistant.sh <cmd> [args]      (Windows : .\assistant.ps1 <cmd> [args])
#   scan               liste les projets des racines (assistés / pourraient / sans signal)
#   statut <projet>    phase + gate + avancement d'un projet
#   new <nom> [racine] crée un projet (copie du kit + _meta neuf)
#   add <dossier>      ajoute le kit à un projet existant (jamais d'écrasement)
#   remark <texte>     (depuis un projet) journal des remarques au vol (remontee au projet assistant)
#   commence <nom>     → l'agent : ouvre opencode dans le projet (handoff)
#   menu / ?           ce menu
#
# La logique de scan/statut vit ICI (source unique) : les commandes opencode /ap-scan-projets /ap-statut-projet l'appellent.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

# Copie du kit dans $target. $nom = nom du projet. $skipfile = fichier de sortie (liste des ignorés).
# (un fichier et pas une variable : copy_kit est appelé via $(...) = sous-shell, les variables globales y sont perdues)
# Ne copie JAMAIS les données d'inception du kit (_meta/fiche.md du kit, backlog/WP-*, logs/*, registry local).
# Jamais d'écrasement : un fichier/dossier pré-existant est signalé et ignoré.
copy_kit() {
  local target="$1" nom="$2" skipfile="$3"
  local date; date="$(date +%F)"
  local copied=0; local skipped=()

  # 1) Fichiers racine du kit (génériques)
  local f
  for f in AGENT-projet.md referentiel-templates-PM2.md opencode.json .gitignore assistant.ps1 assistant.sh; do
    if [ -e "$ROOT/$f" ]; then
      if [ -e "$target/$f" ]; then skipped+=("$f")
      else cp "$ROOT/$f" "$target/$f"; copied=$((copied+1)); fi
    fi
  done

  # 2) Dossiers de phases (0*) + checklists + docs + tools
  local d
  for d in "$ROOT"/*; do
    local base; base="$(basename "$d")"
    case "$base" in
      0*) ;;  # dossier de phase "01 Lancement" etc.
      checklists|docs|tools) ;;
      *) continue ;;
    esac
    if [ -d "$d" ]; then
      if [ -e "$target/$base" ]; then skipped+=("$base/")
      else cp -R "$d" "$target/$base"; copied=$((copied+1)); fi
    fi
  done

  # 3) .opencode (agent + command, SANS node_modules)
  if [ -e "$target/.opencode" ]; then skipped+=(".opencode/")
  else
    mkdir -p "$target/.opencode"
    for sub in agent command; do
      [ -d "$ROOT/.opencode/$sub" ] && cp -R "$ROOT/.opencode/$sub" "$target/.opencode/$sub"
    done
    [ -f "$ROOT/.opencode/.gitignore" ] && cp "$ROOT/.opencode/.gitignore" "$target/.opencode/.gitignore"
    copied=$((copied+1))
  fi

  # 4) projet.md : copie du template avec pré-remplissage (nom + date), sans écraser
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

  # 5) dossier méta NEUF (pas celui du kit) — nom = $META (défaut _meta, lu de la config)
  local meta="$META"
  if [ -e "$target/$meta" ]; then
    skipped+=("$meta/ (pré-existant, non touché)")
  else
    mkdir -p "$target/$meta/backlog" "$target/$meta/logs" "$target/$meta/report" "$target/$meta/registry"
    sed -e "s/{{NOM}}/$nom/g" -e "s/{{DATE}}/$date/g" \
      "$ROOT/tools/templates/fiche-projet.md" > "$target/$meta/fiche.md"
    [ -f "$ROOT/$meta/backlog/README.md" ] && cp "$ROOT/$meta/backlog/README.md" "$target/$meta/backlog/README.md"
    [ -f "$ROOT/$meta/registry/README.md" ] && cp "$ROOT/$meta/registry/README.md" "$target/$meta/registry/README.md"
    printf '# registry/connexions.md - registres des connexions du projet\nkit_source: %s\n' "$ROOT" > "$target/$meta/registry/connexions.md"
    : > "$target/$meta/logs/.gitkeep"
    : > "$target/$meta/report/.gitkeep"
    copied=$((copied+1))
  fi

  if [ ${#skipped[@]} -gt 0 ]; then printf '%s\n' "${skipped[@]}" > "$skipfile"; else : > "$skipfile"; fi
  echo "$copied"
}

# ── Commandes ───────────────────────────────────────────────────────────────
# Resync des fichiers GÉNÉRIQUES du kit vers le projet (zéro écrasement :
# seuls les fichiers ABSENTS du projet sont copiés, y compris dans les dossiers existants).
# update_kit <projet> <kit> → un chemin ajouté par ligne (relatif au projet)
update_kit() {
  local target="$1" kit="$2"
  local f src dst rel mdir
  # 1) Fichiers racine génériques (JAMAIS .gitignore = data du projet)
  for f in AGENT-projet.md referentiel-templates-PM2.md opencode.json assistant.ps1 assistant.sh; do
    src="$kit/$f"; dst="$target/$f"
    if [ -f "$src" ] && [ ! -e "$dst" ]; then cp "$src" "$dst"; printf '%s\n' "$f"; fi
  done
  # 2) Dossiers de phases + checklists + docs + tools : les fichiers manquants (recursif)
  local d
  for d in "$kit"/*; do
    [ -d "$d" ] || continue
    local base; base="$(basename "$d")"
    case "$base" in
      0*|checklists|docs|tools) ;;
      *) continue ;;
    esac
    dst="$target/$base"
    if [ ! -d "$dst" ]; then
      cp -R "$d" "$dst"
      printf '%s/\n' "$base"
      continue
    fi
    local sl="${d%/}"
    find "$d" -type f | while IFS= read -r m; do
      rel="${m#"$sl"/}"
      if [ ! -e "$dst/$rel" ]; then
        mdir="$(dirname "$dst/$rel")"
        mkdir -p "$mdir"
        cp "$m" "$dst/$rel"
        printf '%s/%s\n' "$base" "$rel"
      fi
    done
  done
  # 3) .opencode/agent + command (fichiers manquants, recursif)
  local sub
  for sub in agent command; do
    src="$kit/.opencode/$sub"
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
  return 0
}

# cmd_update : resync du kit, lance DEPUIS le projet (dossier courant).
cmd_update() {
  local p; p="$(pwd)"
  if [ ! -f "$p/projet.md" ] && [ ! -f "$p/$META/fiche.md" ]; then
    echo "Tu n'es pas dans un projet (relancer depuis le dossier d'un projet — avec projet.md ou $META/)."
    return
  fi
  # Origine du kit : ligne 'kit_source: <chemin>' dans <meta>/registry/connexions.md
  local reg="$p/$META/registry/connexions.md"
  local kit_src=""
  if [ -f "$reg" ]; then
    kit_src="$(grep -m1 -E '^[[:space:]]*kit_source:' "$reg" | sed -E 's/^[[:space:]]*kit_source:[[:space:]]*//')"
  fi
  if [ -z "$kit_src" ]; then
    echo "Pas de 'kit_source' dans $reg — je ne sais pas d'où vient le kit."
    echo "  Ajoute la ligne : kit_source: <chemin du kit>"
    return
  fi
  if [ ! -f "$kit_src/assistant.ps1" ]; then
    echo "Kit source introuvable ou invalide : $kit_src"
    return
  fi
  echo ""; echo "Update du kit depuis : $kit_src"
  echo "  (zéro écrasement : seuls les fichiers du kit manquants sont ajoutés)"
  local added; added="$(update_kit "$p" "$kit_src")"
  if [ -z "$added" ]; then
    echo "  Déjà à jour — rien à ajouter."
  else
    local n; n="$(printf '%s\n' "$added" | grep -c .)"
    echo "  $n éléments ajoutés :"
    printf '%s\n' "$added" | while IFS= read -r a; do [ -n "$a" ] && echo "    + $a"; done
  fi
  echo ""
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
    local k_n=0 p_n=0 po_n=0 pl_n=0
    local kits="" parts="" pourrs="" plain=""
    local d
    while IFS= read -r d; do
      [ -z "$d" ] && continue
      local n; n="$(basename "$d")"
      local hasP=0 hasA=0 hasM=0
      [ -f "$d/projet.md" ] && hasP=1
      [ -f "$d/AGENT-projet.md" ] && hasA=1
      [ -d "$d/$META" ] && hasM=1
      if [ $hasP -eq 1 ] && [ $hasA -eq 1 ]; then
        kits="${kits}${n}
"; k_n=$((k_n+1))
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

    if [ $k_n -gt 0 ]; then
      echo "  [Assistés]"
      while IFS= read -r n; do
        [ -z "$n" ] && continue
        local fm_phase fm_gate
        fm_phase="$(awk '/^---$/{c++;next} c==1{if(/^phase:/){sub(/^phase:[ \t]*/,""); gsub(/^"|"$/,""); print; exit}}' "$r/$n/projet.md")"
        fm_gate="$(awk '/^---$/{c++;next} c==1{if(/^gate_suivant:/){sub(/^gate_suivant:[ \t]*/,""); gsub(/^"|"$/,""); print; exit}}' "$r/$n/projet.md")"
        printf '    + %s  -  phase %s, gate %s\n' "$n" "${fm_phase:-?}" "${fm_gate:-?}"
      done <<< "$kits"
    fi
    if [ $p_n -gt 0 ]; then
      echo "  [À compléter]"
      while IFS= read -r n; do
        [ -z "$n" ] && continue
        local hP=0 hA=0 hM=0
        [ -f "$r/$n/projet.md" ] && hP=1
        [ -f "$r/$n/AGENT-projet.md" ] && hA=1
        [ -d "$r/$n/$META" ] && hM=1
        local detail="kit partiel"
        if [ $hM -eq 1 ] && [ $hP -eq 0 ]; then detail="projet sans code (ne contient que $META) -> assistant add"
        elif [ $hM -eq 1 ]; then detail="kit partiel (manque AGENT-projet.md)"
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
    local total=$((k_n+p_n+po_n+pl_n))
    printf '  -> %d dossiers : %d assistés, %d à compléter, %d pourraient, %d sans signal\n' "$total" "$k_n" "$p_n" "$po_n" "$pl_n"
    tk=$((tk+k_n)); tp=$((tp+p_n)); tpo=$((tpo+po_n)); tpl=$((tpl+pl_n))
  done <<< "$roots"
  echo ""
  printf 'Total : %d dossiers - %d assistés, %d à compléter, %d pourraient, %d sans signal\n' "$((tk+tp+tpo+tpl))" "$tk" "$tp" "$tpo" "$tpl"
  echo "Travailler sur un projet :  assistant commence <nom>   (ou, dans opencode : « commence le projet <nom> »)"
  echo "Ajouter le kit à un dossier :  assistant add <dossier>   (jamais d'écrasement)"
}

cmd_statut() {
  local name="$1"
  local p=""
  if [ -z "$name" ]; then
    # Sans argument : le projet du dossier courant (si c'en est un) — pour le /ap-statut-projet depuis le projet.
    if [ -f "$(pwd)/projet.md" ] || [ -f "$(pwd)/$META/fiche.md" ]; then p="$(pwd)"
    else echo "Usage : assistant statut <projet>   (ou sans argument dans le dossier d'un projet)"; return; fi
  else
    p="$(find_project "$name")"
    if [ -z "$p" ]; then
      echo "Projet '$name' introuvable (cherche dans le kit, le dossier courant et les racines)."
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
  copied="$(copy_kit "$target" "$name" "$skipfile")"
  local nsk; nsk="$(grep -c . "$skipfile" 2>/dev/null || true)"
  echo ""; echo "Projet créé : $target"
  echo "  $copied éléments copiés, ${nsk:-0} ignorés."
  while IFS= read -r s; do [ -n "$s" ] && echo "  - ignoré (pré-existant) : $s"; done < "$skipfile"
  rm -f "$skipfile"
  echo ""
  echo "  Méthode PM2 : 4 phases (Lancement → Planification → Exécution → Clôture), chacune clôturée par un gate (checklist)."
  echo "  On attaque par la Lancement. Une phase peut être sautée, mais le statut le signalera ensuite — à faire par maîtrise ou curiosité."
  echo ""
  echo "  Prochain pas : aller dans le projet et lancer l'agent :"
  echo "    cd $target"
  echo "    opencode   (l'agent lit AGENT-projet.md → annonce la phase + gate : C'EST LE TEST)"
  echo "  Puis tester :  /ap-statut-projet   (phase + gate + avancement)  -  et dire : « commence le projet »"
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
  copied="$(copy_kit "$target" "$(basename "$target")" "$skipfile")"
  local nsk; nsk="$(grep -c . "$skipfile" 2>/dev/null || true)"
  echo ""; echo "Kit ajouté : $target"
  echo "  $copied éléments copiés, ${nsk:-0} ignorés."
  while IFS= read -r s; do [ -n "$s" ] && echo "  - ignoré (pré-existant) : $s"; done < "$skipfile"
  rm -f "$skipfile"
  echo ""
  echo "  Méthode PM2 : 4 phases (Lancement → Planification → Exécution → Clôture), chacune clôturée par un gate (checklist)."
  echo "  On attaque par la Lancement. Une phase peut être sautée, mais le statut le signalera ensuite — à faire par maîtrise ou curiosité."
  echo ""
  echo "  Prochain pas : aller dans le projet et lancer l'agent :"
  echo "    cd $target"
  echo "    opencode   (l'agent lit AGENT-projet.md → annonce la phase + gate : C'EST LE TEST)"
  echo "  Puis tester :  /ap-statut-projet   (phase + gate + avancement)  -  et dire : « commence le projet »"
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
  scan                 les projets des racines : assistés / pourraient / sans signal
  statut <projet>      phase + gate + avancement (lit projet.md ou _meta/fiche.md)
  new <nom> [racine] [-doc]   créer un projet  (-doc = SEUL _meta, sans kit : projet sans code)
  add <dossier>        ajouter le kit à un projet existant (jamais d'écrasement)
  update               (depuis un projet) resync les fichiers génériques du kit (zéro écrasement)
  remark <texte>       (depuis un projet) journal des remarques au vol (remontée au projet assistant)
------------------------------------------------
  commence <nom>       → L'AGENT : ouvre opencode dans le projet (conduite, mode B/C)
  install.sh           (re)initialiser la config transversale (racines, connexions)
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
  update) cmd_update ;;
  remark) cmd_remark "${2:-}" ;;
  commence) cmd_commence "${2:-}" ;;
  menu|"\?") show_menu ;;
  *) echo "Commande inconnue : $c"; show_menu ;;
esac                                                                                                                                                                                                                                                                                                                                                                                                                                                                     