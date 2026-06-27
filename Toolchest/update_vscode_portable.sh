#!/usr/bin/env bash
# Update VS Code Portable in-place, preserving data/ and User configs
# Usage: ./update_vscode_portable.sh [linux|windows|both]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
PORTABLE_DEV="$(dirname "$SCRIPT_DIR")"

update_linux() {
  local vscode_dir="$PORTABLE_DEV/VSCodePortable-Linux"
  local tmpdir
  tmpdir="$(mktemp -d)"

  info "Downloading VS Code Portable for Linux..."
  curl -fsSL "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" -o "$tmpdir/vscode.tar.gz"

  info "Extracting..."
  tar -xzf "$tmpdir/vscode.tar.gz" -C "$tmpdir"

  # Find the single top-level dir the archive extracts to
  local extracted
  extracted="$(find "$tmpdir" -mindepth 1 -maxdepth 1 -type d | head -1)"

  if [[ ! -d "$extracted" ]]; then
    error "Could not find extracted VS Code directory"
    rm -rf "$tmpdir"
    return 1
  fi

  # Back up data/ before replacing
  if [[ -d "$vscode_dir/data" ]]; then
    info "Backing up data/..."
    cp -a "$vscode_dir/data" "$tmpdir/data-backup"
  fi

  # Wipe the old install (but not data/ if it wasn't backed up)
  info "Replacing program files..."
  rm -rf "${vscode_dir:?}/"*
  cp -a "$extracted"/* "$vscode_dir/"

  # Restore data/
  if [[ -d "$tmpdir/data-backup" ]]; then
    info "Restoring data/ (settings, extensions)..."
    rm -rf "$vscode_dir/data"
    mv "$tmpdir/data-backup" "$vscode_dir/data"
  fi

  rm -rf "$tmpdir"
  info "VS Code Portable (Linux) updated to: $("$vscode_dir/bin/code" --version 2>/dev/null | head -1)"
}

update_windows() {
  local vscode_dir="$PORTABLE_DEV/VSCodePortable-Windows"
  local tmpdir
  tmpdir="$(mktemp -d)"

  info "Downloading VS Code Portable for Windows..."
  curl -fsSL "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive" -o "$tmpdir/vscode.zip"

  info "Extracting..."
  unzip -q "$tmpdir/vscode.zip" -d "$tmpdir"

  # Find the single top-level dir the zip extracts to (varies by release)
  local extracted
  extracted="$(find "$tmpdir" -mindepth 1 -maxdepth 1 -type d | head -1)"

  if [[ ! -d "$extracted" ]]; then
    error "Could not find extracted VS Code directory"
    rm -rf "$tmpdir"
    return 1
  fi

  if [[ -d "$vscode_dir/data" ]]; then
    info "Backing up data/..."
    cp -a "$vscode_dir/data" "$tmpdir/data-backup"
  fi

  info "Replacing program files..."
  rm -rf "${vscode_dir:?}/"*
  cp -a "$extracted"/* "$vscode_dir/"

  if [[ -d "$tmpdir/data-backup" ]]; then
    info "Restoring data/ (settings, extensions)..."
    rm -rf "$vscode_dir/data"
    mv "$tmpdir/data-backup" "$vscode_dir/data"
  fi

  rm -rf "$tmpdir"
  local code_exe
  code_exe="$(find "$vscode_dir" -name "Code.exe" -type f | head -1)"
  if [[ -n "$code_exe" ]]; then
    info "VS Code Portable (Windows) updated."
  fi
}

info() { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
error() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*" >&2; }

case "${1:-both}" in
linux) update_linux ;;
windows) update_windows ;;
both)
  update_linux
  update_windows
  ;;
*)
  echo "Usage: $0 [linux|windows|both]"
  exit 1
  ;;
esac

info "Update complete. Your settings and extensions are preserved."
