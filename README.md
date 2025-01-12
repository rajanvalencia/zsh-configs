# zsh-configs for MacOS

My terminal configurations for MacOS

![スクリーンショット 2024-12-20 午前3 21 57](https://github.com/user-attachments/assets/5baaf1cf-6ce7-4928-979f-5a41f844eb93)

## Installation

1. Install [Homebrew](https://brew.sh/)

2. Install Dracula theme [Dracula](https://draculatheme.com/terminal)

3. Set theme

  ![スクリーンショット 2024-12-20 午前3 11 11](https://github.com/user-attachments/assets/f147598e-4472-40de-b719-00a62a13078a)

4. Install font

```bash
make install-font
```

5. Set font

  ![スクリーンショット 2024-12-23 午前7 00 53](https://github.com/user-attachments/assets/702ae15b-ab74-48e0-9b57-204608735713)

6. Check Ruby version and upgrade
```
ruby -v
```

If below 3.0
```
make install-ruby
```

7. Install all

```bash
make install-all
```

8. Change VSCode Terminal Font to Hack Nerd Font

![スクリーンショット 2025-01-12 午後6 25 44](https://github.com/user-attachments/assets/50d8535c-4a22-43c9-9775-07ff7b40fabf)

### Restart your terminal and enjoy🎉

---

## Help

```bash
make help
```

## Change colors
Open `~/.p10k.zsh` and find the following lines. Change the colors by changing the values from 0 to 15
```bash
# OS identifier color.
typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=3
typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=8

# Current directory background color.
typeset -g POWERLEVEL9K_DIR_BACKGROUND=12
# Default current directory foreground color.
typeset -g POWERLEVEL9K_DIR_FOREGROUND=0
```

Run below to apply changes immediately
```bash
make setup-powerlevel10k-theme && source ~/.zshrc 
```
