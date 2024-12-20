FONT_NAME_CODE=font-hack-nerd-font

help: ## help
	@echo "------- Commands ------"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36mmake %-25s\033[0m %s\n", $$1, $$2}'

install-font: ## install font [ args : FONT_NAME_CODE ]
	@echo "Installing fonts..."
	@brew install --cask $(FONT_NAME_CODE)

install-all: ## install all [ args : OS ]
	make install-zsh
	make set-zsh-as-default
	make install-bat
	make install-starship
	make install-colorls
	make remove-cloned-repos
	make clone-repos
	make setup-starship
	make setup-powerlevel10k-theme
	make setup-zsh
	make run-zshrc

configure-design: ## configure terminal design
	@cd && p10k configure

install-command-line-tools: ## install command line tools
	@echo "Installing command line tools..."
	@if ! xcode-select -p > /dev/null 2>&1; then \
		xcode-select --install; \
	else \
		echo "Command line tools are already installed."; \
	fi

install-zsh: ## install zsh
	@echo "Installing zsh..."
	@brew update
	@brew install zsh

set-zsh-as-default: ## set zsh as default shell
	@echo "Setting zsh as default shell..."
	@chsh -s /bin/zsh

install-bat: ## install bat
	@echo "Installing bat..."
	@brew install bat

install-starship: ## install starship
	@echo "Installing starship..."
	@brew install starship

clone-repos: ## clone repos
	@mkdir -p ~/.zsh && \
	cd ~/.zsh && \
	git clone https://github.com/zsh-users/zsh-autosuggestions && \
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git && \
	git clone https://github.com/romkatv/powerlevel10k.git && \
	git clone https://github.com/dracula/colorls.git

setup-starship: ## copy starship.toml to ~/.config/starship.toml
	@cp starship.toml ~/.config/starship.toml

setup-powerlevel10k-theme: ## copy .p10k.zsh to ~/
	@cp -rf .p10k.zsh ~/.p10k.zsh

install-colorls: ## setup colorls
	@echo "Installing colorls..."
	@make install-command-line-tools
	@brew install ruby
	@sudo gem install colorls -n /usr/local/bin
	@if ! grep -q 'colorls' ~/.zshrc; then \
		echo "Updating PATH to include colorls..."; \
		echo 'export PATH=$$PATH:$(ruby -e "puts Gem.bindir")' >> ~/.zshrc; \
	else \
		echo "colorls already in PATH"; \
	fi

setup-zsh: ## create .zsh-config and update .zshrc to source it
	@cp -r .zsh-config ~/.zsh-config
	@echo "Updating .zshrc to source .zsh-config..."
	@if grep -q 'colorls --dark --tree=1' ~/.zshrc; then \
	echo 'colorls alias already set in .zshrc'; \
	else \
	echo '' >> ~/.zshrc; \
	echo 'alias ls="colorls --dark --tree=1"' >> ~/.zshrc; \
	fi
	@if grep -q '.zsh-config' ~/.zshrc; then \
	echo '.zsh-config already sourced in .zshrc'; \
	else \
	echo '' >> ~/.zshrc; \
	echo 'source ~/.zsh-config' >> ~/.zshrc; \
	fi

run-zshrc: ## run .zshrc
	@source ~/.zshrc >/dev/null 2>&1
	@echo ".zshrc run completed!!! Please restart your terminal"

remove-all: ## remove all custom configurations and installations
	make remove-zsh-config
	make uninstall-starship
	make uninstall-colorls
	make remove-cloned-repos
	make remove-powerlevel10k
	make remove-zsh
	make run-zshrc

remove-starship-config: ## remove starship config
	@echo "Removing starship config..."
	@rm -f ~/.config/starship.toml

remove-zsh-config: ## remove .zsh-config and update .zshrc to not source it
	@echo "Removing .zsh-config..."
	@rm -f ~/.zsh-config
	@echo "Updating .zshrc to not source .zsh-config..."
	@sed -i '' '/source ~\/.zsh-config/d' ~/.zshrc

unset-zsh-as-default: ## reset default shell, assume bash as default
	@echo "Resetting default shell to bash..."
	@chsh -s /bin/bash

uninstall-font: ## uninstall font, using FONT_NAME_CODE
	@echo "Uninstalling font..."
	@brew uninstall --cask $(FONT_NAME_CODE)

uninstall-bat: ## uninstall bat
	@echo "Uninstalling bat..."
	@brew uninstall bat

uninstall-starship: ## uninstall starship
	@echo "Uninstalling starship..."
	@brew uninstall starship

uninstall-colorls: ## uninstall colorls
	yes | sudo gem uninstall colorls
	@echo "Removing colorls from PATH..."
	@sed -i '' '/colorls/d' ~/.zshrc

remove-cloned-repos: ## remove cloned repos
	@echo "Removing cloned repositories..."
	@rm -rf ~/.zsh/zsh-autosuggestions
	@rm -rf ~/.zsh/zsh-syntax-highlighting
	@rm -rf ~/.zsh/powerlevel10k
	@rm -rf ~/.zsh/colorls

remove-powerlevel10k: ## remove powerlevel10k
	@echo "Removing powerlevel10k..."
	@rm -rf ~/.p10k.zsh

remove-zsh: ## uninstall zsh
	@echo "Uninstalling zsh..."
	@brew uninstall zsh
