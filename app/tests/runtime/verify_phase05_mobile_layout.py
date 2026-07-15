#!/usr/bin/env python3
"""Static Phase 0.5 mobile layout foundation verifier."""
from __future__ import annotations

import hashlib
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[3]

FROZEN = {
    "app/src/gameplay/runtime/ChallengeSessionService.gd": "af05843c0fd1e47311ac19479edc52f1723584eac97e6e07b0b4a05adf75f70c",
    "app/src/ui/screens/ObservationChallengeScreen.gd": "a15d99e93eb73951273bdacdbf13563ef9ce62cf19fe3d57188336cf95169e15",
    "app/src/ui/screens/MemoryQuestionScreen.gd": "648a628c8cc90250a3cede4595075448c55f118e54f3b7cfed2b5ca22f5f6a8a",
}


def text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def fail_if(condition: bool, message: str, failures: list[str]) -> None:
    if condition:
        failures.append(message)


def require(condition: bool, message: str, failures: list[str]) -> None:
    if not condition:
        failures.append(message)


def sha(path: str) -> str:
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


def main() -> int:
    failures: list[str] = []
    responsive = text("app/src/ui/layout/ResponsiveLayout.gd")
    require("const MIN_TOUCH_TARGET: float = 56.0" in responsive, "ResponsiveLayout touch target floor must be 56dp-equivalent.", failures)
    require("prepare_mobile_scroll" in responsive, "ResponsiveLayout must expose mobile scroll preparation.", failures)
    require("prepare_scroll_descendants" in responsive, "ResponsiveLayout must prepare nested/family tutorial scroll containers.", failures)

    shell = text("app/src/ui/shell/AppShell.gd")
    require("ResponsiveLayout.prepare_scroll_descendants(_current_screen)" in shell, "AppShell must prepare scroll descendants after route load.", failures)

    for path in [
        "app/src/ui/screens/HomeV2Screen.gd",
        "app/src/ui/screens/ExperiencesScreen.gd",
        "app/src/ui/screens/SettingsScreen.gd",
        "app/src/ui/screens/ProfileScreen.gd",
        "app/src/ui/screens/ResultScreen.gd",
    ]:
        require("ResponsiveLayout.prepare_mobile_scroll" in text(path), f"Primary scroll screen missing explicit mobile scroll prep: {path}", failures)

    require("ResponsiveLayout.enforce_touch_targets(_current_screen)" in shell,
            "AppShell must enforce touch targets on loaded screens, including family tutorials.", failures)

    theme = text("app/src/systems/theme/ThemeService.gd")
    for needle in [
        '"display": {"size": 38',
        '"headline": {"size": 30',
        '"body": {"size": 20',
        '"body_small": {"size": 18',
        '"button": {"size": 20',
        '"touch_target_min": 56',
    ]:
        require(needle in theme, f"Theme readability token missing: {needle}", failures)

    card_expectations = {
        "app/src/ui/components/DailyExperienceCard.tscn": ["Vector2(0, 320)", "Vector2(0, 128)", "Vector2(0, 72)"],
        "app/src/ui/components/ExperienceCard.tscn": ["Vector2(0, 448)", "Vector2(0, 176)", "Vector2(0, 60)"],
        "app/src/ui/components/ProgramCard.tscn": ["Vector2(0, 392)", "Vector2(0, 152)", "Vector2(0, 64)"],
    }
    for path, needles in card_expectations.items():
        source = text(path)
        for needle in needles:
            require(needle in source, f"Mobile card sizing missing {needle} in {path}", failures)

    for path, expected in FROZEN.items():
        require(sha(path) == expected, f"Frozen gameplay file changed during Phase 0.5: {path}", failures)

    forbidden = text("app/src/gameplay/runtime/ChallengeSessionService.gd")
    fail_if("Phase 0.5" in forbidden or "mobile" in forbidden.lower(), "ChallengeSessionService must not carry Phase 0.5 mobile concerns.", failures)

    if failures:
        print("PHASE0_5_MOBILE_LAYOUT_FAIL")
        for failure in failures:
            print(f"- {failure}")
        return 1
    print("PHASE0_5_MOBILE_LAYOUT_PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
