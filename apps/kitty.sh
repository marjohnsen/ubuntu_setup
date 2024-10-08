#!/bin/bash
set -e
set -o pipefail

dependencies=("packages")

install_kitty() {
  sudo apt install kitty -y
}

configure_kitty() {
  mkdir -p "$HOME/.config/kitty/"
  safe_symlink "$ROOT_DIR/configs/kitty" "$HOME/.config/kitty/kitty.conf"
}

configure_theme() {
  mkdir -p "$HOME/.config/kitty"
  curl https://raw.githubusercontent.com/dexpota/kitty-themes/master/themes/gruvbox_dark.conf >"$HOME/.config/kitty/theme.conf"
}

main() {
  install_kitty
  configure_kitty
  configure_theme
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  source "$ROOT_DIR/utils/safe_symlink.sh"
  main "$@"
fi
