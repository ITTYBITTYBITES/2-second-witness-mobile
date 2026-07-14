"""
Two Second Witness — Audio Asset Generator

Generates a complete, cohesive sound language as 16-bit mono WAV files
at 44.1 kHz. Designed to feel premium and tactile without sounding
like raw synth placeholders.

Categories:
  - UI        : micro-interactions (taps, hovers, transitions)
  - SFX       : gameplay events (flash, conceal, reveal, mastery)
  - Ambient   : subtle BGM-style loops
"""

import math
import os
import random
import struct
import wave
from typing import Callable, List

SR = 44100
TWO_PI = 2.0 * math.pi
_OUT_DIR_THIS = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(_OUT_DIR_THIS, "..", "app", "assets", "audio")


def _clip(x: float) -> float:
    if x > 1.0:
        return 1.0
    if x < -1.0:
        return -1.0
    return x


def _normalize(buf: List[float], peak: float = 0.95) -> List[float]:
    if not buf:
        return buf
    m = max(abs(v) for v in buf)
    if m < 1e-6:
        return buf
    s = peak / m
    return [v * s for v in buf]


def _adsr(n: int, a: float, d: float, s: float, r: float) -> List[float]:
    a_n = int(a * n)
    d_n = int(d * n)
    r_n = int(r * n)
    s_n = max(0, n - a_n - d_n - r_n)
    out: List[float] = []
    for i in range(a_n):
        out.append(i / max(1, a_n))
    for i in range(d_n):
        out.append(1.0 - (1.0 - s) * (i / max(1, d_n)))
    for _ in range(s_n):
        out.append(s)
    for i in range(r_n):
        out.append(s * (1.0 - i / max(1, r_n)))
    while len(out) < n:
        out.append(0.0)
    return out[:n]


def _sine(freq: float, n: int, phase: float = 0.0) -> List[float]:
    return [math.sin(phase + TWO_PI * freq * i / SR) for i in range(n)]


def _triangle(freq: float, n: int) -> List[float]:
    period = SR / freq
    out: List[float] = []
    for i in range(n):
        t = (i % period) / period
        v = 4.0 * abs(t - 0.5) - 1.0
        out.append(v)
    return out


def _noise(n: int) -> List[float]:
    rng = random.Random(0xC0FFEE)
    return [rng.uniform(-1.0, 1.0) for _ in range(n)]


def _pink(n: int) -> List[float]:
    rng = random.Random(0xBADA55)
    b = [0.0] * 7
    out: List[float] = []
    for _ in range(n):
        white = rng.uniform(-1.0, 1.0)
        b[0] = 0.99886 * b[0] + white * 0.0555179
        b[1] = 0.99332 * b[1] + white * 0.0750759
        b[2] = 0.96900 * b[2] + white * 0.1538520
        b[3] = 0.86650 * b[3] + white * 0.3104856
        b[4] = 0.55000 * b[4] + white * 0.5329522
        b[5] = -0.7616 * b[5] - white * 0.0168980
        pink = sum(b) * 0.11
        out.append(pink)
    return out


def _sweep(f0: float, f1: float, n: int, curve: str = "exp") -> List[float]:
    out: List[float] = []
    for i in range(n):
        t = i / max(1, n - 1)
        if curve == "exp":
            k = math.log(f1 / max(1e-3, f0))
            f = f0 * math.exp(k * t)
        else:
            f = f0 + (f1 - f0) * t
        out.append(f)
    return out


def _to_wav(name: str, samples: List[float]) -> None:
    pcm = b"".join(struct.pack("<h", int(_clip(s) * 32767)) for s in samples)
    path = os.path.join(OUT_DIR, name)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm)
    print(f"  wrote {name:32s} {len(samples) / SR * 1000:7.1f} ms")


# ----------------------------------------------------------------------------
# UI
# ----------------------------------------------------------------------------

def sfx_ui_click() -> List[float]:
    n = int(0.060 * SR)
    a = _sine(880, n, phase=0.0)
    b = _sine(1760, n, phase=0.0)
    buf = [0.7 * a[i] + 0.3 * b[i] for i in range(n)]
    env = _adsr(n, 0.001, 0.040, 0.0, 0.020)
    return [buf[i] * env[i] for i in range(n)]


