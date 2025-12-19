#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# shellcheck disable=SC1091
source .venv/bin/activate

pushd DEMOS/demo-02-containerized-python-service >/dev/null

python -m ruff check .
python -m pytest -q

# Basic “security hygiene” checks (local-friendly)
python -m pip_audit -r requirements.txt --progress-spinner off || true
python -m bandit -q -r src || true

popd >/dev/null

echo "CI-local gates complete."
