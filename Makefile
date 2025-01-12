FONT_NAME_CODE=font-hack-nerd-font
RUBY_VERSION=3.3.6

help: ## Display available commands
	@echo "------- Commands ------"
	@grep -E '^[a-zA-Z0-9_-]+:.*## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "\033[36mmake %-25s\033[0m %s\n", $$1, $$2}'

install-font: ## install font [ args : FONT_NAME_CODE ]
	@make text-info MESSAGE="Installing fonts..."
	@brew install --cask $(FONT_NAME_CODE)
	@make text-success MESSAGE="Fonts installed successfully"

install-all: ## install all [ args : OS ]
	@make install-command-line-tools
	@make brew-update
	@make install-zsh
	@make set-zsh-as-default
	@make setup-zsh-1
	@make install-ruby
	@make install-bat
	@make install-starship
	@make install-colorls
	@make remove-cloned-repos
	@make clone-repos
	@make setup-starship
	@make setup-powerlevel10k-theme
	@make setup-zsh-2
	@make text-success MESSAGE="Task completed!! Please restart your terminal"
	@source ~/.zshrc

remove-all: ## remove all custom configurations and installations
	@make remove-zsh-config
	@make uninstall-starship
	@make uninstall-colorls
	@make remove-cloned-repos
	@make remove-powerlevel10k
	@make remove-zsh
	@make text-success MESSAGE="Task completed!! Please restart your terminal"
	@source ~/.zshrc

install-command-line-tools: ## install command line tools
	@make text-info MESSAGE="Installing command line tools..."
	@if ! xcode-select -p > /dev/null 2>&1; then \
		xcode-select --install; \
	else \
		make text-warning MESSAGE="Command line tools are already installed."; \
	fi

brew-update: ## brew update
	@make text-info MESSAGE="Updating brew..."
	@brew update

install-zsh: ## install zsh
	@make text-info MESSAGE="Installing zsh..."
	@brew update
	@brew install zsh
	@make text-success MESSAGE="ZSH installed successfully"

set-zsh-as-default: ## set zsh as default shell
	@make text-info MESSAGE="Setting zsh as default shell..."
	@chsh -s /bin/zsh
	@make text-success MESSAGE="ZSH set as default shell successfully"

install-ruby: ## install ruby [ args : RUBY_VERSION ]
	@make text-info MESSAGE="Installing ruby..."
	@brew install ruby
	@make text-info MESSAGE="Installing rbenv..."
	@brew install rbenv ruby-build
	@make text-info MESSAGE="RBENV version"
	@rbenv -v
	@rbenv install $(RUBY_VERSION) --force
	@rbenv global $(RUBY_VERSION)
	@source ~/.zshrc
	@make text-info MESSAGE="RUBY version"
	@ruby -v
	@make text-success MESSAGE="Ruby installed successfully"

install-bat: ## install bat
	@make text-info MESSAGE="Installing bat..."
	@brew install bat
	@make text-success MESSAGE="Bat installed successfully"

install-starship: ## install starship
	@make text-info MESSAGE="Installing starship..."
	@brew install starship
	@make text-success MESSAGE="Starship installed successfully"

clone-repos: ## clone repos
	@mkdir -p ~/.zsh && \
	cd ~/.zsh && \
	git clone https://github.com/zsh-users/zsh-autosuggestions && \
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git && \
	git clone https://github.com/romkatv/powerlevel10k.git && \
	git clone https://github.com/dracula/colorls.git

setup-starship: ## copy starship.toml to ~/.config/starship.toml
	@cp starship.toml ~/.config/starship.toml
	@make text-success MESSAGE="Starship config setup successfully"

setup-powerlevel10k-theme: ## copy .p10k.zsh to ~/
	@cp -rf .p10k.zsh ~/.p10k.zsh
	@make text-success MESSAGE="Powerlevel10k theme setup successfully"

install-colorls: ## setup colorls
	@make text-info MESSAGE="Installing colorls..."
	@sudo gem install colorls -n /usr/local/bin

