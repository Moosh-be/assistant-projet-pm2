# install.ps1 - INSTALLATION de l'espace de travail assistant-projet-pm2
# Pure ASCII (Windows PowerShell 5.1 lit les .ps1 en ANSI sans BOM UTF-8).
# Sans dependance externe : PowerShell natif (Windows PowerShell 5.1+ / pwsh).
# Idempotent : relanchable, re-ecrit son bloc de config sans ecraser le reste.
# macOS / Linux : lancer ./install.sh (logique identique).
#
# Usage : .\install.ps1   (ou : powershell -ExecutionPolicy Bypass -File .\install.ps1)
#
# Principe racines (WP-0005) : pas de "vault" monolithe. Le kit s'appuie sur les
# RACINES de projets (1..N). Il ne demande JAMAIS de reorganiser des dossiers
# existants : il les liste, tu valides, et il n'ajoute que manifeste + _projet/.

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$RegDir = Join-Path $Root "_projet/registry"
$Conn = Join-Path $RegDir "connexions.md"

function Have($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Ask([string]$q, [string]$d = "") {
  if ($d -ne "") { $a = Read-Host "$q [$d]" } else { $a = Read-Host $q }
  if ([string]::IsNullOrWhiteSpace($a)) { return $d } else { return $a }
}
# Yn : renvoie VRAI/FAUX. (Bug v1 : le resultat n'etait jamais lu par l'appelant
# -> repondre "non" n'empechait pas les questions de detail.)
function Yn([string]$d, [string]$q) {
  $a = Read-Host "$q [$d]"
  if ([string]::IsNullOrWhiteSpace($a)) { $a = $d }
  if ($a -match '^[yY]') { return $true } else { return $false }
}

Write-Host "================================================"
Write-Host " INSTALLATION - assistant-projet-pm2"
Write-Host "================================================"
Write-Host " OS       : $env:OS"
Write-Host " Kit      : $Root"
if (Have git) { Write-Host " git      : $(git --version)" }
if (Have node) { Write-Host " node     : $(node --version)" }
if (Have opencode) { Write-Host " opencode : $(opencode --version 2>$null | Select-Object -First 1)" }
else { Write-Host " opencode : NON detecte" }
Write-Host ""

# --- 1/3 - Racines de projets (1..N dossiers) ---------------------------------
function Get-ProjectRoots {
  $parent = Split-Path $Root -Parent
  $candPaths = @()
  if ($parent) {
    $candPaths = @(Get-ChildItem -Path $parent -Directory -Force -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -notlike '.*' } |
      ForEach-Object { $_.FullName })
  }
  $lines = @()
  $lines += " 1/3 - Ou vivent tes projets ? (racines : 1 ou plusieurs dossiers)"
  if ($candPaths.Count -gt 0) {
    $lines += " Dossiers detects dans '$parent' :"
    $i = 0
    foreach ($p in $candPaths) {
      $i++
      if ($i -gt 5) { break }
      $n = @(Get-ChildItem -Path $p -Directory -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notlike '.*' }).Count
      $tag = ""
      if (Test-Path (Join-Path $p "AGENT-projet.md")) { $tag = " (deja un kit PM2)" }
      $lines += "   $i) $p  [$n sous-dossiers$tag]"
    }
  } else {
    $lines += " (aucun dossier detecte a cote du kit - saisis des chemins)"
  }
  $lines += " Choix : numeros separes par espace ou ;  -  A = ajouter un chemin  -  V = passer"
  Write-Host $lines -NoNewline
  $sel = @()
  while ($true) {
    $r = Read-Host "  Racines"
    if ($null -eq $r -or ($r -as [string]).Trim() -eq "") { break }
    $s = ($r -as [string]).Trim().ToUpper()
    if ($s -eq "V") { break }
    if ($s -like "A*") {
      $p = Read-Host "  Chemin a ajouter"
      if ([string]::IsNullOrWhiteSpace(($p -as [string]).Trim())) { continue }
      $p = ($p -as [string]).Trim().Trim('"')
      if ($sel -notcontains $p) { $sel += $p }
      continue
    }
    foreach ($tok in (($r -as [string]).Split([char[]]@(' ', ';', ','), [System.StringSplitOptions]::RemoveEmptyEntries))) {
      $t = $tok.Trim()
      if ($t -match '^\d+$') {
        $i = [int]$t - 1
        if ($i -ge 0 -and $i -lt [Math]::Min(5, $candPaths.Count)) {
          $p = $candPaths[$i]
          if ($sel -notcontains $p) { $sel += $p }
        }
      }
    }
  }
  return $sel
}

