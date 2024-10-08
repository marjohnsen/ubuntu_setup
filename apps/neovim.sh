#!/bin/bash
set -e
set -o pipefail

dependencies=("packages","python")

install_neovim(){
    if [ -d "/opt/nvim" ]; then
        sudo rm -rf /opt/nvim
    fi

    sudo apt install fuse -y
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage

    sudo mkdir -p /opt/nvim
    sudo mv nvim.appimage /opt/nvim/nvim
}

setup_lazyvim(){
    safe_symlink "$ROOT_DIR/configs/nvim" "$HOME/.config/nvim" 
}

setup_nvim_pyenv(){
    latest_stable=$(pyenv install --list | grep -E '^\s*3\.[0-9]+\.[0-9]+$' | tail -1 | xargs)

    if ! pyenv versions --bare | grep "^$latest_stable$"; then
        pyenv install "$latest_stable"
    fi

    if pyenv versions --bare | grep "^neovim$"; then
        pyenv virtualenv-delete -f neovim
    fi
   
    pyenv virtualenv "$latest_stable" neovim

    $(pyenv prefix neovim)/bin/python -m pip install pynvim
    
    echo pip list | grep ".*pynvim.*" 
}

main(){
    install_neovim
    setup_lazyvim
    setup_nvim_pyenv
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    source "$ROOT_DIR/utils/safe_symlink.sh"
    main "$@"
fi

