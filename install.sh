#!/usr/bin/env bash
#
# zsh-configs installer — replaces the old Makefile.
# Interactive, shows a spinner + [n/N] progress, and is curl-able:
#   curl -fsSL https://raw.githubusercontent.com/rajanvalencia/zsh-configs/main/install.sh | bash
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
FONT_NAME_CODE="font-hack-nerd-font"
REPO_URL="https://github.com/rajanvalencia/zsh-configs.git"
INSTALL_DIR="${HOME}/.zsh-configs"

ZSH_DIR="${HOME}/.zsh"
CONFIG_DIR="${HOME}/.config"
ZSHRC="${HOME}/.zshrc"
ZSH_CONFIG="${HOME}/.zsh-config"
P10K_CONFIG="${HOME}/.p10k.zsh"
THEMES_TERMINAL="${HOME}/themes_terminal"

BLOCK_START="# >>> zsh-configs >>>"
BLOCK_END="# <<< zsh-configs <<<"

REPO_AUTOSUGGESTIONS="https://github.com/zsh-users/zsh-autosuggestions.git"
REPO_SYNTAX_HIGHLIGHTING="https://github.com/zsh-users/zsh-syntax-highlighting.git"
REPO_POWERLEVEL10K="https://github.com/romkatv/powerlevel10k.git"
REPO_DRACULA_TERMINAL="https://github.com/dracula/terminal-app.git"

# Selections (overridable by flags / prompts)
DO_APPS=1               # Supacode, VSCodium
DO_LANGS=1              # bun, nvm, go, gvm, php, php-version, composer, laravel, herd
DO_CLI=1                # aws-cli, openssh
ASSUME_YES=0

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
  C_INFO=$'\033[1;34m'; C_OK=$'\033[1;32m'; C_WARN=$'\033[1;33m'
  C_ERR=$'\033[1;31m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
  # Dracula accents for the interactive menus
  C_ACC=$'\033[38;5;141m'; C_NUM=$'\033[38;5;117m'; C_PROMPT=$'\033[38;5;212m'
  C_BOLD=$'\033[1m'; C_GREEN=$'\033[38;5;84m'
else
  C_INFO=""; C_OK=""; C_WARN=""; C_ERR=""; C_DIM=""; C_RST=""
  C_ACC=""; C_NUM=""; C_PROMPT=""; C_BOLD=""; C_GREEN=""
fi
info()    { printf '%s[INFO]%s %s\n'    "$C_INFO" "$C_RST" "$*"; }
success() { printf '%s[SUCCESS]%s %s\n' "$C_OK"   "$C_RST" "$*"; }
warn()    { printf '%s[WARNING]%s %s\n' "$C_WARN" "$C_RST" "$*"; }
error()   { printf '%s[ERROR]%s %s\n'   "$C_ERR"  "$C_RST" "$*" >&2; }

STEP=0
TOTAL=0