def sfx_ui_hover() -> List[float]:
    n = int(0.045 * SR)
    a = _sine(1320, n)
    env = _adsr(n, 0.002, 0.020, 0.0, 0.020)
    return [0.5 * a[i] * env[i] for i in range(n)]


def sfx_ui_back() -> List[float]:
    n = int(0.140 * SR)
    freqs = _sweep(620, 380, n, "exp")
    s = [math.sin(TWO_PI * freqs[i] * i / SR) for i in range(n)]
    env = _adsr(n, 0.005, 0.060, 0.0, 0.075)
    return [0.7 * s[i] * env[i] for i in range(n)]


def sfx_ui_navigate() -> List[float]:
    n = int(0.110 * SR)
    a = _sine(520, n)
    b = _sine(780, n, phase=0.3)
    buf = [0.5 * a[i] + 0.3 * b[i] for i in range(n)]
    env = _adsr(n, 0.005, 0.040, 0.0, 0.065)
    return [buf[i] * env[i] for i in range(n)]


def sfx_ui_success() -> List[float]:
    """A short two-note positive chime."""
    n1 = int(0.090 * SR)
    n2 = int(0.150 * SR)
    p1 = [math.sin(TWO_PI * 880 * i / SR) for i in range(n1)]
    p2 = [math.sin(TWO_PI * 1320 * i / SR) for i in range(n2)]
    p2b = [math.sin(TWO_PI * 1760 * i / SR) for i in range(n2)]
    e1 = _adsr(n1, 0.003, 0.030, 0.0, 0.060)
    e2 = _adsr(n2, 0.003, 0.050, 0.0, 0.095)
    out = [p1[i] * e1[i] * 0.65 for i in range(n1)]
    for i in range(n2):
        out.append((p2[i] * 0.6 + p2b[i] * 0.3) * e2[i])
    return out


def sfx_ui_failure() -> List[float]:
    """A muted two-note minor-fall cue."""
    n = int(0.180 * SR)
    p1 = [math.sin(TWO_PI * 330 * i / SR) for i in range(n)]
    p2 = [math.sin(TWO_PI * 247 * i / SR) for i in range(n)]
    out: List[float] = []
    half = n // 2
    e1 = _adsr(half, 0.005, 0.060, 0.0, 0.060)
    e2 = _adsr(n - half, 0.005, 0.060, 0.0, 0.090)
    for i in range(half):
        out.append(p1[i] * e1[i] * 0.55)
    for i in range(n - half):
        out.append(p2[i] * e2[i] * 0.55)
    return out


def sfx_ui_unlock() -> List[float]:
    """A bright 3-note arpeggio for achievement unlock."""
    notes = [659.25, 880.0, 1318.51]  # E5, A5, E6
    out: List[float] = []
    note_dur = 0.110
    for f in notes:
        n = int(note_dur * SR)
        partials = [math.sin(TWO_PI * f * i / SR) for i in range(n)]
        partials2 = [0.4 * math.sin(TWO_PI * (2 * f) * i / SR) for i in range(n)]
        env = _adsr(n, 0.005, 0.040, 0.0, 0.070)
        for i in range(n):
            out.append((partials[i] + partials2[i]) * env[i] * 0.6)
    return out


def sfx_ui_achievement() -> List[float]:
    """A more triumphant major arpeggio."""
    notes = [523.25, 659.25, 783.99, 1046.50]  # C5, E5, G5, C6
    out: List[float] = []
    note_dur = 0.090
    for idx, f in enumerate(notes):
        n = int(note_dur * SR)
        fundamental = [math.sin(TWO_PI * f * i / SR) for i in range(n)]
        second = [0.4 * math.sin(TWO_PI * (2 * f) * i / SR) for i in range(n)]
        third = [0.18 * math.sin(TWO_PI * (3 * f) * i / SR) for i in range(n)]
        env = _adsr(n, 0.003, 0.030, 0.0, 0.060)
        for i in range(n):
            out.append((fundamental[i] + second[i] + third[i]) * env[i] * 0.55)
    return out


# ----------------------------------------------------------------------------
# Gameplay
# ----------------------------------------------------------------------------

