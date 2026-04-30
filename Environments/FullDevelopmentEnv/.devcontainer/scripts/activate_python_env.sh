#!/bin/bash
# Activate Python virtual environment in the current directory
if [ -f .venv/bin/activate ]; then
  # shellcheck disable=SC1091
  source .venv/bin/activate
  echo "Activated .venv"
else
  echo "No .venv found in current directory."
fi