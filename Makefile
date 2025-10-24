# ============================================================================
# Configuration Variables
# ============================================================================
FONT_NAME_CODE := font-hack-nerd-font
RUBY_VERSION := 3.3.6

# Paths
HOME_DIR := $(HOME)
ZSH_DIR := $(HOME_DIR)/.zsh
CONFIG_DIR := $(HOME_DIR)/.config
ZSHRC := $(HOME_DIR)/.zshrc
ZSH_CONFIG := $(HOME_DIR)/.zsh-config
P10K_CONFIG := $(HOME_DIR)/.p10k.zsh
STARSHIP_CONFIG := $(CONFIG_DIR)/starship.toml

# Repository URLs
REPO_AUTOSUGGESTIONS := https://github.com/zsh-users/zsh-autosuggestions.git
REPO_SYNTAX_HIGHLIGHTING := https://github.com/zsh-users/zsh-syntax-highlighting.git
REPO_POWERLEVEL10K := https://github.com/romkatv/powerlevel10k.git
REPO_COLORLS := https://github.com/dracula/colorls.git

# Shell paths
ZSH_SHELL := /bin/zsh
BASH_SHELL := /bin/bash

# ============================================================================
# PHONY Targets
# ============================================================================
.PHONY: help install-all remove-all install-font uninstall-font \
        install-command-line-tools brew-update install-zsh set-zsh-as-default unset-zsh-as-default remove-zsh \
        install-ruby install-bat uninstall-bat install-starship uninstall-starship install-colorls uninstall-colorls fix-colorls \
        clone-repos remove-cloned-repos setup-starship remove-starship-config setup-powerlevel10k-theme remove-powerlevel10k \
        setup-zsh-1 setup-zsh-2 remove-zsh-config configure-design \
        text-info text-success text-warning text-error

# ============================================================================
# Help & Information
# ============================================================================
help: ## Display available commands
	@echo "------- Commands ------"
	@grep -E '^[a-zA-Z0-9_-]+:.*## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "\033[36mmake %-25s\033[0m %s\n", $$1, $$2}'

# ============================================================================
# Main Installation & Removal Targets
# ============================================================================
install-all: ## Install complete zsh environment
	@make install-command-line-tools
	@make brew-update
	@make install-zsh
	@make set-zsh-as-default
	@make setup-zsh-1
	@make install-bat
	@make install-starship
	@make install-colorls
	@make remove-cloned-repos
	@make clone-repos
	@make setup-starship
	@make setup-powerlevel10k-theme
	@make setup-zsh-2
	@echo ""
	@make text-success MESSAGE="Installation complete!"
	@echo ""
	@echo "\033[1;33m[NEXT STEPS]\033[0m To activate the new configuration:"
	@echo "  1. Restart your terminal (recommended), OR"
	@echo "  2. Run: exec zsh"
	@echo ""

remove-all: ## Remove all custom configurations and installations
	@make remove-zsh-config
	@make uninstall-starship
	@make uninstall-colorls
	@make remove-cloned-repos
	@make remove-powerlevel10k
	@make remove-zsh
	@echo ""
	@make text-success MESSAGE="Removal complete!"
	@echo ""
	@echo "\033[1;33m[NEXT STEPS]\033[0m To complete the cleanup:"
	@echo "  1. Restart your terminal (recommended), OR"
	@echo "  2. Run: exec zsh"
	@echo ""

# ============================================================================
# System Dependencies
# ============================================================================

install-command-line-tools: ## Install Xcode command line tools
	@make text-info MESSAGE="Installing command line tools..."
	@if ! xcode-select -p > /dev/null 2>&1; then \
		xcode-select --install; \
	else \
		make text-warning MESSAGE="Command line tools are already installed"; \
	fi

brew-update: ## Update Homebrew
	@make text-info MESSAGE="Updating Homebrew..."
	@brew update

# ============================================================================
# Font Installation
# ============================================================================
install-font: ## Install Nerd Font (args: FONT_NAME_CODE)
	@make text-info MESSAGE="Installing fonts..."
	@brew install --cask $(FONT_NAME_CODE)
	@make text-success MESSAGE="Fonts installed successfully"

uninstall-font: ## Uninstall Nerd Font (args: FONT_NAME_CODE)
	@make text-info MESSAGE="Uninstalling font..."
	@brew uninstall --cask $(FONT_NAME_CODE)
	@make text-success MESSAGE="Font uninstalled successfully"

# ============================================================================
# Shell Installation & Configuration
# ============================================================================
install-zsh: ## Install zsh via Homebrew
	@make text-info MESSAGE="Installing zsh..."
	@brew update
	@brew install zsh
	@make text-success MESSAGE="zsh installed successfully"