# run_step "label" func — runs func with a spinner + [n/N]; aborts on failure.
run_step() {
  local label="$1"; shift
  STEP=$((STEP + 1))
  local log; log="$(mktemp)"

  if [ -t 1 ]; then
    ( "$@" ) >"$log" 2>&1 &
    local pid=$! frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏' i=0
    while kill -0 "$pid" 2>/dev/null; do
      i=$(((i + 1) % ${#frames}))
      printf '\r%s[%d/%d]%s %s %s ' "$C_INFO" "$STEP" "$TOTAL" "$C_RST" "${frames:$i:1}" "$label"
      sleep 0.1
    done
    if wait "$pid"; then
      printf '\r%s[%d/%d] ✓%s %s\033[K\n' "$C_OK" "$STEP" "$TOTAL" "$C_RST" "$label"
      rm -f "$log"
    else
      printf '\r%s[%d/%d] ✗%s %s\033[K\n' "$C_ERR" "$STEP" "$TOTAL" "$C_RST" "$label"
      printf '%s' "$C_DIM"; cat "$log"; printf '%s\n' "$C_RST"
      rm -f "$log"
      error "Step failed: ${label}"
      exit 1
    fi
  else
    printf '[%d/%d] %s ... ' "$STEP" "$TOTAL" "$label"
    if ( "$@" ) >"$log" 2>&1; then
      printf 'done\n'; rm -f "$log"
    else
      printf 'FAILED\n'; cat "$log"; rm -f "$log"; exit 1
    fi
  fi
}

# ---------------------------------------------------------------------------
# Brew helpers (idempotent guards)
# ---------------------------------------------------------------------------
have_formula() { brew list --formula "$1" >/dev/null 2>&1; }
have_cask()    { brew list --cask "$1" >/dev/null 2>&1; }
brew_formula() { have_formula "$1" || brew install "$1"; }

# GUI-app casks are best-effort. If the app already exists on disk we skip it
# (adopting it would trigger a sudo password prompt); otherwise we do a clean
# cask install (no --adopt → no sudo). $2 is the optional /Applications path.
brew_cask() {
  have_cask "$1" && return 0
  if [ -n "${2:-}" ] && [ -d "$2" ]; then
    warn "'$1' already installed at $2 (not brew-managed); skipping to avoid a sudo prompt. To register it: brew install --cask --adopt $1"
    return 0
  fi
  if ! brew install --cask "$1"; then
    warn "Cask '$1' was not installed automatically. Install it manually if needed: brew install --cask $1"
  fi
  return 0
}

# ---------------------------------------------------------------------------
# Step functions
# ---------------------------------------------------------------------------
brew_update()      { brew update; }
install_zsh()      { brew_formula zsh; }
install_bat()      { brew_formula bat; }
install_starship() { brew_formula starship; }
install_eza()      { brew_formula eza; }
install_jq()       { brew_formula jq; }
install_ghostty()  { brew_cask ghostty /Applications/Ghostty.app; }
install_font()     { brew_cask "$FONT_NAME_CODE"; }

install_awscli()   { brew_formula awscli; }
install_openssh()  { brew_formula openssh; }

install_bun()      { have_formula bun || brew install oven-sh/bun/bun; }
install_go()       { brew_formula go; }
install_php()      { brew_formula php; }
install_composer() { brew_formula composer; }
install_php_version() {
  [ -d "${HOME}/.php-version" ] || git clone --depth 1 https://github.com/wilmoore/php-version.git "${HOME}/.php-version"
}

install_nvm() {
  brew_formula nvm
  mkdir -p "${HOME}/.nvm"
}

install_gvm() {
  if [ -d "${HOME}/.gvm" ]; then return 0; fi
  bash < <(curl -fsSL https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
}

install_laravel() {
  composer global require laravel/installer
}

install_herd()    { brew_cask herd /Applications/Herd.app; }
install_supacode(){ brew_cask supacode /Applications/Supacode.app; }
install_vscodium(){ brew_cask vscodium /Applications/VSCodium.app; }

# Ensure the `codium` CLI is callable (the cask normally symlinks it into the
# Homebrew prefix; fall back to a manual symlink if it is missing).
ensure_codium_cli() {
  if command -v codium >/dev/null 2>&1; then return 0; fi
  local src="/Applications/VSCodium.app/Contents/Resources/app/bin/codium"
  local dest; dest="$(brew --prefix)/bin/codium"
  [ -x "$src" ] && ln -sf "$src" "$dest"
}

setup_vscodium() {
  local extensions=(
    dracula-theme.theme-dracula      # Dracula Theme Official
    pkief.material-icon-theme        # Material Icon Theme
    golang.go                        # Go
    a-h.templ                        # templ-vscode
    hashicorp.terraform              # HashiCorp Terraform
    bmewburn.vscode-intelephense-client  # PHP Intelephense
    laravel.vscode-laravel           # Laravel
  )
  if command -v codium >/dev/null 2>&1; then
    local ext
    for ext in "${extensions[@]}"; do
      codium --install-extension "$ext" --force >/dev/null 2>&1 || true
    done
  fi

  local dir="${HOME}/Library/Application Support/VSCodium/User"
  local target="${dir}/settings.json"
  mkdir -p "$dir"

  if [ -f "$target" ]; then
    cp "$target" "${target}.bak"
    if command -v jq >/dev/null 2>&1; then
      jq -s '.[0] * .[1]' "$target" "${SCRIPT_DIR}/vscodium/settings.json" > "${target}.tmp" \
        && mv "${target}.tmp" "$target"
    elif command -v python3 >/dev/null 2>&1; then
      python3 - "$target" "${SCRIPT_DIR}/vscodium/settings.json" <<'PY'
import json, sys
cur = json.load(open(sys.argv[1]))
new = json.load(open(sys.argv[2]))
cur.update(new)
json.dump(cur, open(sys.argv[1], "w"), indent=2)
PY
    else
      cp "${SCRIPT_DIR}/vscodium/settings.json" "$target"
    fi
  else
    cp "${SCRIPT_DIR}/vscodium/settings.json" "$target"
  fi
}

clone_repos() {
  mkdir -p "$ZSH_DIR"
  rm -rf "${ZSH_DIR}/zsh-autosuggestions" "${ZSH_DIR}/zsh-syntax-highlighting" "${ZSH_DIR}/powerlevel10k"
  git clone --depth 1 "$REPO_AUTOSUGGESTIONS"     "${ZSH_DIR}/zsh-autosuggestions"
  git clone --depth 1 "$REPO_SYNTAX_HIGHLIGHTING" "${ZSH_DIR}/zsh-syntax-highlighting"
  git clone --depth 1 "$REPO_POWERLEVEL10K"       "${ZSH_DIR}/powerlevel10k"
}

setup_starship() { mkdir -p "$CONFIG_DIR"; cp "${SCRIPT_DIR}/starship.toml" "${CONFIG_DIR}/starship.toml"; }
setup_ghostty()  { mkdir -p "${CONFIG_DIR}/ghostty"; cp "${SCRIPT_DIR}/ghostty/config" "${CONFIG_DIR}/ghostty/config"; }
setup_eza()      { mkdir -p "${CONFIG_DIR}/eza"; cp "${SCRIPT_DIR}/eza/theme.yml" "${CONFIG_DIR}/eza/theme.yml"; }
setup_p10k()     { cp "${SCRIPT_DIR}/.p10k.zsh" "$P10K_CONFIG"; }

setup_zsh_config() {
  cp "${SCRIPT_DIR}/.zsh-config" "$ZSH_CONFIG"
  manage_zshrc
}

# Idempotently maintain a single managed block in ~/.zshrc; strip duplicates
# and the legacy rbenv PATH line from older installs.
manage_zshrc() {
  touch "$ZSHRC"
  cp "$ZSHRC" "${ZSHRC}.bak"
  awk -v s="$BLOCK_START" -v e="$BLOCK_END" '
    $0 == s { inblock = 1; next }
    $0 == e { inblock = 0; next }
    inblock { next }
    /source.*\.zsh-config/ { next }
    /\.rbenv\/shims/ { next }
    { print }
  ' "${ZSHRC}.bak" | awk 'NF { last = NR } { line[NR] = $0 } END { for (i = 1; i <= last; i++) print line[i] }' > "${ZSHRC}.tmp"
  {
    cat "${ZSHRC}.tmp"
    printf '\n%s\n' "$BLOCK_START"
    printf 'source "$HOME/.zsh-config"\n'
    printf '%s\n' "$BLOCK_END"
  } > "$ZSHRC"
  rm -f "${ZSHRC}.tmp"
}

install_dracula_terminal() {
  mkdir -p "$THEMES_TERMINAL"
  [ -d "${THEMES_TERMINAL}/dracula" ] || git clone --depth 1 "$REPO_DRACULA_TERMINAL" "${THEMES_TERMINAL}/dracula"
}

# Foreground steps (may need a GUI dialog or a password prompt — no spinner).
fg_command_line_tools() {
  if ! xcode-select -p >/dev/null 2>&1; then
    info "Installing command line tools (follow the GUI prompt)..."
    xcode-select --install || true
    return
  fi

  # CLT exists — make sure it isn't stale for the running macOS. Apple aligned
  # CLT major versions with the macOS major at 26, so an older CLT major means
  # Homebrew will later abort with "Your Command Line Tools are too outdated."
  local os_major clt_ver clt_major
  os_major="$(sw_vers -productVersion 2>/dev/null | cut -d. -f1)"
  clt_ver="$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables 2>/dev/null | awk '/^version:/ {print $2}')"
  clt_major="${clt_ver%%.*}"

  if [ -n "$os_major" ] && [ -n "$clt_major" ] && [ "$clt_major" -lt "$os_major" ] 2>/dev/null; then
    warn "Command line tools (v${clt_ver}) are too old for macOS ${os_major}."
    warn "Homebrew will refuse to run until they are updated. Please update them yourself:"
    info "  1. sudo rm -rf /Library/Developer/CommandLineTools"
    info "  2. xcode-select --install   (complete the GUI prompt)"
    info "     — or update via  System Settings ▸ General ▸ Software Update"
    info "       (or: softwareupdate --all --install --force)"
    info "Then re-run ./install.sh once the update finishes."
    error "Aborting: command line tools must be updated first."
    exit 1
  else
    info "Command line tools already installed (v${clt_ver:-unknown})"
  fi
}
fg_set_zsh_default() {
  if [ "${SHELL:-}" = "/bin/zsh" ] || [ "${SHELL:-}" = "$(command -v zsh)" ]; then
    info "zsh is already the default shell"
  else
    info "Setting zsh as default shell (you may be prompted for your password)..."
    chsh -s "$(command -v zsh)" || warn "Could not change shell automatically; run: chsh -s $(command -v zsh)"
  fi
}

# ---------------------------------------------------------------------------
# Prompts (read from /dev/tty so they work under `curl ... | bash`)
# ---------------------------------------------------------------------------
# menu <title> <default-num> <opt1> [opt2 ...]  →  echoes chosen number.
# Renders a bordered, colored menu to /dev/tty; only the answer goes to stdout.
menu() {
  local title="$1" def="$2"; shift 2
  {
    printf '\n  %s╭───%s %s%s%s\n'   "$C_ACC" "$C_RST" "$C_BOLD" "$title" "$C_RST"
    printf   '  %s│%s\n'             "$C_ACC" "$C_RST"
    local i=1 o
    for o in "$@"; do
      if [ "$i" = "$def" ]; then
        printf '  %s│%s   %s%d%s  %s %s← default%s\n' "$C_ACC" "$C_RST" "$C_NUM" "$i" "$C_RST" "$o" "$C_DIM" "$C_RST"
      else
        printf '  %s│%s   %s%d%s  %s\n'               "$C_ACC" "$C_RST" "$C_NUM" "$i" "$C_RST" "$o"
      fi
      i=$((i + 1))
    done
    printf '  %s│%s\n'               "$C_ACC" "$C_RST"
    printf '  %s╰─%s%s❯%s '          "$C_ACC" "$C_RST" "$C_PROMPT" "$C_RST"
  } >/dev/tty
  local ans; read -r ans </dev/tty 2>/dev/null || ans=""
  echo "${ans:-$def}"
}

# Interactive checkbox list. Reads CB_LABELS[] and CB_STATE[] (1/0) globals;
# ↑/↓ (or j/k) move, space toggles, enter confirms. Result written to CB_STATE[].
checkbox_menu() {
  local title="$1" n=${#CB_LABELS[@]} cur=0 first=1 key rest i box ptr
  {
    printf '\n  %s╭───%s %s%s%s\n' "$C_ACC" "$C_RST" "$C_BOLD" "$title" "$C_RST"
    printf '  %s│%s  %s↑/↓ move · space toggle · enter confirm%s\n' "$C_ACC" "$C_RST" "$C_DIM" "$C_RST"
    printf '\033[?25l'
  } >/dev/tty
  while true; do
    # Redraw: after the first pass, jump up N lines and erase to end of display
    # (\033[J) to wipe the whole region before reprinting — immune to leftovers.
    if [ "$first" -eq 1 ]; then first=0; else printf '\033[%dA\r\033[J' "$n" >/dev/tty; fi
    for ((i = 0; i < n; i++)); do
      if [ "${CB_STATE[$i]:-0}" -eq 1 ]; then box="${C_GREEN}[x]${C_RST}"; else box="[ ]"; fi
      if [ "$i" -eq "$cur" ]; then ptr="${C_PROMPT}❯${C_RST}"; else ptr=" "; fi
      printf '  %s│%s  %s %s  %s\n' "$C_ACC" "$C_RST" "$ptr" "$box" "${CB_LABELS[$i]}" >/dev/tty
    done
    # Read one byte. If it's ESC, pull the 2 trailing bytes of the arrow escape
    # sequence (ESC [ A / ESC O A). No fractional -t timeout here: macOS ships
    # bash 3.2, which rejects it — arrow keys always deliver all 3 bytes anyway.
    IFS= read -rsn1 key </dev/tty || break
    if [ "$key" = $'\033' ]; then
      IFS= read -rsn2 rest </dev/tty 2>/dev/null || rest=""
      key+="$rest"
    fi
    case "$key" in
      $'\033[A'|$'\033OA'|k|K) cur=$(((cur - 1 + n) % n)) ;;
      $'\033[B'|$'\033OB'|j|J) cur=$(((cur + 1) % n)) ;;
      ' ')                     CB_STATE[$cur]=$((1 - ${CB_STATE[$cur]:-0})) ;;
      '')                      break ;;
    esac
  done
  { printf '\033[?25h'; printf '  %s╰─%s\n' "$C_ACC" "$C_RST"; } >/dev/tty
}

prompt_options() {
  [ "$ASSUME_YES" -eq 1 ] && return 0

  if [ "$(menu 'Install mode?' 1 'Everything (recommended)' 'Custom — pick components')" = "2" ]; then
    CB_LABELS=(
      "Apps  (Supacode, VSCodium)"
      "Dev toolchain  (Bun, Node, Go, PHP, Composer, Laravel, Herd)"
      "CLI tools  (aws-cli, openssh)"
    )
    CB_STATE=(1 1 1)
    checkbox_menu 'Select components — space to toggle'
    DO_APPS="${CB_STATE[0]}"
    DO_LANGS="${CB_STATE[1]}"
    DO_CLI="${CB_STATE[2]}"
  fi
}

# ---------------------------------------------------------------------------
# Orchestration
# ---------------------------------------------------------------------------
STEPS=()
add_step() { STEPS+=("$1"$'\t'"$2"); }

build_plan() {
  add_step "Update Homebrew"                brew_update
  add_step "Install zsh"                    install_zsh
  add_step "Install bat"                    install_bat
  add_step "Install Starship"               install_starship
  add_step "Install eza"                    install_eza
  add_step "Install jq"                     install_jq
  add_step "Clone zsh plugins"              clone_repos
  add_step "Install Hack Nerd Font"         install_font

  add_step "Install Ghostty"                install_ghostty
  add_step "Install Dracula (Terminal.app)" install_dracula_terminal

  if [ "$DO_CLI" -eq 1 ]; then
    add_step "Install aws-cli"              install_awscli
    add_step "Install OpenSSH"              install_openssh
  fi

  if [ "$DO_LANGS" -eq 1 ]; then
    add_step "Install Bun"                  install_bun
    add_step "Install nvm"                  install_nvm
    add_step "Install Go"                   install_go
    add_step "Install gvm"                  install_gvm
    add_step "Install PHP"                  install_php
    add_step "Install php-version"          install_php_version
    add_step "Install Composer"             install_composer
    add_step "Install Laravel installer"    install_laravel
    add_step "Install Laravel Herd"         install_herd
  fi

  if [ "$DO_APPS" -eq 1 ]; then
    add_step "Install Supacode"             install_supacode
    add_step "Install VSCodium"             install_vscodium
    add_step "Configure VSCodium"           setup_vscodium
  fi

  add_step "Set up Starship config"         setup_starship
  add_step "Set up eza theme"               setup_eza
  add_step "Set up Ghostty config"          setup_ghostty
  add_step "Set up Powerlevel10k theme"     setup_p10k
  add_step "Set up .zsh-config & .zshrc"    setup_zsh_config
}

print_next_steps() {
  echo ""
  success "Installation complete!"
  echo ""
  printf '%s[NEXT STEPS]%s\n' "$C_WARN" "$C_RST"
  echo "  1. Restart your terminal (or run: exec zsh)"
  echo "  2. Ghostty is already themed via ~/.config/ghostty/config — just open it"
  echo "  3. Terminal.app → Settings → Profiles → import ~/themes_terminal/dracula/Dracula.terminal,"
  echo "     set it default, and choose 'Hack Nerd Font' under Text"
  [ "$DO_APPS" -eq 1 ] && echo "  4. VSCodium is themed with Dracula + Hack Nerd Font automatically"
  echo ""
}

usage() {
  cat <<EOF
zsh-configs installer

Usage: ./install.sh [options]

Options:
  --no-apps                     Skip Supacode + VSCodium
  --no-langs                    Skip the dev toolchain
  --no-cli                      Skip aws-cli + openssh
  -y, --yes                     Non-interactive; accept all defaults
  -h, --help                    Show this help

Run with no options for the interactive experience.
EOF
}

main() {
  for arg in "$@"; do
    case "$arg" in
      --no-apps)    DO_APPS=0 ;;
      --no-langs)   DO_LANGS=0 ;;
      --no-cli)     DO_CLI=0 ;;
      -y|--yes)     ASSUME_YES=1 ;;
      -h|--help)    usage; exit 0 ;;
      *) error "Unknown option: $arg"; usage; exit 1 ;;
    esac
  done

  if ! command -v brew >/dev/null 2>&1; then
    error "Homebrew is required. Install it from https://brew.sh and re-run."
    exit 1
  fi

  # Locate repo data files; clone if running via curl with no local checkout.
  local self="${BASH_SOURCE[0]:-}"
  if [ -n "$self" ] && [ -f "$self" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$self")" && pwd)"
  else
    SCRIPT_DIR=""
  fi
  if [ -z "$SCRIPT_DIR" ] || [ ! -f "${SCRIPT_DIR}/.zsh-config" ]; then
    info "Fetching zsh-configs into ${INSTALL_DIR}..."
    rm -rf "$INSTALL_DIR"
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
    SCRIPT_DIR="$INSTALL_DIR"
  fi

  prompt_options

  fg_command_line_tools
  fg_set_zsh_default

  build_plan
  TOTAL=${#STEPS[@]}
  echo ""
  info "Running ${TOTAL} steps..."
  local entry label func
  for entry in "${STEPS[@]}"; do
    label="${entry%%$'\t'*}"
    func="${entry#*$'\t'}"
    run_step "$label" "$func"
  done

  print_next_steps
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
