#!/bin/bash
set -e

# Install Oh My Bash if not present
if [ ! -d "$HOME/.oh-my-bash" ]; then
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
fi
