# assistant.ps1 - assistant-projet-pm2 : ENTRY-POINT NATIF (deterministe, sans IA, sans dependance)
# Principe : tout ce qui est faisable sans IA se fait sans IA.
#   - l'IA (l'agent opencode) n'intervient QUE pour : conduire (mode B), ecouter (mode C), decider (add-ons).
#   - le reste (trouver les projets, classer, lire le frontmatter, ajouter le kit) est deterministe -> ici.
#
# Usage : .\assistant.ps1 <cmd> [args]      (macOS/Linux : ./assistant.sh <cmd> [args])
#   scan               liste les projets des racines (assistes / pourraient / sans signal)
#   statut <projet>    phase + gate + avancement d'un projet
#   new <nom> [racine] cree un projet (copie du kit + _projet neuf)
#   add <dossier>      ajoute le kit a un projet existant (jamais d'ecrasement)
#   commence <nom>     -> l'agent : ouvre opencode dans le projet (handoff)
#   menu / ?           ce menu
#
# Pure ASCII (Windows PowerShell 5.1 lit les .ps1 en ANSI sans BOM UTF-8).
# La logique de scan/statut vit ICI (source unique) : les commandes opencode /scan /statut l'appellent.

$ErrorActionPreference = "Stop"
# PSScriptRoot (et pas $MyInvocation.MyCommand.Path) : robuste quel que soit le mode d'appel
# (-File, & depuis un autre script, dot-sourcing). = le dossier qui contient ce script.
$Root = $PSScriptRoot
$RegDir = Join-Path $Root "_projet/registry"
$OldConn = Join-Path $RegDir "connexions.md"   # registre ANCIEN (fallback de transition)

# Config machine a la racine du kit (WP-0017) : 1er des 3 noms qui existe.
$Config = $null
foreach ($cn in @(".assistant.config", "assistant.config", "assistant.config.md")) {
  if (Test-Path (Join-Path $Root $cn)) { $Config = Join-Path $Root $cn; break }
}

# Nom du dossier meta (defaut _projet) - lu de la config s'il existe.
function Get-MetaFolder {
  if ($null -ne $Config -and (Test-Path $Config)) {
    foreach ($l in (Get-Content $Config -Encoding UTF8)) {
      if ($l -match '^\s*meta_folder\s*=\s*(.+)$') {
        $v = $Matches[1].Trim()
        if ($v -ne "") { return $v }
      }
    }
  }
  return "_projet"
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

function Find-Project([string]$name) {
  $c = Join-Path $Root $name
  if (Test-Path (Join-Path $c "projet.md")) { return (Resolve-Path $c).Path }
  $c = Join-Path (Get-Location).Path $name
  if (Test-Path (Join-Path $c "projet.md")) { return (Resolve-Path $c).Path }
  foreach ($r in (Get-Racines)) {
    $c = Join-Path $r $name
    if (Test-Path (Join-Path $c "projet.md")) { return (Resolve-Path $c).Path }
  }
  return $null
}

# Copie du kit dans $target. $nom = nom du projet (pour pre-remplir projet.md + fiche).
# Ne copie JAMAIS les donnees d'inception du kit (_projet/fiche.md du kit, backlog/WP-*, logs/*, registry local).
# Jamais d'ecrasement : un fichier/dossier pre-existant est signale et ignore.
function Copy-Kit([string]$target, [string]$nom) {
  $date = Get-Date -Format "yyyy-MM-dd"
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  $copied = 0
  $skipped = @()

  # 1) Fichiers racine du kit (generiques)
  foreach ($f in @("AGENT-projet.md","referentiel-templates-PM2.md","opencode.json",".gitignore")) {
    if (Test-Path (Join-Path $Root $f)) {
      if (Test-Path (Join-Path $target $f)) { $skipped += $f }
      else { Copy-Item (Join-Path $Root $f) (Join-Path $target $f); $copied++ }
    }
  }

  # 2) Dossiers de phases + checklists + docs + tools (liste par pattern, pas en dur)
  $dirs = @(Get-ChildItem -Path $Root -Directory |
    Where-Object { $_.Name -match '^0[0-9] ' -or @("checklists","docs","tools") -contains $_.Name } |
    ForEach-Object { $_.Name })
  foreach ($d in $dirs) {
    if (Test-Path (Join-Path $target $d)) { $skipped += "$d/" }
    else { Copy-Item (Join-Path $Root $d) (Join-Path $target $d) -Recurse; $copied++ }
  }

  # 3) .opencode (agent + command, SANS node_modules)
  $ocDst = Join-Path $target ".opencode"
  if (Test-Path $ocDst) { $skipped += ".opencode/" }
  else {
    New-Item -ItemType Directory -Force -Path $ocDst | Out-Null
    foreach ($sub in @("agent","command")) {
      $src = Join-Path $Root ".opencode/$sub"
      if (Test-Path $src) { Copy-Item $src (Join-Path $ocDst $sub) -Recurse }
    }
    if (Test-Path "$Root/.opencode/.gitignore") { Copy-Item "$Root/.opencode/.gitignore" "$ocDst/.gitignore" }
    $copied += 1
  }

  # 4) projet.md : copie du template avec pre-remplissage (nom + date), sans accent en source
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

  # 5) dossier meta NEUF (pas celui du kit) - nom = meta_folder (defaut _projet)
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
    [System.IO.File]::WriteAllText((Join-Path $proj "registry/connexions.md"),
      "# registry/connexions.md - registres des connexions du projet`n", $utf8)
    [System.IO.File]::WriteAllText((Join-Path $proj "logs/.gitkeep"), "", $utf8)
    [System.IO.File]::WriteAllText((Join-Path $proj "report/.gitkeep"), "", $utf8)
    $copied += 1
  }

  return @{ Copied = $copied; Skipped = $skipped }
}

