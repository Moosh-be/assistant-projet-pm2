# assistant.ps1 - assistant-projet-pm2 : ENTRY-POINT NATIF (deterministe, sans IA, sans dependance)
# Principe : tout ce qui est faisable sans IA se fait sans IA.
#   - l'IA (l'agent opencode) n'intervient QUE pour : conduire (mode B), ecouter (mode C), decider (add-ons).
#   - le reste (trouver les projets, classer, lire le frontmatter, deployer) est deterministe -> ici.
#
# ARCHITECTURE (WP-0025) : le projet est MINCE.
#   - la data = projet.md, 01..05, _meta (le fruit du travail) - elle voyage (sync chez un tiers).
#   - l'outillage = ce repo (le "bundle") : moteur, protocole, templates, checklists, harness opencode.
#   - la config de connexion = _meta/registry/connexions.md (partagee, voyage) + connexions.local.md (machine).
#   - le bootstrap (bootstrap.ps1/.sh, dans le projet) retablit le bundle SANS IA : pointer/chercher/installer,
#     en annoncant + confirmant avant chaque action, puis propose le harness opencode.
#
# Usage : .\assistant.ps1 <cmd> [args]      (macOS/Linux : ./assistant.sh <cmd> [args])
#   scan               liste les projets des racines (assistes / pourraient / sans signal)
#   statut <projet>    phase + gate + avancement d'un projet (sans argument : le projet courant, ou la liste)
#   liste              les projets (nom + phase + gate) - depuis le kit ou les racines
#   new <nom> [racine] cree un projet MINCE (data + config + lanceur mince + bootstrap)
#   add <dossier>      ajoute l'assistant (mince) a un projet existant (jamais d'ecrasement)
#   sync [--force-harness]  (depuis un projet) verifie le bundle (version) + le harness opencode (remplace update)
#   bootstrap          (depuis un projet) (re)installe le bundle : pointer / chercher / installer + harness
#   remark <texte>     (depuis un projet) journal des remarques au vol (remontee au projet assistant)
#   commence <nom>     -> l'agent : ouvre opencode dans le projet (handoff)
#   menu / ?           ce menu
#
# Pure ASCII (Windows PowerShell 5.1 lit les .ps1 en ANSI sans BOM UTF-8).
# La logique de scan/statut vit ICI (source unique) : les commandes opencode /ap-scan-projets /ap-statut-projet l'appellent.

$ErrorActionPreference = "Stop"
# PSScriptRoot (et pas $MyInvocation.MyCommand.Path) : robuste quel que soit le mode d'appel
# (-File, & depuis un autre script, dot-sourcing). = le dossier qui contient ce script.
$Root = $PSScriptRoot
$RegDir = Join-Path $Root "_meta/registry"
$OldConn = Join-Path $RegDir "connexions.md"   # registre ANCIEN (fallback de transition)

# Config machine a la racine du kit (WP-0017) : 1er des 3 noms qui existe.
$Config = $null
foreach ($cn in @(".assistant.config", "assistant.config", "assistant.config.md")) {
  if (Test-Path (Join-Path $Root $cn)) { $Config = Join-Path $Root $cn; break }
}

# Nom du dossier meta (defaut _meta) - lu de la config s'il existe.
function Get-MetaFolder {
  if ($null -ne $Config -and (Test-Path $Config)) {
    foreach ($l in (Get-Content $Config -Encoding UTF8)) {
      if ($l -match '^\s*meta_folder\s*=\s*(.+)$') {
        $v = $Matches[1].Trim()
        if ($v -ne "") { return $v }
      }
    }
  }
  return "_meta"
}
$MetaFolder = Get-MetaFolder

# -- Helpers -------------------------------------------------------------------
# Get-Racines : lit la ligne "racines = ..." de la config (ou fallback : registre ancien).
# Chaque entree : "<chemin> (<qualificatif>)", separees par " ; ". Le chemin ne contient pas de "(".
function Get-Racines {
  $line = $null
  if ($null -ne $Config -and (Test-Path $Config)) {
    foreach ($l in (Get-Content $Config -Encoding UTF8)) {
      if ($l -match '^\s*racines\s*=\s*(.+)$') { $line = $Matches[1].Trim(); break }
    }
  }
  if ($null -eq $line -and (Test-Path $OldConn)) {
    foreach ($l in (Get-Content $OldConn -Encoding UTF8)) {
      if ($l -match '^\s*- racines:\s*(.+)$') { $line = $Matches[1].Trim(); break }
    }
  }
  if ($null -eq $line -or $line -eq "aucune") { return @() }
  $paths = @([regex]::Matches($line, '(?:^|; )([^\(]+) \(') | ForEach-Object { $_.Groups[1].Value.Trim() } | Where-Object { $_ -ne "" })
  return $paths
}

function Get-Signaux([string]$d) {
  $s = @()
  if (Test-Path (Join-Path $d ".git")) { $s += ".git" }
  foreach ($f in @("package.json","pyproject.toml","requirements.txt","pom.xml","build.gradle","go.mod","Cargo.toml","Dockerfile","README.md")) {
    if (Test-Path (Join-Path $d $f)) { $s += $f }
  }
  if (Test-Path (Join-Path $d "src")) { $s += "src/" }
  $mf = (Get-MetaFolder)
  if (Test-Path (Join-Path $d $mf)) { $s += "$mf/" }
  return $s
}

function Read-Frontmatter([string]$file) {
  $res = @{}
  if (-not (Test-Path $file)) { return $res }
  $txt = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
  if ($txt -match "(?m)^---[ \t]*\r?\n([\s\S]*?)\r?\n---") {
    foreach ($l in ($Matches[1] -split "`r?`n")) {
      if ($l -match '^([A-Za-z_][A-Za-z0-9_]*)[ \t]*:[ \t]*(.*)$') {
        $k = $Matches[1]; $v = $Matches[2].Trim()
        if ($v.Length -ge 2 -and (($v.StartsWith('"')) -or ($v.StartsWith("'")))) { $v = $v.Substring(1, $v.Length - 2) }
        $res[$k] = $v
      }
    }
  }
  return $res
}

