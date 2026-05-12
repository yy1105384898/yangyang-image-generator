#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
VENV_DIR="${VENV_DIR:-$ROOT_DIR/.venv}"
PYTHON_BIN="${PYTHON_BIN:-python3}"

cd "$ROOT_DIR"

if [ ! -f ".env" ]; then
  cp .env.example .env
  echo "Created .env from .env.example. Edit it before production use."
fi

"$PYTHON_BIN" -m venv "$VENV_DIR"
# shellcheck disable=SC1091
. "$VENV_DIR/bin/activate"
python -m pip install --upgrade pip
pip install -r requirements.txt
mkdir -p "$ROOT_DIR/data"

echo "Install complete."
echo "Start manually: ./scripts/server-run.sh"
echo "For systemd: copy deploy/systemd/yangyang-image-generator.service.example and adjust paths."
