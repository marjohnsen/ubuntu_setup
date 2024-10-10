install_rustup() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

install_dependencies() {
  sudo apt install -y \
    rustc \
    cargo \
    libgtk-3-dev \
    libgtk-layer-shell-dev \
    libpango1.0-dev \
    libgdk-pixbuf2.0-dev \
    libdbusmenu-gtk3-dev \
    libcairo2-dev \
    libglib2.0-dev \
    gcc \
    libc6-dev
}

build() {
  git clone https://github.com/elkowar/eww /usr/local/src/eww
  cargo build --release --no-default-features --features x11 --manifest-path /usr/local/src/eww/cargo.toml
  chmod +x ./usr/local/src/eww/target/release/eww
  sudo ln -s /usr/local/src/eww/target/release/eww /usr/local/bin/eww
  mkdir -p "$HOME/.config/eww"
}

configure() {

}
