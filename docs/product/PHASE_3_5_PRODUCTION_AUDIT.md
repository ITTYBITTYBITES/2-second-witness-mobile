# Phase 3.5 — Production Audit

**Date:** 2026-07-12
**Scope:** Boot, Android layout, product UI, accessibility, performance, and regression readiness

## Findings and resolutions

### Boot

**Finding:** Godot boot splash used the application launcher icon, causing the icon to appear before the sponsor route. Android 12+ also supplies a system splash icon independently of Godot's engine splash.

**Resolution:**

- Godot boot splash now uses full-screen ITTYBITTYBITES sponsor artwork.
- PublisherSplashScreen continues the same artwork.
- Both Android presets use Gradle custom builds.
- Both presets inject a transparent Android system splash animated icon and matching background.

**Remaining:** Install/verify the Godot Android build template, export with a local SDK, and capture Android 12+ launch frames.

### Android renderer selection

**Finding during exported-build validation:** The first API 31 emulator launch selected Vulkan because only the general renderer was set; Android export reads the mobile renderer override separately.

**Minimal correction:**

- Added `renderer/rendering_method.mobile="gl_compatibility"`.
- Added `rendering_device/driver.android="opengl3"`.
- Re-exported the development APK.
- Confirmed through corrected logcat that `usesVulkan()` is false and the selected renderer/driver are `gl_compatibility`/`opengl3`.

**Remaining:** The available non-KVM SwiftShader emulator could not link the Godot GLES3 scene shaders or remain stable under load. Full visual boot confirmation still requires suitable hardware or a hardware-accelerated emulator.

### Safe areas and wide displays

**Finding:** AppShell applied physical safe-area pixels directly to logical Control offsets. Product surfaces also expanded indefinitely on wide tablets/foldables.

**Resolution:**

- Safe-area insets now scale from window pixels into viewport coordinates.
- ResponsiveLayout supplies centered maximum-width margins.
- Ten shared/product/gameplay screens use responsive margins.
- Local phone, tablet, and unfolded profiles are automated.

**Remaining:** Vendor foldable hinge behavior and real cutout reporting require device/emulator execution.

### Touch and input

**Finding:** Several scene-authored buttons declared 40-pixel minimums, and Android Back had no shell-level handling.

**Resolution:**

- AppShell recursively enforces 48-pixel minimum touch targets.
- Device matrix tests audit effective targets.
- `ui_cancel`/Android Back now uses NavigationService history and Home fallback.
- Top-bar actions use compact symbols with descriptive tooltips.

### Loading and navigation polish

**Finding:** Global loading used a stock rotating symbol. Home launches had no visible preparation state. Screen swaps were abrupt.

**Resolution:**

- Loading uses a labeled eye-like pulse.
- Home Play Now, Continue, and featured launches present branded preparation copy for at least one frame.
- Route changes use a restrained 180 ms fade.
- Reduced Motion disables both pulse and route animation.
- Hidden cached screens defer expensive reconstruction until revisited.

### Text scaling and contrast

**Finding:** Text Size updated AccessibilityService but ThemeService typography ignored the value. High Contrast was stored but did not derive a high-contrast palette.

**Resolution:**

- Shared typography now scales from 80–140 percent.
- Custom display/icon sizes use the same scale helper.
- High Contrast derives complete dark/light surface, border, primary, and text tokens.
- Automated contrast checks require at least 7:1 for primary and secondary text.
- Long product screens remain scrollable.

### Color reliance

**Finding:** Scene Investigation could ask players to identify an object's color. High Contrast alone does not resolve color-vision differences.

**Resolution:**

- Added persisted Color Assistance.
- PlayerProgressService exposes it to family policies.
- Scene Investigation removes color-attribute questions when enabled.
- Result status still uses explicit text and symbols in addition to color.

### Settings interaction

**Finding:** Slider changes could trigger immediate full-screen reconstruction while a drag was active.

**Resolution:** Theme/font refresh is debounced; unrelated setting changes no longer rebuild the entire Settings surface.

### Performance

**Finding:** Product timing was visible in logs but not consistently measured, and large textures imported at unrestricted size.

**Resolution:**

- Cold service readiness, screen presentation, challenge preparation, generation attempts, and static memory are instrumented through the existing AnalyticsService.
- Hidden screen refreshes are deferred.
- Seven large textures now have 1024/1280-pixel runtime import limits.
- A repeatable local benchmark enforces construction, snapshot, layout-matrix, and memory ceilings.

## Architecture conclusion

Phase 3.5 adds no alternate navigation, save, analytics, accessibility, or loading framework. It fixes and extends the existing Foundation services and shared shell. Family-specific Color Assistance remains inside Scene Investigation policy/generation, while shared settings only carry the preference.
