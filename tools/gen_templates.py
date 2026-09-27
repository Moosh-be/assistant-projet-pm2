#!/usr/bin/env python3
"""gen_templates.py — génère les squelettes Markdown des artefacts PM² (v3.0.1).

Le kit « assistant-projet-pm2 » : 1 artefact = 1 fichier .md avec
  - frontmatter machine (template, phase, gate, statut, projet)
  - les sections standard du template
  - les QUESTIONS DE L'ASSISTANT (une par champ, pour le mode « entretien »)
  - les instructions d'usage

Version PUBLIQUE (contribution PM²) : générique, aucune donnée RTBF.
Le fork RTBF (GitLab) remplace/enrichit les champs avec les traductions RTBF
des templates Word v3.0.1 (bibliothèque Gestiondeprojet-PM).

Usage : python tools/gen_templates.py   (dans la racine du repo)
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# (code, nom, phase, gate, sections, questions)
TEMPLATES = [
    # ── 01 Lancement (→ RfP) ──────────────────────────────────────────
    ("01", "I", "Demande de lancement de projet", "01 Lancement", "RfP",
     ["Demandeur et date", "Intitulé du projet", "Description synthétique du besoin",
      "Résultats attendus (valeur)", "Justification (pourquoi maintenant)",
      "Critères de succès", "Décision demandée (go/no-go)"],
     ["Qui porte la demande (demandeur, date) ?", "Que va changer ce projet (besoin) ?",
      "Quels résultats mesurables attendez-vous (valeur) ?", "Pourquoi maintenant (urgence/opportunité) ?",
      "Qu'est-ce qui prouvera que le projet a réussi (critères) ?"]),
    ("02", "I", "Cas d'usage (business case)", "01 Lancement", "RfP",
     ["Contexte et problème", "Options considérées", "Option retenue et pourquoi",
      "Estimation de la valeur (bénéfices)", "Estimation du coût", "Hypothèses et dépendances"],
     ["Quel problème résout-on (qui est impacté aujourd'hui) ?", "Quelles options ont été envisagées ?",
      "Pourquoi cette option (comparaison) ?", "Combien ça rapporte / qu'est-ce que ça économise ?",
      "Combien ça coûte (enveloppe) ?", "Sur quelles hypothèses repose-t-on ?"]),
    ("03", "I", "Charte du projet", "01 Lancement", "RfP",
     ["Objectifs et périmètre (dans / hors)", "Résultats attendus et critères",
      "Parties prenantes clés et rôles (Sponsor, BM, Chef de projet, Fournisseur)",
      "Jalons prévisionnels", "Risque principal", "Budget d'ordre de grandeur",
      "Décision de lancement (go/no-go + date)"],
     ["Quel est l'objectif en une phrase ?", "Qu'est-ce qui est explicitement HORS périmètre ?",
      "Qui est le Sponsor (décide) ? le Business Manager (valeur) ? le Chef de projet (livre) ? le Fournisseur (ressources) ?",
      "Quels sont les 3 jalons qui comptent ?", "Quel est LE risque qui pourrait tout tuer ?",
      "L'ordre de grandeur du budget ?", "Le go est-il donné, par qui, quand ?"]),
    # ── 02 Planification (→ RfE) ──────────────────────────────────────
    ("04", "P", "Manuel du projet", "02 Planification", "RfE",
     ["Comment ce projet fonctionne (règles du jeu)", "Organisation et gouvernance (instances, fréquence, décision)",
      "Communication (canx, rituels, qui est informé)", "Outils et espaces de travail", "Gestion des livrables et de la qualité"],
     ["Quelles sont les règles du jeu de CE projet (pas celles de l'orga) ?", "Qui décide quoi, quand (instances) ?",
      "Comment la information circule (canx, fréquence) ?", "Où vit le projet (outils, dossiers) ?"]),
    ("05", "P", "Matrice des parties prenantes", "02 Planification", "RfE",
     ["Tableau : partie prenante | rôle | intérêt | influence | niveau de soutien (favorable/neutre/hostile) | stratégie"],
     ["Qui est impacté par le projet (liste) ?", "Qui a le pouvoir d'aider ou de bloquer ?",
      "Qui est favorable / neutre / défavorable ? À quoi reconnaît-on ça ?", "Quelle posture avec chacun (informer, consulter, impliquer, manager de près) ?"]),
    ("06", "P", "Plan de travail", "02 Planification", "RfE",
     ["Découpage (WBS / livrables)", "Activités et séquences", "Jalons et dates", "Durées et chevauchements", "Ressources par activité"],
     ["Quels sont les livrables (de la grosse découpe) ?", "Dans quel ordre, avec quelles dépendances ?",
      "Quelles dates sont non négociables ?", "Qui fait quoi, combien de temps ?"]),
    ("07", "P", "Plan d'externalisation", "02 Planification", "RfE",
     ["Ce qui est externalisé / interne (découpage)", "Fournisseurs et périmètre de chaque prestation",
      "Interfaçage (qui fait la jonction, quand)", "Suivi des prestations (livrables, fréquence)"],
     ["Qu'est-ce qu'on fait nous-mêmes et qu'est-ce qu'on achète ?", "Quelles prestations, chez quels fournisseurs ?",
      "Qui gère la jonction interne/externe ?", "Comment suit-on les prestations (livrables, rituels) ?"]),
    ("08", "P", "Plan d'acceptation des livrables", "02 Planification", "RfE",
     ["Qui accepte quoi", "Critères d'acceptation par livrable", "Démarche de recette (qui, quand, comment)", "Conditions de passage"],
     ["Qui a le pouvoir d'accepter chaque livrable ?", "Quels critères (mesurables) pour qu'un livrable soit accepté ?",
      "Comment se déroule la recette (démarche, durée) ?", "Que se passe-t-il si un livrable n'est pas accepté ?"]),
    ("09", "P", "Plan de transition", "02 Planification", "RfE",
     ["Ce qui doit être en place pour passer en exploitation", "Transferts (compétences, données, outils)",
      "Plan de formation", "Conditions de bascule (critères)"],
     ["Qu'est-ce que l'exploitation doit être prête à prendre en charge ?", "Qui est formé, à quoi, d'ici quand ?",
      "Quels sont les critères qui déclenchent la bascule ?"]),
    ("10", "P", "Plan de mise en œuvre de l'activité", "02 Planification", "RfE",
     ["Déploiement (phases, lots)", "Conditions opérationnelles", "Accompagnement des utilisateurs", "Mesure de l'adoption"],
     ["Comment le déploiement est-il découpé (phases/lots) ?", "Quelles conditions techniques/orga pour chaque lot ?",
      "Qui accompagne les utilisateurs, comment ?", "Comment mesure-t-on que c'est adopté ?"]),
    ("11", "P", "Plan de gestion des exigences", "02 Planification", "RfE",
     ["Source des exigences et collecte", "Traçabilité (exigence → décision → livrable)", "Validation et priorisation", "Évolution des exigences"],
     ["Où viennent les exigences (qui les formule) ?", "Comment trace-t-on chaque exigence jusqu'au livrable ?",
      "Qui valide et qui priorise ?", "Comment gère-t-on une exigence qui change en cours ?"]),
    ("12", "P", "Plan de gestion des changements", "02 Planification", "RfE",
     ["Qui peut demander un changement", "Démarche (formulaire, analyse d'impact)", "Instance d'arbitrage", "Suivi et clôture des demandes"],
     ["Qui peut demander un changement (périmètre, planning, budget) ?", "Quelle démarche (formulaire, analyse d'impact) ?",
      "Quelle instance arbitre (qui, quand) ?", "Comment suit-on jusqu'à clôture (appliqué/refusé) ?"]),
    ("13", "P", "Plan de gestion des risques", "02 Planification", "RfE",
     ["Approche (qui identifie, quand, comment)", "Registre des risques (description | proba | impact | score | réponse | propriétaire)",
      "Réponses (éviter, réduire, transférer, accepter)", "Rituels de revue"],
     ["Quels sont les risques majeurs (3-5 à minima) ?", "Pour chacun : probabilité, impact, score ?",
      "Quelle réponse et qui en est propriétaire ?", "À quelle fréquence le registre est-il revu ?"]),
    ("14", "P", "Plan de gestion des problèmes", "02 Planification", "RfE",
     ["Différence risque / problème", "Registre des problèmes (description | sévérité | action | responsable | date)",
      "Escalade (à quel seuil, vers qui)", "Rituels de suivi"],
     ["Quel est le problème en cours le plus critique ?", "Quelle action, par qui, pour quand ?",
      "Quand un problème s'aggrave-t-il et vers qui monte-t-on ?"]),
    ("15", "P", "Plan de gestion de la qualité", "02 Planification", "RfE",
     ["Définition de la qualité (critères par livrable)", "Contrôles (qui, quand, quoi)", "Amélioration continue"],
     ["Qu'est-ce qui fait qu'un livrable est « bon » (critères) ?", "Quels contrôles (revue, test, audit) à quel moment ?",
      "Comment apprend-on des non-conformités (retour d'expérience) ?"]),
    ("16", "P", "Plan de gestion de la communication", "02 Planification", "RfE",
     ["Qui a besoin de quelle information, quand, comment", "Rituels de communication (comités, points, reporting)",
      "Gestion de la visibilité (succès, dérive)"],
     ["Qui a besoin de quoi, à quelle fréquence, par quel canal ?", "Quels rituels (comités, points) avec qui ?",
      "Comment communique-t-on une dérive (à quel moment, à qui) ?"]),
    # ── 03 Exécution ─────────────────────────────────────────────────
    ("18", "E", "Procès-verbal de réunion", "03 Exécution", None,
     ["Objet et participants", "Décisions (qui décide quoi)", "Actions (qui fait quoi, pour quand)", "Points d'attention"],
     ["Quelle décision a été prise (et par qui) ?", "Quelles actions (qui, quoi, quand) ?",
      "Quel point mérite une attention particulière ?"]),
    # ── 04 Suivi & Contrôle ──────────────────────────────────────────
    ("19", "E", "Rapport d'état de projet", "04 Suivi-Controle", None,
     ["Feux (planning, budget, périmètre, risque)", "Avancement (livrables, jalons)", "Prochaines étapes", "Problèmes et décisions demandées"],
     ["Quel feu pour chaque dimension (planning/budget/périmètre/risque) — et pourquoi ce feu ?",
      "Quel jalon vient de passer / est en danger ?", "Quelle décision est demandée, par qui, avant quand ?"]),
    ("21", "E", "Demande de modification", "04 Suivi-Controle", None,
     ["Description de la demande", "Impact (coût, planning, périmètre, qualité)", "Options", "Recommandation"],
     ["Que demande-t-on de changer, exactement ?", "Quel est l'impact chiffré (coût/planning) ?",
      "Quelles options (avec coût) ?", "Que recommandes-tu ?"]),
    ("22", "E", "Rapport d'état de projet (scorecard)", "04 Suivi-Controle", None,
     ["Indicateurs (valeur, avancement, budget, risque, qualité)", "Tendances et écarts", "Actions correctives"],
     ["Quel est l'écart le plus important aujourd'hui ?", "Quelle action corrective (qui, quand) ?"]),
    ("27", "MC", "Liste de contrôle de sortie de phase", "04 Suivi-Controle", "gate",
     ["Checklist du gate RfP (artefacts Lancement complétés, décision go/no-go, rôles confirmés)",
      "Checklist du gate RfE (artefacts Planification complétés, plan approuvé, baseline posée)",
      "Checklist du gate RfC (livrables acceptés, transition prête, leçons apprises, clôture administrative)"],
     ["Quel artefact manque pour valider ce gate ?", "Quelle condition de passage n'est pas encore remplie ?"]),
    # ── 05 Clôture ───────────────────────────────────────────────────
    ("33", "C", "Rapport de fin de projet", "05 Cloture", "RfC",
     ["Résultats atteints vs objectifs (critères de la charte)", "Budget et planning final vs prévision",
      "Ce qui a bien marché (à reproduire)", "Ce qui a mal marché (à éviter)", "Leçons apprises",
      "Transfert à l'exploitation (confirmé)", "Clôture administrative (ressources libérées)"],
     ["Les objectifs de la charte sont-ils atteints (critère par critère) ?",
      "Budget et planning final : écart et pourquoi ?", "Qu'est-ce qu'on ferait pareil / différemment ?",
      "Le transfert est-il effectif (exploitation prête) ?", "Les ressources sont-elles libérées ?"]),
]

FRONT = """---
template: "{code}.{let}"
nom: "{nom}"
phase: "{phase}"
gate: "{gate}"
projet: ""
statut: vide            # vide | en cours | fait | ignore
date_maj: ""
source: ""
---
"""

BODY = """
# {nom}

