#!/usr/bin/env python3
"""Build the 83-second Two Second Witness cinematic trailer.

The script creates the deliberately altered observation frames, title cards,
procedural suspense score, narration mix, and the final H.264 trailer.

Dependencies:
    python3 -m pip install pillow numpy imageio-ffmpeg

Run from the repository root:
    python3 trailer/build_trailer.py
"""

from __future__ import annotations

import math
import os
from pathlib import Path
import shutil
import subprocess
import sys
import wave

try:
    import numpy as np
    from PIL import Image, ImageDraw, ImageFilter, ImageFont
except ImportError as exc:  # pragma: no cover - build environment guidance
    raise SystemExit(
        "Missing build dependencies. Run: "
        "python3 -m pip install pillow numpy imageio-ffmpeg"
    ) from exc

ROOT = Path(__file__).resolve().parent
ASSETS = ROOT / "assets"
AUDIO = ROOT / "audio"
GENERATED = ROOT / "generated"
CLIPS = ROOT / ".render" / "clips"
OUTPUT = ROOT / "two_second_witness_trailer.mp4"
WIDTH, HEIGHT, FPS = 1920, 1080, 24
DURATION = 83.0
PURPLE = (124, 92, 255)
WHITE = (237, 238, 242)
MUTED = (150, 154, 165)
FONT = Path("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")
FONT_BOLD = Path("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf")


def ffmpeg_executable() -> str:
    """Locate system ffmpeg, falling back to imageio-ffmpeg's static build."""
    binary = shutil.which("ffmpeg")
    if binary:
        return binary
    try:
        import imageio_ffmpeg
    except ImportError as exc:
        raise SystemExit(
            "ffmpeg was not found. Install imageio-ffmpeg with: "
            "python3 -m pip install imageio-ffmpeg"
        ) from exc
    return imageio_ffmpeg.get_ffmpeg_exe()


def run(command: list[str]) -> None:
    print("+", " ".join(command))
    subprocess.run(command, check=True)


def feathered_polygon(size: tuple[int, int], points: list[tuple[int, int]], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).polygon(points, fill=255)
    return mask.filter(ImageFilter.GaussianBlur(radius))