# -- Commandes -----------------------------------------------------------------
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
    $kits = @(); $parts = @(); $pourrs = @(); $plain = @()
    foreach ($d in $dirs) {
      $hasP = Test-Path (Join-Path $d.FullName "projet.md")
      $hasA = Test-Path (Join-Path $d.FullName "AGENT-projet.md")
      if ($hasP -and $hasA) { $kits += $d }
      elseif ($hasP -or $hasA) { $parts += $d }
      else {
        $s = @(Get-Signaux $d.FullName)
        if ($s.Count -gt 0) { $pourrs += [pscustomobject]@{ Dir = $d; Sig = $s } }
        else { $plain += $d }
      }
    }
    if ($kits.Count -gt 0) {
      Write-Host "  [Assistes]"
      foreach ($d in $kits) {
        $fm = Read-Frontmatter (Join-Path $d.FullName "projet.md")
        Write-Host ("    + {0}  -  phase {1}, gate {2}" -f $d.Name, $fm["phase"], $fm["gate_suivant"])
      }
    }
    if ($parts.Count -gt 0) {
      Write-Host "  [A completer]"
      foreach ($d in $parts) { Write-Host ("    ~ {0}  -  kit partiel (manque projet.md ou AGENT-projet.md)" -f $d.Name) }
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
    $t_kit += $kits.Count; $t_part += $parts.Count; $t_pour += $pourrs.Count; $t_plain += $plain.Count
    Write-Host ("  -> {0} dossiers : {1} assistes, {2} a completer, {3} pourraient, {4} sans signal" -f $dirs.Count, $kits.Count, $parts.Count, $pourrs.Count, $plain.Count)
  }
  Write-Host ""
  Write-Host ("Total : {0} dossiers - {1} assistes, {2} a completer, {3} pourraient, {4} sans signal" -f ($t_kit + $t_part + $t_pour + $t_plain), $t_kit, $t_part, $t_pour, $t_plain)
  Write-Host "Travailler sur un projet :  assistant commence <nom>   (ou, dans opencode : 'commence le projet <nom>')"
  Write-Host "Ajouter le kit a un dossier :  assistant add <dossier>   (jamais d'ecrasement)"
}

function Cmd-Statut([string]$name) {
  if ([string]::IsNullOrWhiteSpace($name)) { Write-Host "Usage : assistant statut <projet>"; return }
  $p = Find-Project $name
  if ($null -eq $p) {
    Write-Host "Projet '$name' introuvable (cherche dans le kit, le dossier courant et les racines)."
    return
  }
  $fm = Read-Frontmatter (Join-Path $p "projet.md")
  Write-Host ""
  Write-Host "=== Statut : $(Split-Path $p -Leaf) ==="
  Write-Host ("  Phase : {0}   |   Gate suivant : {1}" -f $fm["phase"], $fm["gate_suivant"])
  $r1 = @(); if ($fm["sponsor"]) { $r1 += "sponsor: $($fm['sponsor'])" }; if ($fm["bm"]) { $r1 += "bm: $($fm['bm'])" }; if ($fm["cp"]) { $r1 += "cp: $($fm['cp'])" }; if ($fm["moe"]) { $r1 += "moe: $($fm['moe'])" }
  if ($r1.Count -gt 0) { Write-Host ("  Roles   : {0}" -f ($r1 -join "  |  ")) } else { Write-Host "  Roles   : (non identifies)" }
  $c1 = @(); if ($fm["sp_project"]) { $c1 += "SP: $($fm['sp_project'])" }; if ($fm["op_id"]) { $c1 += "OP: $($fm['op_id'])" }
  if ($c1.Count -gt 0) { Write-Host ("  Tickets : {0}" -f ($c1 -join "  |  ")) } else { Write-Host "  Tickets : (aucune connexion active)" }
  # Table "Etat de la phase" (section 3 du projet.md)
  $in3 = $false; $table = $false
  $lines3 = [System.IO.File]::ReadAllLines((Join-Path $p "projet.md"), [System.Text.Encoding]::UTF8)
  foreach ($l in $lines3) {
    if ($l -match '^## 3\.') { $in3 = $true; continue }
    if ($in3 -and $l -match '^## ') { break }
    if ($in3 -and $l.TrimStart().StartsWith("|")) {
      if (-not $table -and $l -match '^\| Phase \|') { $table = $true; Write-Host "  Avancement :" }
      if ($table) { Write-Host ("    {0}" -f $l.Trim()) }
    }
  }
}

