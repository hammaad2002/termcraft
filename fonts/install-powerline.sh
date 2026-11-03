#!/usr/bin/env bash
# Installs the Powerline-patched fonts into ~/.local/share/fonts.
set -euo pipefail

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

git clone --depth=1 https://github.com/powerline/fonts.git "$TMP_DIR/fonts"
"$TMP_DIR/fonts/install.sh"
fc-cache -f
