#!/usr/bin/env bash
set -euo pipefail
set -x

# Detect bash major.minor version from the first line, e.g. 5.2
BASH_VERSION_SHORT="$(bash --version | awk 'NR==1 {split($4, v, "."); print v[1] "." v[2]}')"

# Map bash version to bashdb branch (adjust as needed)
case "$BASH_VERSION_SHORT" in
  5.4*) BASHDB_BRANCH="bash-5.3" ;;
  5.3*) BASHDB_BRANCH="bash-5.3" ;;
  5.2*) BASHDB_BRANCH="bash-5.2" ;;
  5.1*) BASHDB_BRANCH="bash-5.1" ;;
  5.0*) BASHDB_BRANCH="bash-5.0" ;;
  *) BASHDB_BRANCH="master" ;;
esac

echo "Detected Bash version: $BASH_VERSION_SHORT"
echo "Using bashdb branch: $BASHDB_BRANCH"

# Install dependencies (should already be present in container)
# dnf install -y git make autoconf gcc gcc-c++ wget tar which

# Download and build bashdb in an isolated temp directory
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

git clone --branch "$BASHDB_BRANCH" --depth 1 https://github.com/rocky/bashdb.git "$TMP_DIR/bashdb"
cd "$TMP_DIR/bashdb"
if [[ -x ./autogen.sh ]]; then
  ./autogen.sh
fi
./configure --prefix=/usr
make
make install

echo "bashdb installation complete."
