# wtbr - worktree branch out 
wtbr() {
    local parent_dir="${PWD:h}"
    if [[ ! -d "$parent_dir" ]]; then
        echo "Error: Cannot access parent directory"
        return 1
    fi

    local current_basename="${PWD:t}"
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is not installed. Please install fzf to use wtbr."
        return 1
    fi

    local selected=$(ls -1d "$parent_dir"/*/ 2>/dev/null | while read dir; do
        local dirname="${dir:t}"
        [[ "$dirname" != "$current_basename" ]] && echo "$dirname"
    done | sort | fzf --height=40% --reverse --prompt="Select sibling directory: ")

    if [[ -n "$selected" ]]; then
        cd "$parent_dir/$selected" && pwd || echo "Failed to change directory"
    else
        echo "No directory selected"
        return 1
    fi
}