def sfx_observation_start() -> List[float]:
    """A soft ascending sweep that primes the user to look."""
    n = int(0.450 * SR)
    freqs = _sweep(180, 620, n, "exp")
    s = [math.sin(TWO_PI * freqs[i] * i / SR) for i in range(n)]
    sh = [0.3 * math.sin(TWO_PI * (freqs[i] * 1.5) * i / SR) for i in range(n)]
    env = _adsr(n, 0.030, 0.180, 0.0, 0.240)
    return [(s[i] + sh[i]) * env[i] * 0.7 for i in range(n)]


def sfx_observation_pulse() -> List[float]:
    """A short rhythmic blip used by timer beats in observation."""
    n = int(0.110 * SR)
    f = 540.0
    s = [math.sin(TWO_PI * f * i / SR) for i in range(n)]
    s2 = [0.3 * math.sin(TWO_PI * (2 * f) * i / SR) for i in range(n)]
    env = _adsr(n, 0.003, 0.040, 0.0, 0.060)
    return [(s[i] + s2[i]) * env[i] * 0.55 for i in range(n)]


def sfx_conceal() -> List[float]:
    """A descending whisper that says 'image gone'."""
    n = int(0.380 * SR)
    freqs = _sweep(700, 120, n, "exp")
    s = [math.sin(TWO_PI * freqs[i] * i / SR) for i in range(n)]
    sh = _pink(n)
    env = _adsr(n, 0.020, 0.150, 0.0, 0.210)
    return [(s[i] * 0.5 + sh[i] * 0.25) * env[i] for i in range(n)]


def sfx_flash_pulse() -> List[float]:
    """A short swell used in flash-words intervals."""
    n = int(0.180 * SR)
    f = 320.0
    s = [math.sin(TWO_PI * f * i / SR) for i in range(n)]
    sh = _pink(n)
    env = _adsr(n, 0.020, 0.080, 0.0, 0.080)
    return [(s[i] * 0.4 + sh[i] * 0.2) * env[i] for i in range(n)]


def sfx_flash_interval() -> List[float]:
    """A subtle ambient blip between flash words."""
    n = int(0.080 * SR)
    f = 760.0
    s = [math.sin(TWO_PI * f * i / SR) for i in range(n)]
    env = _adsr(n, 0.003, 0.020, 0.0, 0.055)
    return [s[i] * env[i] * 0.35 for i in range(n)]


def sfx_flash_reveal_click() -> List[float]:
    """A precise click for reveal moments."""
    n = int(0.040 * SR)
    noise = _noise(n)
    s = _sine(1400, n)
    env = _adsr(n, 0.001, 0.012, 0.0, 0.025)
    return [(noise[i] * 0.5 + s[i] * 0.3) * env[i] for i in range(n)]


def sfx_flash_correct() -> List[float]:
    """A confident two-tone answer chime."""
    n1 = int(0.090 * SR)
    n2 = int(0.220 * SR)
    p1 = [math.sin(TWO_PI * 880 * i / SR) for i in range(n1)]
    p2 = [math.sin(TWO_PI * 1318.51 * i / SR) for i in range(n2)]
    p2b = [0.4 * math.sin(TWO_PI * 2637.02 * i / SR) for i in range(n2)]
    e1 = _adsr(n1, 0.003, 0.030, 0.0, 0.060)
    e2 = _adsr(n2, 0.005, 0.060, 0.0, 0.150)
    out = [p1[i] * e1[i] * 0.65 for i in range(n1)]
    for i in range(n2):
        out.append((p2[i] + p2b[i]) * e2[i] * 0.55)
    return out


def sfx_flash_incorrect() -> List[float]:
    """A short muted thunk."""
    n = int(0.230 * SR)
    f0 = 200.0
    freqs = _sweep(f0, 90, n, "exp")
    s = [math.sin(TWO_PI * freqs[i] * i / SR) for i in range(n)]
    sh = _pink(n)
    env = _adsr(n, 0.005, 0.080, 0.0, 0.140)
    return [(s[i] * 0.5 + sh[i] * 0.25) * env[i] for i in range(n)]


