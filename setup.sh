#!/bin/bash

## setup ubuntu/debian in wsl

git init -b wsl &&
    git remote add origin https://github.com/cethien/dotfiles.git &&
    git pull origin wsl

# install nala
sudo apt update &&
    sudo apt install -y nala

# update distro
sudo nala update &&
    sudo nala upgrade -y

# nix + home manager
curl -fsSL https://nixos.org/nix/install | bash /dev/stdin --no-daemon &&
    mkdir -p $HOME/.config/nix &&
    echo "experimental-features = nix-command flakes" >> $HOME/.config/nix/nix.conf &&
    mv "$HOME"/.bashrc "$HOME"/.bashrc_default &&
    mv "$HOME"/.profile "$HOME"/.profile_default &&
    . "$HOME"/.nix-profile/etc/profile.d/nix.sh &&
    nix build .config/home-manager#homeConfigurations.cethien.activationPackage &&
    result/activate &&
    home-manager switch &&
    rm -rf result

# add windows ssh-passthru
curl -fsSL https://gist.githubusercontent.com/Jaykul/19e9f18b8a68f6ab854e338f9b38ca7b/raw/ssh-agent-pipe.sh | sudo tee /usr/local/bin/ssh-agent-pipe >/dev/null &&
sudo chmod +x /usr/local/bin/ssh-agent-pipe

# remove sudo pw prompt
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/"$USER" >/dev/null

sudo reboot
