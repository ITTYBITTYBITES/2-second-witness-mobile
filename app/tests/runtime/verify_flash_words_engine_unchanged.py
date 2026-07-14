#!/usr/bin/env python3
"""Preserves Gate 4 while allowing approved Phase 3/3.5 product evolution.

The baseline records the 71 files that were unchanged when Flash Words was added.
Later approved phases may evolve explicit shared product/polish files. Every file
outside this allowlist must still match its Gate 4 hash.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASELINE = ROOT / "docs/product/FLASH_WORDS_ENGINE_BASELINE.json"

APPROVED_EVOLUTION_ALLOWLIST = {
    # Intentional Phase 3 product/runtime changes.
    "app/project.godot",
    "app/src/core/app/AppBoot.gd",
    "app/src/core/app/AppState.gd",
    "app/src/core/navigation/AppRoutes.gd",
    "app/src/core/navigation/NavigationService.gd",
    "app/src/gameplay/runtime/ChallengeSessionService.gd",
    "app/src/gameplay/runtime/PlayerProgressService.gd",
    "app/src/gameplay/runtime/RecommendationService.gd",
    "app/src/systems/save/ProfileService.gd",
    "app/src/systems/settings/SettingsService.gd",
    "app/src/ui/components/ExperienceCard.gd",
    "app/src/ui/components/ExperienceCard.tscn",
    "app/src/ui/screens/ExperiencesScreen.gd",
    "app/src/ui/screens/ExperiencesScreen.tscn",
    "app/src/ui/screens/HomeScreen.gd",
    "app/src/ui/screens/HomeScreen.tscn",
    "app/src/ui/screens/ProfileScreen.gd",
    "app/src/ui/screens/ProfileScreen.tscn",
    "app/src/ui/screens/SettingsScreen.gd",
    "app/src/ui/shell/AppShell.gd",
    # Phase 3 closeout removed pre-existing whitespace-only blank lines.
    "app/src/ui/components/AppButton.gd",
    "app/src/ui/components/AppCard.gd",
    "app/src/ui/components/SectionHeader.gd",
    "app/src/ui/screens/MemoryQuestionScreen.gd",
    "app/src/ui/screens/ObservationChallengeScreen.gd",
    "app/src/ui/screens/ResultScreen.gd",
    "app/src/ui/screens/TitleSplashScreen.gd",
    # Approved Phase 3.5 production-polish evolution.
    "app/src/systems/accessibility/AccessibilityService.gd",
    "app/src/systems/theme/ThemeService.gd",
    "app/src/ui/dialogs/PrivacyTermsDialog.gd",
    "app/src/ui/screens/AboutScreen.gd",
    "app/src/ui/screens/PublisherSplashScreen.gd",
    "app/src/ui/screens/PublisherSplashScreen.tscn",
    "app/src/ui/screens/SettingsScreen.tscn",
    "app/src/ui/shell/AppShell.tscn",
    "app/src/ui/shell/MainNavigation.gd",
    "app/src/ui/shell/TopBar.gd",
    # Approved Phase 4 Program tutorial-context evolution.
    "app/src/ui/screens/TutorialScreen.gd",
    # Approved Phase 6 production-readiness hardening and PR #28 type annotations.
    "app/src/core/app/ErrorHandler.gd",
    "app/src/core/events/EventBus.gd",
    "app/src/gameplay/runtime/ResultService.gd",
    "app/src/systems/analytics/AnalyticsService.gd",
    "app/src/systems/audio/AudioService.gd",
    "app/src/systems/config/ConfigService.gd",
    "app/src/systems/content/ContentService.gd",
    "app/src/systems/content/ExperienceRegistry.gd",
    "app/src/systems/save/SaveService.gd",
    "app/src/ui/dialogs/PrivacyTermsDialog.tscn",
    "app/src/ui/screens/AboutScreen.tscn",
    "app/src/ui/screens/MemoryQuestionScreen.tscn",
    "app/src/ui/screens/ObservationChallengeScreen.tscn",
    "app/src/ui/screens/PlaceholderScreen.gd",
    "app/src/ui/screens/ResultScreen.tscn",
    "app/src/ui/screens/TitleSplashScreen.tscn",
    # Approved Phase 5A generic Interaction Adapter evolution.
    "app/src/gameplay/contracts/PresentationProfile.gd",
    "app/src/gameplay/runtime/ChallengeFamilyModule.gd",
    "app/src/gameplay/runtime/ChallengeFamilyRegistry.gd",
}

data = json.loads(BASELINE.read_text())
errors: list[str] = []
changed: set[str] = set()
unchanged = 0
for relative, expected in data.get("files", {}).items():
    path = ROOT / relative
    if not path.exists():
        changed.add(relative)
        if relative not in APPROVED_EVOLUTION_ALLOWLIST:
            errors.append(f"protected file removed: {relative}")
        continue
    actual = hashlib.sha256(path.read_bytes()).hexdigest()
    if actual == expected:
        unchanged += 1
    else:
        changed.add(relative)
        if relative not in APPROVED_EVOLUTION_ALLOWLIST:
            errors.append(f"protected file changed outside approved post-Gate-4 allowlist: {relative}")

missing_expected_changes = changed - APPROVED_EVOLUTION_ALLOWLIST
if missing_expected_changes:
    errors.append(f"unapproved changed files: {sorted(missing_expected_changes)}")

if errors:
    for error in errors:
        print(f"ENGINE BASELINE FAIL: {error}")
    raise SystemExit(1)

print(
    "FLASH_WORDS_ENGINE_BASELINE_POST_PHASE5_PASS "
    f"baseline_files={len(data.get('files', {}))} "
    f"protected_unchanged={unchanged} approved_evolved={len(changed)}"
)
