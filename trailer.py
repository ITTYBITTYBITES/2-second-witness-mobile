#!/usr/bin/env python3
"""One-command launcher for the Two Second Witness trailer pipeline.

On a clean machine this creates an isolated local environment, installs the
small deterministic render toolchain, and runs the production build. Existing
environments with the dependencies already installed start immediately.
"""

from __future__ import annotations

import importlib.util
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent
BUILD_SCRIPT = ROOT / "trailer" / "build_trailer_v3.py"
REQUIREMENTS = ROOT / "trailer" / "requirements.txt"
REQUIRED_MODULES = ("numpy", "PIL", "imageio_ffmpeg", "yaml", "qrcode")


def environment_python(environment: Path) -> Path:
    return environment / ("Scripts/python.exe" if os.name == "nt" else "bin/python")


def dependencies_available() -> bool:
    return all(importlib.util.find_spec(module) is not None for module in REQUIRED_MODULES)


def main() -> None:
    if dependencies_available():
        os.execv(sys.executable, [sys.executable, str(BUILD_SCRIPT), *sys.argv[1:]])

    environment = ROOT / ".trailer-venv"
    python = environment_python(environment)
    if not python.exists():
        print("Creating isolated trailer render environment…")
        subprocess.run([sys.executable, "-m", "venv", str(environment)], check=True)
    print("Installing trailer render dependencies…")
    subprocess.run([str(python), "-m", "pip", "install", "--disable-pip-version-check", "-r", str(REQUIREMENTS)], check=True)
    os.execv(str(python), [str(python), str(BUILD_SCRIPT), *sys.argv[1:]])


if __name__ == "__main__":
    main()
