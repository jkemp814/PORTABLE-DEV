#!/usr/bin/env bash
set -euo pipefail

# Install Rust toolchain (rustup, cargo, rustc)
if ! command -v cargo >/dev/null 2>&1; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
fi

# Source cargo environment for current shell and future logins
source "$HOME/.cargo/env"
echo 'source $HOME/.cargo/env' >> "$HOME/.bashrc"
