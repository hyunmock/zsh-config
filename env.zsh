# env.zsh

# Load sensitive tokens (not tracked by git). Safe if the file is absent.
[ -f ~/.zsh/secrets.zsh ] && source ~/.zsh/secrets.zsh
