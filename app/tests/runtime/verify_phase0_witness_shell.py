#!/usr/bin/env python3
"""Static Phase 0 Witness Foundation Shell verifier.

This does not replace Godot runtime/device validation. It checks the approved
Phase 0 boundaries that can be verified from source: primary nav labels,
secondary Library access, unchanged gameplay/session files, and required shell
foundation components.
"""
from __future__ import annotations

import hashlib
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]

EXPECTED_BASE_HASHES = {
    "app/src/gameplay/runtime/ChallengeSessionService.gd": "af05843c0fd1e47311ac19479edc52f1723584eac97e6e07b0b4a05adf75f70c",
    "app/src/ui/screens/ObservationChallengeScreen.gd": "a15d99e93eb73951273bdacdbf13563ef9ce62cf19fe3d57188336cf95169e15",
    "app/src/ui/screens/MemoryQuestionScreen.gd": "648a628c8cc90250a3cede4595075448c55f118e54f3b7cfed2b5ca22f5f6a8a",
    "app/src/ui/screens/TutorialScreen.gd": "828ada2b9ea6ebb655e1da9a079b6811372c520b1349996dc9049c7ac702c790",
}


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def sha256(path: str) -> str:
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


def require(condition: bool, message: str, failures: list[str]) -> None:
    if not condition:
        failures.append(message)


def main() -> int:
    failures: list[str] = []
    routes = read("app/src/core/navigation/AppRoutes.gd")
    nav = read("app/src/ui/shell/MainNavigation.gd")
    home = read("app/src/ui/screens/HomeV2Screen.gd")
    result = read("app/src/ui/screens/ResultScreen.gd")

    require('const TAB_ORDER := ["home", "profile", "settings"]' in routes,
            "Primary tab order must be Witness/Home, Record/Profile, Settings only.", failures)
    require('"experiences": {' in routes and '"screen": "ExperiencesScreen"' in routes and '"label": "Explore Experiences"' in routes,
            "Experiences/Library route must remain present as a secondary destination.", failures)
    require('{"route": "home", "label": "Witness"' in nav, "Bottom nav must display Witness.", failures)
    require('{"route": "profile", "label": "Record"' in nav, "Bottom nav must display Record for profile route.", failures)
    require('"route": "experiences"' not in nav.split('const TABS := [', 1)[1].split(']', 1)[0],
            "Library/experiences must not be in primary bottom navigation.", failures)

    require('"Observe what others miss."' in home, "Witness Home must carry the approved witness invitation.", failures)
    require('NavigationService.navigate_to("experiences")' in home, "Witness Home must still reach Explore Experiences/Library.", failures)
    require('NavigationService.navigate_to("profile")' in home, "Witness Home must provide Record access.", failures)
    require('NavigationService.navigate_to("settings")' in home, "Witness Home must provide Settings access.", failures)

    require('EvidenceRevealContainer.gd' in result, "Result must mount the Phase 0 EvidenceRevealContainer wrapper.", failures)
    require((ROOT / "app/src/ui/components/ScreenContainer.gd").exists(), "ScreenContainer component missing.", failures)
    require((ROOT / "app/src/ui/components/ModalLayer.gd").exists(), "ModalLayer component missing.", failures)
    require((ROOT / "app/src/ui/components/EvidenceRevealContainer.gd").exists(), "EvidenceRevealContainer component missing.", failures)

    for folder in ["scenes", "evidence", "home", "record", "branding"]:
        require((ROOT / "app/assets" / folder / ".gitkeep").exists(), f"Missing asset placeholder folder: {folder}", failures)

    for path, expected in EXPECTED_BASE_HASHES.items():
        require(sha256(path) == expected, f"Frozen gameplay/session file changed: {path}", failures)

    if failures:
        print("Phase 0 Witness shell verification failed:")
        for failure in failures:
            print(f"- {failure}")
        return 1
    print("Phase 0 Witness shell static verification passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
