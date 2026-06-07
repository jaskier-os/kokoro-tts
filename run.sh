#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

# Local CPU run helper. All values can be overridden via the environment
# (see .env.example). Defaults below match the project's expectations.
export USE_GPU=${USE_GPU:-false}
export USE_ONNX=${USE_ONNX:-false}
export PYTHONPATH=$(pwd):$(pwd)/api
export MODEL_DIR=${MODEL_DIR:-src/models}
export VOICES_DIR=${VOICES_DIR:-src/voices/v1_0}
export WEB_PLAYER_PATH=${WEB_PLAYER_PATH:-$(pwd)/web}
export ESPEAK_DATA_PATH=${ESPEAK_DATA_PATH:-/usr/lib/x86_64-linux-gnu/espeak-ng-data}
HOST=${HOST:-0.0.0.0}
PORT=${PORT:-8880}
unset VIRTUAL_ENV

if ! command -v uv &> /dev/null; then
  echo "[kokoro-tts] Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

echo "[kokoro-tts] Syncing dependencies..."
uv sync --extra cpu

echo "[kokoro-tts] Fetching model and voices (skips if already present)..."
./fetch_models.sh

echo "[kokoro-tts] Starting on ${HOST}:${PORT}..."
exec uv run --no-sync uvicorn api.src.main:app --host "${HOST}" --port "${PORT}"
