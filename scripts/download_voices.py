#!/usr/bin/env python3
"""Download Kokoro v1.0 voice packs from the public Hugging Face repo.

Voices are standard, publicly available pretrained assets published by the
Kokoro authors at https://huggingface.co/hexgrad/Kokoro-82M (subfolder
``voices/``). They are NOT bundled in this repository to keep it lightweight;
run this script once after cloning to populate ``api/src/voices/v1_0``.

Usage:
    python scripts/download_voices.py
    python scripts/download_voices.py --output api/src/voices/v1_0
    HF_REPO_ID=hexgrad/Kokoro-82M python scripts/download_voices.py
"""

import argparse
import os
import sys
from pathlib import Path


DEFAULT_REPO_ID = os.environ.get("HF_REPO_ID", "hexgrad/Kokoro-82M")
DEFAULT_OUTPUT = "api/src/voices/v1_0"


def download_voices(output_dir: str, repo_id: str) -> None:
    """Download every ``*.pt`` voice pack from the HF repo's ``voices`` folder."""
    try:
        from huggingface_hub import HfApi, hf_hub_download
    except ImportError:
        print(
            "huggingface_hub is required. Install project dependencies first "
            "(uv sync / pip install -e .) or run: pip install huggingface_hub",
            file=sys.stderr,
        )
        sys.exit(1)

    os.makedirs(output_dir, exist_ok=True)

    api = HfApi()
    files = api.list_repo_files(repo_id=repo_id)
    voice_files = [f for f in files if f.startswith("voices/") and f.endswith(".pt")]

    if not voice_files:
        print(f"No voice files found in repo {repo_id}", file=sys.stderr)
        sys.exit(1)

    print(f"Found {len(voice_files)} voices in {repo_id}")

    for remote in voice_files:
        name = Path(remote).name
        target = Path(output_dir) / name
        if target.exists() and target.stat().st_size > 0:
            print(f"  exists, skipping: {name}")
            continue
        print(f"  downloading: {name}")
        cached = hf_hub_download(repo_id=repo_id, filename=remote)
        # Copy out of the HF cache into the project voices dir.
        with open(cached, "rb") as src, open(target, "wb") as dst:
            dst.write(src.read())

    print(f"Done. Voices are in {output_dir}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Download Kokoro voice packs")
    parser.add_argument(
        "--output",
        default=DEFAULT_OUTPUT,
        help=f"Output directory for voice files (default: {DEFAULT_OUTPUT})",
    )
    parser.add_argument(
        "--repo-id",
        default=DEFAULT_REPO_ID,
        help=f"Hugging Face repo id (default: {DEFAULT_REPO_ID})",
    )
    args = parser.parse_args()
    download_voices(args.output, args.repo_id)


if __name__ == "__main__":
    main()
