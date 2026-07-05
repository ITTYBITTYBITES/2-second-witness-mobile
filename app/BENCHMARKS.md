# Verification Suite (Regression Gate)

The `benchmark/verify_*.gd` scripts are the project's automated regression suite. They `extend SceneTree` and reference autoloads as bare identifiers, which **do not compile** when run directly via `godot -s` (Godot does not expose autoload globals to a standalone `-s` script). This project provides a compatibility layer so the suite runs unmodified.

## How it works (zero benchmark edits)

`benchmark/VerificationRunner.tscn` + `benchmark/run_verification.gd` is a scene run in **app context** (autoloads active). It loads each benchmark via `load(path).new()`. A script loaded inside the running app compiles *with* autoload globals, so the bare identifiers resolve and the benchmark executes against the real, live autoloads and loaded content.

`tools/run_verification_suite.py` orchestrates: one benchmark per Godot subprocess, capturing output and reporting compile/execute status + the first failure diagnostic.

## Usage

```bash
# Run the whole suite (set GODOT to your Godot 4.6 binary)
GODOT=/path/to/godot python3 tools/run_verification_suite.py

# Run a single benchmark by substring
GODOT=/path/to/godot python3 tools/run_verification_suite.py --only verify_scenario_execution
```

Exit code: `0` = all benchmarks compile & execute (no infrastructure regression); `1` = compile/infrastructure failure; `2` = Godot binary not found.

## Current status (2026-07-05)

- **All 40 benchmarks COMPILE & EXECUTE** (previously: all failed to compile in `-s` mode).
- Many have **failing assertions**. Root causes are content/architecture drift, **not** infrastructure:
  1. Benchmarks hardcode navigation to universes not yet playable (`history`, `frontier`, …) — these now correctly return "no playable worlds" until their content is authored and `status` flipped to `complete`.
  2. Some assertions target APIs changed by the "eliminate hardcoded IDs" refactor and the observation data-contract adapter.
  3. Benchmarks run in the booted-app context (subsystems already initialized), whereas they were originally written for a pristine `-s` SceneTree.

As content is authored for each universe and benchmark assertions are aligned to the current architecture, the suite goes green. The gate's job — detecting compile/infrastructure regressions automatically — is functional today.

## Adding the gate to CI

```yaml
- name: Verification suite
  env: { GODOT: godot }
  run: python3 app/tools/run_verification_suite.py
```
