<div align="center">

# zsh-configs for macOS

A one-command setup for a beautiful, fast macOS terminal — Powerlevel10k, Starship,
Ghostty, the Dracula theme and a full developer toolchain.

[Quick Start](#quick-start) · [Features](#features) · [What gets installed](#what-gets-installed) · [Customization](#customization)

</div>

> [View a screenshot of the prompt](https://github.com/user-attachments/assets/50d8535c-4a22-43c9-9775-07ff7b40fabf)

---

## Quick Start

**Prerequisite:** [Homebrew](https://brew.sh/).

Fresh Mac — one line (clones the repo and runs the installer):

```bash
curl -fsSL https://raw.githubusercontent.com/rajanvalencia/zsh-configs/main/install.sh | bash
```

Already cloned:

```bash
./install.sh
```

The installer is interactive: it asks which terminal to configure (Ghostty or Terminal.app)
and whether you want everything or a custom subset, then shows a live spinner with `[n/N]`
progress for each step.

> **Safe to re-run.** `install.sh` is idempotent — running it again updates plugins and
> configs, skips anything already installed, and never duplicates lines in `~/.zshrc`. Use it
> to update an existing setup or to add components you skipped earlier.

<details>
<summary>Non-interactive / scripted use</summary>

```bash
./install.sh --yes                 # accept all defaults
./install.sh --terminal=terminal   # configure Terminal.app instead of Ghostty
./install.sh --no-langs --no-cli   # skip the dev toolchain and CLI tools
./install.sh --help                # all options
```
</details>

---

## Features

**Shell & terminal**
- 🎨 Powerlevel10k + Starship prompt
- ✨ Syntax highlighting & autosuggestions
- 📁 [eza](https://github.com/eza-community/eza) (modern `ls` with icons + tree) · 🐱 [bat](https://github.com/sharkdp/bat) (`cat` with syntax highlighting)
- 👻 [Ghostty](https://ghostty.org) terminal · 🔤 Hack Nerd Font · 🧛 Dracula theme

**Apps**
- 🧑‍💻 [Supacode](https://supacode.sh) · 🆚 [VSCodium](https://vscodium.com) (auto-themed with Dracula + Hack Nerd Font)

**Dev toolchain**
- 🥟 Bun · ⬢ Node (nvm) · 🐹 Go (gvm) · 🐘 PHP (php-version) · 🎼 Composer · 🅻 Laravel + Laravel Herd

**CLI**
- ☁️ aws-cli · 🔐 openssh

---

## What gets installed

| Tool | Purpose |
| --- | --- |
| Powerlevel10k / Starship | Prompt theming |
| zsh-autosuggestions / zsh-syntax-highlighting | Shell quality-of-life |
| eza / bat | Modern `ls` / `cat` |
| Ghostty | Terminal (themed via `~/.config/ghostty/config`) |
| Hack Nerd Font | Glyphs & icons |
| Supacode / VSCodium | Apps |
| Bun / nvm / Go / gvm | JS & Go runtimes + version managers |
| PHP / php-version / Composer / Laravel / Herd | PHP & Laravel toolchain |
| aws-cli / openssh | CLI utilities |

---

## Customization

**Ghostty** — edit `ghostty/config` (theme, `font-family`, `font-size`) and re-run `./install.sh`.

**Prompt colors** — open `~/.p10k.zsh` and tweak values (0–15):

```bash
typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=3
typeset -g POWERLEVEL9K_DIR_BACKGROUND=12
```

Apply changes immediately:

```bash
cp .p10k.zsh ~/.p10k.zsh && exec zsh
```

---

## License

[MIT](LICENSE)
