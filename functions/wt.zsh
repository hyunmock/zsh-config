# wt - git worktree wrapper
# wt add <worktree-name> <branch-name>  : create worktree + copy .env/CLAUDE.md/AGENTS.md + cd
# wt switch | wt sw [worktree-name]     : fzf-pick (or jump directly by name) an existing worktree and cd into it
# wt <anything-else>                    : passthrough to `git worktree`

_wt_add() {
    local wt_name="$1"
    local branch_name="$2"

    if [[ -z "$wt_name" || -z "$branch_name" ]]; then
        echo "Usage: wt add <worktree-name> <branch-name>"
        return 1
    fi

    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$repo_root" ]]; then
        echo "Error: Not a git repository."
        return 1
    fi

    local wt_path="${repo_root:h}/${wt_name}"
    if [[ -e "$wt_path" ]]; then
        echo "Error: Path already exists: $wt_path"
        return 1
    fi

    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        git worktree add "$wt_path" "$branch_name" || return 1
    else
        git worktree add -b "$branch_name" "$wt_path" || return 1
    fi

    local f
    for f in .env CLAUDE.md AGENTS.md; do
        [[ -f "$repo_root/$f" ]] && cp "$repo_root/$f" "$wt_path/$f"
    done

    cd "$wt_path" && pwd
}

_wt_switch() {
    local target="$1"

    local current_path
    current_path=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$current_path" ]]; then
        echo "Error: Not a git repository."
        return 1
    fi

    local parent_path="${current_path:h}"

    local entries
    entries=$(git worktree list --porcelain | awk -v cur="$current_path" -v parent="$parent_path" '
        /^worktree /  { path = substr($0, 10); n = split(path, a, "/"); name = a[n] }
        /^branch /    { if (path != cur && path ~ "^" parent "/[^/]+$") print path "\t" name; path=""; name="" }
        /^detached$/  { if (path != cur && path ~ "^" parent "/[^/]+$") print path "\t" name; path=""; name="" }
    ')

    if [[ -n "$target" ]]; then
        local target_name="${target:t}"
        local matches
        matches=$(echo "$entries" | awk -F'\t' -v p="$target" -v n="$target_name" '$1 == p || $2 == n')

        if [[ -z "$matches" ]]; then
            echo "Error: No worktree matching '$target'"
            return 1
        elif [[ $(echo "$matches" | wc -l) -gt 1 ]]; then
            echo "Error: Multiple worktrees matching '$target':"
            echo "$matches" | cut -f2
            return 1
        fi

        local target_path="${matches%%$'\t'*}"
        cd "$target_path" && pwd || echo "Failed to change directory"
        return
    fi

    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is not installed. Please install fzf to use wt switch."
        return 1
    fi

    local selected
    selected=$(echo "$entries" | fzf --height=40% --reverse --prompt="Select worktree: " --with-nth=2 --delimiter='\t')

    if [[ -n "$selected" ]]; then
        local target_path="${selected%%$'\t'*}"
        cd "$target_path" && pwd || echo "Failed to change directory"
    else
        echo "No worktree selected"
        return 1
    fi
}

wt() {
    case "$1" in
        add)
            shift
            _wt_add "$@"
            ;;
        switch|sw)
            shift
            _wt_switch "$@"
            ;;
        *)
            git worktree "$@"
            ;;
    esac
}

_wt() {
    local -a subcmds branches

    case $CURRENT in
        2)
            subcmds=(
                'add:create worktree + branch'
                'switch:fzf-pick an existing worktree'
                'sw:fzf-pick an existing worktree'
            )
            _describe -t commands 'wt command' subcmds
            return
            ;;
    esac

    case ${words[2]} in
        add)
            case $CURRENT in
                3)
                    _message 'worktree name'
                    ;;
                4)
                    branches=(${(f)"$(git for-each-ref --format='%(refname:short)' refs/heads/ 2>/dev/null)"})
                    _describe -t branches 'branch name' branches
                    ;;
            esac
            ;;
        switch|sw)
            local current_path parent_path
            current_path=$(git rev-parse --show-toplevel 2>/dev/null)
            if [[ -n "$current_path" ]]; then
                parent_path="${current_path:h}"
                local -a wt_entries
                wt_entries=(${(f)"$(git worktree list --porcelain | awk -v cur="$current_path" -v parent="$parent_path" '
                    /^worktree /  { path = substr($0, 10); n = split(path, a, "/"); name = a[n] }
                    /^branch /    { if (path != cur && path ~ "^" parent "/[^/]+$") print name ":" path; path=""; name="" }
                    /^detached$/  { if (path != cur && path ~ "^" parent "/[^/]+$") print name ":" path; path=""; name="" }
                ')"})
                _describe -t worktrees 'worktree' wt_entries
            fi
            ;;
        *)
            _git
            ;;
    esac
}
compdef _wt wt
