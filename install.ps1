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
# existants : il les liste, tu valides, et il n'ajoute que manifeste + _meta/.

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$RegDir = Join-Path $Root "_meta/registry"
$OldConn = Join-Path $RegDir "connexions.md"   # bloc wizard ANCIEN (migration WP-0017)

# --- Config machine (WP-0017) ---------------------------------------------------
# Fichier de config a la RACINE du kit (gitignored), entierement genere par le wizard.
# 3 noms possibles, le code lit/ecrit le 1er qui existe (defaut : .assistant.config) :
#   .assistant.config  (defaut, cache)  |  assistant.config  |  assistant.config.md
$Config = $null
foreach ($c in @(".assistant.config", "assistant.config", "assistant.config.md")) {
  if (Test-Path (Join-Path $Root $c)) { $Config = Join-Path $Root $c; break }
}
if ($null -eq $Config) { $Config = Join-Path $Root ".assistant.config" }
$EnvFile = Join-Path $Root ".assistant-projet.env"   # secrets (gitignored)

# Upsert d'une variable dans le .env SANS jamais afficher la valeur.
function Upsert-Env([string]$file, [string]$var, [string]$val) {
  if (-not (Test-Path $file)) {
    [System.IO.File]::WriteAllText($file, "# Assistant-projet - secrets (genere par install - gitignored, ne JAMAIS commit)`n", (New-Object System.Text.UTF8Encoding($false)))
  }
  $pattern = "^(\s*)${var}(\s*)=.*$"
  if (Select-String -Path $file -Pattern "^\s*${var}\s*=" -Quiet) {
    $lines = @(Get-Content $file -Encoding UTF8)
    $out = foreach ($l in $lines) { if ($l -match "^\s*${var}\s*=.*$") { "${var}=${val}" } else { $l } }
    [System.IO.File]::WriteAllLines($file, $out, (New-Object System.Text.UTF8Encoding($false)))
  } else {
    Add-Content -Path $file -Value "${var}=${val}" -Encoding UTF8
  }
}

# --- Migration WP-0017 : le bloc wizard de l'ancien registre a demenage --------
if ((Test-Path $OldConn) -and (Select-String -Path $OldConn -Pattern "wizard:start" -Quiet)) {
  # 1) le token pose dans token_env (valeur longue, pas un nom de variable court) -> .env
  $oldTok = $null
  $m = Select-String -Path $OldConn -Pattern 'token_env:\s*([A-Za-z0-9_-]+)' | Select-Object -First 1
  if ($m) { $oldTok = $m.Matches[0].Groups[1].Value }
  if ($oldTok -and $oldTok -match '^[A-Za-z0-9_-]{32,}$') {
    Upsert-Env $EnvFile "OP_API_TOKEN" $oldTok
    Write-Host " Migration : le token de l'ancien registre est deplace dans .assistant-projet.env (variable OP_API_TOKEN)."
  }
  # 2) le registre ne garde que le registre de projet (la config machine -> fichier a la racine)
  Set-Content -Path $OldConn -Encoding UTF8 -Value @(
    "# _meta/registry/connexions.md - registres des connexions DU PROJET (ids sp_project / op_id / MCP)",
    "# La config machine (racines, connexions transversales) vit dans $(Split-Path $Config -Leaf) a la racine du kit (WP-0017)."
  )
  Write-Host " Migration : le bloc wizard de l'ancien registre est remplace par la config a la racine du kit ($Config)."
  Write-Host "             Les reponses de cette installation le remplissent (les anciens choix sont re-proposes)."
}

