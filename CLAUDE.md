# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal zsh configuration repository with a modular structure for shell aliases, environment variables, and functions.

## Architecture

The configuration follows a modular loading pattern:

- `init.zsh` - Main entry point that sources all other modules
- `env.zsh` - Environment variables (currently empty)
- `aliases.zsh` - Shell aliases for common commands
- `functions.zsh` - Loader that sources all function files from `functions/` directory
- `functions/` - Directory containing individual function files:
  - `br.zsh` - Git branch switching with fzf
  - `fzf.zsh` - FZF shell integration
  - `wtbr.zsh` - Worktree branch navigation

## Key Dependencies

- `eza` - Modern replacement for ls (used in aliases)
- `fzf` - Fuzzy finder (used in br and wtbr functions)
- `nvim` - Neovim (aliased as vi)

## Common Operations

### Adding New Functions
Create new `.zsh` files in the `functions/` directory. They will be automatically loaded by `functions.zsh`.

### Modifying Configuration
- Aliases: Edit `aliases.zsh`
- Environment variables: Edit `env.zsh`
- Functions: Add to `functions/` directory or modify existing files

### Testing Changes
Source the configuration manually: `source ~/.zsh/init.zsh`

## Function Details

- `br()` - Interactive git branch switcher using fzf
- `wtbr()` - Navigate between sibling directories (useful for git worktrees)