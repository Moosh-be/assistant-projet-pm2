# Du résilient rudimentaire au confort

> Une notion importante, à **raconter** plutôt qu'à documenter : **prévoir le pire comme le meilleur**.
>
> Le pire, c'est « **text only** » : des fichiers texte que tu édites **même avec `nano`** — et **tout fonctionne**.
> Le meilleur, c'est **le confort** : une interface, une IA, un harness, **celui que tu veux** — pendant que ton collaborateur en utilise un autre.
>
> Entre les deux : **la même data**, du brut au confort. Une lecture courte, pas une doc technique :
> le détail des 3 modes (fichier / natif / IA) est dans le [guide §1.3](guide.md#13-les-3-modes-dutilisation-dégradation-résiliente) ;
> ici on raconte la **posture**. La racine du principe est dans le [README](../README.fr.md) (« 🛟 Résilient : les données survivent à l'outillage »).

## Le pire — « text only », et tout fonctionne

Le jour où tout disparaît — l'IA indisponible, le bundle introuvable, l'interface fermée — il te reste quoi ?
**Des fichiers Markdown sur un disque.** Tu ouvres `projet.md` avec `nano`, tu changes la phase, tu remplis un artefact. **Et tout fonctionne.**

- Les **artefacts sont du Markdown, lisibles n'importe où** : la phase, le gate, la data sont *dans le fichier* — pas dans un serveur, une base, ou une interface qui disparaîtrait.
- Les **commandes natives** (`assistant.ps1` / `assistant.sh` : `scan`, `statut`, `new`, `sync`, `liste`) tournent **sans IA ni interface**, sur un simple drive — le principe du kit : *tout ce qui est faisable sans IA se fait sans IA*.
- **Le pire est une version, pas un accident.** C'est simplement le cran le plus bas de l'échelle **fichier / natif / IA** (guide §1.3) : on y *est* — volontairement, si l'environnement l'impose — on n'y *tombe* pas. On perd des capacités à chaque cran, **jamais les données**.

Le « résilient rudimentaire », c'est ça : le socle est si bas qu'**aucune panne ne peut être pire que lui**.

## Le meilleur — le confort, chacun le sien

Le confort, c'est **une interface, une IA, un harness — celui que tu veux**. Le « marteau » (l'agent) et le « coffre » (le gestionnaire de notes) sont **interchangeables** : opencode ou un autre agent, Obsidian ou un autre coffre — le kit ne dépend d'aucun, et *changer de marteau ne change rien au projet*.

Et surtout : **chacun le sien**. Toi, ton agent ; ton collaborateur, le sien — même projet, même data, **deux habitats différents**. Ça passe parce que le projet est **mince** :

- il ne porte que sa **data** (`projet.md`, `01..05`, `_meta`) + un **pointeur vers le bundle** ;
- l'outillage **reste dans le bundle** : pointé, jamais copié dans le projet partagé (les skills — WP-0050) → **zéro sync, zéro copie** → **pas de conflit de confort** : personne ne tranche qui a raison entre deux interfaces ;
- le confort est **machine** : la copie du harness est locale (gitignorée, `.opencode/`) — il **ne voyage pas** avec le projet.

**Le confort ne se copie pas, il s'adapte.** On n'impose ni le marteau ni le coffre ; le projet reste lisible par tous, et chacun travaille avec ce qui lui convient.

## Le fil — la même data, du brut au confort

Ce qui relie les deux pôles : **la même data**, lue et écrite par tous les crans.

- **La descente est résiliente** : IA → natif → fichier — on perd des capacités à chaque cran, jamais les données ; le pire est le dernier cran, une *version*.
- **L'ascension est progressive** : depuis un cran bas, le `bootstrap` retablit le lien vers le bundle **sans IA** (pointer / chercher / installer — annonce + confirmation à chaque action), puis le harness, puis la session agent : **un cran à la fois**.
- **Les 3 modes** (guide §1.3) : **fichier** (la data seule, un simple drive suffit) · **natif** (le moteur, sans IA ni internet) · **IA** (le confort, chacun le sien) — chacun fonctionnel seul. Renvoyé, pas dupliqué.

**Prévoir le pire comme le meilleur**, c'est ça : le pire **d'abord** — parce que c'est le socle, et qu'il *doit* tenir — le meilleur **ensuite** — parce qu'il est gratuit quand le socle tient. Les deux sont vrais **en même temps**, sans compromis : c'est la promesse du kit.
