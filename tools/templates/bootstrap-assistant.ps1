# bootstrap.ps1 - BOOTSTRAP (WP-0025) - NATIF (sans IA, sans dependance)
# Cet espace projet fonctionne avec l'"assistant de gestion de projet" (PM2).
# Si l'assistant (le bundle = le repo assistant) n'est pas detecte sur cette machine,
# ce script :
#   - explique tout a l'utilisateur et demande confirmation AVANT chaque action,
#   - propose : pointer <chemin> | chercher <dossier...> | installer (git clone de la config partagee),
#   - puis propose la meme operation pour le harness opencode (la couche IA).
# L'emplacement de l'assistant est ecrit dans _meta/registry/connexions.local.md (machine, gitignore).
# Jamais d'ecrasement : seules la ligne assistant_local de la config machine (et les fichiers
# ABSENTS du harness) sont ecrits.
$ErrorActionPreference = "Stop"
$proj = $PSScriptRoot

# --- Helpers ------------------------------------------------------------------
function Read-ConfLine([string]$file, [string]$key) {
  if (-not (Test-Path $file)) { return "" }
  foreach ($l in (Get-Content $file -Encoding UTF8)) {
    if ($l -match '^\s*' + [regex]::Escape($key) + '\s*:\s*(.+)$') { return $Matches[1].Trim() }
  }
  return ""
}

# Lit une ligne (Read-Host, tolere la fin d'entree).
function Read-Line {
  $v = $null
  try { $v = Read-Host } catch { $v = $null }
  if ($null -eq $v) { return "" }
  return $v
}

# Ecrit/remplace la ligne "key: value" dans une config (zero ecrasement : les autres lignes intactes).
function Set-ConfLine([string]$file, [string]$key, [string]$value) {
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  $lines = @()
  if (Test-Path $file) { $lines = @(Get-Content $file -Encoding UTF8) }
  $done = $false
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\s*' + [regex]::Escape($key) + '\s*:') { $lines[$i] = "${key}: $value"; $done = $true }
  }
  if (-not $done) { $lines += "${key}: $value" }
  [System.IO.File]::WriteAllLines($file, $lines, $utf8)
}

# Annonce + confirmation (o/n). Retourne un bool.
function Confirm-Action([string]$what) {
  Write-Host ""
  Write-Host ("Action a effectuer : {0}" -f $what)
  Write-Host "  proceder ? (o/n) " -NoNewline
  $a = (Read-Line).Trim().ToLower()
  return ($a -eq "o" -or $a -eq "oui" -or $a -eq "yes" -or $a -eq "y")
}

# --- Etat (detection, lecture seule) -------------------------------------------
$mf = "_meta"
$shared = Join-Path $proj "$mf/registry/connexions.md"
$localf = Join-Path $proj "$mf/registry/connexions.local.md"
$mfCfg = Read-ConfLine $shared "meta_folder"
if ($mfCfg -ne "") {
  $shared = Join-Path $proj "$mfCfg/registry/connexions.md"
  $localf = Join-Path $proj "$mfCfg/registry/connexions.local.md"
}
$gitUrl = Read-ConfLine $shared "assistant_git"
$ref = Read-ConfLine $shared "assistant_ref"
if ($ref -eq "") { $ref = "latest" }
$localPath = Read-ConfLine $localf "assistant_local"

# Un bundle valide = un dossier avec assistant.ps1 (ou .sh) + le marqueur .assistant.version.
function Test-BundleRaw([string]$b) {
  if ([string]::IsNullOrWhiteSpace($b)) { return $false }
  $hasEngine = (Test-Path (Join-Path $b "assistant.ps1")) -or (Test-Path (Join-Path $b "assistant.sh"))
  return ($hasEngine -and (Test-Path (Join-Path $b ".assistant.version")))
}

# Resout le moteur effectif (racine du bundle, ou versions/<ref> si assistant_ref != latest).
function Resolve-Engine([string]$b) {
  if (-not (Test-BundleRaw $b)) { return $null }
  if ($ref -ne "latest" -and (Test-Path (Join-Path $b "versions"))) { $b = Join-Path $b "versions/$ref" }
  if (Test-BundleRaw $b) { return $b }
  return $null
}

function Get-BundleVersion([string]$b) {
  $v = (Get-Content (Join-Path $b ".assistant.version") -TotalCount 1).Trim()
  return $v
}

