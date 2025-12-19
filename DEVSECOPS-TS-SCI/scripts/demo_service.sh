#!/usr/bin/env bash
set -euo pipefail

mode="${1:-local}"

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [[ "$mode" == "local" ]]; then
  # shellcheck disable=SC1091
  source .venv/bin/activate
  exec uvicorn demo_service.main:app --reload --port 8080 --app-dir DEMOS/demo-02-containerized-python-service/src
fi

if [[ "$mode" == "docker" ]]; then
  image="devsecops-ts-sci/demo-service:local"
  docker build -t "$image" DEMOS/demo-02-containerized-python-service
  echo "Starting container on http://localhost:8080"
  exec docker run --rm -p 8080:8080 "$image"
fi

echo "Unknown mode: $mode (use: local | docker)" >&2
exit 2