$roots = @(Get-ProjectRoots)
$rootEntries = @()
foreach ($r0 in $roots) {
  $r = [string]$r0
  if ([string]::IsNullOrWhiteSpace($r)) { continue }
  if (-not (Test-Path $r -PathType Container)) {
    Write-Host " '$r' n'existe pas."
    if (Yn "n" "   Je le cree ?") {
      New-Item -ItemType Directory -Force -Path $r | Out-Null
      $rootEntries += "$r (cree, vide)"
    } else {
      $rootEntries += "$r (ABSENT - non cree)"
    }
    continue
  }
  $kids = @(Get-ChildItem -Path $r -Directory -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notlike '.*' })
  if ($kids.Count -eq 0) { $rootEntries += "$r (vide)" }
  else {
    $rootEntries += "$r ($($kids.Count) sous-dossiers - deja rempli, rien ne sera deplace)"
    Write-Host "   Contenu de '$r' :"
    foreach ($k in $kids) { Write-Host "     - $($k.Name)" }
  }
}
if ($rootEntries.Count -eq 0) {
  Write-Host " Aucune racine retenue : l'installation continue sans (re-lance le script pour en definir)."
}
Write-Host ""

# --- 2/3 - opencode (le marteau) ----------------------------------------------
$opencodeStatut = "non installe"
if (Have opencode) {
  $opencodeStatut = "installe"
} else {
  Write-Host " opencode non detecte."
  if (Yn "n" "2/3 - L'installer maintenant (npm install -g opencode-ai) ?") {
    if (Have npm) {
      npm install -g opencode-ai
      if ($LASTEXITCODE -eq 0) { $opencodeStatut = "installe (via npm)" } else { Write-Host " Echec de l'installation npm." }
    } else {
      Write-Host " Node.js requis avant d'installer opencode : https://nodejs.org"
    }
  }
}

# --- 3/3 - Connexions / plugins ------------------------------------------------
# Regle dure : un "non" = pas de question de detail.
$opUrl = ""; $opTokenEnv = ""; $opStatut = "non"
$spStatut = "non"
$ghRepo = ""; $ghStatut = "non"
$glabUrl = ""; $glabStatut = "non"

if (Have op) { Write-Host " CLI OpenProject (op) detectee." }
if (Yn "n" "3/3 - Connexion OpenProject ?") {
  $opStatut = "oui"
  $opUrl = Ask "   URL de l'instance" "https://<instance>/openproject"
  $opTokenEnv = Ask "   Variable d'env du token API (ne JAMAIS ecrire le token dans le repo)" "OP_API_TOKEN"
}
if (Yn "n" "   Connexion SuperProductivity (taches locales) ?") { $spStatut = "oui" }
if (Have gh) { Write-Host " CLI GitHub (gh) detectee." }
if (Yn "n" "   Connexion GitHub Issue ?") {
  $ghStatut = "oui"
  $ghDefault = ""
  try {
    $url = git -C $Root remote get-url origin 2>$null
    if ($url -match "github\.com[:/]([^/]+/[^/.]+)") { $ghDefault = $Matches[1] }
  } catch { }
  $ghRepo = Ask "   Repo (owner/name)" $ghDefault
}
if (Have glab) { Write-Host " CLI GitLab (glab) detectee." }
if (Yn "n" "   Connexion GitLab Issue ?") {
  $glabStatut = "oui"
  $glabUrl = Ask "   URL de l'instance GitLab" "https://gitlab.com"
}