function Cmd-New([string]$name, [string]$rootOverride) {
  if ([string]::IsNullOrWhiteSpace($name)) { Write-Host "Usage : assistant new <nom> [racine]"; return }
  # NB : pas de $root ici - PowerShell est insensible a la casse, $root ecraserait le $Root global (chemin du kit).
  $rroot = $rootOverride
  if ([string]::IsNullOrWhiteSpace($rroot)) {
    $roots = @(Get-Racines)
    if ($roots.Count -eq 0) { Write-Host "Aucune racine definie : passe une racine (assistant new <nom> <racine>) ou lance install."; return }
    $rroot = $roots[0]
  }
  $target = Join-Path $rroot $name
  if (Test-Path $target) { Write-Host "'$target' existe deja -> rien n'est cree ni ecrase."; return }
  New-Item -ItemType Directory -Force -Path $target | Out-Null
  $res = Copy-Kit -Target $target -Nom $name
  Write-Host ""
  Write-Host "Projet cree : $target"
  Write-Host ("  {0} elements copies, {1} ignores." -f $res.Copied, $res.Skipped.Count)
  foreach ($s in $res.Skipped) { Write-Host ("  - ignore (pre-existant) : {0}" -f $s) }
  Write-Host ""
  Write-Host "  Prochain pas : assistant commence ${name}   (l'agent prend le relais, phase Lancement)"
}

function Cmd-Add([string]$path) {
  if ([string]::IsNullOrWhiteSpace($path)) { Write-Host "Usage : assistant add <dossier>"; return }
  $target = (Resolve-Path $path -ErrorAction SilentlyContinue)
  if ($null -eq $target) { Write-Host "Dossier introuvable : $path (pour un projet NEUF : assistant new <nom>)"; return }
  $target = $target.Path
  if (-not (Test-Path (Join-Path $target "projet.md")) -and -not (Test-Path (Join-Path $target "AGENT-projet.md"))) {
    Write-Host "Aucun marqueur de kit dans '$target' : ajout du kit dans un dossier vierge (OK)."
  }
  $res = Copy-Kit -Target $target -Nom (Split-Path $target -Leaf)
  Write-Host ""
  Write-Host "Kit ajoute : $target"
  Write-Host ("  {0} elements copies, {1} ignores." -f $res.Copied, $res.Skipped.Count)
  foreach ($s in $res.Skipped) { Write-Host ("  - ignore (pre-existant) : {0}" -f $s) }
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
  Write-Host "  (l'agent lit AGENT-projet.md -> annonce la phase -> propose le prochain artefact)"
  Push-Location $p
  try { opencode } finally { Pop-Location }
}

function Show-Menu {
  Write-Host ""
  Write-Host "================================================"
  Write-Host " assistant - menu  (sans IA : rapide, gratuit)"
  Write-Host "================================================"
  Write-Host "  scan                 les projets des racines : assistes / pourraient / sans signal"
  Write-Host "  statut <projet>      phase + gate + avancement"
  Write-Host "  new <nom> [racine]   creer un projet (kit + _projet neuf)"
  Write-Host "  add <dossier>        ajouter le kit a un projet existant (jamais d'ecrasement)"
  Write-Host "------------------------------------------------"
  Write-Host "  commence <nom>       -> L'AGENT : ouvre opencode dans le projet (conduite, mode B/C)"
  Write-Host "  install.ps1          (re)initialiser la config transversale (racines, connexions)"
  Write-Host "  menu / ?             ce menu"
  Write-Host ""
}

# -- Dispatch ------------------------------------------------------------------
if ($args.Count -eq 0) { Show-Menu; return }
$c = $args[0] -replace '^[/-]', ''
switch -regex ($c) {
  '^scan$' { Cmd-Scan }
  '^statut$' { Cmd-Statut $args[1] }
  '^new$' { Cmd-New $args[1] $(if ($args.Count -ge 3) { $args[2] } else { "" }) }
  '^add$' { Cmd-Add $args[1] }
  '^commence$' { Cmd-Commence $args[1] }
  '^menu$|^\?$' { Show-Menu }
  default { Write-Host "Commande inconnue : $c"; Show-Menu }
}
