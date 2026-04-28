#!/bin/bash
# setup-ssh.sh: Generate and configure SSH keys for the devcontainer
set -e

KEY_PATH="$HOME/.ssh/id_ed25519"

# Create .ssh directory if it doesn't exist
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Generate SSH key if it doesn't exist
if [ ! -f "$KEY_PATH" ]; then
    echo "Generating new SSH key..."
    ssh-keygen -t ed25519 -f "$KEY_PATH" -N ""
else
    echo "SSH key already exists at $KEY_PATH"
fi

# Start ssh-agent and add key
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)"
fi
ssh-add "$KEY_PATH"

# Print public key
echo "\nYour public key is:"
cat "$KEY_PATH.pub"
echo "\nAdd this public key to your GitHub/GitLab/other service account."
