#!/usr/bin/env bash
# debug-run.sh: Run a shell script with debugging enabled

set -euo pipefail

SCRIPT="${1:-}"
if [[ -z "$SCRIPT" || ! -f "$SCRIPT" ]]; then
  echo "Usage: $0 <script-to-run> [args...]"
  exit 1
fi

echo "Running: $SCRIPT $*"
echo "Shell: $SHELL"
echo "Working directory: $(pwd)"
echo "Arguments: ${*:2}"

# Enable shell debugging
set -x

# Run the script with all arguments
bash "$@"
