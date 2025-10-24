# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS terminal configuration repository that sets up a customized zsh environment with Powerlevel10k theme, Starship prompt, syntax highlighting, autosuggestions, and colorls. The configuration provides a visually enhanced terminal experience using the Dracula color theme.

## Key Commands

### Installation
```bash
make install-all     # Full installation (installs zsh, plugins, fonts, themes)
make install-font    # Install Hack Nerd Font only
make install-ruby    # Install Ruby 3.3.6 via rbenv (required for colorls)
make fix-colorls     # Fix colorls gem conflicts (if you get gem errors)
make help            # Show all available commands
```

### Configuration Management
```bash
make setup-powerlevel10k-theme  # Copy .p10k.zsh to home directory
make setup-starship             # Copy starship.toml to ~/.config/
make configure-design           # Run interactive p10k configuration
```

### Removal
```bash
make remove-all      # Remove all configurations and installations
```

## Architecture

### Installation Flow
The `install-all` target follows this sequence:
1. Install command line tools (xcode-select)
2. Update Homebrew
3. Install zsh and set as default shell
4. Create initial rbenv PATH setup in .zshrc (setup-zsh-1)
5. Install utilities: bat, starship
6. Install colorls (Ruby gem, requires Ruby 3.0+)
7. Clone plugin repositories to ~/.zsh/
8. Copy configuration files to home directory
9. Source .zsh-config in .zshrc (setup-zsh-2)

### Configuration Files
- `.zsh-config`: Main zsh configuration sourced by .zshrc. Sets up:
  - Powerlevel10k instant prompt
  - Plugin loading (syntax highlighting, autosuggestions, powerlevel10k)
  - Starship prompt initialization
  - Colorls theme setup
  - Aliases: `ls` → `colorls --dark --tree=1`, `cat` → `bat --theme=Dracula`

- `.p10k.zsh`: Powerlevel10k theme configuration (88KB, extensive customization)

- `starship.toml`: Starship prompt symbol customization for various languages/tools

### Plugin Repositories (cloned to ~/.zsh/)
- zsh-autosuggestions
- zsh-syntax-highlighting
- powerlevel10k
- colorls (Dracula theme)

### Dependencies
- Homebrew (package manager)
- Ruby 3.0+ (for colorls gem)
- rbenv (Ruby version manager)
- Hack Nerd Font (for icon display)
- Dracula Terminal theme (manual installation)

## Important Notes

- The repository modifies ~/.zshrc by adding rbenv PATH and sourcing ~/.zsh-config
- Font installation requires manual theme selection in Terminal preferences
- Ruby version must be 3.0+ for colorls compatibility
- All make targets use @ prefix for cleaner output, showing only colored status messages
- The Makefile defines FONT_NAME_CODE and RUBY_VERSION as configurable variables at the top
