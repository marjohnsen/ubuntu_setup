#!/bin/bash
set -e
set -o pipefail

dependencies=("packages")

install_and_setup_zsh(){
    sudo apt install zsh -y 
    chsh -s /usr/bin/zsh
}

install_and_setup_ohmyzsh(){
    if [ -d $HOME/.oh-my-zsh/ ]; then
        rm -rf $HOME/.oh-my-zsh/
    fi

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    safe_symlink "$ROOT_DIR/configs/zshrc" "$HOME/.zshrc"
}

install_and_setup_p10k(){
    local p10k_dir=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
	

    if [ -d "$p10k_dir" ]; then
        rm -rf "$p10k_dir"
    fi

    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    echo "Starting p10k configuration in a new terminal..."
    x-terminal-emulator -e zsh -c "source ~/.zshrc && p10k configure; exec zsh" & disown
    read -p "Press [Enter] after completing the p10k configuration to resume setup..."
}

main(){
    install_and_setup_zsh 
    install_and_setup_ohmyzsh
    install_and_setup_p10k
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    source "$ROOT_DIR/utils/safe_symlink.sh"
    main "$@"
fi
