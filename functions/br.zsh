br() {
    git branch | fzf --height=50% --reverse --info=inline | xargs git switch
}

