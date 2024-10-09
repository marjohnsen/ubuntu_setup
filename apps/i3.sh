#!/bin/bash
set -e
set -o pipefail

dependencies=("packages")

install_i3() {
  sudo apt install -y picom compton imagemagick scrot i3-wm polybar pavucontrol feh
}

install_rofi_themes() {
  git clone --depth=1 https://github.com/adi1090x/rofi.git
  cd rofi
  chmod +x setup.sh
  ./setup.sh
  cd ..
  rm -rf rofi
  sed -i "s/theme='style-1'/theme='style-5'/" "$HOME/.config/rofi/scripts/launcher_t1"
  sed -i "s/theme='style-1'/theme='style-2'/" "$HOME/.config/rofi/scripts/powermenu_t1"
  sed -i 's|/colors/.*\.rasi|/colors/gruvbox.rasi|' "$HOME/.config/rofi/launchers/type-1/shared/colors.rasi"
  sed -i 's|/colors/.*\.rasi|/colors/gruvbox.rasi|' "$HOME/.config/rofi/powermenu/type-1/shared/colors.rasi"
}

symlink_configs() {
  mkdir -p "$HOME/.config/i3"
  mkdir -p "$HOME/.config/polybar"
  mkdir -p "$HOME/.config/picom"

  safe_symlink "$ROOT_DIR/utils/i3_lock_screen.sh" "$HOME/.config/i3/i3_lock_screen.sh"
  safe_symlink "$ROOT_DIR/configs/i3/polybar" "$HOME/.config/polybar/config.ini"
  safe_symlink "$ROOT_DIR/configs/i3/config" "$HOME/.config/i3/config"
  safe_symlink "$ROOT_DIR/configs/i3/dmrc" "$HOME/.dmrc"
  safe_symlink "$ROOT_DIR/configs/i3/picom" "$HOME/.config/picom/picom.conf"
  safe_symlink "$ROOT_DIR/configs/i3/wallpaper.jpg" "$HOME/.config/i3/wallpaper.jpg"
}

main() {
  install_i3
  install_rofi_themes
  symlink_configs
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  source "$ROOT_DIR/utils/safe_symlink.sh"
  main "$@"
fi