# --- Persistance (idempotent : bloc entre marqueurs) ---------------------------
function Build-Bloc([string]$os, [string]$roots, [string]$oc, [string]$op, [string]$opu, [string]$opt, [string]$sp, [string]$gh, [string]$ghr, [string]$gl, [string]$glu) {
  $opExtra = ""; if ($op -eq "oui") { $opExtra = " - url: $opu - token_env: $opt" }
  $ghExtra = ""; if ($gh -eq "oui") { $ghExtra = " - repo: $ghr" }
  $glExtra = ""; if ($gl -eq "oui") { $glExtra = " - url: $glu" }
  $rootsLine = "aucune"
  if ($roots -ne "") { $rootsLine = $roots }
  @(
    "<!-- wizard:start (genere par install.sh / install.ps1 - regene a chaque installation, ne pas editer) -->",
    "## Configuration de l'espace de travail (wizard d'installation)",
    "- genere_le: $(Get-Date -Format yyyy-MM-dd_HH:mm)",
    "- os: $os",
    "- racines: $rootsLine",
    "- opencode: $oc",
    "- openproject: $op$opExtra",
    "- superproductivity: $sp",
    "- github_issue: $gh$ghExtra",
    "- gitlab_issue: $gl$glExtra",
    "<!-- wizard:end -->"
  ) -join "`n"
}

$rootsStr = ($rootEntries -join " ; ")
$bloc = Build-Bloc $env:OS $rootsStr $opencodeStatut $opStatut $opUrl $opTokenEnv $spStatut $ghStatut $ghRepo $glabStatut $glabUrl

if (-not (Test-Path $RegDir)) { New-Item -ItemType Directory -Force -Path $RegDir | Out-Null }
if ((Test-Path $Conn) -and (Select-String -Path $Conn -Pattern "wizard:start" -Quiet)) {
  $lines = @(Get-Content $Conn -Encoding UTF8)
  $out = @(); $inBlock = $false
  foreach ($l in $lines) {
    if ($l -match "wizard:start") { $out += ($bloc -split "`n"); $inBlock = $true; continue }
    if ($l -match "wizard:end") { $inBlock = $false; continue }
    if (-not $inBlock) { $out += $l }
  }
  Set-Content -Path $Conn -Value $out -Encoding UTF8
} else {
  if (-not (Test-Path $Conn)) { Set-Content -Path $Conn -Value "# _projet/registry/connexions.md - registres des connexions" -Encoding UTF8 }
  Add-Content -Path $Conn -Value "" -Encoding UTF8
  Add-Content -Path $Conn -Value $bloc -Encoding UTF8
}

# --- Recapitulatif ---------------------------------------------------------------
Write-Host ""
Write-Host "================================================"
Write-Host " Recapitulatif de l'installation"
Write-Host "================================================"
if ($rootsStr -eq "") { Write-Host " Racines       : AUCUNE (les projets existants ne sont pas touches)" }
else { Write-Host " Racines       : $rootsStr" }
Write-Host " opencode      : $opencodeStatut"
Write-Host " OpenProject   : $opStatut"
Write-Host " Sprod         : $spStatut"
Write-Host " GitHub Issue  : $ghStatut"
Write-Host " GitLab Issue  : $glabStatut"
Write-Host " Config        : $Conn"
Write-Host ""
Write-Host " Prochaines etapes :"
if ($rootsStr -ne "") {
  Write-Host "  1. Ouvrir l'agent dans un projet d'une racine  ->  opencode"
} else {
  Write-Host "  1. Copier ce kit dans un dossier projet existant (ou un nouveau)"
}
Write-Host "  2. Dans l'agent : /scan  (liste les projets detectes dans les racines)"
Write-Host "  3. Demander : commence le projet <NomDuProjet>"