set-zsh-as-default: ## Set zsh as default shell
	@make text-info MESSAGE="Setting zsh as default shell..."
	@if [ "$$SHELL" = "$(ZSH_SHELL)" ]; then \
		make text-warning MESSAGE="zsh is already the default shell"; \
	else \
		chsh -s $(ZSH_SHELL); \
		make text-success MESSAGE="zsh set as default shell successfully"; \
	fi

unset-zsh-as-default: ## Reset default shell to bash
	@make text-info MESSAGE="Resetting default shell to bash..."
	@if [ "$$SHELL" = "$(BASH_SHELL)" ]; then \
		make text-warning MESSAGE="bash is already the default shell"; \
	else \
		chsh -s $(BASH_SHELL); \
		make text-success MESSAGE="Default shell reset successfully"; \
	fi

remove-zsh: ## Uninstall zsh
	@make text-info MESSAGE="Uninstalling zsh..."
	@brew uninstall zsh
	@make text-success MESSAGE="zsh uninstalled successfully"

# ============================================================================
# Ruby & rbenv Installation
# ============================================================================
install-ruby: ## Install Ruby via rbenv (args: RUBY_VERSION)
	@make install-zsh
	@make set-zsh-as-default
	@make text-info MESSAGE="Installing Ruby..."
	@brew install ruby
	@make text-info MESSAGE="Installing rbenv..."
	@brew install rbenv ruby-build
	@make text-info MESSAGE="rbenv version:"
	@rbenv -v
	@rbenv install $(RUBY_VERSION) --force
	@rbenv global $(RUBY_VERSION)
	@make text-info MESSAGE="Ruby version:"
	@ruby -v
	@make text-success MESSAGE="Ruby installed successfully"

# ============================================================================
# Utilities Installation
# ============================================================================
install-bat: ## Install bat (cat replacement)
	@make text-info MESSAGE="Installing bat..."
	@brew install bat
	@make text-success MESSAGE="bat installed successfully"

uninstall-bat: ## Uninstall bat
	@make text-info MESSAGE="Uninstalling bat..."
	@brew uninstall bat
	@make text-success MESSAGE="bat uninstalled successfully"

install-starship: ## Install Starship prompt
	@make text-info MESSAGE="Installing Starship..."
	@brew install starship
	@make text-success MESSAGE="Starship installed successfully"

uninstall-starship: ## Uninstall Starship prompt
	@make text-info MESSAGE="Uninstalling Starship..."
	@brew uninstall starship
	@make text-success MESSAGE="Starship uninstalled successfully"

install-colorls: ## Install colorls Ruby gem
	@make text-info MESSAGE="Installing colorls..."
	@if [ -f /usr/local/bin/colorls ]; then \
		make text-warning MESSAGE="Removing old colorls installation from /usr/local/bin..."; \
		sudo rm -f /usr/local/bin/colorls || true; \
	fi
	@make text-info MESSAGE="Installing colorls gem via rbenv..."
	@gem install colorls 2>&1 | grep -v "ERROR:" | grep -v "You don't have write permissions" || true
	@rbenv rehash
	@if command -v colorls > /dev/null 2>&1 && colorls --version > /dev/null 2>&1; then \
		make text-success MESSAGE="colorls installed successfully"; \
	else \
		make text-error MESSAGE="colorls installation failed - please check rbenv setup"; \
		exit 1; \
	fi

uninstall-colorls: ## Uninstall colorls Ruby gem
	@make text-info MESSAGE="Uninstalling colorls..."
	@gem uninstall -x colorls || true
	@rbenv rehash
	@if [ -f /usr/local/bin/colorls ]; then \
		make text-warning MESSAGE="Removing old colorls installation from /usr/local/bin..."; \
		sudo rm -f /usr/local/bin/colorls || true; \
	fi
	@make text-success MESSAGE="colorls uninstalled successfully"

fix-colorls: ## Fix colorls gem conflicts (removes old installation and reinstalls)
	@make text-info MESSAGE="Fixing colorls installation conflicts..."
	@if [ -f /usr/local/bin/colorls ]; then \
		make text-warning MESSAGE="Removing conflicting colorls from /usr/local/bin..."; \
		sudo rm -f /usr/local/bin/colorls; \
	fi
	@make text-info MESSAGE="Reinstalling colorls via rbenv..."
	@gem uninstall -x colorls 2>/dev/null || true
	@gem install colorls 2>&1 | grep -v "ERROR:" | grep -v "You don't have write permissions" || true
	@rbenv rehash
	@make text-success MESSAGE="colorls fixed! Try running 'colorls --version' to verify"

