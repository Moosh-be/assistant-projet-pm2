# OS / éditeurs
.DS_Store
Thumbs.db
desktop.ini

# Obsidian (si le projet est ouvert dans un vault)
.obsidian/workspace*
.trash/

# Python
__pycache__/
*.pyc

# État local machine — ne part jamais sur la forge (WP-0025)
# La connexion à l'assistant : la partie machine est gitignorée, la partie partagée (connexions.md) voyage.
_meta/registry/connexions.local.md
.assistant.config
assistant.config
assistant.config.md
.assistant-projet.env

# Harness opencode (machine-local, redéployable par le bootstrap / sync)
.opencode/
