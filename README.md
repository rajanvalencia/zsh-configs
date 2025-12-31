# zsh-configs for MacOS

My terminal configurations for MacOS (Terminal.app and iTerm2)

## Installation

1. Install [Homebrew](https://brew.sh/)

2. Install Dracula theme

   **For Terminal.app:**
   ```bash
   make install-dracula-terminal
   ```
   Then: Terminal → Settings → Profiles → Import `~/themes_terminal/dracula/Dracula.terminal`

   **For iTerm2:**
   ```bash
   make install-dracula-iterm
   ```
   Then: iTerm2 → Settings → Profiles → Colors → Color Presets → Import `~/themes_iterm/dracula/Dracula.itermcolors`

3. Install font

   ```bash
   make install-font
   ```

4. Set font

   - **Terminal.app:** Terminal → Settings → Profiles → Text → Font → Hack Nerd Font
   - **iTerm2:** iTerm2 → Settings → Profiles → Text → Font → Hack Nerd Font

5. Check Ruby version and upgrade
```
ruby -v
```

If below 3.0 (this will install Ruby 3.3.6)
```
make install-ruby
exec zsh
```

6. Install all

```bash
make install-all
```

7. Activate configuration (choose one):
   - Restart your terminal (recommended), OR
   - Run `exec zsh`

8. Change VSCode Terminal Font to Hack Nerd Font

![スクリーンショット 2025-01-12 午後6 25 44](https://github.com/user-attachments/assets/50d8535c-4a22-43c9-9775-07ff7b40fabf)

Enjoy🎉

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
make setup-powerlevel10k-theme && exec zsh
```

## Troubleshooting

### colorls not found or gem error
If you see an error like `can't find gem colorls`, you have a conflict between an old system-wide colorls installation and the rbenv version.

**Quick fix:**
```bash
make fix-colorls
```

**Manual fix:**
```bash
sudo rm /usr/local/bin/colorls
make install-colorls
```

This removes the old installation and reinstalls colorls properly via rbenv.
