#!/bin/bash
set -e

# Install ble.sh if not present
if [ ! -d "$HOME/ble.sh" ]; then
  git clone --recursive https://github.com/akinomyoga/ble.sh.git "$HOME/ble.sh"
  bash "$HOME/ble.sh/install.sh" --no-modify-bashrc
fi

# Add ble.sh initialization at the top of .bashrc if not present
if ! grep -Fxq '[[ $- == *i* ]] && source -- "$HOME/.local/share/blesh/ble.sh" --attach=none' "$HOME/.bashrc"; then
  sed -i '1i # Source ble.sh (Bash Line Editor) as recommended by the developer:\n[[ $- == *i* ]] && source -- "$HOME/.local/share/blesh/ble.sh" --attach=none\n' "$HOME/.bashrc"
fi

# Add ble.sh attachment at the bottom of .bashrc if not present
if ! tail -n 10 "$HOME/.bashrc" | grep -Fxq '[[ ${BLE_VERSION-} ]] && ble-attach'; then
  echo -e '\n# Add this line at the end of .bashrc:\n[[ ${BLE_VERSION-} ]] && ble-attach' >> "$HOME/.bashrc"
fi
