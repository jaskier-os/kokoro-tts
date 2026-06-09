#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

export USE_GPU=false
export USE_ONNX=false
export PYTHONPATH=$(pwd):$(pwd)/api
export MODEL_DIR=src/models
export VOICES_DIR=src/voices/v1_0
export WEB_PLAYER_PATH=$(pwd)/web
export ESPEAK_DATA_PATH=/usr/lib/x86_64-linux-gnu/espeak-ng-data
unset VIRTUAL_ENV

if ! command -v uv &> /dev/null; then
  echo "[kokoro-tts] Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

echo "[kokoro-tts] Syncing dependencies..."
uv sync --extra cpu

echo "[kokoro-tts] Downloading models..."
uv run --no-sync python docker/scripts/download_model.py --output api/src/models/v1_0

echo "[kokoro-tts] Starting on port 10007..."
exec uv run --no-sync uvicorn api.src.main:app --host 0.0.0.0 --port 10007
