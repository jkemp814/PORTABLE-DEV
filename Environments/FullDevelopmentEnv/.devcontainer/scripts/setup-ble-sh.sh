#!/bin/bash
set -e

# Install ble.sh using the official install script
if [ ! -d "$HOME/.local/share/blesh" ]; then
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/akinomyoga/ble.sh/master/install.sh)" -- --no-modify-bashrc
fi

# Add ble.sh initialization at the top of .bashrc if not present
if ! grep -Fxq '[[ $- == *i* ]] && source -- "$HOME/.local/share/blesh/ble.sh" --attach=none' "$HOME/.bashrc"; then
  sed -i '1i # Source ble.sh (Bash Line Editor) as recommended by the developer:\n[[ $- == *i* ]] && source -- "$HOME/.local/share/blesh/ble.sh" --attach=none\n' "$HOME/.bashrc"
fi

# Add ble.sh attachment at the bottom of .bashrc if not present
if ! tail -n 10 "$HOME/.bashrc" | grep -Fxq '[[ ${BLE_VERSION-} ]] && ble-attach'; then
  echo -e '\n# Add this line at the end of .bashrc:\n[[ ${BLE_VERSION-} ]] && ble-attach' >> "$HOME/.bashrc"
fi
