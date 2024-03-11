FONT_NAME_CODE=font-hack-nerd-font

help: ## help
	@echo "------- Commands ------"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36mmake %-25s\033[0m %s\n", $$1, $$2}'

install-all: ## install all [ args : OS ]
	make install-zsh
	make set-zsh-as-default
	make install-font
	make install-starship
	make clone-repos
	make setup-zsh

install-zsh: ## install zsh
	@echo "Installing zsh..."
	brew update
	brew install zsh

set-zsh-as-default: ## set zsh as default shell
	@echo "Setting zsh as default shell..."
	chsh -s /bin/zsh

install-starship: ## install starship
	@echo "Installing starship..."
	brew install starship

install-font: ## install font [ args : FONT_NAME_CODE ]
	@echo "Installing fonts..."
	brew tap homebrew/cask-fonts
	brew install --cask $(FONT_NAME_CODE)

clone-repos: ## clone repos
	@mkdir -p ~/.zsh && \
	cd ~/.zsh && \
	git clone https://github.com/zsh-users/zsh-autosuggestions && \
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git

setup-starship: ## copy starship.toml to ~/.config/starship.toml
	cp starship.toml ~/.config/starship.toml

setup-zsh: ## create .zsh-config and update .zshrc to source it
	cp -r .zsh-config ~/.zsh-config
	@echo "Updating .zshrc to source .zsh-config..."
	@if grep -q '.zsh-config' ~/.zshrc; then \
	echo '.zsh-config already sourced in .zshrc'; \
	else \
	echo 'source ~/.zsh-config' >> ~/.zshrc; \
	fi
	@echo "Setup completed!!! Please restart your terminal or run:"
	@echo "\tsource ~/.zshrc"

remove-all: ## remove all custom configurations and installations
	make remove-zsh-config
	make unset-zsh-as-default
	make uninstall-font
	make uninstall-starship
	make remove-cloned-repos
	make remove-zsh

remove-zsh-config: ## remove .zsh-config and update .zshrc to not source it
	@echo "Removing .zsh-config..."
	rm -f ~/.zsh-config
	@echo "Updating .zshrc to not source .zsh-config..."
	sed -i '' '/source ~\/.zsh-config/d' ~/.zshrc

unset-zsh-as-default: ## reset default shell, assume bash as default
	@echo "Resetting default shell to bash..."
	chsh -s /bin/bash

uninstall-font: ## uninstall font, using FONT_NAME_CODE
	@echo "Uninstalling font..."
	brew uninstall --cask $(FONT_NAME_CODE)

uninstall-starship: ## uninstall starship
	@echo "Uninstalling starship..."
	brew uninstall starship

remove-cloned-repos: ## remove cloned repos
	@echo "Removing cloned repositories..."
	rm -rf ~/.zsh/zsh-autosuggestions
	rm -rf ~/.zsh/zsh-syntax-highlighting

remove-zsh: ## uninstall zsh
	@echo "Uninstalling zsh..."
	brew uninstall zsh