function Have($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Ask([string]$q, [string]$d = "") {
  if ($d -ne "") { $a = Read-Host "$q [$d]" } else { $a = Read-Host $q }
  if ([string]::IsNullOrWhiteSpace($a)) { return $d } else { return $a }
}
# Yn : renvoie VRAI/FAUX. (Bug v1 : le resultat n'etait jamais lu par l'appelant
# -> repondre "non" n'empechait pas les questions de detail.)
# Le script est en francais : affiche (o/n) et accepte "o" (oui) ET "y" (yes) ;
# si rien n'est tape, c'est le defaut (ici "non") qui s'applique.
function Yn([string]$d, [string]$q) {
  $a = Read-Host "$q (o/n)"
  if ([string]::IsNullOrWhiteSpace($a)) { $a = $d }
  if ($a -match '^[yYoO]') { return $true } else { return $false }
}
# AskSecret : saisie masquee (Read-Host -AsSecureString) - pour les tokens.
function AskSecret([string]$q) {
  $s = Read-Host -Prompt $q -AsSecureString
  if ($null -eq $s -or $s.Length -eq 0) { return "" }
  $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
  try { return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr) }
  finally { [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
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
  $candNotes = @()
  if ($parent) {
    # Candidats 1..3 : le dossier du kit + 2 niveaux au-dessus.
    # Cas frequent : le kit est clone DANS le dossier de projets
    # -> c'est le PARENT qu'il faut comme racine, pas les projets a cote.
    $up = $parent
    $depth = 0
    $upNotes = @("dossier du kit", "1 niveau au-dessus du kit", "2 niveaux au-dessus du kit")
    while ($depth -le 2) {
      $candPaths += $up
      $candNotes += $upNotes[$depth]
      $upNext = Split-Path $up -Parent
      if (-not $upNext -or ($upNext -eq $up)) { break }
      $up = $upNext
      $depth++
    }
    # Candidats suivants : les dossiers a cote du kit (max 5, comme avant).
    $sibCount = 0
    $sibs = @(Get-ChildItem -Path $parent -Directory -Force -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -notlike '.*' })
    foreach ($s in $sibs) {
      if ($sibCount -ge 5) { break }
      $candPaths += $s.FullName
      $candNotes += ""
      $sibCount++
    }
  }
  $shown = [Math]::Min($candPaths.Count, 8)
  $lines = @()
  $lines += " 1/3 - Ou vivent tes projets ? (racines : 1 ou plusieurs dossiers)"
  $lines += " Une racine = un dossier qui CONTIENT des projets (1 projet = 1 sous-dossier)."
  if ($shown -gt 0) {
    $lines += " Dossiers proposes :"
    for ($i = 0; $i -lt $shown; $i++) {
      $p = $candPaths[$i]
      $n = @(Get-ChildItem -Path $p -Directory -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notlike '.*' }).Count
      $tag = ""
      if (Test-Path (Join-Path $p "AGENT-projet.md")) { $tag = " (deja un kit PM2)" }
      $note = ""
      if ($candNotes[$i]) { $note = " ($($candNotes[$i]))" }
      $lines += "   $($i+1)) $p$note  [$n sous-dossiers$tag]"
    }
  } else {
    $lines += " (aucun dossier detecte - saisis des chemins avec A)"
  }
  $lines += " Choix : numeros des dossiers a retenir, separes par espace ou ;  -  A = ajouter un chemin  -  V = passer"
  # Le prompt de saisie doit etre sur sa propre ligne (avec -NoNewline il se collait a la ligne d aide - bug 01/11).
  Write-Host ($lines -join "`n")
  $sel = @()
  while ($true) {
    $r = Read-Host "  Racines (ex : 1, A, V)"
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
        if ($i -ge 0 -and $i -lt $shown) {
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
$opUrl = ""; $opTokenEnv = ""; $opStatut = "non"; $opTokenState = ""
$spStatut = "non"
$ghRepo = ""; $ghStatut = "non"
$glabUrl = ""; $glabStatut = "non"

if (Have op) { Write-Host " CLI OpenProject (op) detectee." }
if (Yn "n" "3/3 - Connexion OpenProject ?") {
  $opStatut = "oui"
  $opUrl = Ask "   URL de l'instance (celle qui charge ta page d'accueil OpenProject)" "https://<instance>"
  # Page "Mes jetons d'acces" ou on fabrique la cle API.
  $opKeyLink = "$($opUrl.TrimEnd('/'))/my/access_tokens"
  Write-Host "   -> fabriquer la cle API : $opKeyLink"
  $opTokenEnv = Ask "   Variable d'env du token API" "OP_API_TOKEN"
  # Le token est une VALEUR DE CONFIG : il vit dans le .env dedie du kit (genere ici), jamais dans le repo.
  if ((Test-Path $EnvFile) -and (Select-String -Path $EnvFile -Pattern "^\s*${opTokenEnv}\s*=\s*\S" -Quiet)) {
    Write-Host "   Variable ${opTokenEnv} deja presente dans $(Split-Path $EnvFile -Leaf) - je la mets a jour si tu saisis une nouvelle cle."
  }
  if (Yn "n" "   Saisir la cle API maintenant ?") {
    $tok = AskSecret "   Cle API (masquee, Entree pour valider)"
    if ($tok -ne "") {
      Upsert-Env $EnvFile $opTokenEnv $tok
      $opTokenState = "saisie dans $(Split-Path $EnvFile -Leaf)"
      Write-Host "   -> token ecrit dans $(Split-Path $EnvFile -Leaf) (gitignored - jamais dans le repo)."
    } else {
      Upsert-Env $EnvFile $opTokenEnv ""
      $opTokenState = "placeholder vide dans $(Split-Path $EnvFile -Leaf) (a remplir)"
      Write-Host "   -> variable ${opTokenEnv}= laissee vide dans $(Split-Path $EnvFile -Leaf) : remplis-la plus tard."
    }
  } else {
    # Pas de saisie maintenant : on s'assure que la variable existe (placeholder) pour un remplissage plus tard.
    if (-not ((Test-Path $EnvFile) -and (Select-String -Path $EnvFile -Pattern "^\s*${opTokenEnv}\s*=" -Quiet))) {
      Upsert-Env $EnvFile $opTokenEnv ""
    }
    $opTokenState = "placeholder vide dans $(Split-Path $EnvFile -Leaf) (a remplir)"
    Write-Host "   -> a faire plus tard : coller la cle dans $(Split-Path $EnvFile -Leaf) (variable ${opTokenEnv})."
  }
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

# --- Persistance : config machine a la racine du kit (idempotent) ----------------
$rootsStr = ($rootEntries -join " ; ")

# Lignes conditionnelles (une connexion "oui" deployee en sous-cles)
$opLines = @("openproject = $opStatut")
if ($opStatut -eq "oui") {
  $opLines = @(
    "openproject = oui",
    "openproject_url = $opUrl",
    "openproject_token_env = $opTokenEnv",
    "openproject_token_file = $EnvFile"
  )
}
$ghLines = @("github_issue = $ghStatut")
if ($ghStatut -eq "oui") {
  $ghRepoVal = if ($ghRepo -ne "") { $ghRepo } else { "?" }
  $ghLines = @("github_issue = oui", "github_repo = $ghRepoVal")
}
$glLines = @("gitlab_issue = $glabStatut")
if ($glabStatut -eq "oui") { $glLines = @("gitlab_issue = oui", "gitlab_url = $glabUrl") }

# Header statique (explique les 3 noms possibles + meta_folder + env_file)
$cfgName = Split-Path $Config -Leaf
$cfgHeader = @(
  "# $cfgName - Config machine de l'espace assistant-projet (WP-0017)",
  "# Genere par install.sh / install.ps1 - le bloc wizard est regene a chaque installation.",
  "# Fichier local a la MACHINE : chemins/instances de l'utilisateur (jamais de donnees entreprise).",
  "# Gitignored : ne part jamais sur la forge.",
  "#",
  "# 3 noms possibles (le wizard utilise le 1er trouve, defaut = le 1er) :",
  "#   .assistant.config      (defaut, cache)",
  "#   assistant.config       (visible)",
  "#   assistant.config.md    (lisible dans Obsidian)",
  "#",
  "# Les secrets (tokens) ne vivent PAS ici : ils vivent dans le fichier pointe par env_file.",
  "",
  "# Dossier de documentation du projet (defaut _meta)",
  "meta_folder = _meta",
  "# Fichier des secrets (tokens, etc.)",
  "env_file = .assistant-projet.env",
  ""
)

$rootsLine = if ($rootsStr -ne "") { $rootsStr } else { "aucune" }
$wizardLines = @(
  "<!-- wizard:start (genere par install.sh / install.ps1 - ne pas editer) -->",
  "genere_le = $(Get-Date -Format yyyy-MM-dd_HH:mm)",
  "os = $env:OS",
  "racines = $rootsLine",
  "opencode = $opencodeStatut"
) + $opLines + @(
  "superproductivity = $spStatut"
) + $ghLines + $glLines + @(
  "<!-- wizard:end -->"
)

$utf8 = New-Object System.Text.UTF8Encoding($false)
if ((Test-Path $Config) -and (Select-String -Path $Config -Pattern "wizard:start" -Quiet)) {
  # Remplace uniquement le bloc wizard (conserve le header + tout contenu avant/apres)
  $lines = @(Get-Content $Config -Encoding UTF8)
  $out = @(); $inBlock = $false
  foreach ($l in $lines) {
    if ($l -match "wizard:start") { $out += $wizardLines; $inBlock = $true; continue }
    if ($l -match "wizard:end") { $inBlock = $false; continue }
    if (-not $inBlock) { $out += $l }
  }
  [System.IO.File]::WriteAllLines($Config, $out, $utf8)
} else {
  [System.IO.File]::WriteAllLines($Config, ($cfgHeader + $wizardLines), $utf8)
}

# --- Recapitulatif ---------------------------------------------------------------
Write-Host ""
Write-Host "================================================"
Write-Host " Installation terminee : la config transversale est en place"
Write-Host "================================================"
if ($rootsStr -eq "") { Write-Host " Racines       : AUCUNE (les projets existants ne sont pas touches)" }
else { Write-Host " Racines       : $rootsStr" }
Write-Host " opencode      : $opencodeStatut"
if ($opStatut -eq "oui") { Write-Host " OpenProject   : $opStatut  (token : $opTokenState)" }
else { Write-Host " OpenProject   : $opStatut" }
Write-Host " Sprod         : $spStatut"
Write-Host " GitHub Issue  : $ghStatut"
Write-Host " GitLab Issue  : $glabStatut"
Write-Host " Config        : $Config"
Write-Host " Secrets       : $EnvFile"
Write-Host ""
Write-Host " Menu natif (sans IA : rapide, gratuit) :  .\assistant.ps1"
Write-Host "   -- Gerer les projets (depuis le kit ou les racines) --"
Write-Host "   scan                 tes projets existants : 3 buckets (assistes / pourraient / sans signal) + phase"
Write-Host "   liste                les projets (nom + phase + gate)"
Write-Host "   statut <projet>      ou en est un projet (phase + gate + avancement)"
Write-Host "   new <nom> [racine]   creer un projet (kit + _meta neuf)"
Write-Host "   add <dossier>        ajouter le kit a un projet existant (jamais d'ecrasement)"
Write-Host "   -- Dans un projet (depuis le dossier du projet) --"
Write-Host "   statut               le statut du projet courant (sans argument)"
Write-Host "   update               resync le kit de CE projet (zero ecrasement)"
Write-Host "   remark <texte>       journal des remarques au vol (remontee au projet assistant)"
Write-Host "   commence <nom>       -> l'AGENT : ouvre opencode dans le projet"
Write-Host ""
if ($rootsStr -ne "") {
  Write-Host " Conseil : tu as des projets existants ? Commence par :  .\assistant.ps1 scan"
  Write-Host " Puis, pour travailler sur un projet :  .\assistant.ps1 commence <Nom>   (l'agent prend le relais)."
} else {
  Write-Host " Conseil : aucun projet scanne pour l'instant -> cree ton premier projet :"
  Write-Host "   .\assistant.ps1 new <Nom>   (ou, dans l'agent : 'cree un projet <Nom>')"
  Write-Host " ...ou relance l'install pour definir des racines."
}