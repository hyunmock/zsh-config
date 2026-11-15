# ~/.zsh/init.zsh

# Load environment variables
source ~/.zsh/env.zsh

# Load path variables
source ~/.zsh/path_vars.zsh

# Load aliases
source ~/.zsh/aliases.zsh

# Load qgenie aliases (only on machines with qgenie installed)
(( $+commands[qgenie] )) && source ~/.zsh/qgenie.zsh

# ---------------------------------------------
# ⚙️ Custom Functions
# ---------------------------------------------
# 1. Add custom functions path
fpath=(~/.zsh/functions $fpath)

source ~/.zsh/functions.zsh

# 2. Autoload functions
autoload -U sync_br
