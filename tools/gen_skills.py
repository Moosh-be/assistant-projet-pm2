#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""gen_skills.py — génère 1 skill opencode par document de méthode.

Principe (WP-0050) : **un skill = un document de méthode / pratique / norme** — PM² est
le premier cas d'usage, le générateur est **agnostique de la méthode** : il découvre
`methode/<M>/<lang>/` (présence = méthode soutenue, WP-0045) et génère 1 skill par
document du **référentiel** de la méthode (catalogue : | Code | Artefact | Phase | Gate | Fichier |).

Sortie : .opencode/skills/ap-<methode>[-<lang>]-<NN>-<slug>/SKILL.md  (dans le bundle)
      — si le code du référentiel porte un abrégé en lettres au lieu d'un numéro
      (ex. l'espace `Doc` : `DOC-TECHN.P`), pas de <NN> : ap-<methode>-<slug>.

Sources de vérité :
  - le catalogue   : methode/<M>/<lang>/referentiel*.md
  - les templates  : methode/<M>/<lang>/<dossier>/<fichier>
                     (frontmatter + section « ## 2. Questions de l'assistant »)

Conventions du kit pour être détecté :
  - 1 dossier `methode/<M>/<lang>/` = 1 méthode/langue soutenue ;
  - le référentiel porte le catalogue (tableau 5 colonnes) ;
  - chaque template a une section « ## 2. Questions de l'assistant » (bullets `- [ ]`).

Usage : python tools/gen_skills.py
Régénère tous les skills — utile après modification des templates ou du protocole commun.
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
METHROOT = ROOT / "methode"
OUT = ROOT / ".opencode" / "skills"

# plans de gestion PM² (codes) → note anti-surcharge (proposer envisagé / utilisé / ignoré)
PLANS_GESTION = {
    "PM2-07.P", "PM2-08.P", "PM2-09.P", "PM2-10.P",
    "PM2-11.P", "PM2-12.P", "PM2-13.P", "PM2-14.P",
    "PM2-15.P", "PM2-16.P",
}


def discover():
    """methode/<M>/<lang>/ avec un référentiel → une entrée par (méthode, langue)."""
    entries = []
    if not METHROOT.is_dir():
        return entries
    for m_dir in sorted(METHROOT.iterdir()):
        if not m_dir.is_dir():
            continue
        for lang_dir in sorted(m_dir.iterdir()):
            if not lang_dir.is_dir():
                continue
            refs = sorted(lang_dir.glob("referentiel*.md"))
            if refs:
                entries.append({
                    "methode": m_dir.name.lower(), "methode_name": m_dir.name,
                    "lang": lang_dir.name, "dir": lang_dir, "ref": refs[0],
                })
    # si une méthode a plusieurs langues, l'id des skills prend le suffixe -<lang>
    per_meth = {}
    for e in entries:
        per_meth.setdefault(e["methode"], []).append(e)
    for langs in per_meth.values():
        for e in langs:
            e["lang_suffix"] = f"-{e['lang']}" if len(langs) > 1 else ""
    return entries


def parse_catalog(ref_path):
    """Lignes du catalogue : | Code | Artefact | Phase | Gate | Fichier |"""
    rows = []
    for line in ref_path.read_text(encoding="utf-8").splitlines():
        m = re.match(r"^\|\s*([A-Za-z0-9]+-[A-Za-z0-9]+\.[A-Z]+)\s*\|([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)\|", line)
        if not m:
            continue
        code, nom, phase, gate, fichier = (g.strip() for g in m.groups())
        rows.append({
            "code": code, "nom": nom, "phase": phase, "gate": gate,
            "fichier": fichier.strip("`"),
        })
    return rows


def find_template(mdir, fichier):
    dossier, pattern = fichier.split("/", 1)
    cands = sorted((mdir / dossier).glob(pattern))
    if len(cands) != 1:
        sys.exit(f"template introuvable ou ambigu pour « {fichier} » : {cands}")
    return cands[0]


def read_template(path):
    """Frontmatter (nom/phase/gate/…) + questions de la section 2."""
    txt = path.read_text(encoding="utf-8")
    fm = {}
    m = re.match(r"^---\r?\n(.*?)\r?\n---", txt, re.S)
    if m:
        for line in m.group(1).splitlines():
            k, _, v = line.partition(":")
            fm[k.strip()] = v.strip().strip('"')
    questions = []
    m = re.search(r"^## 2\. Questions de l'assistant\s*\n(.*?)(?=^## )", txt, re.S | re.M)
    if m:
        for line in m.group(1).splitlines():
            q = re.match(r"^\s*-\s*\[[ xX]\]\s*(.+)$", line)
            if q:
                questions.append(q.group(1).strip())
    return fm, questions


def gate_lines(r):
    gate = r["gate"].replace("→", "").strip()
    if r["code"] == "PM2-27.MC":
        return [
            "## Gate",
            "",
            "- Ce document **est** la checklist de sortie de phase (PM2-27) — le **pilote des",
            "  gates** : une checklist par gate (`checklists/gate-RfP.md` / `gate-RfE.md` /",
            "  `gate-RfC.md`). Elle **bloque ou fait passer** la phase : items tous verts →",
            "  proposer le passage (`gate_suivant` → phase + 1 dans le frontmatter de `projet.md`).",
        ]
    if gate == "—":
        return [
            "## Gate",
            "",
            "- Pas de gate direct (document de conduite / de suivi).",
        ]
    return [
        "## Gate",
        "",
        f"- Cet artefact alimente la checklist **{gate}** (PM2-27) : `checklists/gate-{gate}.md` (bundle).",
        "- Règle du gate : tant que la checklist n'est pas verte, **aucun artefact de la phase suivante**.",
    ]


def build_skill(r, tpl_path, mdir, fm, questions, by_phase, e):
    code = r["code"]
    num = re.search(r"(\d+)$", code.split(".")[0])            # PM2-01.I → 01 ; None si abrégé en lettres
    num = num.group(1) if num else None
    slug = re.sub(r"^[A-Za-z0-9]+-[A-Za-z0-9]+\.[A-Z]+-", "", tpl_path.stem)
    sid = f"ap-{e['methode']}{e['lang_suffix']}" + (f"-{num}" if num else "") + f"-{slug}"
    phase_disp = fm.get("phase", r["phase"])
    gate = r["gate"].replace("→", "").strip()
    gate_desc = "sans gate direct" if gate == "—" else f"gate {gate}"
    # fichier exact du template (relatif à methode/<M>/<lang>/) — pas le glob du catalogue
    fichier_exact = tpl_path.relative_to(mdir).as_posix()
    ref_bundle = f"methode/{e['methode_name']}/{e['lang']}/{fichier_exact}"

    codes = by_phase.get(r["phase"], [code.split(".")[0]])
    cycle = " · ".join(codes)
    if r["phase"] == "Planification / Suivi":
        cycle += " ; suivi dans les phases Planification et Suivi & Contrôle"
    if code == "PM2-27.MC":
        cycle += " — c'est LE pilote des 3 gates"

    name = f"{code} — {r['nom']}"
    desc = (f"Remplir / relire le {code} {r['nom']} ({phase_disp}, {gate_desc}) : "
            f"questions d'entretien, discipline [À confirmer] + source, mise à jour frontmatter "
            f"et phase. À utiliser quand on travaille ce document dans un projet assisté.")

    q_block = "\n".join(f"- {q}" for q in questions) if questions else "- (section 2 du template à compléter)"

    plan_step = ""
    if code in PLANS_GESTION:
        plan_step = ("\n6. **Anti-surcharge** : proposer le statut **envisagé / utilisé / ignoré** "
                     "(tableau §4 de `projet.md`) — aucun plan n'est créé par défaut.\n")

    body = f"""---
name: "{name}"
description: "{desc}"
---

# {name} (skill de remplissage)

> **1 skill = 1 document de méthode** (WP-0050). Le **template** (structure, champs) = source de
> vérité : `{ref_bundle}` (bundle). Ce skill = le **protocole de remplissage** de ce
> document ; le protocole commun (modes A/B/C, annonce de session, journal des échanges) :
> `AGENT-projet.md` §3 (bundle).

## Position

- **Phase** : {phase_disp} · **Gate** : {gate}
- **Dans le cycle** : {cycle}
- **Dans le projet** : `{r['fichier']}` (1 projet = 1 folder ; les templates vivent dans le bundle).
  Absent du projet → le **créer depuis le template du bundle** (copie) ; présent → on
  **complète** (jamais d'écrasement).

## Questions de l'entretien (du template §2 — au fil de l'eau, quand les données viennent)

{q_block}

## Protocole de remplissage

1. **Mode B** : une question à la fois, quand la donnée vient (pas un interrogatoire en bloc).
2. **Ne jamais inventer** : donnée absente → on la demande ; donnée déduite → `[À confirmer]` + sa `source`.
3. **À chaque remplissage** : frontmatter de l'artefact (`statut` · `date_maj` · `source`) +
   sa section « Statut de remplissage ».
4. **La phase** : tableau §3 de `projet.md` (artefacts faits / dus) — mis à jour par l'assistant.
5. **Mode C** : une donnée qui tombe dans un échange → la proposer dans ce document
   (inscription avec sa `source` : « échange du JJ/MM »).
{plan_step}
{chr(10).join(gate_lines(r))}
"""
    return sid, body


def main():
    entries = discover()
    if not entries:
        sys.exit("aucune méthode détectée (methode/<M>/<lang>/ avec un référentiel*)")

    total = 0
    for e in entries:
        rows = parse_catalog(e["ref"])
        if not rows:
            print(f"  ! {e['ref'].name} : catalogue illisible — ignoré")
            continue
        by_phase = {}
        for r in rows:
            by_phase.setdefault(r["phase"], []).append(r["code"].split(".")[0])

        n = 0
        for r in rows:
            tpl = find_template(e["dir"], r["fichier"])
            fm, questions = read_template(tpl)
            sid, body = build_skill(r, tpl, e["dir"], fm, questions, by_phase, e)
            d = OUT / sid
            d.mkdir(parents=True, exist_ok=True)
            (d / "SKILL.md").write_text(body, encoding="utf-8")
            n += 1
            total += 1
            print(f"  + {sid}/SKILL.md  ({len(questions)} questions)")
        print(f"{e['methode']}/{e['lang']} : {n} skills ({e['ref'].name})")
    print(f"OK : {total} skills générés dans .opencode/skills/")


if __name__ == "__main__":
    main()