def sfx_reveal_correct() -> List[float]:
    """A longer confident resolution for the result screen."""
    n1 = int(0.120 * SR)
    n2 = int(0.180 * SR)
    n3 = int(0.420 * SR)
    p1 = [math.sin(TWO_PI * 659.25 * i / SR) for i in range(n1)]
    p2 = [math.sin(TWO_PI * 880.0 * i / SR) for i in range(n2)]
    p3 = [math.sin(TWO_PI * 1318.51 * i / SR) for i in range(n3)]
    p3b = [0.5 * math.sin(TWO_PI * 2637.02 * i / SR) for i in range(n3)]
    e1 = _adsr(n1, 0.004, 0.040, 0.0, 0.075)
    e2 = _adsr(n2, 0.004, 0.050, 0.0, 0.125)
    e3 = _adsr(n3, 0.006, 0.090, 0.0, 0.320)
    out = [p1[i] * e1[i] * 0.6 for i in range(n1)]
    for i in range(n2):
        out.append(p2[i] * e2[i] * 0.6)
    for i in range(n3):
        out.append((p3[i] + p3b[i]) * e3[i] * 0.55)
    return out


def sfx_reveal_incorrect() -> List[float]:
    """A more deliberate, empathetic fail cue."""
    n = int(0.560 * SR)
    freqs = _sweep(330, 220, n, "exp")
    s = [math.sin(TWO_PI * freqs[i] * i / SR) for i in range(n)]
    sh = _pink(n)
    env = _adsr(n, 0.020, 0.200, 0.0, 0.340)
    return [(s[i] * 0.45 + sh[i] * 0.20) * env[i] for i in range(n)]


def sfx_object_settle() -> List[float]:
    """A soft tactile 'thunk' for object-recall placement."""
    n = int(0.220 * SR)
    f0 = 160.0
    freqs = _sweep(f0, 80, n, "exp")
    s = [math.sin(TWO_PI * freqs[i] * i / SR) for i in range(n)]
    sh = _pink(n)
    env = _adsr(n, 0.003, 0.090, 0.0, 0.120)
    return [(s[i] * 0.55 + sh[i] * 0.18) * env[i] for i in range(n)]


def sfx_pattern_step() -> List[float]:
    """A clean per-step tone for pattern recall."""
    n = int(0.090 * SR)
    f = 660.0
    s = [math.sin(TWO_PI * f * i / SR) for i in range(n)]
    s2 = [0.4 * math.sin(TWO_PI * (2 * f) * i / SR) for i in range(n)]
    env = _adsr(n, 0.002, 0.030, 0.0, 0.055)
    return [(s[i] + s2[i]) * env[i] * 0.55 for i in range(n)]


def sfx_difference_switch() -> List[float]:
    """A short 'swap' cue for spot-the-difference."""
    n = int(0.180 * SR)
    f0 = 500.0
    freqs = _sweep(f0, 1000, n, "exp")
    s = [math.sin(TWO_PI * freqs[i] * i / SR) for i in range(n)]
    sh = _pink(n)
    env = _adsr(n, 0.005, 0.060, 0.0, 0.110)
    return [(s[i] * 0.5 + sh[i] * 0.2) * env[i] for i in range(n)]


def sfx_result_settle() -> List[float]:
    """A smooth result-screen 'settle' tone."""
    n = int(0.520 * SR)
    f0 = 392.0  # G4
    s = [math.sin(TWO_PI * f0 * i / SR) for i in range(n)]
    s2 = [0.4 * math.sin(TWO_PI * (2 * f0) * i / SR) for i in range(n)]
    env = _adsr(n, 0.030, 0.180, 0.0, 0.310)
    return [(s[i] + s2[i]) * env[i] * 0.5 for i in range(n)]


def sfx_mastery_up() -> List[float]:
    """A bright ascending chime for mastery progression."""
    notes = [523.25, 659.25, 880.0, 1318.51]
    out: List[float] = []
    note_dur = 0.130
    for f in notes:
        n = int(note_dur * SR)
        fundamental = [math.sin(TWO_PI * f * i / SR) for i in range(n)]
        second = [0.35 * math.sin(TWO_PI * (2 * f) * i / SR) for i in range(n)]
        env = _adsr(n, 0.004, 0.050, 0.0, 0.075)
        for i in range(n):
            out.append((fundamental[i] + second[i]) * env[i] * 0.55)
    return out


