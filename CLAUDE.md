# CLAUDE.md -- kokoro-tts

This file provides guidance to Claude Code when working in this repository.

IMPORTANT: NEVER USE EMOJIS ANYWHERE IN LOGGING, CODE OR OTHER TEXT!

## What this is

Self-contained copy of [Kokoro-FastAPI](https://github.com/remsky/Kokoro-FastAPI): an OpenAI-compatible TTS service wrapping the [Kokoro-82M](https://huggingface.co/hexgrad/Kokoro-82M) model. Exposes `/v1/audio/speech` (OpenAI Speech API), a voices endpoint, and a web player at `/web`. Multi-language, supports voice mixing and per-word timestamps.

This is the Kokoro TTS backend in a larger AI orchestration system; it is reached on port 10007 in that system. For the whole-system map -- architecture, full port allocation, and every service -- see the `jaskier-os/orchestrator` repo's CLAUDE.md / docs. Don't duplicate that here.

IMPORTANT: this is a vendored upstream project (public Kokoro-FastAPI). Treat upstream code as third-party -- prefer minimal, surgical changes so it stays mergeable with upstream, rather than the usual "remove redundant code" rule.

## Key files

- `api/src/` -- the FastAPI service. `api/src/core/config.py` holds the pydantic settings (`.env.example` maps 1:1 to it).
- `run.sh` / `start-cpu.sh` / `start-gpu.sh` -- local run helpers (uv-based)
- `fetch_models.sh` -- downloads weights + voice packs
- `docker/{cpu,gpu,rocm}/` -- compose files; image fetches model + voices at build when `DOWNLOAD_MODEL=true`
- `web/` -- web player; `.env.example` -- source of truth for configuration

## Build / run

See `README.md`. Quick local CPU run: `uv sync --extra cpu && ./fetch_models.sh && ./run.sh`. Served on `http://${HOST}:${PORT}` (default `0.0.0.0:8880`), web UI at `/web`, docs at `/docs`. Tests: `uv run --extra test pytest`. Config is env vars; an empty `.env` is valid because every field has a default.

## Deployment

This service auto-deploys on push to `main` (CI builds the image, pushes to `localhost:5000`, then commits an `image:` tag bump into the `infrastructure/deploy` repo for FluxCD to reconcile).

- Do NOT build/push production Docker images by hand. Commit + push and let CI do it.
- NEVER modify the Kubernetes cluster directly (`kubectl set env/edit/patch`). All deploy changes go through the `infrastructure/deploy` repo so Flux reconciles them; direct changes get overwritten and cause drift.
- `main` is protected; normal (non-force) commits by Maintainers are fine. NEVER force-push.
