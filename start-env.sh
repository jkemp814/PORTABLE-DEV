#!/usr/bin/env bash
# PORTABLE-DEV Linux Launcher
# Auto-detects drive mount path and configures PortablePodman

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
PORTABLE_PODMAN="$SCRIPT_DIR/PortablePodman"
VSCODE_DIR="$SCRIPT_DIR/VSCodePortable-Linux"
WORKSPACE="$SCRIPT_DIR/PORTABLE-DEV.code-workspace"

info() { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
error() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*" >&2; }

# --- Detect mount point ---
DRIVE_MOUNT="$SCRIPT_DIR"
if [[ "$DRIVE_MOUNT" == /run/media/* ]]; then
	info "Detected automount path: $DRIVE_MOUNT"
elif [[ "$DRIVE_MOUNT" == /mnt/* ]]; then
	info "Detected manual mount path: $DRIVE_MOUNT"
else
	info "Running from: $DRIVE_MOUNT"
fi

# --- Configure PortablePodman storage ---
if [[ -x "$PORTABLE_PODMAN/bin/podman" ]]; then
	info "PortablePodman detected -- configuring..."

	export PODMAN_USERNS="keep-id"
	export CONTAINERS_STORAGE_CONF="$PORTABLE_PODMAN/config/storage.conf"
	export CONTAINERS_REGISTRIES_CONF="$PORTABLE_PODMAN/config/registries.conf"
	export CONTAINERS_CONTAINERS_CONF="$PORTABLE_PODMAN/config/containers.conf"

	mkdir -p "$PORTABLE_PODMAN/storage/runroot" "$PORTABLE_PODMAN/storage/graph"

	if grep -q "__PORTABLE_DEV__" "$CONTAINERS_STORAGE_CONF" 2>/dev/null; then
		sed -i "s|__PORTABLE_DEV__|$SCRIPT_DIR|g" "$CONTAINERS_STORAGE_CONF"
		info "Storage config paths rewritten for current mount."
	fi

	export PATH="$PORTABLE_PODMAN/bin:$PATH"
	info "PortablePodman ready. Container layers stored on drive."
else
	info "No PortablePodman binary found -- using host Podman if available."
	if ! command -v podman &>/dev/null && ! command -v docker &>/dev/null; then
		error "Neither PortablePodman, host podman, nor docker found."
		error "Place a static podman binary in $PORTABLE_PODMAN/bin/ or install Podman on the host."
		exit 1
	fi
fi

# --- Launch VS Code ---
if [[ -x "$VSCODE_DIR/bin/code" ]]; then
	info "Launching VS Code Portable..."
	exec "$VSCODE_DIR/bin/code" "$WORKSPACE"
else
	error "VS Code Portable not found at $VSCODE_DIR"
	error "Run Toolchest/setup_vscode_portable_linux.sh to download it."
	exit 1
fi
