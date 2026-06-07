#!/usr/bin/env bash
#
# Fetch the Kokoro v1.0 pretrained model and voice packs.
#
# These are STANDARD, publicly available pretrained assets (not custom/in-house),
# so they are intentionally NOT committed to this repository. Run this script once
# after cloning to populate:
#   - api/src/models/v1_0/kokoro-v1_0.pth  (+ config.json)
#   - api/src/voices/v1_0/*.pt
#
# Sources:
#   - Model:  GitHub release (remsky/Kokoro-FastAPI) via docker/scripts/download_model.py
#   - Voices: Hugging Face hexgrad/Kokoro-82M via scripts/download_voices.py
#
# Override the model output dir with MODEL_OUTPUT_DIR and voices dir with
# VOICES_OUTPUT_DIR if you keep weights outside the default tree.

set -euo pipefail

cd "$(dirname "$0")"

MODEL_OUTPUT_DIR="${MODEL_OUTPUT_DIR:-api/src/models/v1_0}"
VOICES_OUTPUT_DIR="${VOICES_OUTPUT_DIR:-api/src/voices/v1_0}"

# Prefer running through uv if available (matches the rest of the project),
# otherwise fall back to plain python3.
if command -v uv >/dev/null 2>&1; then
    PY="uv run --no-sync python"
else
    PY="python3"
fi

echo "[fetch_models] Downloading model into ${MODEL_OUTPUT_DIR}"
${PY} docker/scripts/download_model.py --output "${MODEL_OUTPUT_DIR}"

echo "[fetch_models] Downloading voices into ${VOICES_OUTPUT_DIR}"
${PY} scripts/download_voices.py --output "${VOICES_OUTPUT_DIR}"

echo "[fetch_models] Done."