# Lit la valeur d'une ligne "key: value" d'un fichier de config (ou vide si absente).
function Read-ConfLine([string]$file, [string]$key) {
  if (-not (Test-Path $file)) { return "" }
  foreach ($l in (Get-Content $file -Encoding UTF8)) {
    if ($l -match '^\s*' + [regex]::Escape($key) + '\s*:\s*(.+)$') { return $Matches[1].Trim() }
  }
  return ""
}

function Test-ProjectDir([string]$dir) {
  $mf = (Get-MetaFolder)
  $hasP = Test-Path (Join-Path $dir "projet.md")
  $hasM = Test-Path (Join-Path $dir "$mf/fiche.md")
  return ($hasP -or $hasM)
}

function Find-Project([string]$name) {
  # Un projet = un dossier avec projet.md OU avec <meta>/fiche.md (projet sans code).
  $c = Join-Path $Root $name
  if (Test-ProjectDir $c) { return (Resolve-Path $c).Path }
  $c = Join-Path (Get-Location).Path $name
  if (Test-ProjectDir $c) { return (Resolve-Path $c).Path }
  foreach ($r in (Get-Racines)) {
    $c = Join-Path $r $name
    if (Test-ProjectDir $c) { return (Resolve-Path $c).Path }
  }
  return $null
}

