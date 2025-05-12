#!/usr/bin/env bash
source "$(dirname "$0")/liblog.sh"
log blue  "Installing favourite CLI tools: Neovim, Zsh, htop, neofetch"
apt update && apt install -y neovim zsh htop neofetch
log blue  "Setting Zsh as default shell for $USER"
chsh -s /usr/bin/zsh "$USER"
log green "CLI goodies ready – open a new terminal 🎉"
