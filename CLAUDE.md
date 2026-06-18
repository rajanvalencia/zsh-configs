# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS terminal configuration repository that sets up a customized zsh environment with the Powerlevel10k theme, Starship prompt, syntax highlighting, autosuggestions, and `eza`. It also installs the Ghostty terminal, the Dracula theme, Hack Nerd Font, a set of apps (Supacode, VSCodium), and a developer toolchain (Bun, Node/nvm, Go/gvm, PHP/php-version, Composer, Laravel + Herd, aws-cli, openssh). Everything is driven by a single interactive `install.sh`.

## Key Commands

```bash
./install.sh                   # Interactive install (prompts for terminal + components)
./install.sh --yes             # Non-interactive; accept all defaults
./install.sh --terminal=terminal   # Configure Terminal.app instead of Ghostty
./install.sh --no-apps --no-langs --no-cli  # Skip optional component groups
./install.sh --help            # Show all options
```

`install.sh` is **idempotent / re-runnable**: re-running updates plugins and configs, skips
already-installed tools (via `have_formula`/`have_cask` guards), and de-duplicates the managed
block in `~/.zshrc`. There is no separate uninstall script — re-run `install.sh` to update.

## Architecture

### Installation Flow (`install.sh`)
1. Verify Homebrew is present; bootstrap-clone the repo to `~/.zsh-configs` if run via `curl` with no local checkout.
2. Prompt for terminal choice + install mode (or read flags).
3. Foreground steps (may need GUI/password, no spinner): command line tools, set zsh as default.
4. Build a step list from the selections; run each via `run_step` (spinner + `[n/N]`).
5. Print NEXT STEPS.

Key implementation details:
- `run_step "label" func` runs a function in the background, animates a braille spinner, captures output to a temp log, and aborts with the log on failure.
- `manage_zshrc` maintains a single managed block delimited by `# >>> zsh-configs >>>` / `# <<< zsh-configs <<<`, stripping old blocks, stray `source ~/.zsh-config` lines, and the legacy rbenv PATH line; backs up to `~/.zshrc.bak`.

### Configuration Files
- `.zsh-config`: Main zsh config sourced by `.zshrc` via the managed block. Loads plugins, Starship, the `eza` theme dir (`EZA_CONFIG_DIR`), aliases (`ls` → `eza --icons --tree --level=1`, `cat` → `bat --theme=Dracula`), and guarded dev-env init (nvm, gvm, php-version, Composer/Go PATH, Herd shims).
- `.p10k.zsh`: Powerlevel10k theme configuration (extensive).
- `starship.toml`: Starship prompt symbols.
- `ghostty/config`: Ghostty terminal config → `~/.config/ghostty/config`. Self-contained; uses Ghostty's built-in `Dracula` theme (no download).
- `eza/theme.yml`: eza Dracula theme → `~/.config/eza/theme.yml`.
- `vscodium/settings.json`: VSCodium settings (Hack Nerd Font + Dracula), deep-merged into the user's settings.

### Plugin Repositories (cloned to ~/.zsh/)
- zsh-autosuggestions
- zsh-syntax-highlighting
- powerlevel10k

### Dependencies
- Homebrew (package manager; required)
- Hack Nerd Font (for icon display)
- jq (used to merge VSCodium settings; python3 fallback)
- Dracula theme for Terminal.app (cloned only when Terminal.app is chosen; Ghostty has Dracula built in)

## Git Commits

- Do not add Claude Code attribution or Co-Authored-By lines to commit messages

## Important Notes

- The installer modifies `~/.zshrc` only inside its managed block (backed up to `~/.zshrc.bak`).
- Ghostty/VSCodium are themed automatically; Terminal.app still needs manual theme/font selection.
- `install.sh` defines `FONT_NAME_CODE`, `REPO_URL`, and `INSTALL_DIR` as configurable variables at the top.
