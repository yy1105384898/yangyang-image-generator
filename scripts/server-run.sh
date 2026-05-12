#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/app"
VENV_DIR="${VENV_DIR:-$ROOT_DIR/.venv}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-3012}"
WORKERS="${WORKERS:-2}"
TIMEOUT="${TIMEOUT:-660}"

if [ ! -x "$VENV_DIR/bin/gunicorn" ]; then
  echo "Missing virtualenv or gunicorn: $VENV_DIR" >&2
  echo "Run: python3 -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt" >&2
  exit 1
fi

if [ -f "$ROOT_DIR/.env" ]; then
  eval "$("$VENV_DIR/bin/python" - "$ROOT_DIR/.env" <<'PY'
import pathlib
import shlex
import sys

path = pathlib.Path(sys.argv[1])
for raw_line in path.read_text(encoding="utf-8").splitlines():
    line = raw_line.strip()
    if not line or line.startswith("#") or "=" not in line:
        continue
    key, value = line.split("=", 1)
    key = key.strip()
    if not key or key.lower().startswith("export "):
        continue
    if not key.replace("_", "").isalnum():
        continue
    print(f"export {key}={shlex.quote(value.strip())}")
PY
)"
fi

export DATA_DIR="${DATA_DIR:-$ROOT_DIR/data}"
mkdir -p "$DATA_DIR"

cd "$APP_DIR"
exec "$VENV_DIR/bin/gunicorn" \
  -b "$HOST:$PORT" \
  --workers "$WORKERS" \
  --timeout "$TIMEOUT" \
  server:app
