# assistant.ps1 - assistant-projet-pm2 : ENTRY-POINT NATIF (deterministe, sans IA, sans dependance)
# Principe : tout ce qui est faisable sans IA se fait sans IA.
#   - l'IA (l'agent opencode) n'intervient QUE pour : conduire (mode B), ecouter (mode C), decider (add-ons).
#   - le reste (trouver les projets, classer, lire le frontmatter, ajouter le kit) est deterministe -> ici.
#
# Usage : .\assistant.ps1 <cmd> [args]      (macOS/Linux : ./assistant.sh <cmd> [args])
#   scan               liste les projets des racines (assistes / pourraient / sans signal)
#   statut <projet>    phase + gate + avancement d'un projet (sans argument : le projet courant, ou la liste)
#   liste              les projets (nom + phase + gate) - depuis le kit ou les racines
#   new <nom> [racine] cree un projet (copie du kit + _meta neuf)
#   add <dossier>      ajoute le kit a un projet existant (jamais d'ecrasement)
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

# Copie du kit dans $target. $nom = nom du projet (pour pre-remplir projet.md + fiche).
# Ne copie JAMAIS les donnees d'inception du kit (_meta/fiche.md du kit, backlog/WP-*, logs/*, registry local).
# Jamais d'ecrasement : un fichier/dossier pre-existant est signale et ignore.
function Copy-Kit([string]$target, [string]$nom) {
  $date = Get-Date -Format "yyyy-MM-dd"
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  $copied = 0
  $skipped = @()

  # 1) Fichiers racine du kit (generiques)
  foreach ($f in @("AGENT-projet.md","referentiel-templates-PM2.md","opencode.json",".gitignore","assistant.ps1","assistant.sh")) {
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

  # 5) dossier meta NEUF (pas celui du kit) - nom = meta_folder (defaut _meta)
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
      "# registry/connexions.md - registres des connexions du projet`nkit_source: $Root`n", $utf8)
    [System.IO.File]::WriteAllText((Join-Path $proj "logs/.gitkeep"), "", $utf8)
    [System.IO.File]::WriteAllText((Join-Path $proj "report/.gitkeep"), "", $utf8)
    $copied += 1
  }

  return @{ Copied = $copied; Skipped = $skipped }
}

