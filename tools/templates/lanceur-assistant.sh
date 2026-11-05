#!/usr/bin/env bash
# assistant.sh — LANCEUR MINCE (WP-0025)
# Le projet = la data (projet.md, 01..05, _meta). L'outillage = le bundle
# (le repo assistant, pointé par la config). Ce script ne fait rien lui-même :
# il localise le bundle et délègue TOUTES les commandes au moteur du bundle.
#   - config partagée :  _meta/registry/connexions.md       (assistant_git, assistant_ref, meta_folder)
#   - config machine   :  _meta/registry/connexions.local.md (assistant_local — écrit par le bootstrap)
# Bundle introuvable → le bootstrap est lancé (pointer / chercher / installer).
set -u
proj="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

read_conf() { # read_conf <fichier> <clé> → valeur (ou vide)
  local f="$1" k="$2"
  [ -f "$f" ] || return 0
  sed -nE "s/^[[:space:]]*$k[[:space:]]*:[[:space:]]*//p" "$f" | head -n1 | sed 's/[[:space:]]*$//'
}

mf="_meta"
shared="$proj/$mf/registry/connexions.md"
localf="$proj/$mf/registry/connexions.local.md"
mfcfg="$(read_conf "$shared" "meta_folder")"
if [ -n "$mfcfg" ]; then
  shared="$proj/$mfcfg/registry/connexions.md"
  localf="$proj/$mfcfg/registry/connexions.local.md"
fi
ref="$(read_conf "$shared" "assistant_ref")"
[ -z "$ref" ] && ref="latest"

resolve_engine() {
  local b
  b="$(read_conf "$localf" "assistant_local")"
  [ -z "$b" ] && return 1
  if [ "$ref" != "latest" ] && [ -d "$b/versions" ]; then b="$b/versions/$ref"; fi
  { [ -f "$b/assistant.sh" ] && [ -f "$b/.assistant.version" ]; } || return 1
  printf '%s' "$b"
}

bundle="$(resolve_engine || true)"
if [ -z "$bundle" ]; then
  echo ""
  echo "L'assistant (bundle) n'est pas localisé sur cette machine."
  echo "  Config partagée : $shared"
  echo "Lancement du bootstrap (pointer / chercher / installer)..."
  echo ""
  [ -f "$proj/bootstrap.sh" ] && bash "$proj/bootstrap.sh"
  bundle="$(resolve_engine || true)"
fi
if [ -z "$bundle" ]; then
  echo "Pas de bundle valide. Relancer :  ./bootstrap.sh"
  exit 1
fi
bash "$bundle/assistant.sh" "$@"
