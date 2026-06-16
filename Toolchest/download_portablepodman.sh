#!/usr/bin/env bash
# Download static PortablePodman binaries and configs
# Usage: ./download_portablepodman.sh [version]
#   version: optional tag from mgoltzsche/podman-static (default: latest)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
PORTABLE_DEV="$(dirname "$SCRIPT_DIR")"
PORTABLE_PODMAN="$PORTABLE_DEV/PortablePodman"

REPO="mgoltzsche/podman-static"
ARCHIVE="podman-linux-amd64.tar.gz"
ARCHIVE_URL="https://github.com/$REPO/releases/latest/download/$ARCHIVE"
VERSION="${1:-latest}"

if [[ "$VERSION" != "latest" ]]; then
	ARCHIVE_URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"
fi

info() { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
die() {
	printf "\033[1;31m[ERROR]\033[0m %s\n" "$*" >&2
	exit 1
}

TMPDIR="$(mktemp -d)"
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

info "Downloading static Podman from $REPO ($VERSION)..."
curl -fsSL "$ARCHIVE_URL" -o "$TMPDIR/$ARCHIVE" || die "Download failed"

info "Extracting..."
tar -xzf "$TMPDIR/$ARCHIVE" -C "$TMPDIR"

EXTRACTED="$TMPDIR/podman-linux-amd64"

info "Installing binaries to $PORTABLE_PODMAN/bin/"
mkdir -p "$PORTABLE_PODMAN/bin"
cp "$EXTRACTED/usr/local/bin/"* "$PORTABLE_PODMAN/bin/"
cp "$EXTRACTED/usr/local/lib/podman/"* "$PORTABLE_PODMAN/bin/"

info "Installing configs to $PORTABLE_PODMAN/config/"
mkdir -p "$PORTABLE_PODMAN/config"
cp "$EXTRACTED/etc/containers/"* "$PORTABLE_PODMAN/config/"

# Restore __PORTABLE_DEV__ placeholder in storage.conf if rewritten
if grep -q "$PORTABLE_DEV" "$PORTABLE_PODMAN/config/storage.conf" 2>/dev/null; then
	sed -i "s|$PORTABLE_DEV|__PORTABLE_DEV__|g" "$PORTABLE_PODMAN/config/storage.conf"
fi

info "Done! Installed:"
find "$PORTABLE_PODMAN/bin/" -maxdepth 1 -type f -printf '%f\n' | sort | head -15
echo "... ($(find "$PORTABLE_PODMAN/bin/" -type f | wc -l) files total)"
