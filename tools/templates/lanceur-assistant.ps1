# assistant.ps1 - LANCEUR MINCE (WP-0025)
# Le projet = la data (projet.md, 01..05, _meta). L'outillage = le bundle
# (le repo assistant, pointe par la config). Ce script ne fait rien lui-meme :
# il localise le bundle et delgue TOUTES les commandes au moteur du bundle.
#   - config partagee :  _meta/registry/connexions.md       (assistant_git, assistant_ref, meta_folder)
#   - config machine   :  _meta/registry/connexions.local.md (assistant_local - ecrite par le bootstrap)
# Bundle introuvable -> le bootstrap est lance (pointer / chercher / installer).
$ErrorActionPreference = "Stop"
$proj = $PSScriptRoot

function Read-ConfLine([string]$file, [string]$key) {
  if (-not (Test-Path $file)) { return "" }
  foreach ($l in (Get-Content $file -Encoding UTF8)) {
    if ($l -match '^\s*' + [regex]::Escape($key) + '\s*:\s*(.+)$') { return $Matches[1].Trim() }
  }
  return ""
}

$mf = "_meta"
$shared = Join-Path $proj "$mf/registry/connexions.md"
$localf = Join-Path $proj "$mf/registry/connexions.local.md"
$mfCfg = Read-ConfLine $shared "meta_folder"
if ($mfCfg -ne "") {
  $shared = Join-Path $proj "$mfCfg/registry/connexions.md"
  $localf = Join-Path $proj "$mfCfg/registry/connexions.local.md"
}
$ref = Read-ConfLine $shared "assistant_ref"
if ($ref -eq "") { $ref = "latest" }

function Resolve-Engine([string]$localFile) {
  $b = Read-ConfLine $localFile "assistant_local"
  if ([string]::IsNullOrWhiteSpace($b)) { return $null }
  if ($ref -ne "latest" -and (Test-Path (Join-Path $b "versions"))) { $b = Join-Path $b "versions/$ref" }
  if ((Test-Path (Join-Path $b "assistant.ps1")) -and (Test-Path (Join-Path $b ".assistant.version"))) { return $b }
  return $null
}

$bundle = Resolve-Engine $localf
if ($null -eq $bundle) {
  Write-Host ""
  Write-Host "L'assistant (bundle) n'est pas localise sur cette machine."
  Write-Host "  Config partagee : $shared"
  Write-Host "Lancement du bootstrap (pointer / chercher / installer)..."
  Write-Host ""
  $boot = Join-Path $proj "bootstrap.ps1"
  if (Test-Path $boot) { & $boot }
  $bundle = Resolve-Engine $localf
}
if ($null -eq $bundle) {
  Write-Host "Pas de bundle valide. Relancer :  .\bootstrap.ps1"
  return
}
& (Join-Path $bundle "assistant.ps1") @args
