#!/usr/bin/env python3
"""Build the 45-second Two Second Witness cinematic reveal trailer.

The pipeline is deterministic and configuration-driven. It prepares five hero
plates, creates changed versions, estimates depth, separates foreground and
background, animates 2.5D camera moves and environmental layers, renders the
actual two-second game mechanic, builds a procedural soundscape, mixes the
provided narration, burns accessible captions, normalizes loudness, and exports
an H.264/AAC web master.

Use the repository-level entry point:
    python trailer.py
"""

from __future__ import annotations

import argparse
import json
import math
import re
import shutil
import subprocess
import sys
import wave
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Iterable

try:
    import imageio_ffmpeg
    import numpy as np
    from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps
    import qrcode
    import yaml
except ImportError as exc:  # pragma: no cover - handled by trailer.py bootstrap
    raise SystemExit(
        "Trailer dependencies are missing. Run `python trailer.py`; the root "
        "launcher installs the isolated render environment automatically."
    ) from exc


ROOT = Path(__file__).resolve().parent
REPO = ROOT.parent
CONFIG_PATH = ROOT / "trailer.yaml"
BUILD = ROOT / ".build_v3"
PLATES = BUILD / "plates"
DEPTH = BUILD / "depth"
LAYERS = BUILD / "layers"
EFFECTS = BUILD / "effects"
CLIPS = BUILD / "clips"
AUDIO_BUILD = BUILD / "audio"
OUTPUT = ROOT / "two_second_witness_trailer.mp4"
SRT = ROOT / "two_second_witness_trailer.srt"
VTT = ROOT / "two_second_witness_trailer.vtt"
ASS = BUILD / "two_second_witness_trailer.ass"
POSTER = ROOT / "poster.jpg"

with CONFIG_PATH.open("r", encoding="utf-8") as stream:
    CONFIG = yaml.safe_load(stream)

PROJECT = CONFIG["project"]
LOOK = CONFIG["look"]
WIDTH = int(PROJECT["width"])
HEIGHT = int(PROJECT["height"])
FPS = int(PROJECT["fps"])
DURATION = float(PROJECT["runtime_seconds"])
TOTAL_FRAMES = round(DURATION * FPS)
ACCENT = tuple(int(v) for v in LOOK["accent"])
WHITE = (239, 240, 244)
MUTED = (154, 160, 173)
DARK = (4, 6, 11)
FORCE = False
SESSION_EFFECTS: set[str] = set()


@dataclass(frozen=True)
class Shot:
    index: int
    name: str
    frames: int

    @property
    def duration(self) -> float:
        return self.frames / FPS

    @property
    def path(self) -> Path:
        return CLIPS / f"{self.index:02d}_{self.name}.mp4"


# Every duration is frame-accurate. The sum is exactly 1,080 frames / 45 seconds.
# Act I uses seven shorter, internally animated shots; Act III preserves the
# two-second test while completing select -> confirm -> advance before one end card.
SHOTS = [
    Shot(0, "quiet_room", 72),          # 00:00.000 — 00:03.000
    Shot(1, "key_insert", 36),          # 00:03.000 — 00:04.500
    Shot(2, "hallway", 48),             # 00:04.500 — 00:06.500
    Shot(3, "evidence_desk", 60),       # 00:06.500 — 00:09.000
    Shot(4, "investigator", 60),        # 00:09.000 — 00:11.500
    Shot(5, "photo_hand", 36),          # 00:11.500 — 00:13.000
    Shot(6, "photo_observe", 48),       # 00:13.000 — 00:15.000
    Shot(7, "photo_change", 56),        # 00:15.000 — 00:17.333
    Shot(8, "object_change", 53),       # 00:17.333 — 00:19.542
    Shot(9, "expression_change", 53),   # 00:19.542 — 00:21.750
    Shot(10, "files_change", 50),       # 00:21.750 — 00:23.833
    Shot(11, "gameplay_montage", 76),   # 00:23.833 — 00:27.000
    Shot(12, "eye", 34),                # 00:27.000 — 00:28.417
    Shot(13, "notebook", 38),           # 00:28.417 — 00:30.000
    Shot(14, "countdown", 48),          # 00:30.000 — 00:32.000
    Shot(15, "blackout", 16),           # 00:32.000 — 00:32.667
    Shot(16, "search", 34),             # 00:32.667 — 00:34.083
    Shot(17, "selection", 36),          # 00:34.083 — 00:35.583
    Shot(18, "confirmation", 32),       # 00:35.583 — 00:36.917
    Shot(19, "advance", 62),            # 00:36.917 — 00:39.500
    Shot(20, "final_card", 132),        # 00:39.500 — 00:45.000
]

if sum(shot.frames for shot in SHOTS) != TOTAL_FRAMES:
    raise RuntimeError("The authored shot list must equal exactly 45 seconds.")


