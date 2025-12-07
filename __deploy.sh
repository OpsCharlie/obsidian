#!/bin/bash

set -e

BIN_DIR=~/.local/bin
DESKTOP_DIR=~/.local/share/applications
ICONS_DIR=~/.local/share/icons
DIR=$(dirname "$(readlink -f "$0")")

# Create directories
mkdir -p "$BIN_DIR" "$DESKTOP_DIR" "$ICONS_DIR"

# Fetch latest release information
REPO_URL="https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest"
RELEASE_INFO=$(curl -s "$REPO_URL")

# Extract latest version, name and URL from GitHub API response using jq
LATEST_VERSION=$(echo "$RELEASE_INFO" | jq -r '.tag_name | sub("^v"; "")')
APPIMAGE_INFO=$(echo "$RELEASE_INFO" | jq -r '.assets[] | select(.name | contains("AppImage") and (contains("arm64") | not)) | {name: .name, url: .browser_download_url}')
APPIMAGE_NAME=$(echo "$APPIMAGE_INFO" | jq -r '.name')
APPIMAGE_URL=$(echo "$APPIMAGE_INFO" | jq -r '.url')

# Download Obsidian AppImage
curl -# -L -o "$BIN_DIR/$APPIMAGE_NAME" "$APPIMAGE_URL"
chmod 750 "$BIN_DIR/$APPIMAGE_NAME"

# Create symlink
ln -sf "$BIN_DIR/$APPIMAGE_NAME" "$BIN_DIR/obsidian"

# Copy icon file
cp "$DIR/obsidian.svg" "$ICONS_DIR/obsidian.svg"
chmod 640 "$ICONS_DIR/obsidian.svg"

# Create desktop file with templated content
cat > "$DESKTOP_DIR/obsidian.desktop" << EOF
[Desktop Entry]
Name=Obsidian
GenericName=Sharpen your thinking
StartupWMClass=obsidian
Exec=$BIN_DIR/obsidian --no-sandbox
Icon=$ICONS_DIR/obsidian.svg
Terminal=false
Type=Application
Categories=Utility;Office
MimeType=application/x-md;x-scheme-handler/obsidian;
X-Desktop-File-Install-Version=0.22
EOF
chmod 640 "$DESKTOP_DIR/obsidian.desktop"

# Update desktop database
update-desktop-database "$DESKTOP_DIR"

