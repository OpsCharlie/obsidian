#!/bin/bash

set -e

BIN_DIR=~/.local/bin
[[ -d $BIN_DIR ]] || mkdir -p  $BIN_DIR

DIR=$(dirname "$(readlink -f "$0")")

curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep -P 'browser_download_url(?!.*arm64).*AppImage' | cut -d '"' -f 4 | xargs curl -L -o $BIN_DIR/obsidian

chmod +x $BIN_DIR/obsidian

cp "$DIR"/obsidian.desktop ~/.local/share/applications/obsidian.desktop
cp "$DIR"/obsidian.svg ~/.local/share/icons/obsidian.svg

sed -i "s|BIN_DIR|$BIN_DIR|g" ~/.local/share/applications/obsidian.desktop
sed -i "s|HOME|$HOME|" ~/.local/share/applications/obsidian.desktop
update-desktop-database ~/.local/share/applications