function Show-State {
  Write-Host ""
  Write-Host "Etat detecte (lecture seule) :"
  Write-Host ("  - config partagee : {0}" -f $shared)
  Write-Host ("      assistant_git : {0}" -f $(if ($gitUrl -eq "") { "(non defini)" } else { $gitUrl }))
  Write-Host ("      assistant_ref : {0}" -f $ref)
  if (Test-BundleRaw $localPath) {
    Write-Host ("  - assistant     : present (version {0})" -f (Get-BundleVersion $localPath))
    Write-Host ("      assistant_local : {0}" -f $localPath)
  } else {
    Write-Host "  - assistant     : NON detecte"
    Write-Host ("      assistant_local : {0}" -f $(if ($localPath -eq "") { "(non defini)" } else { "$localPath (invalide)" }))
  }
  if (Get-Command opencode -ErrorAction SilentlyContinue) { Write-Host "  - opencode      : present" }
  else { Write-Host "  - opencode      : NON detecte" }
  if (Test-Path (Join-Path $proj ".opencode/agent/assistant-projet.md")) { Write-Host "  - harness       : deploye (.opencode/)" }
  else { Write-Host "  - harness       : absent (.opencode/)" }
}

# --- Actions -------------------------------------------------------------------

# 1) POINTER - l'utilisateur donne l'emplacement de l'assistant (validation, ecriture config machine).
function Act-Pointer([string]$chemin) {
  if ([string]::IsNullOrWhiteSpace($chemin)) { Write-Host "Usage : bootstrap.ps1 pointer <chemin>"; return }
  if (-not (Test-Path $chemin)) { Write-Host "Chemin inexistant : $chemin"; return }
  if (-not (Test-BundleRaw $chemin)) {
    Write-Host "Assistant non detecte dans : $chemin"
    Write-Host "  (le dossier doit contenir assistant.ps1 ou assistant.sh + le marqueur .assistant.version)"
    return
  }
  if (Confirm-Action "Definir l'emplacement de l'assistant : $chemin`n  (ecrit dans $localf - config machine, gitignoree)") {
    Set-ConfLine $localf "assistant_local" $chemin
    Write-Host "Fait : assistant_local -> $chemin"
    Propose-Opencode
  } else { Write-Host "Annule." }
}

# 2) CHERCHER - recherche du marqueur .assistant.version dans les dossiers indiques (pas de scan de disque entier).
function Act-Chercher([string[]]$dirs) {
  if ($null -eq $dirs -or $dirs.Count -eq 0) { Write-Host "Usage : bootstrap.ps1 chercher <dossier...>"; return }
  $cands = @()
  foreach ($d in $dirs) {
    if ([string]::IsNullOrWhiteSpace($d)) { continue }
    if (-not (Test-Path $d)) { Write-Host "(dossier inexistant : $d)"; continue }
    $m = @(Get-ChildItem -Path $d -Recurse -Depth 3 -Filter ".assistant.version" -Force -ErrorAction SilentlyContinue)
    foreach ($x in $m) {
      $root = $x.Directory.FullName
      if ((Test-BundleRaw $root) -and -not ($cands -contains $root)) { $cands += $root }
    }
  }
  if ($cands.Count -eq 0) {
    Write-Host "Rien trouve (aucun marqueur .assistant.version dans les dossiers indiques)."
    return
  }
  if ($cands.Count -eq 1) { Act-Pointer $cands[0]; return }
  Write-Host ""
  Write-Host ("Candidats ({0}) :" -f $cands.Count)
  for ($i = 0; $i -lt $cands.Count; $i++) { Write-Host ("  {0}) {1}" -f ($i + 1), $cands[$i]) }
  $c = (Read-Line).Trim()
  if ($c -match '^\d+$' -and ([int]$c -ge 1) -and ([int]$c -le $cands.Count)) { Act-Pointer $cands[[int]$c - 1] }
  else { Write-Host "Annule." }
}

