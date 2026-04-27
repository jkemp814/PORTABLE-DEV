#!/bin/bash
# Deactivate Python virtual environment if active
if [[ -n "$VIRTUAL_ENV" ]]; then
  deactivate
  echo "Deactivated Python virtual environment."
else
  echo "No Python virtual environment is active."
fi