def generate_changed_frames() -> None:
    """Create changes that reward a second look without feeling artificial."""
    GENERATED.mkdir(parents=True, exist_ok=True)

    # The child's rust-red scarf becomes cool blue inside the printed photo.
    photo = Image.open(ASSETS / "05_photo_base.png").convert("RGB")
    arr = np.asarray(photo).astype(np.float32)
    yy, xx = np.mgrid[0 : arr.shape[0], 0 : arr.shape[1]]
    spatial = ((xx - 872) / 78) ** 2 + ((yy - 580) / 145) ** 2 < 1.0
    red = (arr[..., 0] > arr[..., 1] * 1.08) & (arr[..., 0] > arr[..., 2] * 1.12)
    selection = spatial & red
    luma = arr[..., 0] * 0.30 + arr[..., 1] * 0.59 + arr[..., 2] * 0.11
    recolor = np.stack((luma * 0.53, luma * 0.73, luma * 0.92), axis=-1)
    # Soft edge makes the recolor inherit the original print grain.
    raw_mask = Image.fromarray((selection * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(2.2))
    photo_changed = Image.composite(
        Image.fromarray(np.clip(recolor, 0, 255).astype(np.uint8)),
        photo,
        raw_mask,
    )
    photo_changed.save(GENERATED / "06_photo_changed.png", optimize=True)

    # Move the ceramic knight from the left side of the table to the right.
    room = Image.open(ASSETS / "07_room_object_base.png").convert("RGB")
    room_arr = np.asarray(room).astype(np.float32)
    source_points = [(340, 645), (380, 618), (430, 644), (455, 730), (448, 800), (326, 800), (325, 710)]
    object_mask = feathered_polygon(room.size, source_points, 5)
    # Refine the hand mask with luminance so the sofa/table are not carried over.
    luminance = room_arr[..., 0] * 0.30 + room_arr[..., 1] * 0.59 + room_arr[..., 2] * 0.11
    tonal = np.clip((luminance - 56.0) * 7.0, 0, 255).astype(np.uint8)
    object_mask = Image.fromarray(
        np.minimum(np.asarray(object_mask), tonal).astype(np.uint8)
    ).filter(ImageFilter.GaussianBlur(1.3))

    # Reconstruct the now-empty source region by interpolating its left/right context.
    cleaned = room_arr.copy()
    x0, x1, y0, y1 = 316, 465, 610, 813
    left = room_arr[y0:y1, x0 - 8 : x0 - 7]
    right = room_arr[y0:y1, x1 + 8 : x1 + 9]
    blend = np.linspace(0.0, 1.0, x1 - x0, dtype=np.float32)[None, :, None]
    fill = left * (1.0 - blend) + right * blend
    # Borrow nearby fine texture so the reconstruction does not become sterile.
    texture = room_arr[y0:y1, 486 : 486 + (x1 - x0)]
    fill = fill * 0.78 + texture * 0.22
    cleaned[y0:y1, x0:x1] = fill
    cleaned_image = Image.fromarray(np.clip(cleaned, 0, 255).astype(np.uint8))
    source_cover = feathered_polygon(room.size, source_points, 13)
    moved = Image.composite(cleaned_image, room, source_cover)

    source_rgba = room.convert("RGBA")
    source_rgba.putalpha(object_mask)
    crop_box = (310, 606, 470, 818)
    knight = source_rgba.crop(crop_box)
    moved = moved.convert("RGBA")
    moved.alpha_composite(knight, dest=(1110, 606))
    moved.convert("RGB").save(GENERATED / "08_room_object_changed.png", optimize=True)

    # A neutral mouth turns into a nearly imperceptible half-smile.
    face = Image.open(ASSETS / "09_face_base.png").convert("RGB")
    face_arr = np.asarray(face).copy()
    x0, x1, y0, y1 = 755, 914, 376, 463
    patch = face_arr[y0:y1, x0:x1].astype(np.float32)
    h, w = patch.shape[:2]
    warped = patch.copy()
    source_y = np.arange(h, dtype=np.float32)
    for x in range(w):
        # Lift the two mouth corners, leaving the philtrum and chin anchored.
        edge = abs((x / (w - 1)) - 0.5) * 2.0
        x_focus = max(0.0, (edge - 0.42) / 0.58)
        for channel in range(3):
            shift = -5.2 * x_focus
            sampled = np.interp(source_y + shift, source_y, patch[:, x, channel])
            warped[:, x, channel] = sampled
    local_mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(local_mask).ellipse((6, 9, w - 7, h - 6), fill=205)
    local_mask = local_mask.filter(ImageFilter.GaussianBlur(16))
    face_patch = Image.composite(
        Image.fromarray(np.clip(warped, 0, 255).astype(np.uint8)),
        Image.fromarray(patch.astype(np.uint8)),
        local_mask,
    )
    face_changed = face.copy()
    face_changed.paste(face_patch, (x0, y0))
    face_changed.save(GENERATED / "10_face_changed.png", optimize=True)

    # The fourth file silently acquires the first witness's portrait.
    documents = Image.open(ASSETS / "11_documents_base.png").convert("RGB")
    first_portrait = documents.crop((333, 267, 427, 372)).resize((94, 105), Image.Resampling.LANCZOS)
    portrait_mask = Image.new("L", first_portrait.size, 255).filter(ImageFilter.GaussianBlur(1.2))
    documents_changed = documents.copy()
    documents_changed.paste(first_portrait, (1483, 266), portrait_mask)
    documents_changed.save(GENERATED / "12_documents_changed.png", optimize=True)

    # The final room is the opening room—but the brass key has disappeared.
    quiet = Image.open(ASSETS / "01_quiet_room.png").convert("RGB")
    quiet_arr = np.asarray(quiet).astype(np.float32)
    changed_arr = quiet_arr.copy()
    x0, x1, y0, y1 = 1118, 1254, 616, 693
    left = quiet_arr[y0:y1, x0 - 9 : x0 - 8]
    right = quiet_arr[y0:y1, x1 + 9 : x1 + 10]
    blend = np.linspace(0.0, 1.0, x1 - x0, dtype=np.float32)[None, :, None]
    fill = left * (1.0 - blend) + right * blend
    texture = quiet_arr[y0:y1, 969 : 969 + (x1 - x0)]
    fill = fill * 0.86 + texture * 0.14
    changed_arr[y0:y1, x0:x1] = fill
    reconstructed = Image.fromarray(np.clip(changed_arr, 0, 255).astype(np.uint8))
    key_mask = feathered_polygon(
        quiet.size,
        [(1112, 628), (1148, 613), (1227, 617), (1260, 649), (1243, 685), (1134, 686)],
        12,
    )
    quiet_changed = Image.composite(reconstructed, quiet, key_mask)
    quiet_changed.save(GENERATED / "18_quiet_room_changed.png", optimize=True)

    # Memory and reality overlap by only a few pixels—a visual doubt, not an effect shot.
    base = Image.open(ASSETS / "07_room_object_base.png").convert("RGB")
    altered = Image.open(GENERATED / "08_room_object_changed.png").convert("RGB")
    ghost = Image.blend(base, altered.transform(altered.size, Image.Transform.AFFINE, (1, 0, -13, 0, 1, 0)), 0.48)
    overlay = Image.new("RGBA", ghost.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    draw.line((ghost.width // 2, 110, ghost.width // 2, ghost.height - 110), fill=(124, 92, 255, 105), width=2)
    draw.ellipse((ghost.width // 2 - 8, ghost.height // 2 - 8, ghost.width // 2 + 8, ghost.height // 2 + 8), outline=(237, 238, 242, 120), width=2)
    composite = Image.alpha_composite(ghost.convert("RGBA"), overlay).convert("RGB")
    composite.save(GENERATED / "16_memory_reality.png", optimize=True)


def letterspaced(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, center_x: float, y: float,
                  spacing: int, fill: tuple[int, int, int], anchor_y: str = "top") -> None:
    widths = [draw.textlength(char, font=font) for char in text]
    width = sum(widths) + spacing * max(0, len(text) - 1)
    x = center_x - width / 2
    for char, char_width in zip(text, widths):
        draw.text((x, y), char, font=font, fill=fill, anchor="la" if anchor_y == "middle" else None)
        x += char_width + spacing


def card_background() -> Image.Image:
    yy, xx = np.mgrid[0:HEIGHT, 0:WIDTH]
    radial = np.sqrt(((xx - WIDTH * 0.5) / WIDTH) ** 2 + ((yy - HEIGHT * 0.48) / HEIGHT) ** 2)
    glow = np.clip(1.0 - radial * 2.0, 0, 1)
    base = np.zeros((HEIGHT, WIDTH, 3), dtype=np.float32)
    base[..., 0] = 5 + glow * 8
    base[..., 1] = 7 + glow * 7
    base[..., 2] = 12 + glow * 17
    # Fine texture keeps the black title cards alive on a large display.
    rng = np.random.default_rng(22)
    noise = rng.normal(0, 0.85, (HEIGHT, WIDTH, 1))
    base += noise
    return Image.fromarray(np.clip(base, 0, 255).astype(np.uint8), "RGB")


def make_text_card(filename: str, headline: str, subhead: str = "", accent: bool = False) -> None:
    image = card_background()
    draw = ImageDraw.Draw(image, "RGBA")
    font = ImageFont.truetype(str(FONT), 54 if not accent else 44)
    letterspaced(draw, headline.upper(), font, WIDTH / 2, HEIGHT / 2 - 48, 14 if not accent else 12, WHITE)
    if subhead:
        sub = ImageFont.truetype(str(FONT), 24)
        letterspaced(draw, subhead.upper(), sub, WIDTH / 2, HEIGHT / 2 + 48, 7, MUTED)
    draw.line((WIDTH / 2 - 34, HEIGHT / 2 - 86, WIDTH / 2 + 34, HEIGHT / 2 - 86), fill=PURPLE + (220,), width=2)
    image.save(GENERATED / filename, optimize=True)


def make_title_card(filename: str, compact: bool = False) -> None:
    image = card_background()
    draw = ImageDraw.Draw(image, "RGBA")
    cx, cy = WIDTH / 2, HEIGHT / 2 - (25 if compact else 0)

    # Observation aperture: fragmented elliptical rings, never a literal horror eye.
    for offset, alpha, width in [(0, 150, 2), (25, 70, 2), (52, 35, 1)]:
        box = (cx - 270 - offset, cy - 103 - offset * 0.24, cx + 270 + offset, cy + 103 + offset * 0.24)
        draw.arc(box, 188, 348, fill=PURPLE + (alpha,), width=width)
        draw.arc(box, 8, 168, fill=PURPLE + (alpha,), width=width)
    draw.ellipse((cx - 8, cy - 8, cx + 8, cy + 8), fill=PURPLE + (230,))
    draw.line((cx - 94, cy, cx - 22, cy), fill=WHITE + (90,), width=1)
    draw.line((cx + 22, cy, cx + 94, cy), fill=WHITE + (90,), width=1)

    title_font = ImageFont.truetype(str(FONT_BOLD), 66 if not compact else 48)
    title_y = cy + 160
    letterspaced(draw, "TWO SECOND WITNESS", title_font, cx, title_y, 10 if not compact else 7, WHITE)
    subtitle = ImageFont.truetype(str(FONT), 23 if not compact else 19)
    letterspaced(draw, "HOW MUCH CAN YOU NOTICE IN TWO SECONDS?", subtitle, cx, title_y + (103 if not compact else 78), 4, MUTED)
    image.save(GENERATED / filename, optimize=True)


def generate_cards() -> None:
    make_text_card("15_two_seconds.png", "TWO SECONDS.", "THEN THE SCENE IS GONE", accent=True)
    make_title_card("17_title.png")
    make_text_card("19_observe.png", "OBSERVE.")
    make_text_card("20_remember.png", "REMEMBER.")
    make_text_card("21_discover.png", "DISCOVER WHAT CHANGED.")
    make_title_card("22_final_title.png", compact=True)


def read_wav_mono(path: Path, target_rate: int) -> np.ndarray:
    with wave.open(str(path), "rb") as source:
        channels = source.getnchannels()
        width = source.getsampwidth()
        rate = source.getframerate()
        frames = source.readframes(source.getnframes())
    if width != 2:
        raise ValueError(f"Expected 16-bit narration WAV: {path}")
    samples = np.frombuffer(frames, dtype="<i2").astype(np.float32) / 32768.0
    if channels > 1:
        samples = samples.reshape(-1, channels).mean(axis=1)
    if rate != target_rate:
        old_x = np.arange(len(samples), dtype=np.float64) / rate
        new_x = np.arange(int(len(samples) * target_rate / rate), dtype=np.float64) / target_rate
        samples = np.interp(new_x, old_x, samples).astype(np.float32)
    return samples


def write_wav_stereo(path: Path, samples: np.ndarray, rate: int = 48000) -> None:
    pcm = np.clip(samples, -1.0, 1.0)
    pcm = (pcm * 32767).astype("<i2")
    with wave.open(str(path), "wb") as output:
        output.setnchannels(2)
        output.setsampwidth(2)
        output.setframerate(rate)
        output.writeframes(pcm.tobytes())


def generate_audio() -> None:
    """Synthesize a restrained score and mix the supplied investigative narration."""
    AUDIO.mkdir(parents=True, exist_ok=True)
    rate = 48000
    count = int(DURATION * rate)
    t = np.arange(count, dtype=np.float64) / rate
    rng = np.random.default_rng(2026)

    # Low, slowly breathing harmonic bed.
    breathe = 0.62 + 0.38 * np.sin(2 * np.pi * 0.038 * t - 0.8)
    score = 0.040 * np.sin(2 * np.pi * (43.0 + 0.15 * np.sin(2 * np.pi * 0.03 * t)) * t)
    score += 0.020 * np.sin(2 * np.pi * 64.5 * t + 0.5) * breathe
    score += 0.010 * np.sin(2 * np.pi * 86.0 * t + 1.1)

    # Air/room tone, efficiently low-passed without scipy.
    def moving_average(values: np.ndarray, window: int) -> np.ndarray:
        padded = np.pad(values, (window // 2, window - 1 - window // 2), mode="edge")
        cumulative = np.cumsum(np.insert(padded.astype(np.float64), 0, 0.0))
        return ((cumulative[window:] - cumulative[:-window]) / window).astype(np.float32)

    noise = rng.normal(0, 1, count).astype(np.float32)
    air = moving_average(noise, 900)
    air /= max(1e-6, np.max(np.abs(air)))
    score += air * 0.021

    def tone(at: float, frequency: float, length: float, amplitude: float, attack: float = 0.02) -> None:
        start = int(at * rate)
        n = min(int(length * rate), count - start)
        if n <= 0:
            return
        local = np.arange(n, dtype=np.float64) / rate
        envelope = (1.0 - np.exp(-local / max(attack, 1e-4))) * np.exp(-local / max(length * 0.31, 1e-4))
        score[start : start + n] += amplitude * envelope * np.sin(2 * np.pi * frequency * local)

    def boom(at: float, amplitude: float = 0.13) -> None:
        start = int(at * rate)
        n = min(int(2.8 * rate), count - start)
        local = np.arange(n, dtype=np.float64) / rate
        frequency = 54 - 23 * (local / max(local[-1], 1e-6))
        phase = 2 * np.pi * np.cumsum(frequency) / rate
        envelope = np.exp(-local * 1.65)
        score[start : start + n] += amplitude * envelope * np.sin(phase)

    for at in [7, 11, 16, 20, 28.4, 32.7, 37, 46, 50, 54]:
        tone(at, 278.0, 1.8, 0.019)
    for at in [22.5, 26.7, 31.0, 35.4, 71.0]:
        tone(at, 1190.0, 0.16, 0.050, attack=0.002)
    for at in [0.5, 29.2, 39.4, 58.0, 71.0, 80.0]:
        boom(at)
    # Clinical two-second ticks as the central mechanic is introduced.
    for at in np.arange(39.5, 50.1, 2.0):
        tone(float(at), 1760.0, 0.10, 0.046, attack=0.001)
        tone(float(at) + 0.05, 880.0, 0.20, 0.028, attack=0.001)
    # Rapid observation flashes.
    for at in [42.5, 42.9, 43.3, 43.7]:
        tone(at, 2430.0, 0.09, 0.038, attack=0.001)

    # Let the final observation breathe before the answer cards.
    score *= np.where((t >= 66) & (t < 73), 0.66, 1.0)
    left = score * (0.98 + 0.02 * np.sin(2 * np.pi * 0.09 * t))
    right = score * (0.98 + 0.02 * np.sin(2 * np.pi * 0.09 * t + 1.8))
    mix = np.stack((left, right), axis=1).astype(np.float32)

    narration_positions = [
        (3.0, AUDIO / "narration_01.wav"),
        (11.1, AUDIO / "narration_02.wav"),
        (29.25, AUDIO / "narration_03.wav"),
    ]
    narration_bus = np.zeros(count, dtype=np.float32)
    for at, path in narration_positions:
        voice = read_wav_mono(path, rate)
        # Gentle fades remove hard digital edges from generated speech clips.
        fade = min(int(0.08 * rate), len(voice) // 2)
        if fade:
            voice[:fade] *= np.linspace(0, 1, fade, dtype=np.float32)
            voice[-fade:] *= np.linspace(1, 0, fade, dtype=np.float32)
        start = int(at * rate)
        narration_bus[start : start + len(voice)] += voice * 0.86

    # Duck the score under narration using a smoothed voice envelope.
    voice_env = moving_average(np.abs(narration_bus), int(0.08 * rate))
    duck = 1.0 - 0.56 * np.clip(voice_env / 0.07, 0, 1)
    mix *= duck[:, None]
    mix += narration_bus[:, None]

    # Quiet mastering: preserve dynamics, catch only the tallest transients.
    mix = np.tanh(mix * 1.15) / 1.15
    peak = np.max(np.abs(mix))
    if peak > 0.94:
        mix *= 0.94 / peak
    write_wav_stereo(GENERATED / "trailer_mix.wav", mix, rate)


# image, seconds, movement, fade-in, fade-out
TIMELINE: list[tuple[str | None, float, str, float, float]] = [
    (None, 2.0, "static", 0.0, 0.0),
    ("01_quiet_room.png", 5.0, "push", 0.9, 0.35),
    ("02_hallway.png", 4.0, "push", 0.35, 0.35),
    ("03_desk_documents.png", 5.0, "drift_right", 0.35, 0.35),
    ("04_observer.png", 4.0, "push", 0.35, 0.35),
    ("05_photo_base.png", 2.5, "push", 0.25, 0.0),
    ("06_photo_changed.png", 1.7, "push_late", 0.0, 0.25),
    ("07_room_object_base.png", 2.5, "static", 0.25, 0.0),
    ("08_room_object_changed.png", 1.7, "static", 0.0, 0.25),
    ("09_face_base.png", 2.6, "push", 0.25, 0.0),
    ("10_face_changed.png", 1.7, "push_late", 0.0, 0.25),
    ("11_documents_base.png", 2.7, "drift_left", 0.25, 0.0),
    ("12_documents_changed.png", 1.6, "drift_late", 0.0, 0.3),
    ("15_two_seconds.png", 2.5, "push", 0.45, 0.35),
    ("13_eye_closeup.png", 3.0, "push", 0.25, 0.15),
    ("02_hallway.png", 0.4, "static", 0.02, 0.04),
    ("05_photo_base.png", 0.4, "static", 0.02, 0.04),
    ("11_documents_base.png", 0.4, "static", 0.02, 0.04),
    ("10_face_changed.png", 0.4, "static", 0.02, 0.04),
    ("13_eye_closeup.png", 1.9, "push_late", 0.08, 0.25),
    ("14_notes.png", 4.0, "drift_right", 0.3, 0.3),
    ("04_observer.png", 4.0, "drift_left", 0.3, 0.3),
    ("16_memory_reality.png", 4.0, "push", 0.3, 0.45),
    ("17_title.png", 6.5, "push", 0.8, 0.8),
    (None, 1.5, "static", 0.0, 0.0),
    ("01_quiet_room.png", 5.0, "static", 0.8, 0.0),
    ("18_quiet_room_changed.png", 2.0, "static", 0.0, 0.55),
    ("19_observe.png", 2.0, "push", 0.35, 0.3),
    ("20_remember.png", 2.0, "push", 0.3, 0.3),
    ("21_discover.png", 3.0, "push", 0.3, 0.3),
    ("22_final_title.png", 3.0, "push", 0.35, 0.8),
]


def resolve_image(name: str) -> Path:
    generated = GENERATED / name
    return generated if generated.exists() else ASSETS / name


def zoompan_filter(seconds: float, movement: str, fade_in: float, fade_out: float) -> str:
    frames = max(1, round(seconds * FPS))
    # Starting zoom varies so altered pairs can preserve continuous framing.
    if movement == "push":
        z = f"1+0.055*on/{max(1, frames - 1)}"
        x = "iw/2-(iw/zoom/2)"
    elif movement == "push_late":
        z = f"1.055+0.035*on/{max(1, frames - 1)}"
        x = "iw/2-(iw/zoom/2)"
    elif movement == "drift_right":
        z = "1.075"
        x = f"(iw-iw/zoom)*on/{max(1, frames - 1)}"
    elif movement == "drift_left":
        z = "1.075"
        x = f"(iw-iw/zoom)*(1-on/{max(1, frames - 1)})"
    elif movement == "drift_late":
        z = "1.075"
        x = f"(iw-iw/zoom)*(0.35-0.35*on/{max(1, frames - 1)})"
    else:
        z = "1.0"
        x = "0"
    y = "ih/2-(ih/zoom/2)" if movement != "static" else "0"
    filters = [
        f"zoompan=z='{z}':x='{x}':y='{y}':d={frames}:s={WIDTH}x{HEIGHT}:fps={FPS}",
        f"trim=duration={seconds:.3f}",
        "setpts=PTS-STARTPTS",
        "format=yuv420p",
    ]
    if fade_in > 0:
        filters.append(f"fade=t=in:st=0:d={min(fade_in, seconds / 2):.3f}")
    if fade_out > 0:
        start = max(0.0, seconds - fade_out)
        filters.append(f"fade=t=out:st={start:.3f}:d={fade_out:.3f}")
    return ",".join(filters)


def render_video() -> None:
    CLIPS.mkdir(parents=True, exist_ok=True)
    ffmpeg = ffmpeg_executable()
    clip_paths: list[Path] = []
    total = sum(item[1] for item in TIMELINE)
    if not math.isclose(total, DURATION, abs_tol=0.001):
        raise RuntimeError(f"Timeline is {total:.3f}s, expected {DURATION:.3f}s")

    for index, (name, seconds, movement, fade_in, fade_out) in enumerate(TIMELINE):
        output = CLIPS / f"{index:02d}.mp4"
        clip_paths.append(output)
        if output.exists() and output.stat().st_mtime > Path(__file__).stat().st_mtime:
            continue
        if name is None:
            command = [
                ffmpeg, "-y", "-f", "lavfi", "-i",
                f"color=c=0x020307:s={WIDTH}x{HEIGHT}:r={FPS}:d={seconds}",
                "-an", "-c:v", "libx264", "-preset", "medium", "-crf", "20",
                "-pix_fmt", "yuv420p", "-r", str(FPS), str(output),
            ]
        else:
            image = resolve_image(name)
            command = [
                ffmpeg, "-y", "-i", str(image),
                "-vf", zoompan_filter(seconds, movement, fade_in, fade_out),
                "-an", "-c:v", "libx264", "-preset", "medium", "-crf", "20",
                "-tune", "film", "-pix_fmt", "yuv420p", "-r", str(FPS), str(output),
            ]
        run(command)

    concat_file = CLIPS.parent / "concat.txt"
    concat_file.write_text("".join(f"file '{path.resolve()}'\n" for path in clip_paths))
    silent_video = CLIPS.parent / "silent.mp4"
    run([
        ffmpeg, "-y", "-f", "concat", "-safe", "0", "-i", str(concat_file),
        "-c", "copy", str(silent_video),
    ])
    run([
        ffmpeg, "-y", "-i", str(silent_video), "-i", str(GENERATED / "trailer_mix.wav"),
        "-map", "0:v:0", "-map", "1:a:0", "-c:v", "copy", "-c:a", "aac", "-b:a", "256k",
        "-shortest", "-movflags", "+faststart",
        "-metadata", "title=Two Second Witness — Official Cinematic Trailer",
        "-metadata", "artist=ITTYBITTYBITES",
        "-metadata", "comment=Observe. Remember. Discover what changed.",
        str(OUTPUT),
    ])


def main() -> None:
    print("Preparing altered observation frames...")
    generate_changed_frames()
    print("Designing title cards...")
    generate_cards()
    print("Building score and narration mix...")
    generate_audio()
    print("Rendering cinematic trailer...")
    render_video()
    size_mb = OUTPUT.stat().st_size / 1024 / 1024
    print(f"Created {OUTPUT} ({DURATION:.0f}s, {size_mb:.1f} MB)")


if __name__ == "__main__":
    main()