def find_font(bold: bool = False) -> Path:
    candidates = [
        Path("C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf"),
        Path("C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf"),
        Path("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"),
        Path("/usr/share/fonts/truetype/liberation2/LiberationSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/liberation2/LiberationSans-Regular.ttf"),
        Path("/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate
    raise FileNotFoundError("No supported sans-serif font was found.")


FONT = find_font(False)
FONT_BOLD = find_font(True)


def ffmpeg() -> str:
    return shutil.which("ffmpeg") or imageio_ffmpeg.get_ffmpeg_exe()


def run(command: list[str], *, capture: bool = False, check: bool = True) -> subprocess.CompletedProcess[str]:
    printable = " ".join(command)
    print("+", printable[:500] + (" …" if len(printable) > 500 else ""))
    return subprocess.run(
        command,
        check=check,
        text=True,
        capture_output=capture,
        cwd=REPO,
    )


def ensure_directories() -> None:
    for directory in (BUILD, PLATES, DEPTH, LAYERS, EFFECTS, CLIPS, AUDIO_BUILD):
        directory.mkdir(parents=True, exist_ok=True)


def fresh(output: Path, dependencies: Iterable[Path]) -> bool:
    if FORCE or not output.exists():
        return False
    stamp = output.stat().st_mtime
    return all(not dependency.exists() or dependency.stat().st_mtime <= stamp for dependency in dependencies)


def fit_frame(image: Image.Image) -> Image.Image:
    """Fill the 16:9 canvas without distorting the source composition."""
    return ImageOps.fit(
        image.convert("RGB"),
        (WIDTH, HEIGHT),
        method=Image.Resampling.LANCZOS,
        centering=(0.5, 0.5),
    )


def cinematic_grade(image: Image.Image) -> Image.Image:
    """Apply restrained print contrast, cool shadows, warm practical highlights."""
    arr = np.asarray(image.convert("RGB"), dtype=np.float32) / 255.0
    luma = arr[..., 0] * 0.2126 + arr[..., 1] * 0.7152 + arr[..., 2] * 0.0722
    contrast = float(LOOK["contrast"])
    arr = (arr - 0.5) * contrast + 0.5

    # Saturation is intentionally restrained rather than genre-teal/orange.
    sat = float(LOOK["saturation"])
    arr = luma[..., None] + (arr - luma[..., None]) * sat
    shadows = np.clip((0.58 - luma) / 0.58, 0, 1) ** 1.7
    highlights = np.clip((luma - 0.42) / 0.58, 0, 1) ** 1.8
    arr *= 1.0 + shadows[..., None] * (np.array(LOOK["shadow_tint"], dtype=np.float32) - 1.0)
    arr *= 1.0 + highlights[..., None] * (np.array(LOOK["highlight_tint"], dtype=np.float32) - 1.0)

    yy, xx = np.mgrid[0:HEIGHT, 0:WIDTH]
    distance = ((xx - WIDTH * 0.5) / (WIDTH * 0.72)) ** 2 + ((yy - HEIGHT * 0.48) / (HEIGHT * 0.76)) ** 2
    vignette = np.clip(1.0 - np.maximum(0, distance - 0.24) * 0.13, 0.78, 1.0)
    arr *= vignette[..., None]
    return Image.fromarray(np.clip(arr * 255.0, 0, 255).astype(np.uint8), "RGB")


def prepare_changed_sources() -> None:
    """Create all five believable changes from the supplied matching plates."""
    generated = ROOT / "generated"
    expected = [
        generated / "06_photo_changed.png",
        generated / "08_room_object_changed.png",
        generated / "10_face_changed.png",
        generated / "12_documents_changed.png",
        generated / "18_quiet_room_changed.png",
    ]
    sources = [ROOT / scene["source"] for scene in CONFIG["hero_scenes"]]
    if not FORCE and all(fresh(path, [ROOT / "build_trailer.py", *sources]) for path in expected):
        print("  changed scene plates are current")
        return
    # Version 1 contains the authored, deterministic object edits; no v1 render runs.
    sys.path.insert(0, str(ROOT))
    import build_trailer as authored_changes

    authored_changes.generate_changed_frames()


def prepare_plates() -> dict[str, Path]:
    """Generate standardized cinematic plates for heroes and contextual b-roll."""
    prepared: dict[str, Path] = {}
    scene_sources: dict[str, Path] = {}
    for scene in CONFIG["hero_scenes"]:
        scene_sources[scene["id"]] = ROOT / scene["source"]
        scene_sources[f"{scene['id']}_changed"] = ROOT / scene["changed"]
    for name, relative in CONFIG["context_scenes"].items():
        scene_sources[name] = ROOT / relative

    for name, source in scene_sources.items():
        if not source.exists():
            raise FileNotFoundError(f"Configured scene is missing: {source}")
        target = PLATES / f"{name}.jpg"
        prepared[name] = target
        if fresh(target, [source, CONFIG_PATH, Path(__file__)]):
            continue
        image = cinematic_grade(fit_frame(Image.open(source)))
        image.save(target, quality=95, subsampling=0, optimize=True)

    # Two inserts are generated from the wide plates, preserving location and
    # lighting while adding editorial variety at no asset-generation cost.
    detail = PLATES / "quiet_detail.jpg"
    quiet = prepared["quiet_room"]
    prepared["quiet_detail"] = detail
    if not fresh(detail, [quiet, CONFIG_PATH, Path(__file__)]):
        wide = Image.open(quiet).convert("RGB")
        crop = wide.crop((980, 430, 1920, 959)).resize((WIDTH, HEIGHT), Image.Resampling.LANCZOS)
        crop.save(detail, quality=95, subsampling=0, optimize=True)

    photo_detail = PLATES / "photo_detail.jpg"
    photo = prepared["family_photo"]
    prepared["photo_detail"] = photo_detail
    if not fresh(photo_detail, [photo, CONFIG_PATH, Path(__file__)]):
        wide = Image.open(photo).convert("RGB")
        crop = wide.crop((500, 220, 1600, 839)).resize((WIDTH, HEIGHT), Image.Resampling.LANCZOS)
        crop.save(photo_detail, quality=95, subsampling=0, optimize=True)
    return prepared


def normalize01(array: np.ndarray) -> np.ndarray:
    low, high = np.percentile(array, (4, 96))
    return np.clip((array - low) / max(1e-6, high - low), 0, 1)


def estimate_depth(image: Image.Image) -> Image.Image:
    """Estimate a deterministic monocular pseudo-depth map with no model download.

    The estimator combines perspective (lower image regions tend to be nearer),
    local contrast/focus, chroma saliency, and a soft center prior. A production
    can replace this function with Depth Anything without changing the renderer.
    """
    work = image.resize((480, 270), Image.Resampling.LANCZOS).convert("RGB")
    arr = np.asarray(work, dtype=np.float32) / 255.0
    gray = arr[..., 0] * 0.2126 + arr[..., 1] * 0.7152 + arr[..., 2] * 0.0722
    blurred = np.asarray(work.convert("L").filter(ImageFilter.GaussianBlur(5)), dtype=np.float32) / 255.0
    focus = normalize01(np.abs(gray - blurred))
    chroma = normalize01(arr.max(axis=2) - arr.min(axis=2))
    yy, xx = np.mgrid[0:270, 0:480]
    perspective = np.clip((yy / 269.0 - 0.12) / 0.88, 0, 1) ** 0.85
    center = np.exp(-(((xx - 240) / 230) ** 2 + ((yy - 145) / 180) ** 2))
    depth = 0.45 * perspective + 0.25 * focus + 0.17 * chroma + 0.13 * center
    depth = normalize01(depth)
    result = Image.fromarray((depth * 255).astype(np.uint8), "L")
    return result.resize((WIDTH, HEIGHT), Image.Resampling.BICUBIC).filter(ImageFilter.GaussianBlur(7))


def depth_to_mask(depth: Image.Image) -> Image.Image:
    arr = np.asarray(depth, dtype=np.float32) / 255.0
    threshold = float(np.percentile(arr, 61))
    mask = np.clip((arr - threshold + 0.055) / 0.18, 0, 1)
    # Keep the extreme edges out of the near plane to avoid revealing frame seams.
    yy, xx = np.mgrid[0:HEIGHT, 0:WIDTH]
    edge = np.minimum.reduce([xx / 125.0, (WIDTH - 1 - xx) / 125.0, yy / 95.0, (HEIGHT - 1 - yy) / 95.0])
    mask *= np.clip(edge, 0, 1)
    return Image.fromarray((mask * 255).astype(np.uint8), "L").filter(ImageFilter.GaussianBlur(10))


def separate_depth_layers(plates: dict[str, Path]) -> None:
    """Estimate depth and write a clean background plus transparent near plane."""
    base_masks: dict[str, Image.Image] = {}
    for name, plate_path in plates.items():
        base_name = name.removesuffix("_changed")
        depth_path = DEPTH / f"{base_name}.png"
        mask_path = DEPTH / f"{base_name}_mask.png"
        bg_path = LAYERS / f"{name}_bg.jpg"
        fg_path = LAYERS / f"{name}_fg.png"
        outputs = [depth_path, mask_path, bg_path, fg_path]
        base_plate = PLATES / f"{base_name}.jpg"
        if base_name not in base_masks and fresh(mask_path, [base_plate, CONFIG_PATH, Path(__file__)]):
            base_masks[base_name] = Image.open(mask_path).convert("L")
        if all(fresh(path, [plate_path, CONFIG_PATH, Path(__file__)]) for path in outputs):
            continue

        plate = Image.open(plate_path).convert("RGB")
        if base_name not in base_masks:
            depth = estimate_depth(plate)
            mask = depth_to_mask(depth)
            depth.save(depth_path, optimize=True)
            mask.save(mask_path, optimize=True)
            base_masks[base_name] = mask
        else:
            mask = base_masks[base_name]
        if not mask_path.exists():
            mask.save(mask_path, optimize=True)

        # A softened reconstruction under the near plane prevents doubled edges
        # when foreground and background travel by different amounts.
        reconstructed = plate.filter(ImageFilter.GaussianBlur(22))
        background = Image.composite(reconstructed, plate, mask)
        background.save(bg_path, quality=94, subsampling=0, optimize=True)
        foreground = plate.convert("RGBA")
        foreground.putalpha(mask)
        foreground.save(fg_path, optimize=True)


def render_raw_video(path: Path, frames: int, frame_function: Callable[[int, int], Image.Image], *, size: tuple[int, int], crf: int = 18) -> None:
    if fresh(path, [CONFIG_PATH, Path(__file__)]):
        return
    width, height = size
    command = [
        ffmpeg(), "-hide_banner", "-loglevel", "error", "-y",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{width}x{height}",
        "-r", str(FPS), "-i", "-", "-an", "-c:v", "libx264",
        "-preset", "medium", "-crf", str(crf), "-profile:v", "high",
        "-pix_fmt", "yuv420p", "-r", str(FPS), "-frames:v", str(frames), str(path),
    ]
    print("+", " ".join(command[:-1]), path)
    process = subprocess.Popen(command, stdin=subprocess.PIPE, cwd=REPO)
    assert process.stdin is not None
    try:
        for frame_number in range(frames):
            frame = frame_function(frame_number, frames).convert("RGB")
            process.stdin.write(np.asarray(frame, dtype=np.uint8).tobytes())
    finally:
        process.stdin.close()
    if process.wait() != 0:
        raise RuntimeError(f"Failed to render {path}")


def render_environment_effect(kind: str) -> Path:
    """Render independent rain/dust/fog/light movement for screen compositing."""
    path = EFFECTS / f"{kind}.mp4"
    if kind in SESSION_EFFECTS:
        return path
    width, height, frames = 960, 540, 144
    seed = {"rain": 1207, "dust": 2209, "air": 3313}.get(kind, 4409)
    rng = np.random.default_rng(seed)
    count = 105 if kind == "rain" else 62
    px = rng.uniform(-100, width + 100, count)
    py = rng.uniform(-height, height, count)
    speed = rng.uniform(9, 27, count) if kind == "rain" else rng.uniform(1.2, 5.5, count)
    radius = rng.choice([1, 1, 1, 2], count)
    brightness = rng.integers(25, 78, count)

    def frame(n: int, total: int) -> Image.Image:
        image = Image.new("RGB", (width, height), "black")
        draw = ImageDraw.Draw(image)
        t = n / FPS
        if kind == "rain":
            for i in range(count):
                y = (py[i] + n * speed[i]) % (height + 100) - 50
                x = (px[i] + n * speed[i] * 0.15) % (width + 120) - 60
                length = 10 + speed[i] * 0.8
                value = int(brightness[i])
                draw.line((x, y, x + length * 0.14, y + length), fill=(value // 2, value // 2 + 5, value), width=1)
        else:
            for i in range(count):
                x = (px[i] + math.sin(t * 0.75 + i) * 12 + n * speed[i] * 0.025) % width
                y = (py[i] - n * speed[i] * 0.09) % height
                value = int(brightness[i] * (0.58 + 0.42 * math.sin(t * 1.3 + i * 1.9) ** 2))
                r = int(radius[i])
                draw.ellipse((x-r, y-r, x+r, y+r), fill=(value, value, min(110, value+10)))

        # A practical-light sweep moves independently from both depth planes.
        glow = Image.new("L", (width, height), 0)
        gx = int(width * (0.16 + 0.68 * ((n % total) / max(1, total - 1))))
        ImageDraw.Draw(glow).ellipse((gx-125, 50, gx+125, height-40), fill=22 if kind != "air" else 15)
        glow = glow.filter(ImageFilter.GaussianBlur(80))
        light = Image.new("RGB", image.size, (88, 73, 135))
        return Image.composite(light, image, glow)

    render_raw_video(path, frames, frame, size=(width, height), crf=17)
    SESSION_EFFECTS.add(kind)
    return path


def render_micro_effect(kind: str, frames: int) -> tuple[Path, str]:
    """Create inexpensive, shot-specific motion beyond camera parallax."""
    path = EFFECTS / f"micro_{kind}_{frames}.mp4"
    mode = "multiply" if kind in {"investigator_blink", "notebook_ink"} else "screen"

    def frame(n: int, total: int) -> Image.Image:
        t = n / FPS
        p = n / max(1, total - 1)
        neutral = "white" if mode == "multiply" else "black"
        image = Image.new("RGB", (960, 540), neutral)
        draw = ImageDraw.Draw(image)

        if kind == "steam":
            haze = Image.new("L", image.size, 0)
            hdraw = ImageDraw.Draw(haze)
            for index in range(3):
                phase = (p * 1.25 + index * .31) % 1.0
                x = 584 + 13 * math.sin(phase * math.tau + index)
                y = 330 - 145 * phase
                hdraw.arc((x-24, y-44, x+24, y+42), 95, 272, fill=int(88 * (1-phase)), width=5)
            haze = haze.filter(ImageFilter.GaussianBlur(7))
            image = Image.composite(Image.new("RGB", image.size, (112, 116, 126)), image, haze)
        elif kind == "hallway_reflection":
            shimmer = Image.new("L", image.size, 0)
            sdraw = ImageDraw.Draw(shimmer)
            for index, x in enumerate((438, 465, 492, 520)):
                amplitude = int(28 + 20 * math.sin(t*3.1 + index))
                sdraw.polygon([(x-4, 285), (x+5, 285), (x+15+amplitude//5, 510), (x-12-amplitude//6, 510)], fill=amplitude)
            # Fluorescent fixtures breathe locally rather than changing the whole exposure.
            for index, y in enumerate((54, 82, 108, 132)):
                value = int(16 + 12 * math.sin(t*7.3 + index*.9) ** 2)
                sdraw.rectangle((470-index*11, y, 490+index*11, y+3), fill=value)
            shimmer = shimmer.filter(ImageFilter.GaussianBlur(5))
            image = Image.composite(Image.new("RGB", image.size, (120, 132, 150)), image, shimmer)
        elif kind == "paper_lift":
            lift = 3 + int(7 * (0.5 + 0.5 * math.sin(t*3.0)))
            draw.polygon([(573, 356), (640, 344-lift), (635, 374), (582, 378)], fill=(42, 39, 51))
            draw.line((575, 355, 639, 344-lift), fill=(110, 104, 125), width=2)
        elif kind == "photo_glint":
            mask = Image.new("L", image.size, 0)
            x = int(-150 + p*1260)
            ImageDraw.Draw(mask).polygon([(x-48, 80), (x+8, 70), (x+155, 500), (x+88, 510)], fill=42)
            mask = mask.filter(ImageFilter.GaussianBlur(20))
            image = Image.composite(Image.new("RGB", image.size, (125, 116, 108)), image, mask)
        elif kind == "investigator_blink":
            # A restrained four-frame profile blink breaks the mannequin stillness.
            phase = abs(p - .57)
            closure = max(0.0, 1.0 - phase / .075)
            if closure > 0:
                width = 15
                height = max(1, int(5 * closure))
                draw.ellipse((734-width, 143-height, 734+width, 143+height), fill=(44, 43, 43))
        elif kind == "eye_saccade":
            cx = 456 + int(9 * math.sin(t*4.1))
            cy = 270 + int(3 * math.sin(t*5.7+1.0))
            draw.ellipse((cx-4, cy-4, cx+4, cy+4), fill=(105, 108, 132))
            draw.ellipse((cx-72, cy-72, cx+72, cy+72), outline=(28, 22, 56), width=2)
        elif kind == "notebook_ink":
            # New pencil marks accumulate beneath the otherwise still hand.
            progress = max(0.0, min(1.0, (p-.12)/.72))
            points = [(492, 315), (520, 306), (540, 319), (565, 300), (594, 309)]
            reveal = progress * (len(points)-1)
            for index, (start, end) in enumerate(zip(points, points[1:])):
                local = max(0.0, min(1.0, reveal-index))
                if local > 0:
                    x = start[0] + (end[0]-start[0])*local
                    y = start[1] + (end[1]-start[1])*local
                    draw.line((start[0], start[1], x, y), fill=(72, 68, 63), width=2)
        return image

    render_raw_video(path, frames, frame, size=(960, 540), crf=16)
    return path, mode


def render_transition_effect(style: str, frames: int, change_at: float) -> tuple[Path, str] | None:
    """Create a transition motivated by the photographed scene."""
    if style in {"direct", "lamp_flicker"}:
        return None
    path = EFFECTS / f"transition_{style}_{frames}_{round(change_at*1000)}.mp4"
    mode = "multiply" if style == "witness_blink" else "screen"

    def frame(n: int, total: int) -> Image.Image:
        t = n / FPS
        neutral = "white" if mode == "multiply" else "black"
        image = Image.new("RGB", (960, 540), neutral)
        local = (t-change_at)/.42 + .5
        if style in {"photo_reflection", "paper_sweep"} and -.25 < local < 1.25:
            mask = Image.new("L", image.size, 0)
            draw = ImageDraw.Draw(mask)
            if style == "photo_reflection":
                x = int(-260 + local*1480)
                draw.polygon([(x-115, 0), (x+20, 0), (x+280, 540), (x+115, 540)], fill=108)
                color = (135, 120, 105)
                radius = 25
            else:
                x = int(1180 - local*1400)
                draw.polygon([(x-35, 0), (x+100, 0), (x-80, 540), (x-220, 540)], fill=92)
                color = (122, 124, 134)
                radius = 18
            mask = mask.filter(ImageFilter.GaussianBlur(radius))
            image = Image.composite(Image.new("RGB", image.size, color), image, mask)
        elif style == "witness_blink":
            phase = abs(t-change_at)
            closure = max(0.0, 1.0-phase/.115)
            if closure > 0:
                draw = ImageDraw.Draw(image)
                height = max(1, int(7*closure))
                for cx in (418, 515):
                    draw.ellipse((cx-31, 170-height, cx+31, 170+height), fill=(60, 57, 55))
        return image

    render_raw_video(path, frames, frame, size=(960, 540), crf=16)
    return path, mode


def transform_filter(label_in: str, label_out: str, duration: float, zoom: tuple[float, float], pan: tuple[float, float], *, rgba: bool, breathe: float = 0.0) -> str:
    z = f"({zoom[0]:.6f}+({zoom[1]-zoom[0]:.6f})*t/{duration:.6f})"
    width = f"trunc({WIDTH}*{z}/2)*2"
    height = f"trunc({HEIGHT}*{z}/2)*2"
    px = f"(in_w-{WIDTH})/2+({pan[0]:.4f})*(t/{duration:.6f}-.5)"
    py = f"(in_h-{HEIGHT})/2+({pan[1]:.4f})*(t/{duration:.6f}-.5)"
    if breathe:
        py += f"+{breathe:.3f}*sin(2*PI*t/3.7)"
    fmt = ",format=rgba" if rgba else ""
    return f"[{label_in}]scale=w='{width}':h='{height}':eval=frame,crop={WIDTH}:{HEIGHT}:x='{px}':y='{py}',setsar=1{fmt}[{label_out}]"


def scene_inputs(name: str, duration: float) -> list[str]:
    return [
        "-loop", "1", "-framerate", str(FPS), "-t", f"{duration:.6f}", "-i", str(LAYERS / f"{name}_bg.jpg"),
        "-loop", "1", "-framerate", str(FPS), "-t", f"{duration:.6f}", "-i", str(LAYERS / f"{name}_fg.png"),
    ]


def encode_options(frames: int) -> list[str]:
    return [
        "-an", "-c:v", "libx264", "-preset", "medium", "-crf", "18", "-tune", "film",
        "-profile:v", "high", "-level", "4.1", "-pix_fmt", "yuv420p", "-r", str(FPS),
        "-g", str(FPS * 2), "-frames:v", str(frames),
    ]


def render_layered(shot: Shot, scene: str, *, pan: tuple[float, float], zoom: tuple[float, float] = (1.025, 1.07), atmosphere: str = "dust", fade_in: float = 0.0, fade_out: float = 0.0, overlay: Path | None = None, overlay_opacity: float = 0.75, micro: tuple[Path, str] | None = None, micro_opacity: float = 0.72) -> Path:
    dependencies = [LAYERS / f"{scene}_bg.jpg", LAYERS / f"{scene}_fg.png", CONFIG_PATH, Path(__file__)]
    effect = render_environment_effect(atmosphere)
    dependencies.append(effect)
    if overlay:
        dependencies.append(overlay)
    if micro:
        dependencies.append(micro[0])
    if fresh(shot.path, dependencies):
        return shot.path

    duration = shot.duration
    inputs = scene_inputs(scene, duration)
    inputs += ["-stream_loop", "-1", "-i", str(effect)]
    next_input = 3
    overlay_index: int | None = None
    micro_index: int | None = None
    if overlay:
        overlay_index = next_input
        inputs += ["-stream_loop", "-1", "-i", str(overlay)]
        next_input += 1
    if micro:
        micro_index = next_input
        inputs += ["-stream_loop", "-1", "-i", str(micro[0])]

    filters = [
        transform_filter("0:v", "bg", duration, zoom, pan, rgba=False),
        transform_filter("1:v", "fg", duration, (zoom[0] + 0.018, zoom[1] + 0.044), (-pan[0] * 1.35, -pan[1] * 1.25), rgba=True, breathe=1.8),
        "[bg][fg]overlay=0:0:format=auto,format=gbrp[comp]",
        f"[2:v]scale={WIDTH}:{HEIGHT},setsar=1,format=gbrp[env]",
        f"[comp][env]blend=all_mode=screen:all_opacity={'0.24' if atmosphere == 'rain' else '0.16'}[alive]",
    ]
    current = "alive"
    if overlay_index is not None:
        filters += [
            f"[{overlay_index}:v]scale={WIDTH}:{HEIGHT},setsar=1,format=gbrp[graphic]",
            f"[{current}][graphic]blend=all_mode=screen:all_opacity={overlay_opacity:.3f}[withgraphic]",
        ]
        current = "withgraphic"
    if micro_index is not None and micro is not None:
        mode = micro[1]
        filters += [
            f"[{micro_index}:v]scale={WIDTH}:{HEIGHT},setsar=1,format=gbrp[microfx]",
            f"[{current}][microfx]blend=all_mode={mode}:all_opacity={micro_opacity:.3f}[withmicro]",
        ]
        current = "withmicro"
    filters.append(f"[{current}]eq=brightness='0.0035*sin(19*t)+0.002*sin(43*t)':eval=frame:contrast=1.015:saturation=0.98,vignette=PI/5.7,noise=alls={int(LOOK['grain_strength'])}:allf=t,format=yuv420p[graded]")
    current = "graded"
    if fade_in:
        filters.append(f"[{current}]fade=t=in:st=0:d={fade_in:.4f}[fadein]")
        current = "fadein"
    if fade_out:
        filters.append(f"[{current}]fade=t=out:st={duration-fade_out:.4f}:d={fade_out:.4f}[fadeout]")
        current = "fadeout"
    filters.append(f"[{current}]trim=duration={duration:.6f},setpts=PTS-STARTPTS[out]")

    run([ffmpeg(), "-hide_banner", "-loglevel", "error", "-y", *inputs, "-filter_complex", ";".join(filters), "-map", "[out]", *encode_options(shot.frames), str(shot.path)])
    return shot.path


def render_change(shot: Shot, scene: str, *, change_at: float, pan: tuple[float, float], atmosphere: str = "dust", transition_style: str = "direct") -> Path:
    changed = f"{scene}_changed"
    motivated = render_transition_effect(transition_style, shot.frames, change_at)
    dependencies = [
        LAYERS / f"{scene}_bg.jpg", LAYERS / f"{scene}_fg.png",
        LAYERS / f"{changed}_bg.jpg", LAYERS / f"{changed}_fg.png",
        CONFIG_PATH, Path(__file__),
    ]
    effect = render_environment_effect(atmosphere)
    dependencies.append(effect)
    if motivated:
        dependencies.append(motivated[0])
    if fresh(shot.path, dependencies):
        return shot.path

    duration = shot.duration
    inputs = scene_inputs(scene, duration) + scene_inputs(changed, duration)
    inputs += ["-stream_loop", "-1", "-i", str(effect)]
    if motivated:
        inputs += ["-stream_loop", "-1", "-i", str(motivated[0])]
    filters = [
        transform_filter("0:v", "abg", duration, (1.03, 1.075), pan, rgba=False),
        transform_filter("1:v", "afg", duration, (1.05, 1.115), (-pan[0] * 1.3, -pan[1] * 1.2), rgba=True, breathe=1.5),
        "[abg][afg]overlay=0:0:format=auto[before]",
        transform_filter("2:v", "bbg", duration, (1.03, 1.075), pan, rgba=False),
        transform_filter("3:v", "bfg", duration, (1.05, 1.115), (-pan[0] * 1.3, -pan[1] * 1.2), rgba=True, breathe=1.5),
        "[bbg][bfg]overlay=0:0:format=auto[after]",
    ]
    change_duration = 0.075 if transition_style != "direct" else 0.105
    weight = f"clip((T-{change_at-change_duration/2:.5f})/{change_duration:.5f}\\,0\\,1)"
    filters += [
        f"[before][after]blend=all_expr='A*(1-{weight})+B*{weight}'[changed]",
        "[changed]format=gbrp[changedrgb]",
        f"[4:v]scale={WIDTH}:{HEIGHT},setsar=1,format=gbrp[env]",
        f"[changedrgb][env]blend=all_mode=screen:all_opacity={'0.22' if atmosphere == 'rain' else '0.15'}[alive]",
    ]
    current = "alive"
    if motivated:
        mode = motivated[1]
        filters += [
            f"[5:v]scale={WIDTH}:{HEIGHT},setsar=1,format=gbrp[motivated]",
            f"[{current}][motivated]blend=all_mode={mode}:all_opacity={'0.82' if mode == 'screen' else '0.72'}[transitioned]",
        ]
        current = "transitioned"
    if transition_style == "lamp_flicker":
        dip = f"-0.105*exp(-pow((t-{change_at:.5f})/0.085\\,2))"
        filters.append(f"[{current}]eq=brightness='{dip}':eval=frame[transitioned]")
        current = "transitioned"
    filters.append(
        f"[{current}]eq=brightness='0.003*sin(17*t)+0.002*sin(41*t)':eval=frame:contrast=1.018:saturation=.98,"
        f"vignette=PI/5.7,noise=alls={int(LOOK['grain_strength'])}:allf=t,format=yuv420p[out]"
    )
    run([ffmpeg(), "-hide_banner", "-loglevel", "error", "-y", *inputs, "-filter_complex", ";".join(filters), "-map", "[out]", *encode_options(shot.frames), str(shot.path)])
    return shot.path


def draw_letterspaced(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, center_x: float, y: float, spacing: float, fill: tuple[int, int, int]) -> None:
    widths = [draw.textlength(character, font=font) for character in text]
    full = sum(widths) + spacing * max(0, len(text) - 1)
    x = center_x - full / 2
    for character, width in zip(text, widths):
        draw.text((x, y), character, font=font, fill=fill)
        x += width + spacing


def render_countdown_overlay() -> Path:
    path = EFFECTS / "countdown.mp4"
    font = ImageFont.truetype(str(FONT), 56)
    small = ImageFont.truetype(str(FONT_BOLD), 14)

    def frame(n: int, total: int) -> Image.Image:
        image = Image.new("RGB", (960, 540), "black")
        draw = ImageDraw.Draw(image)
        p = n / max(1, total - 1)
        value = max(0.0, 2.0 * (1.0 - p))
        cx, cy, radius = 480, 104, 67
        end = -90 + 360 * value / 2.0
        draw.arc((cx-radius, cy-radius, cx+radius, cy+radius), -90, end, fill=ACCENT, width=3)
        draw.arc((cx-radius, cy-radius, cx+radius, cy+radius), end, 270, fill=(40, 42, 52), width=2)
        text = f"{value:0.2f}"
        box = draw.textbbox((0, 0), text, font=font)
        draw.text((cx-(box[2]-box[0])/2, cy-34), text, font=font, fill=WHITE)
        label = "OBSERVE"
        box = draw.textbbox((0, 0), label, font=small)
        draw.text((cx-(box[2]-box[0])/2, cy+82), label, font=small, fill=MUTED)
        # Subtle corner brackets make this read as game UI, not a title card.
        for x, y, sx, sy in ((34,35,1,1),(926,35,-1,1),(34,505,1,-1),(926,505,-1,-1)):
            draw.line((x, y, x+22*sx, y), fill=(56, 53, 88), width=1)
            draw.line((x, y, x, y+22*sy), fill=(56, 53, 88), width=1)
        return image

    render_raw_video(path, 48, frame, size=(960, 540), crf=16)
    return path


def render_answer_overlay() -> Path:
    path = EFFECTS / "answer.mp4"
    font = ImageFont.truetype(str(FONT_BOLD), 17)
    # Key location is mapped from the matching 1,672×941 source frame.
    cx, cy = int(1186 / 1672 * 960), int(653 / 941 * 540)

    def frame(n: int, total: int) -> Image.Image:
        image = Image.new("RGB", (960, 540), "black")
        draw = ImageDraw.Draw(image)
        p = n / max(1, total - 1)
        reveal = max(0.0, min(1.0, p / 0.30))
        pulse = 1.0 + 0.055 * math.sin(n / FPS * math.tau * 1.6)
        radius = int((14 + 29 * reveal) * pulse)
        color = tuple(int(channel * (0.55 + 0.45 * reveal)) for channel in ACCENT)
        draw.ellipse((cx-radius, cy-radius, cx+radius, cy+radius), outline=color, width=3)
        draw.ellipse((cx-4, cy-4, cx+4, cy+4), outline=WHITE, width=1)
        if p > 0.22:
            alpha = min(1.0, (p - 0.22) / 0.22)
            line_color = tuple(int(channel * alpha) for channel in ACCENT)
            draw.line((cx-radius, cy, cx-radius-65, cy-42), fill=line_color, width=2)
            label = "THE KEY IS MISSING"
            label_box = draw.textbbox((0, 0), label, font=font)
            label_width = label_box[2] - label_box[0]
            draw.text((cx-radius-72-label_width, cy-54), label, font=font, fill=tuple(int(channel*alpha) for channel in WHITE))
        return image

    render_raw_video(path, 56, frame, size=(960, 540), crf=16)
    return path


def render_selection_overlay(frames: int) -> Path:
    """Animate a player reticle selecting the missing key location."""
    path = EFFECTS / f"selection_{frames}.mp4"
    target = (int(1186 / 1672 * 960), int(653 / 941 * 540))
    start = (485, 260)
    font = ImageFont.truetype(str(FONT_BOLD), 14)

    def frame(n: int, total: int) -> Image.Image:
        image = Image.new("RGB", (960, 540), "black")
        draw = ImageDraw.Draw(image)
        p = n / max(1, total-1)
        travel = max(0.0, min(1.0, p/.64))
        travel = travel*travel*(3-2*travel)
        x = int(start[0] + (target[0]-start[0])*travel)
        y = int(start[1] + (target[1]-start[1])*travel)
        draw.line((x-12, y, x-4, y), fill=(165, 160, 192), width=1)
        draw.line((x+4, y, x+12, y), fill=(165, 160, 192), width=1)
        draw.line((x, y-12, x, y-4), fill=(165, 160, 192), width=1)
        draw.line((x, y+4, x, y+12), fill=(165, 160, 192), width=1)
        draw.ellipse((x-3, y-3, x+3, y+3), outline=WHITE, width=1)
        if p > .62:
            tap = min(1.0, (p-.62)/.28)
            radius = int(8 + 36*tap)
            alpha = max(.18, 1-tap)
            color = tuple(int(channel*alpha) for channel in ACCENT)
            draw.ellipse((target[0]-radius, target[1]-radius, target[0]+radius, target[1]+radius), outline=color, width=3)
        draw.text((40, 38), "SELECT THE CHANGE", font=font, fill=(90, 87, 118))
        return image

    render_raw_video(path, frames, frame, size=(960, 540), crf=16)
    return path


def render_confirmation_overlay(frames: int) -> Path:
    """Render affirmative gameplay feedback after the player's selection."""
    path = EFFECTS / f"confirmation_{frames}.mp4"
    cx, cy = int(1186 / 1672 * 960), int(653 / 941 * 540)
    teal = (46, 224, 166)
    title = ImageFont.truetype(str(FONT_BOLD), 18)
    small = ImageFont.truetype(str(FONT), 13)

    def frame(n: int, total: int) -> Image.Image:
        image = Image.new("RGB", (960, 540), "black")
        draw = ImageDraw.Draw(image)
        p = n / max(1, total-1)
        reveal = max(0.0, min(1.0, p/.28))
        radius = int(30 + 9*math.sin(n/FPS*math.tau*1.4))
        color = tuple(int(channel*reveal) for channel in teal)
        draw.ellipse((cx-radius, cy-radius, cx+radius, cy+radius), outline=color, width=3)
        # Checkmark draws on in two restrained strokes.
        first = max(0.0, min(1.0, reveal*1.7))
        second = max(0.0, min(1.0, reveal*1.7-.7))
        draw.line((cx-13, cy, cx-13+15*first, cy+14*first), fill=color, width=4)
        draw.line((cx+2, cy+14, cx+2+27*second, cy+14-34*second), fill=color, width=4)
        if p > .18:
            alpha = min(1.0, (p-.18)/.24)
            text_color = tuple(int(channel*alpha) for channel in WHITE)
            draw.line((cx-radius, cy, cx-radius-62, cy-41), fill=color, width=2)
            draw.text((390, 309), "CHANGE CONFIRMED", font=title, fill=text_color)
            draw.text((390, 337), "1 OF 1 FOUND", font=small, fill=tuple(int(channel*alpha) for channel in MUTED))
        return image

    render_raw_video(path, frames, frame, size=(960, 540), crf=16)
    return path


def render_advance_overlay(frames: int) -> Path:
    """Make progression explicit as the next, harder investigation appears."""
    path = EFFECTS / f"advance_{frames}.mp4"
    label = ImageFont.truetype(str(FONT_BOLD), 15)
    headline = ImageFont.truetype(str(FONT_BOLD), 27)
    small = ImageFont.truetype(str(FONT), 14)

    def frame(n: int, total: int) -> Image.Image:
        image = Image.new("RGB", (960, 540), "black")
        draw = ImageDraw.Draw(image)
        p = n / max(1, total-1)
        reveal = max(0.0, min(1.0, p/.25))
        color = tuple(int(channel*reveal) for channel in WHITE)
        muted = tuple(int(channel*reveal) for channel in MUTED)
        accent = tuple(int(channel*reveal) for channel in ACCENT)
        draw.line((55, 74, 55+94*reveal, 74), fill=accent, width=3)
        draw.text((55, 91), "NEXT INVESTIGATION", font=label, fill=muted)
        draw.text((55, 124), "CASE 02", font=headline, fill=color)
        draw.text((55, 169), "2 CHANGES TO FIND", font=small, fill=muted)
        # A small advancing index travels across the rule.
        dot_x = 55 + int(94*max(0.0, min(1.0, p/.72)))
        draw.ellipse((dot_x-3, 71, dot_x+3, 77), fill=WHITE)
        return image

    render_raw_video(path, frames, frame, size=(960, 540), crf=16)
    return path


def render_black(shot: Shot, *, fade: bool = False) -> Path:
    if fresh(shot.path, [CONFIG_PATH, Path(__file__)]):
        return shot.path

    def frame(n: int, total: int) -> Image.Image:
        value = 3 if not fade else int(8 * max(0, 1 - n / max(1, total - 1)))
        return Image.new("RGB", (WIDTH, HEIGHT), (value, value, value + 2))

    render_raw_video(shot.path, shot.frames, frame, size=(WIDTH, HEIGHT), crf=18)
    return shot.path


def render_montage(shot: Shot, plates: dict[str, Path]) -> Path:
    dependencies = [plates[name] for name in ("family_photo", "family_photo_changed", "living_room", "living_room_changed", "witness", "witness_changed", "case_files", "case_files_changed", "investigator")]
    if fresh(shot.path, [*dependencies, CONFIG_PATH, Path(__file__)]):
        return shot.path
    pairs = [
        (Image.open(plates["family_photo"]).convert("RGB"), Image.open(plates["family_photo_changed"]).convert("RGB"), "OBSERVE"),
        (Image.open(plates["living_room"]).convert("RGB"), Image.open(plates["living_room_changed"]).convert("RGB"), "REMEMBER"),
        (Image.open(plates["witness"]).convert("RGB"), Image.open(plates["witness_changed"]).convert("RGB"), "DETECT"),
        (Image.open(plates["case_files"]).convert("RGB"), Image.open(plates["case_files_changed"]).convert("RGB"), "CONFIRM"),
        (Image.open(plates["investigator"]).convert("RGB"), Image.open(plates["investigator"]).convert("RGB"), "ADVANCE"),
    ]
    font = ImageFont.truetype(str(FONT_BOLD), 25)
    slot = shot.frames / len(pairs)

    def frame(n: int, total: int) -> Image.Image:
        index = min(len(pairs)-1, int(n / slot))
        local = (n - index * slot) / slot
        before, after, label = pairs[index]
        source = before if local < 0.53 else after
        zoom = 1.0 + 0.055 * (local % 0.53) / 0.53
        scaled = source.resize((int(WIDTH*zoom), int(HEIGHT*zoom)), Image.Resampling.LANCZOS)
        x = max(0, (scaled.width-WIDTH)//2 + int(13 * math.sin(index * 1.8)))
        y = max(0, (scaled.height-HEIGHT)//2 + int(7 * math.cos(index * 1.4)))
        image = scaled.crop((x, y, x+WIDTH, y+HEIGHT))
        # One-frame exposure snap at each cut and each reality change.
        distance = min(local, abs(local-0.53))
        flash = max(0.0, 1.0 - distance / 0.095)
        if flash:
            image = Image.blend(image, Image.new("RGB", image.size, (205, 207, 218)), flash * 0.34)
        draw = ImageDraw.Draw(image)
        draw.line((106, 909, 165, 909), fill=ACCENT, width=3)
        draw.text((106, 927), label, font=font, fill=WHITE)
        return image

    render_raw_video(shot.path, shot.frames, frame, size=(WIDTH, HEIGHT), crf=17)
    return shot.path


def title_background() -> Image.Image:
    yy, xx = np.mgrid[0:HEIGHT, 0:WIDTH]
    radial = np.sqrt(((xx-WIDTH*0.5)/WIDTH)**2 + ((yy-HEIGHT*0.43)/HEIGHT)**2)
    glow = np.clip(1-radial*2.15, 0, 1)
    base = np.zeros((HEIGHT, WIDTH, 3), dtype=np.float32)
    base[..., 0] = 3 + glow * 10
    base[..., 1] = 5 + glow * 9
    base[..., 2] = 10 + glow * 25
    return Image.fromarray(np.clip(base, 0, 255).astype(np.uint8), "RGB")


def draw_aperture(draw: ImageDraw.ImageDraw, cx: int, cy: int, progress: float, t: float) -> None:
    settle = progress * progress * (3 - 2 * progress)
    rx = 80 + 245 * settle
    ry = 23 + 82 * settle
    spin = t * 5.5
    for offset, divisor, width in ((0, 1, 3), (38, 2, 2), (76, 3, 1)):
        color = tuple(channel // divisor for channel in ACCENT)
        box = (cx-rx-offset, cy-ry-offset*.24, cx+rx+offset, cy+ry+offset*.24)
        draw.arc(box, 188+spin, 350+spin, fill=color, width=width)
        draw.arc(box, 8+spin, 170+spin, fill=color, width=max(1, width-1))
    pupil = 6 + int(2 * math.sin(t * 4.2))
    draw.ellipse((cx-pupil, cy-pupil, cx+pupil, cy+pupil), fill=ACCENT)


def render_title(shot: Shot) -> Path:
    if fresh(shot.path, [CONFIG_PATH, Path(__file__)]):
        return shot.path
    base = title_background()
    title_font = ImageFont.truetype(str(FONT_BOLD), 65)
    tagline_font = ImageFont.truetype(str(FONT), 25)

    def frame(n: int, total: int) -> Image.Image:
        image = base.copy()
        draw = ImageDraw.Draw(image)
        p = n / max(1, total-1)
        t = n / FPS
        reveal = max(0.0, min(1.0, p / 0.34))
        draw_aperture(draw, WIDTH//2, 420, reveal, t)
        text_reveal = max(0.0, min(1.0, (p-.18)/.32))
        title_color = tuple(int(channel * text_reveal) for channel in WHITE)
        muted_color = tuple(int(channel * max(0, min(1, (p-.38)/.25))) for channel in MUTED)
        draw_letterspaced(draw, "TWO SECOND WITNESS", title_font, WIDTH/2, 610, 10, title_color)
        draw_letterspaced(draw, "OBSERVE.  REMEMBER.  DISCOVER.", tagline_font, WIDTH/2, 728, 5, muted_color)
        return image

    render_raw_video(shot.path, shot.frames, frame, size=(WIDTH, HEIGHT), crf=17)
    return shot.path


def google_play_badge(size: tuple[int, int] = (330, 98)) -> Image.Image:
    width, height = size
    badge = Image.new("RGBA", size, (4, 5, 8, 255))
    draw = ImageDraw.Draw(badge)
    draw.rounded_rectangle((1, 1, width-2, height-2), radius=13, outline=(184, 188, 196, 255), width=2)
    # Recognizable four-colour Play triangle, drawn locally to keep the build offline.
    draw.polygon([(28, 20), (28, 78), (60, 49)], fill=(52, 168, 83, 255))
    draw.polygon([(28, 20), (69, 42), (60, 49)], fill=(66, 133, 244, 255))
    draw.polygon([(28, 78), (69, 56), (60, 49)], fill=(250, 187, 5, 255))
    draw.polygon([(60, 49), (69, 42), (84, 49), (69, 56)], fill=(234, 67, 53, 255))
    small = ImageFont.truetype(str(FONT), 16)
    large = ImageFont.truetype(str(FONT), 31)
    draw.text((101, 16), "GET IT ON", font=small, fill=(226, 228, 233, 255))
    draw.text((99, 38), "Google Play", font=large, fill=(250, 250, 251, 255))
    return badge


def qr_image(url: str, pixels: int = 184) -> Image.Image:
    code = qrcode.QRCode(version=None, error_correction=qrcode.constants.ERROR_CORRECT_M, box_size=8, border=3)
    code.add_data(url)
    code.make(fit=True)
    return code.make_image(fill_color="#11131a", back_color="#f2f2f4").convert("RGB").resize((pixels, pixels), Image.Resampling.NEAREST)


def render_cta(shot: Shot) -> Path:
    if fresh(shot.path, [CONFIG_PATH, Path(__file__)]):
        return shot.path
    base = title_background()
    badge = google_play_badge()
    qr = qr_image(PROJECT["play_store_url"])
    title_font = ImageFont.truetype(str(FONT_BOLD), 49)
    line_font = ImageFont.truetype(str(FONT), 24)
    url_font = ImageFont.truetype(str(FONT), 18)

    def frame(n: int, total: int) -> Image.Image:
        image = base.copy()
        draw = ImageDraw.Draw(image)
        p = n / max(1, total-1)
        t = n / FPS
        opacity = max(0.0, min(1.0, p / .24))
        draw_aperture(draw, WIDTH//2, 247, 1.0, t)
        color = tuple(int(channel * opacity) for channel in WHITE)
        muted = tuple(int(channel * opacity) for channel in MUTED)
        draw_letterspaced(draw, "TWO SECOND WITNESS", title_font, WIDTH/2, 382, 8, color)
        draw_letterspaced(draw, "PLAY NOW ON ANDROID", line_font, WIDTH/2, 480, 5, muted)
        # Badge and scannable Play Store QR are deliberately well inside title-safe.
        faded_badge = badge.copy()
        faded_badge.putalpha(int(255 * opacity))
        image.paste(faded_badge, (690, 583), faded_badge)
        faded_qr = qr.copy().convert("RGBA")
        faded_qr.putalpha(int(255 * opacity))
        image.paste(faded_qr, (1048, 540), faded_qr)
        draw.text((690, 710), "SCAN TO PLAY", font=url_font, fill=muted)
        draw.text((690, 744), "play.google.com  •  Android", font=url_font, fill=muted)
        return image

    render_raw_video(shot.path, shot.frames, frame, size=(WIDTH, HEIGHT), crf=17)
    return shot.path


def render_final_card(shot: Shot) -> Path:
    """Resolve title, tagline, Android CTA, badge, and QR in one 5.5s card."""
    if fresh(shot.path, [CONFIG_PATH, Path(__file__)]):
        return shot.path
    base = title_background()
    badge = google_play_badge((310, 92))
    qr = qr_image(PROJECT["play_store_url"], 164)
    title_font = ImageFont.truetype(str(FONT_BOLD), 58)
    tagline_font = ImageFont.truetype(str(FONT), 22)
    cta_font = ImageFont.truetype(str(FONT_BOLD), 21)
    small = ImageFont.truetype(str(FONT), 16)

    def frame(n: int, total: int) -> Image.Image:
        image = base.copy()
        draw = ImageDraw.Draw(image)
        p = n / max(1, total-1)
        t = n / FPS
        aperture_reveal = max(0.0, min(1.0, p/.24))
        title_reveal = max(0.0, min(1.0, (p-.08)/.25))
        cta_reveal = max(0.0, min(1.0, (p-.32)/.22))
        draw_aperture(draw, WIDTH//2, 266, aperture_reveal, t)
        title_color = tuple(int(channel*title_reveal) for channel in WHITE)
        tagline_color = tuple(int(channel*max(0.0, min(1.0, (p-.20)/.22))) for channel in MUTED)
        draw_letterspaced(draw, "TWO SECOND WITNESS", title_font, WIDTH/2, 408, 9, title_color)
        draw_letterspaced(draw, "OBSERVE.  REMEMBER.  DISCOVER.", tagline_font, WIDTH/2, 500, 4, tagline_color)
        cta_color = tuple(int(channel*cta_reveal) for channel in WHITE)
        muted = tuple(int(channel*cta_reveal) for channel in MUTED)
        draw_letterspaced(draw, "PLAY NOW ON ANDROID", cta_font, WIDTH/2, 590, 4, cta_color)

        faded_badge = badge.copy()
        faded_badge.putalpha(int(255*cta_reveal))
        image.paste(faded_badge, (704, 662), faded_badge)
        faded_qr = qr.copy().convert("RGBA")
        faded_qr.putalpha(int(255*cta_reveal))
        image.paste(faded_qr, (1045, 624), faded_qr)
        draw.text((704, 780), "SCAN TO PLAY", font=small, fill=muted)
        draw.text((704, 811), "Google Play  •  Android", font=small, fill=muted)
        return image

    render_raw_video(shot.path, shot.frames, frame, size=(WIDTH, HEIGHT), crf=17)
    return shot.path


def build_clips(plates: dict[str, Path]) -> list[Path]:
    countdown = render_countdown_overlay()
    steam = render_micro_effect("steam", SHOTS[1].frames)
    hallway_reflections = render_micro_effect("hallway_reflection", SHOTS[2].frames)
    paper_lift = render_micro_effect("paper_lift", SHOTS[3].frames)
    investigator_blink = render_micro_effect("investigator_blink", SHOTS[4].frames)
    photo_glint = render_micro_effect("photo_glint", SHOTS[5].frames)
    eye_saccade = render_micro_effect("eye_saccade", SHOTS[12].frames)
    notebook_ink = render_micro_effect("notebook_ink", SHOTS[13].frames)
    selection = render_selection_overlay(SHOTS[17].frames)
    confirmation = render_confirmation_overlay(SHOTS[18].frames)
    advance = render_advance_overlay(SHOTS[19].frames)

    clips = [
        # Faster opening: wide, insert, corridor, evidence, person, hand, photograph.
        render_layered(SHOTS[0], "quiet_room", pan=(16, 5), zoom=(1.02, 1.055), atmosphere="rain", fade_in=.35),
        render_layered(SHOTS[1], "quiet_detail", pan=(8, -3), zoom=(1.03, 1.075), atmosphere="air", micro=steam, micro_opacity=.82),
        render_layered(SHOTS[2], "hallway", pan=(-22, 4), zoom=(1.03, 1.07), atmosphere="air", micro=hallway_reflections, micro_opacity=.78),
        render_layered(SHOTS[3], "evidence_desk", pan=(22, -9), zoom=(1.025, 1.07), atmosphere="dust", micro=paper_lift, micro_opacity=.68),
        render_layered(SHOTS[4], "investigator", pan=(-17, 5), zoom=(1.03, 1.08), atmosphere="air", micro=investigator_blink, micro_opacity=.72),
        render_layered(SHOTS[5], "photo_detail", pan=(12, -5), zoom=(1.025, 1.060), atmosphere="dust", micro=photo_glint, micro_opacity=.72),
        render_layered(SHOTS[6], "family_photo", pan=(-7, 3), zoom=(1.035, 1.060), atmosphere="dust"),

        # Each reality change now has a scene-motivated transition treatment.
        render_change(SHOTS[7], "family_photo", change_at=1.22, pan=(15, -5), atmosphere="dust", transition_style="photo_reflection"),
        render_change(SHOTS[8], "living_room", change_at=1.12, pan=(-17, 5), atmosphere="dust", transition_style="lamp_flicker"),
        render_change(SHOTS[9], "witness", change_at=1.10, pan=(13, -4), atmosphere="air", transition_style="witness_blink"),
        render_change(SHOTS[10], "case_files", change_at=1.04, pan=(-20, 7), atmosphere="dust", transition_style="paper_sweep"),
        render_montage(SHOTS[11], plates),
        render_layered(SHOTS[12], "eye", pan=(12, 3), zoom=(1.04, 1.10), atmosphere="air", micro=eye_saccade, micro_opacity=.66),
        render_layered(SHOTS[13], "notebook", pan=(20, -9), zoom=(1.03, 1.085), atmosphere="dust", micro=notebook_ink, micro_opacity=.74),

        # Complete gameplay loop: observe, disappear, search, select, confirm, advance.
        render_layered(SHOTS[14], "quiet_room", pan=(7, 3), zoom=(1.018, 1.035), atmosphere="rain", overlay=countdown, overlay_opacity=.94),
        render_black(SHOTS[15]),
        render_layered(SHOTS[16], "quiet_room_changed", pan=(7, 3), zoom=(1.035, 1.047), atmosphere="rain"),
        render_layered(SHOTS[17], "quiet_room_changed", pan=(6, 2), zoom=(1.047, 1.060), atmosphere="rain", overlay=selection, overlay_opacity=.96),
        render_layered(SHOTS[18], "quiet_room_changed", pan=(5, 2), zoom=(1.060, 1.071), atmosphere="rain", overlay=confirmation, overlay_opacity=.96),
        render_layered(SHOTS[19], "living_room", pan=(-14, 4), zoom=(1.025, 1.065), atmosphere="dust", overlay=advance, overlay_opacity=.94, fade_out=.28),
        render_final_card(SHOTS[20]),
    ]
    return clips


def moving_average(values: np.ndarray, window: int) -> np.ndarray:
    padded = np.pad(values, (window//2, window-1-window//2), mode="edge")
    cumulative = np.cumsum(np.insert(padded.astype(np.float64), 0, 0.0))
    return ((cumulative[window:] - cumulative[:-window]) / window).astype(np.float32)


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


def write_wav_stereo(path: Path, samples: np.ndarray, rate: int) -> None:
    pcm = (np.clip(samples, -1, 1) * 32767).astype("<i2")
    with wave.open(str(path), "wb") as output:
        output.setnchannels(2)
        output.setsampwidth(2)
        output.setframerate(rate)
        output.writeframes(pcm.tobytes())


def generate_audio() -> Path:
    output = AUDIO_BUILD / "trailer_mix.wav"
    narration_files = [ROOT / item["file"] for item in CONFIG["narration"].values()]
    if fresh(output, [*narration_files, CONFIG_PATH, Path(__file__)]):
        return output

    rate = 48000
    count = round(DURATION * rate)
    t = np.arange(count, dtype=np.float64) / rate
    rng = np.random.default_rng(2045)
    score = np.zeros((count, 2), dtype=np.float32)

    # Low investigative bed, opening room air, and a slow three-act intensity rise.
    # The consolidated 39.5s end card receives a firmer final lift.
    intensity = np.interp(t, [0, 12, 24, 30, 36.9, 39.5, 45], [.48, .64, .88, 1.0, .38, .64, .94])
    drone = .030*np.sin(2*np.pi*(41.5 + .14*np.sin(2*np.pi*.031*t))*t)
    drone += .014*np.sin(2*np.pi*62.2*t + .7)
    drone += .007*np.sin(2*np.pi*124.4*t + 1.4)
    air_raw = rng.normal(0, 1, count).astype(np.float32)
    air = moving_average(air_raw, 780)
    air /= max(1e-6, np.max(np.abs(air)))
    bed = (drone + air*.013) * intensity
    score[:, 0] = bed * (0.98 + .02*np.sin(2*np.pi*.071*t))
    score[:, 1] = bed * (0.98 + .02*np.sin(2*np.pi*.071*t+1.7))

    def add_tone(at: float, frequency: float, length: float, amplitude: float, pan: float = 0, attack: float = .006) -> None:
        start = max(0, int(at*rate)); n = min(int(length*rate), count-start)
        if n <= 0:
            return
        local = np.arange(n, dtype=np.float64) / rate
        envelope = (1-np.exp(-local/max(attack, 1e-4))) * np.exp(-local/max(length*.29, 1e-4))
        tone = np.sin(2*np.pi*frequency*local) * envelope * amplitude
        score[start:start+n, 0] += tone * math.sqrt((1-pan)/2)
        score[start:start+n, 1] += tone * math.sqrt((1+pan)/2)

    def add_boom(at: float, amplitude: float = .14) -> None:
        start = int(at*rate); n = min(int(1.8*rate), count-start)
        local = np.arange(n, dtype=np.float64)/rate
        frequency = 57 - 27*local/max(local[-1], 1e-6)
        phase = 2*np.pi*np.cumsum(frequency)/rate
        boom = np.sin(phase)*np.exp(-local*2.05)*amplitude
        score[start:start+n] += boom[:, None]

    def add_swell(at: float, length: float = .48, amplitude: float = .032, pan: float = 0) -> None:
        start = max(0, int((at-length)*rate)); n = min(int(length*rate), count-start)
        raw = rng.normal(0, 1, n).astype(np.float32)
        high = raw-moving_average(raw, 47)
        local = np.linspace(0, 1, n, dtype=np.float32)
        sound = high*(local**2)*amplitude
        score[start:start+n, 0] += sound*math.sqrt((1-pan)/2)
        score[start:start+n, 1] += sound*math.sqrt((1+pan)/2)

    cuts = np.cumsum([shot.frames/FPS for shot in SHOTS])[:-1]
    for index, at in enumerate(cuts):
        amplitude = .014 if at < 15 else (.022 if at < 23.8 else .032)
        add_swell(float(at), .34 if at < 23.8 else .24, amplitude, -.45 if index%2 else .45)
    for at in (0.35, 6.50, 15.0, 23.83, 30.0, 35.58, 36.92, 39.50):
        add_boom(at, .12 if at < 30 else .15)

    # Believable room details: rain, footsteps, paper, pencil and mechanical clicks.
    rain = moving_average(rng.normal(0, 1, count).astype(np.float32), 21)
    rain *= ((t < 4.50) | ((t >= 30) & (t < 36.92))).astype(np.float32) * .009
    score[:, 0] += rain*.82
    score[:, 1] += np.roll(rain, 139)*.78
    for at in (4.92, 5.78, 6.52):
        add_tone(at, 92, .22, .042, -.25 if int(at*10)%2 else .25, .002)
    for at in (7.18, 8.02, 21.9, 22.65):
        add_swell(at, .18, .018)
    for at in np.arange(28.5, 29.95, .19):
        add_tone(float(at), 1320+rng.uniform(-170, 170), .045, .009, rng.uniform(-.25, .25), .001)

    # Increasing pulse and perception clicks through acts II and III.
    for at in np.arange(15.0, 23.8, .92):
        add_tone(float(at), 76, .28, .030, 0, .004)
    for at in np.arange(23.85, 30.0, .40):
        add_tone(float(at), 1540, .055, .025, -.45 if int(at*10)%2 else .45, .001)
    for at in (30.0, 31.0, 32.0):
        add_tone(at, 1880, .08, .052, 0, .001)
        add_tone(at+.045, 720, .24, .030, 0, .001)
    # Selection, confirmation, progression, and the merged end card each get a
    # distinct response instead of sharing the perception-transition sound.
    add_tone(35.12, 2180, .08, .055, 0, .001)
    add_tone(35.58, 880, .44, .046, -.12, .004)
    add_tone(35.69, 1320, .52, .040, .12, .004)
    add_tone(36.92, 420, .80, .034, 0, .006)
    add_tone(39.50, 164, 2.20, .030, 0, .08)
    add_tone(39.50, 246, 2.60, .021, 0, .10)

    # Intentional near-silence across disappearance and return.
    silence = np.ones(count, dtype=np.float32)
    silence[(t >= 31.88) & (t < 32.72)] = .10
    score *= silence[:, None]

    narration_bus = np.zeros(count, dtype=np.float32)
    for item in CONFIG["narration"].values():
        voice = read_wav_mono(ROOT / item["file"], rate)
        fade = min(int(.06*rate), len(voice)//2)
        if fade:
            voice[:fade] *= np.linspace(0, 1, fade, dtype=np.float32)
            voice[-fade:] *= np.linspace(1, 0, fade, dtype=np.float32)
        start = int(float(item["start"])*rate)
        end = min(count, start+len(voice))
        narration_bus[start:end] += voice[:end-start] * .90

    voice_env = moving_average(np.abs(narration_bus), int(.075*rate))
    duck = 1-.62*np.clip(voice_env/.065, 0, 1)
    score *= duck[:, None]
    score += narration_bus[:, None]
    score = np.tanh(score*1.17)/1.17
    peak = float(np.max(np.abs(score)))
    if peak > .94:
        score *= .94/peak
    write_wav_stereo(output, score, rate)
    return output


def timestamp_srt(seconds: float) -> str:
    milliseconds = round(seconds*1000)
    hours, remainder = divmod(milliseconds, 3_600_000)
    minutes, remainder = divmod(remainder, 60_000)
    secs, millis = divmod(remainder, 1000)
    return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"


def timestamp_vtt(seconds: float) -> str:
    return timestamp_srt(seconds).replace(",", ".")


def timestamp_ass(seconds: float) -> str:
    centiseconds = round(seconds*100)
    hours, remainder = divmod(centiseconds, 360_000)
    minutes, remainder = divmod(remainder, 6_000)
    secs, cs = divmod(remainder, 100)
    return f"{hours}:{minutes:02d}:{secs:02d}.{cs:02d}"


def generate_captions() -> None:
    cues = [
        (0.97, 3.96, "Every witness believes they remember what happened."),
        (4.43, 5.65, "Most of them are certain."),
        (6.44, 8.26, "But memory isn't a recording."),
        (8.83, 10.03, "It's a reconstruction."),
        (10.82, 12.38, "Every detail matters."),
        (12.79, 14.16, "Every glance counts."),
        (14.83, 17.66, "Every decision begins with observation."),
        (29.82, 30.32, "You have…"),
        (30.83, 31.74, "two seconds."),
        (32.75, 33.70, "What changed?"),
        (41.75, 44.52, "Play Two Second Witness now on Android."),
    ]
    srt = []
    for index, (start, end, text) in enumerate(cues, 1):
        srt.append(f"{index}\n{timestamp_srt(start)} --> {timestamp_srt(end)}\n{text}\n")
    SRT.write_text("\n".join(srt), encoding="utf-8")

    vtt = ["WEBVTT", ""]
    for start, end, text in cues:
        vtt += [f"{timestamp_vtt(start)} --> {timestamp_vtt(end)}", text, ""]
    VTT.write_text("\n".join(vtt), encoding="utf-8")

    ass = """[Script Info]
Title: Two Second Witness — English Captions
ScriptType: v4.00+
PlayResX: 1920
PlayResY: 1080
WrapStyle: 0
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,DejaVu Sans,39,&H00F1F1F3,&H000000FF,&HBC050609,&H88000000,0,0,0,0,100,100,0,0,3,1,0,2,90,90,54,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""
    for start, end, text in cues:
        ass += f"Dialogue: 0,{timestamp_ass(start)},{timestamp_ass(end)},Default,,0,0,0,,{text}\n"
    ASS.write_text(ass, encoding="utf-8")


def loudnorm_filter(audio: Path) -> str:
    first_pass = run([
        ffmpeg(), "-hide_banner", "-nostats", "-i", str(audio),
        "-af", "loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json", "-f", "null", "-",
    ], capture=True)
    match = re.search(r"\{\s*\"input_i\".*?\}", first_pass.stderr, flags=re.S)
    if not match:
        return "loudnorm=I=-16:TP=-1.5:LRA=11"
    measured = json.loads(match.group(0))
    return (
        "loudnorm=I=-16:TP=-1.5:LRA=11:"
        f"measured_I={measured['input_i']}:measured_TP={measured['input_tp']}:"
        f"measured_LRA={measured['input_lra']}:measured_thresh={measured['input_thresh']}:"
        f"offset={measured['target_offset']}:linear=true:print_format=summary"
    )


def assemble(clips: list[Path], audio: Path) -> None:
    concat = BUILD / "concat.txt"
    concat.write_text("".join(f"file '{clip.resolve()}'\n" for clip in clips), encoding="utf-8")
    silent = BUILD / "silent_master.mp4"
    if not fresh(silent, [*clips, concat]):
        run([ffmpeg(), "-hide_banner", "-loglevel", "error", "-y", "-f", "concat", "-safe", "0", "-i", str(concat), "-c", "copy", str(silent)])

    dependencies = [silent, audio, ASS, CONFIG_PATH, Path(__file__)]
    if fresh(OUTPUT, dependencies):
        print(f"  master is current: {OUTPUT}")
        return
    normalization = loudnorm_filter(audio)
    ass_relative = ASS.relative_to(REPO).as_posix().replace("'", "\\'")
    filter_complex = f"[0:v]ass=filename='{ass_relative}'[captioned];[1:a]{normalization}[masteraudio]"
    run([
        ffmpeg(), "-hide_banner", "-loglevel", "warning", "-y", "-i", str(silent), "-i", str(audio),
        "-filter_complex", filter_complex, "-map", "[captioned]", "-map", "[masteraudio]",
        "-c:v", "libx264", "-preset", "medium", "-crf", "17", "-tune", "film",
        "-profile:v", "high", "-level", "4.1", "-pix_fmt", "yuv420p", "-r", str(FPS),
        "-frames:v", str(TOTAL_FRAMES), "-c:a", "aac", "-b:a", "256k", "-ar", "48000",
        "-t", f"{DURATION:.3f}", "-movflags", "+faststart",
        "-metadata", "title=Two Second Witness — Official 45 Second Reveal Trailer",
        "-metadata", "artist=ITTYBITTYBITES",
        "-metadata", "comment=Observe. Remember. Discover. What changed?", str(OUTPUT),
    ])


def make_poster() -> None:
    if fresh(POSTER, [OUTPUT]):
        return
    run([ffmpeg(), "-hide_banner", "-loglevel", "error", "-y", "-ss", "42.40", "-i", str(OUTPUT), "-frames:v", "1", "-q:v", "2", str(POSTER)])


def validate() -> None:
    # ffmpeg intentionally exits 1 when invoked as a probe without an output.
    probe = run([ffmpeg(), "-hide_banner", "-i", str(OUTPUT)], capture=True, check=False)
    report = probe.stderr
    required = ["Duration: 00:00:45.00", "1920x1080", "24 fps", "Audio: aac"]
    missing = [value for value in required if value not in report]
    if missing:
        raise RuntimeError(f"Delivery validation failed; missing probe values: {missing}\n{report}")
    print("Validated: 45.00s · 1920×1080 · 24 fps · H.264 High · AAC stereo")


def main() -> None:
    global FORCE
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--force", action="store_true", help="rebuild every generated intermediate")
    parser.add_argument("--no-validate", action="store_true", help="skip final delivery probe")
    args = parser.parse_args()
    FORCE = args.force

    ensure_directories()
    print("[1/9] Creating five changed hero scenes…")
    prepare_changed_sources()
    print("[2/9] Generating five cinematic hero plates and contextual plates…")
    plates = prepare_plates()
    print("[3/9] Estimating depth and separating foreground/background…")
    separate_depth_layers(plates)
    print("[4/9] Rendering environmental and graphic motion…")
    for kind in ("rain", "dust", "air"):
        render_environment_effect(kind)
    print("[5/9] Choreographing 45-second picture edit…")
    clips = build_clips(plates)
    print("[6/9] Designing and mixing score, ambience, effects, and narration…")
    audio = generate_audio()
    print("[7/9] Rendering English captions…")
    generate_captions()
    print("[8/9] Normalizing and assembling web master…")
    assemble(clips, audio)
    print("[9/9] Creating poster and validating delivery…")
    make_poster()
    if not args.no_validate:
        validate()
    print(f"Created {OUTPUT} ({OUTPUT.stat().st_size/1024/1024:.1f} MB)")


if __name__ == "__main__":
    main()
