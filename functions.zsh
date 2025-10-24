# ~/.zsh/functions.zsh

# Source fzf.zsh first
if [[ -f ~/.zsh/functions/fzf.zsh ]]; then
    source ~/.zsh/functions/fzf.zsh
fi

# Source remaining function files
for f in ~/.zsh/functions/*.zsh; do
    [[ "${f:t}" != "fzf.zsh" ]] && source "$f"
done


