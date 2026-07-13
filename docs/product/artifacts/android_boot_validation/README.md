# Android Boot Validation Artifacts

The corrected arm64 development APK was generated and verified during the 2026-07-12 validation session. Its SHA-256 was:

`018e76d602212a8101f5483e21ad09375d01511dff9416a660b1ade8f86b49ab`

The 43 MB debug APK and short emulator video/log were not retained in the persisted workspace snapshot. They were temporary validation outputs, not production-signed release artifacts.

Persisted frames:

- `pre_correction_vulkan_failure_frames/` — initial API 31 attempt that exposed the missing mobile renderer override.
- `post_correction_emulator_frames/` — limited corrected-run frames. The emulator did not provide trustworthy full-sequence rendering.

The boot gate remains open pending physical Android 12+ hardware or a hardware-accelerated emulator.