# Depot MINCE du projet (WP-0025) : la data + la config de connexion + le lanceur mince + le bootstrap.
# L'outillage (protocole, templates, checklists, docs, tools, .opencode) NE PART PAS : il vit
# dans le bundle (ce repo), pointe par la config. $nom = nom du projet (pre-remplissage projet.md + fiche).
# Ne copie JAMAIS les donnees d'inception du kit (_meta/fiche.md du kit, backlog/WP-*, logs/*, registry local).
# Jamais d'ecrasement : un fichier/dossier pre-existant est signale et ignore.
function Deploy-Kit([string]$target, [string]$nom) {
  $date = Get-Date -Format "yyyy-MM-dd"
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  $copied = 0
  $skipped = @()

  # 1) projet.md : copie du template avec pre-remplissage (nom + date)
  $pmdSrc = Join-Path $Root "projet.md"
  if (Test-Path (Join-Path $target "projet.md")) {
    $skipped += "projet.md"
  } else {
    $lines = [System.IO.File]::ReadAllLines($pmdSrc, [System.Text.Encoding]::UTF8)
    $out = @()
    foreach ($l in $lines) {
      $repl = $null
      if ($l -match '^([A-Za-z][A-Za-z0-9\p{L}]*)[ \t]*:[ \t]*""[ \t]*$') {
        $key = $Matches[1]
        if ($key -eq "projet") { $repl = "projet: `"${nom}`"" }
        elseif ($key -like "cr*") { $repl = "${key}: ${date}" }   # cree : date
      } elseif ($l.Trim() -eq "# <Nom du projet>") { $repl = "# ${nom}" }
      if ($null -ne $repl) { $out += $repl; continue }
      $out += $l.Replace("<AAAA-MM-JJ>", $date)
    }
    [System.IO.File]::WriteAllLines((Join-Path $target "projet.md"), $out, $utf8)
    $copied += 1
  }

  # 2) Dossiers de phases (01..05) VIDES : la data s'y ecrit, l'outillage n'y vit plus.
  $dirs = @(Get-ChildItem -Path $Root -Directory | Where-Object { $_.Name -match '^0[0-9] ' } | ForEach-Object { $_.Name })
  foreach ($d in $dirs) {
    $t = Join-Path $target $d
    if (Test-Path $t) { $skipped += "$d/" }
    else {
      New-Item -ItemType Directory -Force -Path $t | Out-Null
      [System.IO.File]::WriteAllText((Join-Path $t ".gitkeep"), "", $utf8)
      $copied++
    }
  }

  # 3) dossier meta NEUF (pas celui du kit) + la config de connexion (partagee + machine)
  $proj = Join-Path $target $MetaFolder
  if (Test-Path $proj) {
    $skipped += "$MetaFolder/ (pre-existant, non touche)"
  } else {
    New-Item -ItemType Directory -Force -Path "$proj/backlog","$proj/logs","$proj/report","$proj/registry" | Out-Null
    # fiche.md depuis le template genere (tools/templates/fiche-projet.md)
    $fiche = [System.IO.File]::ReadAllText((Join-Path $Root "tools/templates/fiche-projet.md"), [System.Text.Encoding]::UTF8)
    $fiche = $fiche.Replace("{{NOM}}", $nom).Replace("{{DATE}}", $date)
    [System.IO.File]::WriteAllText((Join-Path $proj "fiche.md"), $fiche, $utf8)
    # docs de format (generiques, pas les donnees) - depuis le dossier meta du kit
    $bk = Join-Path $Root "$MetaFolder/backlog/README.md"
    if (Test-Path $bk) { Copy-Item $bk (Join-Path $proj "backlog/README.md") }
    $rg = Join-Path $Root "$MetaFolder/registry/README.md"
    if (Test-Path $rg) { Copy-Item $rg (Join-Path $proj "registry/README.md") }
    # config de connexion PARTAGEE (voyage avec le projet)
    $gitUrl = ""
    if (Get-Command git -ErrorAction SilentlyContinue) {
      try {
        $g = (& git -C $Root remote get-url origin 2>$null | Select-Object -First 1)
        if ($g) { $gitUrl = $g.Trim() }
      } catch { $gitUrl = "" }
    }
    $cl = @(
      "# registry/connexions.md - config de connexion PARTAGEE (voyage avec le projet - WP-0025)",
      "# assistant_git : le repo assistant (pour le bootstrap : installer)",
      "# assistant_ref : latest = la derniere version du bundle (ou <version> -> versions/<version>/)",
      "assistant_git: ${gitUrl}",
      "assistant_ref: latest",
      "meta_folder: ${MetaFolder}"
    )
    [System.IO.File]::WriteAllLines((Join-Path $proj "registry/connexions.md"), $cl, $utf8)
    # config de connexion MACHINE (gitignoree, ecrite par le bootstrap - pre-remplie : le bundle est sur CETTE machine)
    # Chemin en C:/... (barres obliques) : lisible par le lanceur PS, le lanceur bash (MSYS) et opencode.
    $cll = @(
      "# registry/connexions.local.md - config de connexion MACHINE (gitignoree, ecrite par le bootstrap)",
      "assistant_local: $($Root -replace '\\','/')"
    )
    [System.IO.File]::WriteAllLines((Join-Path $proj "registry/connexions.local.md"), $cll, $utf8)
    [System.IO.File]::WriteAllText((Join-Path $proj "logs/.gitkeep"), "", $utf8)
    [System.IO.File]::WriteAllText((Join-Path $proj "report/.gitkeep"), "", $utf8)
    $copied += 1
  }

  # 4) .gitignore (template projet : gitignore la partie machine de la config + le harness)
  $giSrc = Join-Path $Root "tools/templates/gitignore-projet.md"
  if (Test-Path (Join-Path $target ".gitignore")) { $skipped += ".gitignore" }
  else { Copy-Item $giSrc (Join-Path $target ".gitignore"); $copied++ }

  # 5) Lanceur mince + bootstrap (les 2 : PS + bash, un par OS)
  $map = @{ "assistant.ps1" = "lanceur-assistant.ps1"; "assistant.sh" = "lanceur-assistant.sh"; "bootstrap.ps1" = "bootstrap-assistant.ps1"; "bootstrap.sh" = "bootstrap-assistant.sh" }
  foreach ($dst in @("assistant.ps1","assistant.sh","bootstrap.ps1","bootstrap.sh")) {
    $s = Join-Path $Root ("tools/templates/" + $map[$dst])
    if (Test-Path (Join-Path $target $dst)) { $skipped += $dst }
    else { Copy-Item $s (Join-Path $target $dst); $copied++ }
  }

  # 6) opencode.json : le harness pointe le protocole DANS LE BUNDLE (chemin absolu, en /)
  $ocJson = Join-Path $target "opencode.json"
  if (Test-Path $ocJson) { $skipped += "opencode.json" }
  else {
    $bs = $Root -replace '\\','/'
    $jl = @('{',
      '  "$schema": "https://opencode.ai/config.json",',
      '  "default_agent": "assistant-projet",',
      '  "instructions": ["' + $bs + '/AGENT-projet.md", "projet.md"]',
      '}')
    [System.IO.File]::WriteAllText($ocJson, (($jl -join "`n") + "`n"), $utf8)
    $copied += 1
  }

  return @{ Copied = $copied; Skipped = $skipped }
}

# Deploie le harness opencode du projet depuis le bundle (zero ecrasement : seuls les
# fichiers ABSENTS du projet sont copies ; opencode.json cree si absent, JAMAIS ecrase ;
# .gitignore complete en append). Retourne la liste des chemins ajoutes (relatifs au projet).
function Deploy-Harness([string]$target, [string]$bundle, [string]$meta) {
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  $added = @()
  # 1) .opencode/agent + command (fichiers manquants, recursif)
  foreach ($sub in @("agent","command")) {
    $src = Join-Path $bundle ".opencode/$sub"
    if (-not (Test-Path $src)) { continue }
    $dst = Join-Path $target ".opencode/$sub"
    if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Force -Path $dst | Out-Null }
    $srcLen = $src.Length
    $missing = @(Get-ChildItem $src -File -Recurse | Where-Object { -not (Test-Path (Join-Path $dst $_.FullName.Substring($srcLen + 1))) })
    foreach ($m in $missing) {
      $rel = $m.FullName.Substring($srcLen + 1)
      $mdst = Join-Path $dst $rel
      $mdir = Split-Path $mdst -Parent
      if (-not (Test-Path $mdir)) { New-Item -ItemType Directory -Force -Path $mdir | Out-Null }
      Copy-Item $m.FullName $mdst
      $added += ".opencode/$sub/$rel"
    }
  }
  # 2) opencode.json (cree si absent - JAMAIS ecrase : il pointe le bundle de CETTE machine)
  $ocJson = Join-Path $target "opencode.json"
  if (-not (Test-Path $ocJson)) {
    $bs = $bundle -replace '\\','/'
    $jl = @('{',
      '  "$schema": "https://opencode.ai/config.json",',
      '  "default_agent": "assistant-projet",',
      '  "instructions": ["' + $bs + '/AGENT-projet.md", "projet.md"]',
      '}')
    [System.IO.File]::WriteAllText($ocJson, (($jl -join "`n") + "`n"), $utf8)
    $added += "opencode.json"
  }
  # 3) .gitignore : les lignes machine (append, jamais d'ecrasement)
  $gi = Join-Path $target ".gitignore"
  if (-not (Test-Path $gi)) {
    $gf = Join-Path $bundle "tools/templates/gitignore-projet.md"
    if (Test-Path $gf) { Copy-Item $gf $gi; $added += ".gitignore" }
  } else {
    $c = [System.IO.File]::ReadAllText($gi, [System.Text.Encoding]::UTF8)
    $addl = @()
    if ($c -notmatch '(?m)^[ \t]*\.opencode/') { $addl += ".opencode/" }
    if ($c -notmatch ('(?m)^[ \t]*' + [regex]::Escape("$meta/registry/connexions.local.md"))) { $addl += "$meta/registry/connexions.local.md" }
    if ($addl.Count -gt 0) {
      [System.IO.File]::WriteAllText($gi, ($c.TrimEnd("`r","`n") + "`r`n" + ($addl -join "`r`n") + "`r`n"), $utf8)
      $added += ".gitignore (append)"
    }
  }
  return $added
}

# -- Remarque au vol (WP-0021) -------------------------------------------------
# Journal des remarques : on note au fil de l'usage, on remonte au projet assistant.
function Cmd-Remarque([string]$msg) {
  $p = (Get-Location).Path
  if (-not (Test-ProjectDir $p)) {
    Write-Host "Tu n'es pas dans un projet (relancer depuis le dossier d'un projet - avec projet.md ou $MetaFolder/)."
    return
  }
  if ([string]::IsNullOrWhiteSpace($msg)) { Write-Host "Usage : assistant remark <ta remarque>"; return }
  $dir = Join-Path $p "$MetaFolder/registry"
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $f = Join-Path $dir "remarques.md"
  $date = Get-Date -Format "yyyy-MM-dd"
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  $line = "- [$date] $msg"
  if (Test-Path $f) {
    $c = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
    [System.IO.File]::WriteAllText($f, ($c + $line + "`r`n"), $utf8)
  } else {
    $h = "# remarques.md - journal des remarques au vol`r`n> Notes pendant l'usage (kit ou projet) ; l'agent propose de remonter au projet assistant les entrees marqees [pour l'assistant].`r`n"
    [System.IO.File]::WriteAllText($f, ($h + $line + "`r`n"), $utf8)
  }
  Write-Host "Notee : $f"
  Write-Host "  Pour une amelioration du kit : ajouter [pour l'assistant] dans l'entree."
}

# -- Commandes -----------------------------------------------------------------
# sync (WP-0025 - remplace update) : le projet est MINCE - il n'y a plus de copie locale
# de l'outillage a resynchroniser. sync verifie :
#   1) le bundle (reference assistant_ref + version trouvee + arriere local git, best effort)
#   2) la presence du lanceur mince + du bootstrap (ajout des absents seulement)
#   3) le harness opencode : ajoute les fichiers manquants (zero ecrasement ;
#      --force-harness pour regenerer le harness depuis le bundle)
function Cmd-Sync([bool]$forceHarness) {
  $p = (Get-Location).Path
  if (-not (Test-ProjectDir $p)) {
    Write-Host "Tu n'es pas dans un projet (relancer depuis le dossier d'un projet - avec projet.md ou $MetaFolder/)."
    return
  }
  # Config de connexion du projet (partagee + machine) - meme logique que le lanceur mince.
  $shared = Join-Path $p "$MetaFolder/registry/connexions.md"
  $localf = Join-Path $p "$MetaFolder/registry/connexions.local.md"
  $meta = $MetaFolder
  $mfCfg = Read-ConfLine $shared "meta_folder"
  if ($mfCfg -ne "") {
    $meta = $mfCfg
    $shared = Join-Path $p "$meta/registry/connexions.md"
    $localf = Join-Path $p "$meta/registry/connexions.local.md"
  }
  $ref = Read-ConfLine $shared "assistant_ref"
  if ($ref -eq "") { $ref = "latest" }
  $b = Read-ConfLine $localf "assistant_local"
  if ($ref -ne "latest" -and (Test-Path (Join-Path $b "versions"))) { $b = Join-Path $b "versions/$ref" }
  $bValid = ($b -ne "") -and (Test-Path (Join-Path $b "assistant.ps1")) -and (Test-Path (Join-Path $b ".assistant.version"))
  if (-not $bValid) {
    Write-Host ""
    Write-Host "Pas de bundle valide sur cette machine (assistant_local : $(if ($b -eq '') { '(non defini)' } else { $b }))."
    Write-Host "  -> lancer le bootstrap :  .\bootstrap.ps1   (pointer / chercher / installer)"
    return
  }
  Write-Host ""
  Write-Host "sync - projet : $p"
  Write-Host "  Bundle  : $b"
  $ver = (Get-Content (Join-Path $b ".assistant.version") -TotalCount 1).Trim()
  Write-Host ("  Version : {0}   (reference : {1})" -f $ver, $ref)
  # Si le bundle est un repo git local : arriere local vs upstream (sans reseau, best effort).
  if (Test-Path (Join-Path $b ".git")) {
    try {
      $behind = (& git -C $b rev-list --count "HEAD..@{u}" 2>$null | Select-Object -First 1).Trim()
      if ($behind -match '^\d+$' -and [int]$behind -gt 0) {
        Write-Host ("  NB : le bundle est {0} commit(s) arriere de son upstream local (git pull possible - c'est a toi de le faire)." -f $behind)
      }
    } catch { }
  }
  # 2) Presence du lanceur mince + du bootstrap (ajout des absents seulement).
  $map = @{ "assistant.ps1" = "lanceur-assistant.ps1"; "assistant.sh" = "lanceur-assistant.sh"; "bootstrap.ps1" = "bootstrap-assistant.ps1"; "bootstrap.sh" = "bootstrap-assistant.sh" }
  $addedFiles = @()
  foreach ($dst in @("assistant.ps1","assistant.sh","bootstrap.ps1","bootstrap.sh")) {
    $s = Join-Path $b ("tools/templates/" + $map[$dst])
    if ((Test-Path $s) -and -not (Test-Path (Join-Path $p $dst))) { Copy-Item $s (Join-Path $p $dst); $addedFiles += $dst }
  }
  if ($addedFiles.Count -gt 0) { Write-Host ("  Lanceur : ajoutes (absents) - {0}" -f ($addedFiles -join ", ")) }
  # 3) Le harness opencode
  $ocAgent = Join-Path $p ".opencode/agent/assistant-projet.md"
  $ocJson = Join-Path $p "opencode.json"
  $need = (-not (Test-Path $ocAgent)) -or (-not (Test-Path $ocJson))
  if ($forceHarness) {
    Write-Host "  Harness : --force-harness -> regeneration depuis le bundle (remplace .opencode/agent+command + opencode.json)."
    $a = Read-Host "  Confirmer ? (o/n)"
    if ($a -eq "o" -or $a -eq "oui" -or $a -eq "yes" -or $a -eq "y") {
      foreach ($sub in @("agent","command")) { $d = Join-Path $p ".opencode/$sub"; if (Test-Path $d) { Remove-Item $d -Recurse -Force } }
      if (Test-Path $ocJson) { Remove-Item $ocJson -Force }
      $added = @(Deploy-Harness -Target $p -Bundle $b -Meta $meta)
      foreach ($x in $added) { Write-Host ("    + {0}" -f $x) }
    } else { Write-Host "  Annule." }
  } elseif ($need) {
    Write-Host "  Harness : incomplet/absent (a ajouter, zero ecrasement) :"
    if (-not (Test-Path $ocAgent)) { Write-Host "    + .opencode/agent/ + .opencode/command/  (copies du bundle)" }
    if (-not (Test-Path $ocJson)) { Write-Host "    + opencode.json  (instructions -> AGENT-projet.md du bundle + projet.md)" }
    Write-Host "    + .gitignore  (lignes machine, en append)"
    $a = Read-Host "  Deployer ? (o/n)"
    if ($a -eq "o" -or $a -eq "oui" -or $a -eq "yes" -or $a -eq "y") {
      $added = @(Deploy-Harness -Target $p -Bundle $b -Meta $meta)
      foreach ($x in $added) { Write-Host ("    + {0}" -f $x) }
    } else { Write-Host "  Passe - a refaire :  .\assistant.ps1 sync" }
  } else {
    Write-Host "  Harness : deploye."
  }
  Write-Host ""
  Write-Host "  sync OK."
  if ($ref -eq "latest") { Write-Host "  (Pour figer une version : assistant_ref: <version> dans $shared - le projet migre quand il le sent.)" }
}

# bootstrap (WP-0025) : lance le bootstrap DU PROJET (retablit le bundle sans IA :
# pointer / chercher / installer + le harness opencode). Delegue aux args.
function Cmd-Bootstrap([string[]]$extra) {
  $p = (Get-Location).Path
  if (-not (Test-ProjectDir $p)) {
    Write-Host "Tu n'es pas dans un projet (relancer depuis le dossier d'un projet)."
    return
  }
  $boot = Join-Path $p "bootstrap.ps1"
  if (-not (Test-Path $boot)) {
    Write-Host "bootstrap.ps1 absent dans $p (projet incomplet - relancer l'add sur ce dossier)."
    return
  }
  & $boot @extra
}
function Cmd-Scan {
  $roots = @(Get-Racines)
  if ($roots.Count -eq 0) {
    Write-Host "Aucune racine definie."
    Write-Host "  -> relancer l'install (install.ps1) pour definir les racines, puis relancer le scan."
    return
  }
  $t_kit = 0; $t_part = 0; $t_pour = 0; $t_plain = 0
  foreach ($r in $roots) {
    Write-Host ""
    Write-Host "=== $r ==="
    if (-not (Test-Path $r)) { Write-Host "  (racine absente)"; continue }
    $dirs = @(Get-ChildItem -Path $r -Directory -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike '.*' })
    if ($dirs.Count -eq 0) { Write-Host "  (vide)"; continue }
    $mince = @(); $legacy = @(); $parts = @(); $pourrs = @(); $plain = @()
    $mfScan = (Get-MetaFolder)
    foreach ($d in $dirs) {
      $hasP = Test-Path (Join-Path $d.FullName "projet.md")
      $hasA = Test-Path (Join-Path $d.FullName "AGENT-projet.md")
      $hasM = Test-Path (Join-Path $d.FullName $mfScan)
      if ($hasP -and $hasM) {
        # Assiste (WP-0025) : la data (projet.md) + la couche meta.
        # "mince" = l'outillage est dans le bundle ; "copie complete" = legacy (l'outillage est copie dans le projet).
        if ($hasA) { $legacy += $d } else { $mince += $d }
      }
      elseif ($hasP -or $hasA -or $hasM) { $parts += $d }
      else {
        $s = @(Get-Signaux $d.FullName)
        if ($s.Count -gt 0) { $pourrs += [pscustomobject]@{ Dir = $d; Sig = $s } }
        else { $plain += $d }
      }
    }
    if (($mince.Count + $legacy.Count) -gt 0) {
      Write-Host "  [Assistes]"
      foreach ($d in $mince) {
        $fm = Read-Frontmatter (Join-Path $d.FullName "projet.md")
        Write-Host ("    + {0}  -  phase {1}, gate {2}   (mince)" -f $d.Name, $fm["phase"], $fm["gate_suivant"])
      }
      foreach ($d in $legacy) {
        $fm = Read-Frontmatter (Join-Path $d.FullName "projet.md")
        Write-Host ("    + {0}  -  phase {1}, gate {2}   (copie complete, pre-WP-0025)" -f $d.Name, $fm["phase"], $fm["gate_suivant"])
      }
    }
    if ($parts.Count -gt 0) {
      Write-Host "  [A completer]"
      foreach ($d in $parts) {
        $hasP = Test-Path (Join-Path $d.FullName "projet.md")
        $hasA = Test-Path (Join-Path $d.FullName "AGENT-projet.md")
        $hasM = Test-Path (Join-Path $d.FullName $mfScan)
        $detail = "partiel (projet.md + $mfScan/ attendus)"
        if ($hasM -and -not $hasP) { $detail = "projet sans code (ne contient que $mfScan) -> assistant add" }
        elseif ($hasP -and -not $hasM) { $detail = "manque $mfScan/ -> assistant add" }
        elseif ($hasA -and -not $hasP) { $detail = "copie du kit sans projet.md -> assistant add" }
        Write-Host ("    ~ {0}  -  {1}" -f $d.Name, $detail)
      }
    }
    if ($pourrs.Count -gt 0) {
      Write-Host "  [Pourraient (signaux)]"
      foreach ($p in $pourrs) {
        $s = $p.Sig
        if ($s.Count -gt 4) { $s = $s[0..3] + "..." }
        Write-Host ("    ? {0}  -  {1}" -f $p.Dir.Name, ($s -join ", "))
      }
    }
    if ($plain.Count -gt 0) {
      Write-Host "  [Sans signal]"
      foreach ($d in $plain) { Write-Host ("    . {0}" -f $d.Name) }
    }
    $t_kit += ($mince.Count + $legacy.Count); $t_part += $parts.Count; $t_pour += $pourrs.Count; $t_plain += $plain.Count
    Write-Host ("  -> {0} dossiers : {1} assistes, {2} a completer, {3} pourraient, {4} sans signal" -f $dirs.Count, ($mince.Count + $legacy.Count), $parts.Count, $pourrs.Count, $plain.Count)
  }
  Write-Host ""
  Write-Host ("Total : {0} dossiers - {1} assistes, {2} a completer, {3} pourraient, {4} sans signal" -f ($t_kit + $t_part + $t_pour + $t_plain), $t_kit, $t_part, $t_pour, $t_plain)
  Write-Host "Travailler sur un projet :  assistant commence <nom>   (ou, dans opencode : 'commence le projet <nom>')"
  Write-Host "Ajouter l'assistant (mince) a un dossier :  assistant add <dossier>   (jamais d'ecrasement)"
}

# Show-ProjetListe : la liste des projets (nom + phase + gate) - WP-0024.
function Show-ProjetListe {
  $seen = @{}
  $rows = @()
  foreach ($r in (Get-Racines)) {
    if (-not (Test-Path $r -PathType Container)) { continue }
    foreach ($d in (Get-ChildItem $r -Directory)) {
      if (-not (Test-ProjectDir $d.FullName)) { continue }
      $full = (Resolve-Path $d.FullName).Path
      if ($seen.ContainsKey($full)) { continue }
      $seen[$full] = $true
      $mf = (Get-MetaFolder)
      $src = Join-Path $full "projet.md"
      if (-not (Test-Path $src)) { $src = Join-Path $full "$mf/fiche.md" }
      $fm = Read-Frontmatter $src
      $rows += [pscustomobject]@{ Nom = $d.Name; Phase = $fm["phase"]; Gate = $fm["gate_suivant"] }
    }
  }
  Write-Host ""
  if ($rows.Count -eq 0) { Write-Host "Aucun projet trouve dans les racines."; return }
  Write-Host ("  Projets ({0}) :  statut <nom>  (le nom = le nom du dossier)" -f $rows.Count)
  foreach ($x in $rows) {
    Write-Host ("    {0,-28} [{1,-14} / {2}]" -f $x.Nom, $x.Phase, $x.Gate)
  }
}

function Cmd-Statut([string]$name) {
  # Sans argument : le projet du DOSSIER COURANT (si c'en est un) - pour le /ap-statut-projet depuis le projet.
  # Hors projet : la liste des projets (WP-0024).
  if ([string]::IsNullOrWhiteSpace($name)) {
    if (Test-ProjectDir (Get-Location).Path) { $p = (Get-Location).Path }
    else { Show-ProjetListe; return }
  } else {
    $p = Find-Project $name
    if ($null -eq $p) {
      Write-Host "Projet '$name' introuvable (cherche dans le kit, le dossier courant et les racines)."
      Show-ProjetListe
      return
    }
  }
  # Source de verite : projet.md sinon _meta/fiche.md (projet sans code - WP-0019).
  $mf = (Get-MetaFolder)
  $srcFile = Join-Path $p "projet.md"
  $srcLabel = "projet.md"
  if (-not (Test-Path $srcFile)) { $srcFile = Join-Path $p "$mf/fiche.md"; $srcLabel = "$mf/fiche.md" }
  $fm = Read-Frontmatter $srcFile
  Write-Host ""
  Write-Host "=== Statut : $(Split-Path $p -Leaf) ==="
  Write-Host "  (source : $srcLabel)"
  Write-Host ("  Phase : {0}   |   Gate suivant : {1}" -f $fm["phase"], $fm["gate_suivant"])
  # Pedagogie (WP-0022) : phases sautees = signalees (la table d'avancement = source de verite).
  $in3 = $false; $table = $false
  $phaseNames = @(); $gateByPhase = @{}
  $lines3 = [System.IO.File]::ReadAllLines($srcFile, [System.Text.Encoding]::UTF8)
  foreach ($l in $lines3) {
    if ($l -match '^## 3\.') { $in3 = $true; continue }
    if ($in3 -and $l -match '^## ') { break }
    if ($in3 -and $l.TrimStart().StartsWith("|")) {
      if (-not $table -and $l -match '^\| Phase \|') { $table = $true; Write-Host "  Avancement :" }
      if ($table) { Write-Host ("    {0}" -f $l.Trim()) }
      $cells = @(($l -split '\|') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })
      if ($cells.Count -ge 4 -and $cells[0] -ne "Phase" -and $cells[0] -notmatch '^-+$') {
        $nm = ($cells[0] -replace '\*','').Trim()
        $phaseNames += $nm
        $gateByPhase[$nm] = $cells[3]
      }
    }
  }
  # Phase courante -> rang (prefixe ASCII : les noms reels peuvent etre accentues).
  $cp = "Lan"
  if ($fm["phase"] -like "Pla*") { $cp = "Pla" } elseif ($fm["phase"] -like "Ex*") { $cp = "Ex" } elseif ($fm["phase"] -like "Cl*") { $cp = "Cl" }
  $idx = -1
  for ($i = 0; $i -lt $phaseNames.Count; $i++) { if ($phaseNames[$i] -like "$cp*") { $idx = $i; break } }
  $ok1 = [string][char]0x2611   # case a cocher cochee (gate vert)
  $ok2 = [string][char]0x2705   # marque de verification
  $dash = [string][char]0x2014  # tiret long (pas de gate sur cette phase)
  if ($idx -ge 1) {
    $saut = @()
    for ($i = 0; $i -lt $idx; $i++) {
      $g = "$($gateByPhase[$phaseNames[$i]])"
      if ($g.StartsWith($dash)) { continue }
      if (-not ($g.Contains($ok1) -or $g.Contains($ok2))) { $saut += $phaseNames[$i] }
    }
    if ($saut.Count -gt 0) { Write-Host ("  Sautees : {0}   (gate non vert - a combler par maitrise, pas par dehabitude)" -f ($saut -join ", ")) }
  }
  # Roles + tickets (alignement avec la version bash - promis par le doc de la commande).
  $roles = ""
  if ($fm["sponsor"] -ne "") { $roles = "sponsor: $($fm['sponsor'])" }
  if ($fm["bm"] -ne "") { $roles += $(if ($roles) { "  |  " } else { "" }) + "bm: $($fm['bm'])" }
  if ($fm["cp"] -ne "") { $roles += $(if ($roles) { "  |  " } else { "" }) + "cp: $($fm['cp'])" }
  if ($fm["moe"] -ne "") { $roles += $(if ($roles) { "  |  " } else { "" }) + "moe: $($fm['moe'])" }
  if ($roles -ne "") { Write-Host ("  Roles   : {0}" -f $roles) } else { Write-Host "  Roles   : (non identifies)" }
  $tix = ""
  if ($fm["sp_project"] -ne "") { $tix = "SP: $($fm['sp_project'])" }
  if ($fm["op_id"] -ne "") { $tix += $(if ($tix) { "  |  " } else { "" }) + "OP: $($fm['op_id'])" }
  if ($tix -ne "") { Write-Host ("  Tickets : {0}" -f $tix) } else { Write-Host "  Tickets : (aucune connexion active)" }
}

function Cmd-New([string]$name, [string]$rootOverride, [bool]$doc) {
  if ([string]::IsNullOrWhiteSpace($name)) { Write-Host "Usage : assistant new <nom> [racine] [-doc]"; return }
  # NB : pas de $root ici - PowerShell est insensible a la casse, $root ecraserait le $Root global (chemin du kit).
  $rroot = $rootOverride
  if ([string]::IsNullOrWhiteSpace($rroot)) {
    $roots = @(Get-Racines)
    if ($roots.Count -eq 0) { Write-Host "Aucune racine definie : passe une racine (assistant new <nom> <racine>) ou lance install."; return }
    $rroot = $roots[0]
  }
  $target = Join-Path $rroot $name
  if (Test-Path $target) { Write-Host "'$target' existe deja -> rien n'est cree ni ecrase."; return }
  if ($doc) {
    # Projet sans code (WP-0019) : SEUL le dossier meta est cree (fiche + squelette), pas le kit.
    $date = Get-Date -Format "yyyy-MM-dd"
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    New-Item -ItemType Directory -Force -Path "$target/$MetaFolder/backlog","$target/$MetaFolder/logs","$target/$MetaFolder/report","$target/$MetaFolder/registry" | Out-Null
    $fiche = [System.IO.File]::ReadAllText((Join-Path $Root "tools/templates/fiche-projet.md"), [System.Text.Encoding]::UTF8)
    $fiche = $fiche.Replace("{{NOM}}", $name).Replace("{{DATE}}", $date)
    [System.IO.File]::WriteAllText((Join-Path $target "$MetaFolder/fiche.md"), $fiche, $utf8)
    [System.IO.File]::WriteAllText((Join-Path $target "$MetaFolder/logs/.gitkeep"), "", $utf8)
    [System.IO.File]::WriteAllText((Join-Path $target "$MetaFolder/report/.gitkeep"), "", $utf8)
    Write-Host ""
    Write-Host "Projet documentaire cree (sans kit) : $target"
    Write-Host ("  {0}/ a l etat (fiche + squelette) - le repo ne contient que la couche meta." -f $MetaFolder)
    Write-Host ""
    Write-Host "  Plus tard, si le kit complet est utile : assistant add <nom>  (zero ecrasement, $MetaFolder conserve)"
    Write-Host "  Prochain pas :"
    Write-Host "    avec l'agent : assistant add <nom>  puis  cd $target  +  opencode  (test : il annonce la phase)"
    Write-Host "    sans l'agent : ouvrir $MetaFolder/fiche.md et travailler le markdown directement"
    return
  }
  New-Item -ItemType Directory -Force -Path $target | Out-Null
  $res = Deploy-Kit -Target $target -Nom $name
  Write-Host ""
  Write-Host "Projet cree : $target"
  Write-Host ("  {0} elements copies, {1} ignores." -f $res.Copied, $res.Skipped.Count)
  foreach ($s in $res.Skipped) { Write-Host ("  - ignore (pre-existant) : {0}" -f $s) }
  Write-Host ""
  Write-Host "  Le projet est MINCE : la doc (projet.md, 01..05, _meta) + la config de connexion + le lanceur + le bootstrap."
  Write-Host "  L'outillage (protocole, templates, checklists, harness) vit dans le bundle (le repo assistant), pointe par $MetaFolder/registry/connexions.md."
  Write-Host ""
  Write-Host "  PM2 : 4 phases (Lancement -> Planification -> Execution -> Cloture), chacune cloturee par un gate (checklist)."
  Write-Host "  On attaque par la Lancement. Une phase peut etre sautee, mais le statut le signalera ensuite - a faire par maitrise ou curiosite."
  Write-Host ""
  Write-Host "  Prochain pas : aller dans le projet et lancer l'agent :"
  Write-Host "    cd $target"
  Write-Host "    opencode   (l'agent lit le protocole via opencode.json -> annonce la phase + gate : C'EST LE TEST)"
  Write-Host "  Puis tester :  /ap-statut-projet   (phase + gate + avancement)  -  et dire : ' commence le projet '"
  Write-Host "  Verifier le bundle + le harness :  .\assistant.ps1 sync   (depuis le projet)"
  Write-Host "  Une remarque sur le kit ? Note-la :  assistant remark '...'  (depuis le projet, remonte au projet assistant)"
  Write-Host "  (ou, sans ouvrir opencode : assistant commence $name)"
}

function Cmd-Add([string]$path) {
  if ([string]::IsNullOrWhiteSpace($path)) { Write-Host "Usage : assistant add <dossier>"; return }
  # Resolution : chemin absolu ou relatif au dossier courant ; sinon recherche sous chaque racine.
  $target = (Resolve-Path $path -ErrorAction SilentlyContinue)
  if ($null -eq $target) {
    $found = @()
    foreach ($r in (Get-Racines)) {
      $c = Join-Path $r $path
      if (Test-Path $c -PathType Container) { $found += (Resolve-Path $c) }
    }
    if ($found.Count -eq 0) { Write-Host "Dossier introuvable : $path (cherche le dossier courant + les racines) - pour un projet NEUF : assistant new <nom>"; return }
    $target = $found[0]
  }
  $target = $target.Path
  if (-not (Test-Path (Join-Path $target "projet.md")) -and -not (Test-Path (Join-Path $target "AGENT-projet.md")) -and -not (Test-Path (Join-Path $target $MetaFolder))) {
    Write-Host "Aucun marqueur d'assistant dans '$target' : ajout dans un dossier vierge (OK)."
  }
  $res = Deploy-Kit -Target $target -Nom (Split-Path $target -Leaf)
  Write-Host ""
  Write-Host "Assistant ajoute (mince) : $target"
  Write-Host ("  {0} elements copies, {1} ignores." -f $res.Copied, $res.Skipped.Count)
  foreach ($s in $res.Skipped) { Write-Host ("  - ignore (pre-existant) : {0}" -f $s) }
  $leaf = Split-Path $target -Leaf
  Write-Host ""
  Write-Host "  Le projet est MINCE : la doc (projet.md, 01..05, _meta) + la config de connexion + le lanceur + le bootstrap."
  Write-Host "  L'outillage (protocole, templates, checklists, harness) vit dans le bundle (le repo assistant), pointe par $MetaFolder/registry/connexions.md."
  Write-Host ""
  Write-Host "  PM2 : 4 phases (Lancement -> Planification -> Execution -> Cloture), chacune cloturee par un gate (checklist)."
  Write-Host "  On attaque par la Lancement. Une phase peut etre sautee, mais le statut le signalera ensuite - a faire par maitrise ou curiosite."
  Write-Host ""
  Write-Host "  Prochain pas : aller dans le projet et lancer l'agent :"
  Write-Host "    cd $target"
  Write-Host "    opencode   (l'agent lit le protocole via opencode.json -> annonce la phase + gate : C'EST LE TEST)"
  Write-Host "  Puis tester :  /ap-statut-projet   (phase + gate + avancement)  -  et dire : ' commence le projet '"
  Write-Host "  Verifier le bundle + le harness :  .\assistant.ps1 sync   (depuis le projet)"
  Write-Host "  Une remarque sur le kit ? Note-la :  assistant remark '...'  (depuis le projet, remonte au projet assistant)"
  Write-Host "  (ou, sans ouvrir opencode : assistant commence $leaf)"
}

function Cmd-Commence([string]$name) {
  if ([string]::IsNullOrWhiteSpace($name)) { Write-Host "Usage : assistant commence <nom>"; return }
  $p = Find-Project $name
  if ($null -eq $p) {
    Write-Host "Projet '$name' introuvable. Pour le creer : assistant new ${name}"
    return
  }
  if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
    Write-Host "opencode absent. L'installer : npm install -g opencode-ai  (puis relancer)"
    return
  }
  Write-Host ""
  Write-Host "Handoff vers l'agent : demarrage de '$name' dans opencode."
  Write-Host "  (l'agent lit AGENT-projet.md ou _meta/fiche.md -> annonce la phase -> propose le prochain artefact)"
  Push-Location $p
  try { opencode } finally { Pop-Location }
}

function Show-Menu {
  Write-Host ""
  Write-Host "================================================"
  Write-Host " assistant - menu  (sans IA : rapide, gratuit)"
  Write-Host "================================================"
  Write-Host "  PM2 : Lancement -> Planification -> Execution -> Cloture  (1 gate = 1 checklist par phase)"
  Write-Host ""
  Write-Host "  -- Gerer les projets (depuis le kit ou les racines) --"
  Write-Host "  scan                 les projets des racines : assistes (mince / copie complete) / pourraient / sans signal"
  Write-Host "  liste                les projets (nom + phase + gate)"
  Write-Host "  statut <projet>      phase + gate + avancement d'un projet par son nom"
  Write-Host "  new <nom> [racine] [-doc]   creer un projet MINCE  (-doc = SEUL _meta, sans outillage : projet sans code)"
  Write-Host "  add <dossier>        ajouter l'assistant (mince) a un projet existant (jamais d'ecrasement)"
  Write-Host "  install.ps1          (re)initialiser la config transversale (racines, connexions)"
  Write-Host ""
  Write-Host "  -- Dans un projet (depuis le dossier du projet) --"
  Write-Host "  statut               le statut du projet courant (sans argument)"
  Write-Host "  sync [--force-harness]  verifier le bundle (version) + le harness opencode (remplace update - WP-0025)"
  Write-Host "  bootstrap          (re)installer le bundle sur cette machine : pointer / chercher / installer + harness"
  Write-Host "  remark <texte>       journal des remarques au vol (remontee au projet assistant)"
  Write-Host "  commence <nom>       -> L'AGENT : ouvre opencode dans le projet (conduite, mode B/C)"
  Write-Host "  menu / ?             ce menu"
  Write-Host ""
}

# -- Dispatch ------------------------------------------------------------------
if ($args.Count -eq 0) { Show-Menu; return }
$c = $args[0] -replace '^[/-]', ''
switch -regex ($c) {
  '^scan$' { Cmd-Scan }
  '^statut$' { Cmd-Statut $args[1] }
  '^new$' {
    # Arguments de `new` : <nom> [racine] [-doc] (l'ordre du flag importe pas)
    $docFlag = $false; $nName = ""; $nRoot = ""
    if ($args.Count -ge 2) {
      foreach ($a in $args[1..($args.Count-1)]) {
        if ($a -eq "-doc") { $docFlag = $true } elseif ($nName -eq "") { $nName = $a } else { $nRoot = $a }
      }
    }
    Cmd-New $nName $nRoot $docFlag
  }
  '^add$' { Cmd-Add $args[1] }
  '^liste$' { Show-ProjetListe }
  '^sync$' { if ($args.Count -ge 2 -and $args[1] -eq "--force-harness") { Cmd-Sync $true } else { Cmd-Sync $false } }
  '^update$' { Write-Host "update est devenu sync (WP-0025 : projet mince - plus de copie locale a resynchroniser)"; if ($args.Count -ge 2 -and $args[1] -eq "--force-harness") { Cmd-Sync $true } else { Cmd-Sync $false } }
  '^bootstrap$' { $ex = @(); if ($args.Count -ge 2) { $ex = @($args[1..($args.Count - 1)]) }; Cmd-Bootstrap $ex }
  '^remark$' { Cmd-Remarque $args[1] }
  '^commence$' { Cmd-Commence $args[1] }
  '^menu$|^\?$' { Show-Menu }
  default { Write-Host "Commande inconnue : $c"; Show-Menu }
}