# ----------------------------------------------------------------------------
# BGM
# ----------------------------------------------------------------------------

def _build_bgm_chord_progression(loop_seconds: float, scale: List[float], chords: List[List[int]],
                                 arp: bool = True) -> List[float]:
    """Build a subtle ambient loop using soft sine + light pad + sparse arpeggio."""
    n = int(loop_seconds * SR)
    out: List[float] = [0.0] * n
    chord_dur = loop_seconds / len(chords)
    scale_size = len(scale)
    for ci, chord in enumerate(chords):
        start = int(ci * chord_dur * SR)
        end = int((ci + 1) * chord_dur * SR)
        for note in chord:
            # Normalize negative offsets by adding 12 to step up an octave
            idx = note if note >= 0 else note + 12
            if idx < 0 or idx >= scale_size:
                continue
            f = scale[idx]
            for i in range(start, end):
                if i >= n:
                    break
                t = (i - start) / SR
                env_attack = min(1.0, t / 1.5)
                env_release = max(0.0, 1.0 - (t / chord_dur))
                env = env_attack * env_release
                # Soft pad
                out[i] += 0.16 * env * math.sin(TWO_PI * f * i / SR)
                out[i] += 0.06 * env * math.sin(TWO_PI * (2 * f) * i / SR)
        if arp:
            safe_chord = [c if c >= 0 else c + 12 for c in chord]
            safe_chord = [c for c in safe_chord if 0 <= c < scale_size]
            if not safe_chord:
                continue
            arp_notes = [safe_chord[0], safe_chord[1 % len(safe_chord)],
                         safe_chord[2 % len(safe_chord)], safe_chord[1 % len(safe_chord)]]
            step = chord_dur / len(arp_notes)
            for ai, note in enumerate(arp_notes):
                f = scale[note] * 2  # Octave up
                a = start + int(ai * step * SR)
                b = a + int(step * SR)
                for i in range(a, min(b, n)):
                    t = (i - a) / SR
                    env = math.exp(-t * 8.0) * (1.0 - math.exp(-t * 80.0))
                    out[i] += 0.10 * env * math.sin(TWO_PI * f * i / SR)
    return out


def bgm_publisher() -> List[float]:
    """A neutral, brand-revealing pad loop. ~6s."""
    # Lydian-adjacent for an aspirational feel
    root = 220.0  # A3
    scale = [root * (2 ** (i / 12.0)) for i in [0, 2, 4, 6, 7, 9, 11]]
    # Chord progression in semitones from root
    chords = [[0, 2, 4, 6], [4, 6, 7, 9], [2, 4, 6, 7], [-3, 0, 2, 4]]
    return _normalize(_build_bgm_chord_progression(6.0, scale, chords, arp=True), 0.55)


def bgm_home() -> List[float]:
    """A warm, looping pad for the main menu. ~8s."""
    root = 196.0  # G3
    scale = [root * (2 ** (i / 12.0)) for i in [0, 2, 4, 5, 7, 9, 11]]
    chords = [[0, 2, 4, 7], [5, 7, 9, 0], [-2, 0, 2, 5], [3, 5, 7, 9]]
    return _normalize(_build_bgm_chord_progression(8.0, scale, chords, arp=False), 0.50)


def bgm_gameplay() -> List[float]:
    """A focused, slightly tense pad for observation. ~8s."""
    root = 174.61  # F3
    scale = [root * (2 ** (i / 12.0)) for i in [0, 2, 3, 5, 7, 8, 10]]  # Phrygian-ish
    chords = [[0, 3, 5, 7], [-2, 0, 3, 5], [3, 5, 7, 10], [-5, -2, 0, 3]]
    return _normalize(_build_bgm_chord_progression(8.0, scale, chords, arp=True), 0.45)


def bgm_results() -> List[float]:
    """A resolved, slightly bright pad for the result screen. ~6s."""
    root = 246.94  # B3
    scale = [root * (2 ** (i / 12.0)) for i in [0, 2, 4, 5, 7, 9, 11]]
    chords = [[0, 2, 4, 7], [-3, 0, 2, 4], [-5, -3, 0, 2], [-7, -5, -3, 0]]
    return _normalize(_build_bgm_chord_progression(6.0, scale, chords, arp=False), 0.50)


