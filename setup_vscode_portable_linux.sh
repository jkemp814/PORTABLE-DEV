#!/usr/bin/env bash
# VS Code Portable Setup Script for Linux

set -e

ROOT_DIR="$(dirname \"$0\")"
VSCODE_DIR="$ROOT_DIR/VSCodePortable-Linux"
VSCODE_DATA="$VSCODE_DIR/data"
PROJECTS_DIR="$ROOT_DIR/Projects"
VSCODE_TAR="vscode-linux-x64.tar.gz"
DOWNLOAD_URL="https://update.code.visualstudio.com/latest/linux-x64/stable"
mkdir -p "$VSCODE_DIR"

echo "Downloading VS Code Portable..."
curl -L "$DOWNLOAD_URL" -o "$VSCODE_TAR"

echo "Extracting VS Code..."
tar -xzf "$VSCODE_TAR" -C "$VSCODE_DIR" --strip-components=1

mkdir -p "$PROJECTS_DIR"
mkdir -p "$VSCODE_DATA"

rm "$VSCODE_TAR"

echo "VS Code Portable setup complete!"
echo "To launch, run: $VSCODE_DIR/code"
