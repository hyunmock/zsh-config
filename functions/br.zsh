br() {
    git branch --color=never | fzf --height=50% --reverse --info=inline | xargs git switch
}

