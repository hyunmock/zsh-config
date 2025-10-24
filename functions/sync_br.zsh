# ~/.zsh/functions/sync_br.zsh

sync_br() {
    # 1. Stop execution if not a git repository
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Error: Not a git repository."
        return 1
    fi

    # --- Original script contents ---

    current_branch=$(git rev-parse --abbrev-ref HEAD)

    # 2. Run git fetch
    echo "⬇️  Fetching all remotes, tags, and pruning..."
    if ! git fetch --all --tags --prune; then
        echo "Error: 'git fetch' failed. Aborting."
        return 1
    fi

    # 3. Get list of remote branches (excluding origin/HEAD)
    remote_branches=$(git branch -r | grep -v '\->' | sed 's/^[ \t]*origin\///')

    # 4. Get list of local branches
    local_branches=$(git branch | sed 's/\* //' | sed 's/ //g')

    echo "🔄 Starting remote branch synchronization..."

    # 5. Create local branches for ones that only exist on remote
    # [Fix] Use Zsh's ${(f)} flag due to differences in variable handling vs. Bash.
    # This splits the $remote_branches variable by newline for iteration.
    for branch in ${(f)remote_branches}; do
        if echo "$local_branches" | grep -q "^$branch$"; then
            echo "✅ Branch already exists locally: $branch"
        else
            echo "➕ Creating local branch: $branch"
            git branch --track "$branch" "origin/$branch"
        fi
    done

    # 6. Clean up local branches that were deleted from remote
    echo "🧹 Checking for local-only branches..."

    RED='\033[0;31m'
    NC='\033[0m' # (Note: Fixed typo from original script '[m')

    for branch in $(git branch --format='%(refname:short)'); do
        if [ "$branch" != "$current_branch" ]; then
            # Check if the remote-tracking branch 'origin/$branch' exists
            if ! git show-ref --quiet refs/remotes/origin/$branch; then
                echo -e "${RED}🔥 Deleting local branch (no longer on remote): $branch${NC}"
                git branch -D "$branch"
            fi
        fi
    done

    # 7. Switch back to the original branch and pull
    echo "⤵️  Switching to $current_branch and pulling latest changes..."
    git switch $current_branch
    git pull

    echo "✅ Done!"
}