> **Template** : {code}.{let} · **Phase** : {phase} · **Gate** : {gate}
> Ce document est un **squelette générique** (contribution PM², v3.0.1). Le fork RTBF
> enrichit chaque champ avec la traduction RTBF du template Word d'origine.

## 1. Contenu

{sections}

## 2. Questions de l'assistant

> Mode « entretien » : l'assistant pose ces questions au fil de l'eau, **quand les données viennent**
> (pas un interrogatoire en bloc). Chaque réponse remplit la section 1 correspondante.
> Toute donnée non validée est marquée `[À confirmer]` + sa `source`.

{questions}

## 3. Statut de remplissage
- [ ] Sections remplies : 0/{nsec}
- [ ] Aucune donnée non validée sans `[À confirmer]`
- [ ] Gate (si applicable) : checklist consultée → `checklists/gate-{gate}.md`
"""


def gen():
    n = 0
    for code, let, nom, phase, gate, sections, questions in TEMPLATES:
        d = ROOT / phase
        d.mkdir(parents=True, exist_ok=True)
        slug = nom.lower().replace(" ", "-").replace("'", "").replace("(", "").replace(")", "").replace("/", "-")
        f = d / f"PM2-{code}.{let}-{slug}.md"
        sec = "\n".join(f"### {i+1}. {s}\n\n[À remplir]\n" for i, s in enumerate(sections))
        q = "\n".join(f"- [ ] {q}" for q in questions)
        gate_s = gate if gate and gate != "gate" else "n/a"
        content = FRONT.format(code=code, let=let, nom=nom, phase=phase, gate=gate_s)
        content += BODY.format(code=code, let=let, nom=nom, phase=phase, gate=gate_s,
                               sections=sec, questions=q, nsec=len(sections))
        f.write_text(content, encoding="utf-8")
        n += 1
    print(f"{n} squelettes générés.")


if __name__ == "__main__":
    gen()
