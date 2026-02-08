#!/usr/bin/env bash
set -euo pipefail

echo "Shell: $SHELL"
echo "Git: $(git --version | awk '{print $3}')"
command -v python >/dev/null && echo "Python: $(python -V 2>&1 | awk '{print $2}')" || echo "Python: not found"
command -v pip >/dev/null && echo "Pip: $(python -m pip --version | awk '{print $2}')" || echo "Pip: not found"