# Resync des fichiers GENERIQUES du kit vers le projet (zero ecrasement : seuls les
# fichiers ABSENTS du projet sont copies, y compris a l'interieur des dossiers existants).
# Retourne la liste des chemins ajoutes (relatifs au projet).
function Update-Kit([string]$target, [string]$kitRoot) {
  $added = @()
  # 1) Fichiers racine generiques (JAMAIS .gitignore = data du projet)
  foreach ($f in @("AGENT-projet.md","referentiel-templates-PM2.md","opencode.json","assistant.ps1","assistant.sh")) {
    $s = Join-Path $kitRoot $f
    $d = Join-Path $target $f
    if ((Test-Path $s) -and -not (Test-Path $d)) { Copy-Item $s $d; $added += $f }
  }
  # 2) Dossiers de phases + checklists + docs + tools : les fichiers manquants (recursif)
  $dirs = @(Get-ChildItem -Path $kitRoot -Directory |
    Where-Object { $_.Name -match '^0[0-9] ' -or @("checklists","docs","tools") -contains $_.Name } |
    ForEach-Object { $_.Name })
  foreach ($d in $dirs) {
    $src = Join-Path $kitRoot $d
    $dst = Join-Path $target $d
    if (-not (Test-Path $dst)) {
      Copy-Item $src $dst -Recurse
      $added += "$d/ (dossier entier)"
    } else {
      $srcLen = $src.Length
      $missing = @(Get-ChildItem $src -File -Recurse | Where-Object { -not (Test-Path (Join-Path $dst $_.FullName.Substring($srcLen + 1))) })
      foreach ($m in $missing) {
        $rel = $m.FullName.Substring($srcLen + 1)
        $mdst = Join-Path $dst $rel
        $mdir = Split-Path $mdst -Parent
        if (-not (Test-Path $mdir)) { New-Item -ItemType Directory -Force -Path $mdir | Out-Null }
        Copy-Item $m.FullName $mdst
        $added += (Join-Path $d $rel)
      }
    }
  }
  # 3) .opencode/agent + command (fichiers manquants, recursif)
  foreach ($sub in @("agent","command")) {
    $src = Join-Path $kitRoot ".opencode/$sub"
    $dst = Join-Path $target ".opencode/$sub"
    if (-not (Test-Path $src)) { continue }
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
function Cmd-Update {
  # Lance DEPUIS le projet (dossier courant) : resync le kit generique, zero ecrasement.
  $p = (Get-Location).Path
  if (-not (Test-ProjectDir $p)) {
    Write-Host "Tu n'es pas dans un projet (relancer depuis le dossier d'un projet - avec projet.md ou _meta/)."
    return
  }
  # Origine du kit : ligne 'kit_source: <chemin>' dans _meta/registry/connexions.md
  $reg = Join-Path $p "$MetaFolder/registry/connexions.md"
  $kitSrc = $null
  if (Test-Path $reg) {
    foreach ($l in (Get-Content $reg -Encoding UTF8)) {
      if ($l -match '^\s*kit_source:\s*(.+)$') { $kitSrc = $Matches[1].Trim(); break }
    }
  }
  if ($null -eq $kitSrc) {
    Write-Host "Pas de 'kit_source' dans $reg - je ne sais pas d'ou vient le kit."
    Write-Host "  Ajoute la ligne : kit_source: <chemin du kit>"
    return
  }
  if (-not (Test-Path (Join-Path $kitSrc "assistant.ps1"))) {
    Write-Host "Kit source introuvable ou invalide : $kitSrc"
    return
  }
  Write-Host ""
  Write-Host "Update du kit depuis : $kitSrc"
  Write-Host "  (zero ecrasement : seuls les fichiers du kit manquants sont ajoutes)"
  $added = @(Update-Kit -Target $p -KitRoot $kitSrc)
  if ($added.Count -eq 0) {
    Write-Host "  Deja a jour - rien a ajouter."
  } else {
    Write-Host ("  {0} elements ajoutes :" -f $added.Count)
    foreach ($a in $added) { Write-Host ("    + $a") }
  }
  Write-Host ""
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
    $kits = @(); $parts = @(); $pourrs = @(); $plain = @()
    $mfScan = (Get-MetaFolder)
    foreach ($d in $dirs) {
      $hasP = Test-Path (Join-Path $d.FullName "projet.md")
      $hasA = Test-Path (Join-Path $d.FullName "AGENT-projet.md")
      $hasM = Test-Path (Join-Path $d.FullName $mfScan)
      if ($hasP -and $hasA) { $kits += $d }
      elseif ($hasP -or $hasA) { $parts += $d }
      elseif ($hasM) { $parts += $d }
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
      foreach ($d in $parts) {
        $hasP = Test-Path (Join-Path $d.FullName "projet.md")
        $hasA = Test-Path (Join-Path $d.FullName "AGENT-projet.md")
        $hasM = Test-Path (Join-Path $d.FullName $mfScan)
        $detail = "kit partiel (manque projet.md ou AGENT-projet.md)"
        if ($hasM -and -not $hasP) { $detail = "projet sans code (ne contient que $mfScan) -> assistant add" }
        elseif ($hasM -and -not $hasA) { $detail = "kit partiel (manque AGENT-projet.md)" }
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
    $t_kit += $kits.Count; $t_part += $parts.Count; $t_pour += $pourrs.Count; $t_plain += $plain.Count
    Write-Host ("  -> {0} dossiers : {1} assistes, {2} a completer, {3} pourraient, {4} sans signal" -f $dirs.Count, $kits.Count, $parts.Count, $pourrs.Count, $plain.Count)
  }
  Write-Host ""
  Write-Host ("Total : {0} dossiers - {1} assistes, {2} a completer, {3} pourraient, {4} sans signal" -f ($t_kit + $t_part + $t_pour + $t_plain), $t_kit, $t_part, $t_pour, $t_plain)
  Write-Host "Travailler sur un projet :  assistant commence <nom>   (ou, dans opencode : 'commence le projet <nom>')"
  Write-Host "Ajouter le kit a un dossier :  assistant add <dossier>   (jamais d'ecrasement)"
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
  $res = Copy-Kit -Target $target -Nom $name
  Write-Host ""
  Write-Host "Projet cree : $target"
  Write-Host ("  {0} elements copies, {1} ignores." -f $res.Copied, $res.Skipped.Count)
  foreach ($s in $res.Skipped) { Write-Host ("  - ignore (pre-existant) : {0}" -f $s) }
  Write-Host ""
  Write-Host "  PM2 : 4 phases (Lancement -> Planification -> Execution -> Cloture), chacune cloturee par un gate (checklist)."
  Write-Host "  On attaque par la Lancement. Une phase peut etre sautee, mais le statut le signalera ensuite - a faire par maitrise ou curiosite."
  Write-Host ""
  Write-Host "  Prochain pas : aller dans le projet et lancer l'agent :"
  Write-Host "    cd $target"
  Write-Host "    opencode   (l'agent lit AGENT-projet.md -> annonce la phase + gate : C'EST LE TEST)"
  Write-Host "  Puis tester :  /ap-statut-projet   (phase + gate + avancement)  -  et dire : ' commence le projet '"
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
  if (-not (Test-Path (Join-Path $target "projet.md")) -and -not (Test-Path (Join-Path $target "AGENT-projet.md"))) {
    Write-Host "Aucun marqueur de kit dans '$target' : ajout du kit dans un dossier vierge (OK)."
  }
  $res = Copy-Kit -Target $target -Nom (Split-Path $target -Leaf)
  Write-Host ""
  Write-Host "Kit ajoute : $target"
  Write-Host ("  {0} elements copies, {1} ignores." -f $res.Copied, $res.Skipped.Count)
  foreach ($s in $res.Skipped) { Write-Host ("  - ignore (pre-existant) : {0}" -f $s) }
  $leaf = Split-Path $target -Leaf
  Write-Host ""
  Write-Host "  PM2 : 4 phases (Lancement -> Planification -> Execution -> Cloture), chacune cloturee par un gate (checklist)."
  Write-Host "  On attaque par la Lancement. Une phase peut etre sautee, mais le statut le signalera ensuite - a faire par maitrise ou curiosite."
  Write-Host ""
  Write-Host "  Prochain pas : aller dans le projet et lancer l'agent :"
  Write-Host "    cd $target"
  Write-Host "    opencode   (l'agent lit AGENT-projet.md -> annonce la phase + gate : C'EST LE TEST)"
  Write-Host "  Puis tester :  /ap-statut-projet   (phase + gate + avancement)  -  et dire : ' commence le projet '"
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
  Write-Host "  scan                 les projets des racines : assistes / pourraient / sans signal"
  Write-Host "  liste                les projets (nom + phase + gate)"
  Write-Host "  statut <projet>      phase + gate + avancement d'un projet par son nom"
  Write-Host "  new <nom> [racine] [-doc]   creer un projet  (-doc = SEUL _meta, sans kit : projet sans code)"
  Write-Host "  add <dossier>        ajouter le kit a un projet existant (jamais d'ecrasement)"
  Write-Host "  install.ps1          (re)initialiser la config transversale (racines, connexions)"
  Write-Host ""
  Write-Host "  -- Dans un projet (depuis le dossier du projet) --"
  Write-Host "  statut               le statut du projet courant (sans argument)"
  Write-Host "  update               resync le kit de CE projet (zero ecrasement)"
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
  '^update$' { Cmd-Update }
  '^remark$' { Cmd-Remarque $args[1] }
  '^commence$' { Cmd-Commence $args[1] }
  '^menu$|^\?$' { Show-Menu }
  default { Write-Host "Commande inconnue : $c"; Show-Menu }
}