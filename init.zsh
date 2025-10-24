# ~/.zsh/init.zsh

# Load environment variables
source ~/.zsh/env.zsh

# Load aliases
source ~/.zsh/aliases.zsh

# ---------------------------------------------
# ⚙️ Custom Functions
# ---------------------------------------------
# 1. Add custom functions path
fpath=(~/.zsh/functions $fpath)

source ~/.zsh/functions.zsh

# 2. Autoload functions
autoload -U sync_br
