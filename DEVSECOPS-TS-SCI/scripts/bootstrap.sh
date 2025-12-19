#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [[ ! -d .venv ]]; then
  python3 -m venv .venv
fi

# shellcheck disable=SC1091
source .venv/bin/activate

python -m pip install --upgrade pip

# Base tooling used across demos
python -m pip install -r DEMOS/demo-02-containerized-python-service/requirements.txt

echo "Bootstrap complete."