setup-zsh-1: ## create .zsh-config and update .zshrc to source it
	@make text-info MESSAGE="Ensuring rbenv PATH is in .zshrc..."
	@if grep -q 'export PATH="$$HOME/.rbenv/shims:$$PATH"' ~/.zshrc; then \
		make text-warning MESSAGE="rbenv PATH already exists in .zshrc"; \
	else \
		echo 'export PATH="$$HOME/.rbenv/shims:$$PATH"' >> ~/.zshrc; \
		make text-success MESSAGE="Added rbenv PATH to .zshrc"; \
	fi

setup-zsh-2: ## create .zsh-config and update .zshrc to source it
	@cp -r .zsh-config ~/.zsh-config
	@make text-info MESSAGE="Updating .zshrc to source .zsh-config..."
	@if grep -q '.zsh-config' ~/.zshrc; then \
	echo '.zsh-config already sourced in .zshrc'; \
	else \
	echo '' >> ~/.zshrc; \
	echo 'source ~/.zsh-config' >> ~/.zshrc; \
	fi

remove-starship-config: ## remove starship config
	@make text-info MESSAGE="Removing starship config..."
	@rm -f ~/.config/starship.toml
	@make text-success MESSAGE="Starship config removed successfully"

remove-zsh-config: ## remove .zsh-config and update .zshrc to not source it
	@make text-info MESSAGE="Removing .zsh-config..."
	@rm -f ~/.zsh-config
	@make text-info MESSAGE="Updating .zshrc to not source .zsh-config..."
	@sed -i '' '/source ~\/.zsh-config/d' ~/.zshrc
	@make text-success MESSAGE="ZSH config removed successfully"

unset-zsh-as-default: ## reset default shell, assume bash as default
	@make text-info MESSAGE="Resetting default shell to bash..."
	@chsh -s /bin/bash
	@make text-success MESSAGE="Default shell reset successfully"

uninstall-font: ## uninstall font, using FONT_NAME_CODE
	@make text-info MESSAGE="Uninstalling font..."
	@brew uninstall --cask $(FONT_NAME_CODE)
	@make text-success MESSAGE="Font uninstalled successfully"

uninstall-bat: ## uninstall bat
	@make text-info MESSAGE="Uninstalling bat..."
	@brew uninstall bat
	@make text-success MESSAGE="Bat uninstalled successfully"

uninstall-starship: ## uninstall starship
	@make text-info MESSAGE="Uninstalling starship..."
	@brew uninstall starship
	@make text-success MESSAGE="Starship uninstalled successfully"

uninstall-colorls: ## uninstall colorls
	yes | sudo gem uninstall colorls
	@make text-info MESSAGE="Removing colorls from PATH..."
	@sed -i '' '/colorls/d' ~/.zshrc
	@make text-success MESSAGE="Colorls uninstalled successfully"

remove-cloned-repos: ## remove cloned repos
	@make text-info MESSAGE="Removing cloned repositories..."
	@rm -rf ~/.zsh/zsh-autosuggestions
	@rm -rf ~/.zsh/zsh-syntax-highlighting
	@rm -rf ~/.zsh/powerlevel10k
	@rm -rf ~/.zsh/colorls
	@make text-success MESSAGE="Cloned repositories removed successfully"

remove-powerlevel10k: ## remove powerlevel10k
	@make text-info MESSAGE="Removing powerlevel10k..."
	@rm -rf ~/.p10k.zsh
	@make text-success MESSAGE="Powerlevel10k removed successfully"

remove-zsh: ## uninstall zsh
	@make text-info MESSAGE="Uninstalling zsh..."
	@brew uninstall zsh
	@make text-success MESSAGE="Zsh uninstalled successfully"

configure-design: ## configure terminal design
	@cd && p10k configure

text-info: ## [ args : MESSAGE ]
	@echo "\033[1;34m[INFO]\033[0m $(MESSAGE)"

text-success: ## [ args : MESSAGE ]
	@echo "\033[1;32m[SUCCESS]\033[0m $(MESSAGE)"

text-warning: ## [ args : MESSAGE ]
	@echo "\033[1;33m[WARNING]\033[0m $(MESSAGE)"

text-error: ## [ args : MESSAGE ]
	@echo "\033[1;31m[ERROR]\033[0m $(MESSAGE)"