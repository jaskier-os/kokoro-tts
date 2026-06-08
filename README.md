# kokoro-tts

Self-contained copy of [Kokoro-FastAPI](https://github.com/remsky/Kokoro-FastAPI):
an OpenAI-compatible TTS service wrapping the [Kokoro-82M](https://huggingface.co/hexgrad/Kokoro-82M)
model. Exposes `/v1/audio/speech` (OpenAI Speech API), a voices endpoint, and a web
player at `/web`. Multi-language, supports voice mixing and per-word timestamps.

## Build / run

Local (CPU): `run.sh` installs uv if missing, syncs deps, and serves.

```bash
cp .env.example .env            # optional; defaults work
uv sync --extra cpu             # or --extra gpu for CUDA
./fetch_models.sh               # download weights + voice packs
./run.sh
# or the explicit helpers:
./start-cpu.sh
./start-gpu.sh
```

Served on `http://${HOST}:${PORT}` (default `0.0.0.0:8880`), web UI at `/web`,
docs at `/docs`.

Docker (compose files under `docker/cpu`, `docker/gpu`, `docker/rocm`); the image
fetches the model and voices at build time when `DOWNLOAD_MODEL=true`:

```bash
cd docker/cpu && docker compose up --build     # CPU
cd docker/gpu && docker compose up --build     # NVIDIA GPU
```

Tests: `uv run --extra test pytest`.

## Configuration

Config is env vars; `.env.example` is the source of truth and maps 1:1 to the pydantic
settings in `api/src/core/config.py`. Copy and edit; an empty `.env` is valid because
every field has a default.

```bash
cp .env.example .env
```

Ones that matter: `HOST`, `PORT` (default 8880), `USE_GPU` (true/false),
`DEVICE_TYPE` (cuda/mps/cpu, empty = auto), `DEFAULT_VOICE` (default `af_heart`),
`MODEL_DIR`, `VOICES_DIR`, `ENABLE_WEB_PLAYER`, `ESPEAK_DATA_PATH`. `HF_REPO_ID` is
read only at fetch time, not by the app -- export it inline for `./fetch_models.sh`,
do not put it in `.env`.

## Dependencies

Python 3.10+ (pinned via `.python-version`), managed with [uv](https://docs.astral.sh/uv/)
(`pyproject.toml` / `uv.lock`). Needs `espeak-ng` on the host (`apt-get install espeak-ng`)
as the phonemizer backend. NVIDIA GPU optional; CPU works out of the box. Model weights
(`kokoro-v1_0.pth` + `config.json`) and `*.pt` voice packs are standard public assets,
not committed here -- `./fetch_models.sh` downloads both (voices from `hexgrad/Kokoro-82M`,
overridable via `HF_REPO_ID`) and skips files that already exist.