# 3) INSTALLER - git clone du repo assistant (assistant_git de la config partagee), puis le definit.
function Act-Installer([string]$dossier) {
  if ($gitUrl -eq "") {
    Write-Host "Pas de assistant_git dans la config partagee : $shared"
    Write-Host "  -> utiliser pointer (si l'assistant est deja sur cette machine) ou chercher (pour le trouver sur disque)."
    return
  }
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "git est requis pour installer l'assistant (l'installer, ou utiliser pointer / chercher)."
    return
  }
  if ([string]::IsNullOrWhiteSpace($dossier)) {
    $parent = Split-Path $proj -Parent
    $repo = (Split-Path $gitUrl -Leaf).Replace(".git", "")
    $dossier = Join-Path $parent $repo
  }
  $mode = "clone"
  if (Test-Path (Join-Path $dossier ".git")) { $mode = "mise a jour (git pull du clone existant)" }
  if (Confirm-Action "Installer l'assistant : git $mode`n  depuis : $gitUrl`n  vers   : $dossier`n  puis le definir comme emplacement de l'assistant (assistant_local)") {
    $ok = $false
    if (Test-Path (Join-Path $dossier ".git")) { & git -C $dossier pull; $ok = ($LASTEXITCODE -eq 0) }
    else { & git clone $gitUrl $dossier; $ok = ($LASTEXITCODE -eq 0) }
    if (-not $ok) { Write-Host "git a echoue - rien n'a ete modifie dans la config."; return }
    if (Test-BundleRaw $dossier) {
      Set-ConfLine $localf "assistant_local" $dossier
      Write-Host "Fait : assistant installe -> $dossier"
      Propose-Opencode
    } else {
      Write-Host "Le dossier $dossier ne ressemble pas a un assistant (assistant.ps1/.sh + .assistant.version manquants)."
    }
  } else { Write-Host "Annule." }
}

# Deploie le harness opencode du projet depuis le bundle (zero ecrasement).
# Retourne la liste des chemins ajoutes (relatifs au projet).
function Deploy-Harness([string]$bundle) {
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  $added = @()
  foreach ($sub in @("agent","command")) {
    $src = Join-Path $bundle ".opencode/$sub"
    if (-not (Test-Path $src)) { continue }
    $dst = Join-Path $proj ".opencode/$sub"
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
  $ocJson = Join-Path $proj "opencode.json"
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
  $gi = Join-Path $proj ".gitignore"
  if (-not (Test-Path $gi)) {
    $gf = Join-Path $bundle "tools/templates/gitignore-projet.md"
    if (Test-Path $gf) { Copy-Item $gf $gi; $added += ".gitignore" }
  } else {
    $c = [System.IO.File]::ReadAllText($gi, [System.Text.Encoding]::UTF8)
    $addl = @()
    if ($c -notmatch '(?m)^[ \t]*\.opencode/') { $addl += ".opencode/" }
    if ($c -notmatch ('(?m)^[ \t]*' + [regex]::Escape("$mf/registry/connexions.local.md"))) { $addl += "$mf/registry/connexions.local.md" }
    if ($addl.Count -gt 0) {
      [System.IO.File]::WriteAllText($gi, ($c.TrimEnd("`r","`n") + "`r`n" + ($addl -join "`r`n") + "`r`n"), $utf8)
      $added += ".gitignore (append)"
    }
  }
  return $added
}

# 4) OPENCODE - le harness (couche IA) : le binaire + le depot de .opencode/ + opencode.json.
function Act-Opencode {
  Write-Host ""
  Write-Host "--- harness opencode (la couche IA) ---"
  # a) le binaire
  if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
    Write-Host "  opencode (binaire) : NON detecte."
    if (Get-Command npm -ErrorAction SilentlyContinue) {
      if (Confirm-Action "Installer opencode : npm install -g opencode-ai") {
        & npm install -g opencode-ai
        if (Get-Command opencode -ErrorAction SilentlyContinue) { Write-Host "  opencode installe." }
        else { Write-Host "  opencode toujours non detecte (PATH ?) - re-executer cette etape apres redemarrage du terminal." }
      }
    } else {
      Write-Host "  npm non detecte non plus : installer opencode manuellement (https://opencode.ai), puis re-executer cette etape."
    }
  } else {
    Write-Host "  opencode (binaire) : present."
  }
  # b) l'assistant (bundle) doit etre en place
  $engine = Resolve-Engine $localPath
  if ($null -eq $engine) {
    Write-Host "  L'assistant n'est pas encore en place : pointer / chercher / installer d'abord."
    return
  }
  # c) le harness
  $ha = Test-Path (Join-Path $proj ".opencode/agent/assistant-projet.md")
  $hj = Test-Path (Join-Path $proj "opencode.json")
  if ($ha -and $hj) {
    Write-Host "  Harness : deja deploye (.opencode/ + opencode.json) - rien a ajouter."
    return
  }
  Write-Host "  A deposer (zero ecrasement) :"
  if (-not $ha) { Write-Host "    + .opencode/agent/ + .opencode/command/  (copies du bundle)" }
  if (-not $hj) { Write-Host "    + opencode.json  (instructions -> AGENT-projet.md du bundle + projet.md)" }
  Write-Host "    + .gitignore  (lignes machine, en append)"
  if (Confirm-Action "Deployer le harness opencode dans le projet") {
    $added = @(Deploy-Harness $engine)
    foreach ($a in $added) { Write-Host ("    + {0}" -f $a) }
    Write-Host "  Harness deploye - la couche IA est en place (demarrer : opencode)."
  } else { Write-Host "Annule." }
}