# ============================================================================
# Plugin Repositories
# ============================================================================
clone-repos: ## Clone zsh plugin repositories
	@make text-info MESSAGE="Cloning plugin repositories..."
	@mkdir -p $(ZSH_DIR)
	@cd $(ZSH_DIR) && \
		git clone $(REPO_AUTOSUGGESTIONS) && \
		git clone $(REPO_SYNTAX_HIGHLIGHTING) && \
		git clone $(REPO_POWERLEVEL10K) && \
		git clone $(REPO_COLORLS)
	@make text-success MESSAGE="Repositories cloned successfully"

remove-cloned-repos: ## Remove all cloned plugin repositories
	@make text-info MESSAGE="Removing cloned repositories..."
	@rm -rf $(ZSH_DIR)/zsh-autosuggestions
	@rm -rf $(ZSH_DIR)/zsh-syntax-highlighting
	@rm -rf $(ZSH_DIR)/powerlevel10k
	@rm -rf $(ZSH_DIR)/colorls
	@make text-success MESSAGE="Cloned repositories removed successfully"

# ============================================================================
# Configuration Setup
# ============================================================================
setup-starship: ## Copy starship.toml to ~/.config/
	@make text-info MESSAGE="Setting up Starship configuration..."
	@cp starship.toml $(STARSHIP_CONFIG)
	@make text-success MESSAGE="Starship config setup successfully"

remove-starship-config: ## Remove Starship configuration
	@make text-info MESSAGE="Removing Starship config..."
	@rm -f $(STARSHIP_CONFIG)
	@make text-success MESSAGE="Starship config removed successfully"

setup-powerlevel10k-theme: ## Copy .p10k.zsh to home directory
	@make text-info MESSAGE="Setting up Powerlevel10k theme..."
	@cp -rf .p10k.zsh $(P10K_CONFIG)
	@make text-success MESSAGE="Powerlevel10k theme setup successfully"

remove-powerlevel10k: ## Remove Powerlevel10k configuration
	@make text-info MESSAGE="Removing Powerlevel10k..."
	@rm -rf $(P10K_CONFIG)
	@make text-success MESSAGE="Powerlevel10k removed successfully"

setup-zsh-1: ## Add rbenv PATH to .zshrc
	@make text-info MESSAGE="Ensuring rbenv PATH is in .zshrc..."
	@if grep -q 'export PATH="$$HOME/.rbenv/shims:$$PATH"' $(ZSHRC); then \
		make text-warning MESSAGE="rbenv PATH already exists in .zshrc"; \
	else \
		echo 'export PATH="$$HOME/.rbenv/shims:$$PATH"' >> $(ZSHRC); \
		make text-success MESSAGE="Added rbenv PATH to .zshrc"; \
	fi

setup-zsh-2: ## Create .zsh-config and source it in .zshrc
	@make text-info MESSAGE="Setting up .zsh-config..."
	@cp -r .zsh-config $(ZSH_CONFIG)
	@make text-info MESSAGE="Updating .zshrc to source .zsh-config..."
	@if grep -q '.zsh-config' $(ZSHRC); then \
		make text-warning MESSAGE=".zsh-config already sourced in .zshrc"; \
	else \
		echo '' >> $(ZSHRC); \
		echo 'source $(ZSH_CONFIG)' >> $(ZSHRC); \
		make text-success MESSAGE=".zsh-config sourced in .zshrc"; \
	fi

remove-zsh-config: ## Remove .zsh-config and clean .zshrc
	@make text-info MESSAGE="Removing .zsh-config..."
	@rm -f $(ZSH_CONFIG)
	@make text-info MESSAGE="Updating .zshrc to not source .zsh-config..."
	@sed -i '' '/source ~\/.zsh-config/d' $(ZSHRC)
	@make text-success MESSAGE="zsh config removed successfully"

configure-design: ## Run interactive Powerlevel10k configuration
	@cd && p10k configure

# ============================================================================
# Utility Functions (Internal)
# ============================================================================
text-info: ## Print info message (args: MESSAGE)
	@echo "\033[1;34m[INFO]\033[0m $(MESSAGE)"

text-success: ## Print success message (args: MESSAGE)
	@echo "\033[1;32m[SUCCESS]\033[0m $(MESSAGE)"

text-warning: ## Print warning message (args: MESSAGE)
	@echo "\033[1;33m[WARNING]\033[0m $(MESSAGE)"

text-error: ## Print error message (args: MESSAGE)
	@echo "\033[1;31m[ERROR]\033[0m $(MESSAGE)"