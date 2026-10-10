#!/usr/bin/env bash
# Update VS Code Portable in-place, preserving data/ and User configs
# Usage: ./update_vscode_portable.sh [linux|windows|both]
#
# Requires: curl, tar, unzip, rsync.
#
# Program files are replaced with `rsync --delete --exclude=/data/`, so the
# portable data/ (settings, extensions, user-data) is never touched. The older
# wipe-then-restore approach could silently drop extensions when the temporary
# backup was incomplete.
#
# chrome-sandbox must be root:root 4755 or Electron refuses the sandbox; run the
# Linux update with sudo to reseed it, or fix it by hand afterwards.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
PORTABLE_DEV="$(dirname "$SCRIPT_DIR")"

info() { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
error() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*" >&2; }

reseed_sandbox() {
  local dir="$1"
  [[ -f "${dir}/chrome-sandbox" ]] || return 0
  if [[ "$(id -u)" -eq 0 ]]; then
    chown root:root "${dir}/chrome-sandbox"
    chmod 4755 "${dir}/chrome-sandbox"
  else
    info "to enable the sandbox: sudo chown root:root '${dir}/chrome-sandbox' && sudo chmod 4755 '${dir}/chrome-sandbox'"
  fi
}

update_linux() {
  local vscode_dir="$PORTABLE_DEV/VSCodePortable-Linux"
  local tmpdir extracted
  tmpdir="$(mktemp -d)"

  info "Downloading VS Code Portable for Linux..."
  curl -fsSL "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" -o "$tmpdir/vscode.tar.gz"

  info "Extracting..."
  tar -xzf "$tmpdir/vscode.tar.gz" -C "$tmpdir"
  extracted="$(find "$tmpdir" -mindepth 1 -maxdepth 1 -type d | head -1)"
  if [[ ! -d "$extracted" ]]; then
    error "Could not find extracted VS Code directory"
    rm -rf "$tmpdir"
    return 1
  fi

  info "Syncing program files (data/ preserved)..."
  rsync -aHAX --delete --exclude='/data/' "$extracted/" "$vscode_dir/"

  rm -rf "$tmpdir"
  reseed_sandbox "$vscode_dir"
  info "VS Code Portable (Linux) updated to: $("$vscode_dir/bin/code" --version 2>/dev/null | head -1)"
}

update_windows() {
  local vscode_dir="$PORTABLE_DEV/VSCodePortable-Windows"
  local tmpdir code_exe
  tmpdir="$(mktemp -d)"

  info "Downloading VS Code Portable for Windows..."
  curl -fsSL "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive" -o "$tmpdir/vscode.zip"

  # The win32-x64 archive ships its own top-level layout (Code.exe + a
  # build-hash payload dir + bin/ tools/ policies/ appx/), so extract it to a
  # staging dir and sync across; ntfs-3g fakes modes, so omit -p/-o/-g.
  info "Extracting..."
  unzip -oq "$tmpdir/vscode.zip" -d "$tmpdir/extract"

  info "Syncing program files (data/ preserved)..."
  rsync -rltD --delete --exclude='/data/' "$tmpdir/extract/" "$vscode_dir/"

  rm -rf "$tmpdir"
  code_exe="$(find "$vscode_dir" -name "Code.exe" -type f | head -1)"
  if [[ -n "$code_exe" ]]; then
    info "VS Code Portable (Windows) updated."
  else
    error "Code.exe not found after update — Windows install is incomplete"
    return 1
  fi
}

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