# Apres pointer/chercher/installer : proposer la meme operation pour opencode.
function Propose-Opencode {
  Write-Host ""
  Write-Host "L'assistant est en place. Deployer aussi le harness opencode (la couche IA) ?"
  Write-Host "  (o/n) " -NoNewline
  $a = (Read-Line).Trim().ToLower()
  if ($a -eq "o" -or $a -eq "oui" -or $a -eq "yes" -or $a -eq "y") { Act-Opencode }
  else { Write-Host "  Passe - a faire plus tard :  .\bootstrap.ps1 opencode" }
}

# --- Menu (defaut : sans argument) ---------------------------------------------
function Show-Menu {
  Write-Host ""
  Write-Host "================================================"
  Write-Host " bootstrap - l'assistant de gestion de projet (sans IA)"
  Write-Host "================================================"
  Write-Host " Cet espace projet fonctionne avec l'`"assistant de gestion de projet`"."
  Write-Host " Pour utiliser ses fonctionnalites, il faut l'installer sur cette machine."
  Write-Host ""
  Write-Host " Si c'est deja fait : indiquez son emplacement (pointer)"
  Write-Host " ou je peux le chercher sur votre disque (chercher)."
  Write-Host " Sinon : l'installer (installer - git clone de la config partagee)."
  Show-State
  Write-Host ""
  Write-Host " Actions :"
  Write-Host "   1) pointer    - indiquer l'emplacement de l'assistant"
  Write-Host "   2) chercher   - chercher l'assistant sur le disque (dossiers a indiquer)"
  Write-Host "   3) installer  - installer l'assistant (git clone)"
  Write-Host "   4) opencode   - le harness opencode (la couche IA)"
  Write-Host "   0) quitter    - quitter (rien n'est modifie)"
  while ($true) {
    Write-Host "  Votre choix (0-4) : " -NoNewline
    $ch = (Read-Line).Trim()
    switch ($ch) {
      "1" { $p = Read-Host "  Emplacement de l'assistant ?"; Act-Pointer $p }
      "2" { $s = Read-Host "  Dossiers a chercher ? (separes par espaces)"; $ds = @($s -split '\s+' | Where-Object { $_ -ne "" }); Act-Chercher $ds }
      "3" { Act-Installer "" }
      "4" { Act-Opencode }
      "0" { break }
      default { }
    }
  }
}

# --- Dispatch --------------------------------------------------------------------
$c = $args[0]
if ($null -eq $c) { Show-Menu; return }
$c = "$c" -replace '^[/-]', ''
switch ($c) {
  "pointer" { Act-Pointer $args[1] }
  "chercher" {
    $ds = @()
    if ($args.Count -ge 2) { $ds = @($args[1..($args.Count - 1)]) }
    Act-Chercher $ds
  }
  "installer" {
    $d = ""
    for ($i = 1; $i -lt $args.Count; $i++) {
      if ($args[$i] -eq "-dossier") { if ($i + 1 -lt $args.Count) { $d = $args[$i + 1]; $i++ } }
      elseif ($d -eq "") { $d = $args[$i] }
    }
    Act-Installer $d
  }
  "opencode" { Act-Opencode }
  "menu" { Show-Menu }
  "?" { Show-Menu }
  default { Write-Host "Action inconnue : $c"; Show-Menu }
}
