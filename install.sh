#!/bin/bash

echo "[*] Installing Powerline fonts..."
cd fonts
bash install-powerline.sh
cd ..

echo "[*] Symlinking dotfiles..."
ln -sf $(pwd)/tmux/.tmux.conf ~/.tmux.conf
ln -sf $(pwd)/vim/.vimrc ~/.vimrc
ln -sf $(pwd)/gnome/.gnome-terminal-config ~/.gnome-terminal-config


echo "Installing dependencies ..."
sudo apt install lm-sensors

echo "[*] Done!"

echo "[*] Applying the changes ..."
tmux source ~/.tmux.conf
bash ~/.gnome-terminal-config
