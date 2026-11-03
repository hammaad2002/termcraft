#!/usr/bin/env bash
# termcraft installer: installs dependencies and Powerline fonts, symlinks the
# dotfiles into $HOME (backing up anything already there) and applies the
# GNOME Terminal profile.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.termcraft-backup/$(date +%Y%m%d-%H%M%S)"
BACKED_UP=0

echo "[*] Installing dependencies (sudo needed)..."
sudo apt-get update
sudo apt-get install -y tmux vim xclip lm-sensors curl git fontconfig

echo "[*] Installing Powerline fonts..."
bash "$REPO_DIR/fonts/install-powerline.sh"

# link SRC DEST: symlink DEST -> SRC, moving any existing DEST into the backup dir
link() {
    local src="$1" dest="$2"
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "    $dest already linked"
        return
    fi
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
        BACKED_UP=1
        echo "    backed up existing $dest"
    fi
    ln -sfn "$src" "$dest"
    echo "    $dest -> $src"
}

echo "[*] Symlinking dotfiles..."
link "$REPO_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
link "$REPO_DIR/vim/.vimrc" "$HOME/.vimrc"

# Older versions of this script symlinked the GNOME script into $HOME; nothing
# reads it from there, so clean that link up.
OLD_GNOME_LINK="$HOME/.gnome-terminal-config"
if [ -L "$OLD_GNOME_LINK" ] && [[ "$(readlink "$OLD_GNOME_LINK")" == "$REPO_DIR"/* ]]; then
    rm "$OLD_GNOME_LINK"
    echo "    removed stale $OLD_GNOME_LINK symlink"
fi

echo "[*] Applying GNOME Terminal profile..."
if command -v gsettings >/dev/null 2>&1 \
    && gsettings list-schemas | grep -qx 'org.gnome.Terminal.ProfilesList'; then
    bash "$REPO_DIR/gnome/apply-profile.sh"
else
    echo "    GNOME Terminal not found, skipping"
fi

if tmux has-session 2>/dev/null; then
    echo "[*] Reloading running tmux server..."
    tmux source-file "$HOME/.tmux.conf"
fi

echo "[*] Done!"
if [ "$BACKED_UP" -eq 1 ]; then
    echo "[*] Your previous dotfiles were moved to $BACKUP_DIR"
fi
