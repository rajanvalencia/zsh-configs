# zsh-configs for MacOS

My terminal configurations for MacOS

## Installation

1. Install [Homebrew](https://brew.sh/)

2. Install Dracula theme [Dracula](https://draculatheme.com/terminal)

3. Install font

```bash
make install-font
```

<img width="1625" alt="terminal-settings" src="https://github.com/rajanvalencia/zsh-configs/assets/47655366/2bd373a2-38f7-43b6-9ec1-2986e441cd9f">

4. Install

```bash
make install-all
```

## Help

```bash
make help
```

## Remove

```bash
make remove-all
```

## Change colors
Open `~/.p10k.zsh` and find the following lines. Change the colors by changing the values.
```bash
# OS identifier color.
typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=15
typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=8

# Current directory background color.
typeset -g POWERLEVEL9K_DIR_BACKGROUND=6
# Default current directory foreground color.
typeset -g POWERLEVEL9K_DIR_FOREGROUND=0

```