def bgm_tutorial() -> List[float]:
    """A gentle, encouraging pad for tutorials. ~6s."""
    root = 261.63  # C4
    scale = [root * (2 ** (i / 12.0)) for i in [0, 2, 4, 5, 7, 9, 11]]
    chords = [[0, 2, 4, 7], [4, 5, 7, 9], [2, 4, 5, 7], [0, 2, 4, 7]]
    return _normalize(_build_bgm_chord_progression(6.0, scale, chords, arp=True), 0.45)


# ----------------------------------------------------------------------------
# Driver
# ----------------------------------------------------------------------------

GENERATORS = {
    # UI
    "ui_click": sfx_ui_click,
    "ui_hover": sfx_ui_hover,
    "ui_back": sfx_ui_back,
    "ui_navigate": sfx_ui_navigate,
    "ui_success": sfx_ui_success,
    "ui_failure": sfx_ui_failure,
    "ui_unlock": sfx_ui_unlock,
    "ui_achievement": sfx_ui_achievement,
    # Gameplay
    "observation_start": sfx_observation_start,
    "flash_pulse": sfx_observation_pulse,
    "flash_pulse_short": sfx_flash_pulse,
    "conceal": sfx_conceal,
    "flash_interval": sfx_flash_interval,
    "flash_reveal_click": sfx_flash_reveal_click,
    "flash_correct": sfx_flash_correct,
    "flash_incorrect": sfx_flash_incorrect,
    "reveal_correct": sfx_reveal_correct,
    "reveal_incorrect": sfx_reveal_incorrect,
    "object_settle": sfx_object_settle,
    "pattern_step": sfx_pattern_step,
    "difference_switch": sfx_difference_switch,
    "result_settle": sfx_result_settle,
    "mastery_up": sfx_mastery_up,
    # BGM
    "bgm_publisher": bgm_publisher,
    "bgm_home": bgm_home,
    "bgm_gameplay": bgm_gameplay,
    "bgm_results": bgm_results,
    "bgm_tutorial": bgm_tutorial,
}


def _stable_hash(s: str) -> int:
    """Deterministic FNV-1a 32-bit hash so the .import path is stable across runs."""
    h = 0x811C9DC5
    for c in s:
        h ^= ord(c)
        h = (h * 0x01000193) & 0xFFFFFFFF
    return h


def _write_import(sound_name: str) -> None:
    """Write the matching .import sidecar for a generated WAV."""
    if sound_name in {"bgm_publisher", "bgm_home", "bgm_gameplay", "bgm_results", "bgm_tutorial"}:
        loop = 1
    else:
        loop = 0
    digest = f"{_stable_hash(sound_name):08x}"
    text = (
        "[remap]\n\n"
        f'importer="wav"\n'
        f'type="AudioStreamWAV"\n'
        f'uid="uid://{sound_name}"\n'
        f'path="res://.godot/imported/{sound_name}.wav-{digest}.sample"\n\n'
        "[deps]\n\n"
        f'source_file="res://assets/audio/{sound_name}.wav"\n'
        f'dest_files=[\"res://.godot/imported/{sound_name}.wav-{digest}.sample\"]\n\n'
        "[params]\n\n"
        "force/8_bit=false\n"
        "force/mono=false\n"
        "force/max_rate=false\n"
        "force/max_rate_hz=44100\n"
        "edit/trim=false\n"
        "edit/normalize=false\n"
        f"edit/loop_mode={loop}\n"
        "edit/loop_begin=0\n"
        "edit/loop_end=-1\n"
        "compress/mode=0\n"
    )
    with open(os.path.join(OUT_DIR, f"{sound_name}.wav.import"), "w") as f:
        f.write(text)


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    print(f"Generating audio into {OUT_DIR}/")
    for name, fn in GENERATORS.items():
        _to_wav(f"{name}.wav", _normalize(fn(), 0.9))
        _write_import(name)
    print(f"Done: {len(GENERATORS)} sounds + import metadata.")


if __name__ == "__main__":
    main()
