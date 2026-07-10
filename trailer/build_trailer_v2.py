#!/usr/bin/env python3
"""Build the motion-driven 2.5D Two Second Witness identity trailer.

This second-generation trailer replaces the original still-image animatic with
layered parallax shots, environmental motion, animated evidence graphics,
continuous in-shot changes, focus cues, and a denser investigative sound mix.

Dependencies:
    python3 -m pip install pillow numpy imageio-ffmpeg

Run from the repository root:
    python3 trailer/build_trailer_v2.py
"""

from __future__ import annotations

import math
from pathlib import Path
import shutil
import subprocess
import sys
import wave

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

# Reuse the carefully authored changed frames and audio helpers from v1.
import build_trailer as v1

ROOT = Path(__file__).resolve().parent
ASSETS = ROOT / "assets"
AUDIO = ROOT / "audio"
GEN = ROOT / "v2_generated"
LAYERS = GEN / "layers"
FX = GEN / "effects"
RENDER = ROOT / ".render_v2"
CLIPS = RENDER / "clips"
OUTPUT = ROOT / "two_second_witness_trailer.mp4"
ARCHIVE_V1 = ROOT / "two_second_witness_trailer_animatic_v1.mp4"
WIDTH, HEIGHT, FPS = 1920, 1080, 24
FX_WIDTH, FX_HEIGHT = 960, 540
DURATION = 79.3
PURPLE = (124, 92, 255)
TEAL = (58, 210, 190)
WHITE = (237, 238, 242)
MUTED = (146, 151, 164)
def find_font(bold: bool = False) -> Path:
    """Find a usable sans-serif font on Windows, Linux, or macOS."""
    candidates = [
        Path("C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf"),
        Path("C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf"),
        Path("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"),
        Path("/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate
    raise FileNotFoundError("No supported sans-serif font was found. Update find_font() with an installed TTF path.")


FONT = find_font(False)
FONT_BOLD = find_font(True)


def ffmpeg_executable() -> str:
    binary = shutil.which("ffmpeg")
    if binary:
        return binary
    try:
        import imageio_ffmpeg
    except ImportError as exc:
        raise SystemExit("Install imageio-ffmpeg or provide ffmpeg on PATH.") from exc
    return imageio_ffmpeg.get_ffmpeg_exe()


def run(command: list[str]) -> None:
    print("+", " ".join(command))
    subprocess.run(command, check=True)


def ensure_directories() -> None:
    for directory in (GEN, LAYERS, FX, CLIPS):
        directory.mkdir(parents=True, exist_ok=True)


def resolve(name: str) -> Path:
    for directory in (GEN, v1.GENERATED, ASSETS):
        candidate = directory / name
        if candidate.exists():
            return candidate
    raise FileNotFoundError(name)


def polygon_mask(size: tuple[int, int], polygons: list[list[tuple[int, int]]], ellipses: list[tuple[int, int, int, int]] = [], feather: int = 10) -> Image.Image:
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    for polygon in polygons:
        draw.polygon(polygon, fill=255)
    for ellipse in ellipses:
        draw.ellipse(ellipse, fill=255)
    return mask.filter(ImageFilter.GaussianBlur(feather))


def make_layer(source_name: str, output_name: str, polygons: list[list[tuple[int, int]]], ellipses: list[tuple[int, int, int, int]] = [], feather: int = 10) -> Path:
    source = Image.open(resolve(source_name)).convert("RGBA")
    source.putalpha(polygon_mask(source.size, polygons, ellipses, feather))
    output = LAYERS / output_name
    source.save(output, optimize=True)
    return output


def generate_layers() -> None:
    """Separate visual planes so foreground and background move independently."""
    # Quiet room: leather chair/table/key plane and lamp plane move at different depth.
    quiet_shapes = [[(350, 270), (1030, 260), (1160, 510), (1515, 560), (1600, 940), (250, 940), (160, 655)]]
    make_layer("01_quiet_room.png", "quiet_fg.png", quiet_shapes, feather=16)
    make_layer("18_quiet_room_changed.png", "quiet_changed_fg.png", quiet_shapes, feather=16)

    # Hallway walls frame the distant vanishing point.
    make_layer(
        "02_hallway.png", "hallway_fg.png",
        [[(0, 0), (510, 0), (650, 940), (0, 940)], [(1290, 0), (1672, 0), (1672, 941), (1105, 941)]],
        feather=18,
    )

    # Desk: case papers, magnifier, photograph, and coffee occupy the near plane.
    make_layer(
        "03_desk_documents.png", "desk_fg.png",
        [[(240, 205), (1440, 120), (1665, 720), (1310, 940), (110, 890)]],
        ellipses=[(55, 350, 500, 920), (1220, 20, 1660, 520)], feather=14,
    )

    # Observer remains foreground while the evidence wall drifts behind her.
    observer_shape = [[(920, 0), (1672, 0), (1672, 941), (790, 941), (970, 560)]]
    make_layer("04_observer.png", "observer_fg.png", observer_shape, feather=18)

    # Printed photograph and glove float above the evidence desk.
    photo_shape = [[(300, 75), (1370, 250), (1220, 925), (230, 780)], [(0, 430), (610, 510), (650, 940), (0, 940)]]
    make_layer("05_photo_base.png", "photo_fg.png", photo_shape, feather=9)
    make_layer("06_photo_changed.png", "photo_changed_fg.png", photo_shape, feather=9)

    # Living room foreground table and sofa create three apparent depth planes.
    room_shape = [[(0, 625), (1672, 585), (1672, 941), (0, 941)], [(205, 310), (1530, 300), (1515, 765), (150, 770)]]
    make_layer("07_room_object_base.png", "room_fg.png", room_shape, feather=14)
    make_layer("08_room_object_changed.png", "room_changed_fg.png", room_shape, feather=14)

    # Interview subject separates from the dark room and window.
    face_shape = [[(420, 940), (430, 520), (555, 350), (590, 110), (1080, 50), (1190, 360), (1360, 590), (1450, 940)]]
    make_layer("09_face_base.png", "face_fg.png", face_shape, ellipses=[(520, 40, 1190, 790)], feather=18)
    make_layer("10_face_changed.png", "face_changed_fg.png", face_shape, ellipses=[(520, 40, 1190, 790)], feather=18)

    docs_shape = [[(285, 205), (1655, 190), (1672, 845), (260, 870)]]
    make_layer("11_documents_base.png", "docs_fg.png", docs_shape, feather=10)
    make_layer("12_documents_changed.png", "docs_changed_fg.png", docs_shape, feather=10)

    # Iris can make a minute saccade independently from eyelids and reflected room.
    make_layer("13_eye_closeup.png", "iris_fg.png", [], ellipses=[(615, 285, 975, 665)], feather=9)

    # Hand and notebook occupy different visual depth than the surrounding photographs.
    make_layer(
        "14_notes.png", "notes_fg.png",
        [[(260, 175), (1170, 40), (1320, 875), (325, 940)], [(950, 70), (1672, 120), (1672, 900), (1130, 780)]],
        feather=13,
    )

    make_layer("16_memory_reality.png", "memory_fg.png", room_shape, feather=15)


def render_raw_video(path: Path, seconds: float, frame_function, size: tuple[int, int] = (FX_WIDTH, FX_HEIGHT), crf: int = 20) -> None:
    ffmpeg = ffmpeg_executable()
    width, height = size
    frames = round(seconds * FPS)
    command = [
        ffmpeg, "-hide_banner", "-loglevel", "error", "-y",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{width}x{height}", "-r", str(FPS), "-i", "-",
        "-an", "-c:v", "libx264", "-preset", "medium", "-crf", str(crf), "-pix_fmt", "yuv420p", "-r", str(FPS),
        str(path),
    ]
    process = subprocess.Popen(command, stdin=subprocess.PIPE)
    assert process.stdin is not None
    try:
        for frame_number in range(frames):
            frame = frame_function(frame_number, frames)
            process.stdin.write(np.asarray(frame.convert("RGB"), dtype=np.uint8).tobytes())
    finally:
        process.stdin.close()
    if process.wait() != 0:
        raise RuntimeError(f"Failed to render {path}")


def render_environment_effects() -> None:
    rng = np.random.default_rng(208)
    particle_count = 55
    px = rng.uniform(0, FX_WIDTH, particle_count)
    py = rng.uniform(0, FX_HEIGHT, particle_count)
    speed = rng.uniform(3, 14, particle_count)
    radius = rng.choice([1, 1, 1, 2], particle_count)
    brightness = rng.integers(22, 82, particle_count)

    def dust_frame(n: int, total: int) -> Image.Image:
        image = Image.new("RGB", (FX_WIDTH, FX_HEIGHT), "black")
        draw = ImageDraw.Draw(image)
        for i in range(particle_count):
            x = (px[i] + math.sin(n * 0.017 + i) * 15 + n * speed[i] * 0.018) % FX_WIDTH
            y = (py[i] - n * speed[i] * 0.038) % FX_HEIGHT
            value = int(brightness[i] * (0.55 + 0.45 * math.sin(n * 0.043 + i * 1.7) ** 2))
            draw.ellipse((x - radius[i], y - radius[i], x + radius[i], y + radius[i]), fill=(value, value, min(110, value + 8)))
        return image

    render_raw_video(FX / "dust.mp4", 6.0, dust_frame, crf=17)

    rain_rng = np.random.default_rng(509)
    rx = rain_rng.uniform(-100, FX_WIDTH, 95)
    ry = rain_rng.uniform(-FX_HEIGHT, FX_HEIGHT, 95)
    rs = rain_rng.uniform(13, 26, 95)
    rl = rain_rng.uniform(14, 35, 95)
    rb = rain_rng.integers(22, 70, 95)

    def rain_frame(n: int, total: int) -> Image.Image:
        image = Image.new("RGB", (FX_WIDTH, FX_HEIGHT), "black")
        draw = ImageDraw.Draw(image)
        for i in range(len(rx)):
            y = (ry[i] + n * rs[i]) % (FX_HEIGHT + 120) - 60
            x = (rx[i] + n * rs[i] * 0.15) % (FX_WIDTH + 100) - 50
            value = int(rb[i])
            draw.line((x, y, x + rl[i] * 0.17, y + rl[i]), fill=(value // 2, value // 2 + 5, value), width=1)
        return image

    render_raw_video(FX / "rain.mp4", 5.0, rain_frame, crf=17)


def smoothstep(value: float) -> float:
    value = max(0.0, min(1.0, value))
    return value * value * (3.0 - 2.0 * value)


def render_investigation_fx(kind: str, seconds: float) -> Path:
    """Create shot-specific moving marks on black for screen blending."""
    output = FX / f"{kind}.mp4"
    if output.exists():
        return output

    def frame(n: int, total: int) -> Image.Image:
        t = n / FPS
        p = n / max(1, total - 1)
        image = Image.new("RGB", (FX_WIDTH, FX_HEIGHT), "black")
        draw = ImageDraw.Draw(image)

        # A faint wandering light establishes active attention in every shot.
        glow_x = int(FX_WIDTH * (0.22 + 0.58 * smoothstep(p)))
        glow = Image.new("L", (FX_WIDTH, FX_HEIGHT), 0)
        gdraw = ImageDraw.Draw(glow)
        gdraw.ellipse((glow_x - 100, 85, glow_x + 100, 455), fill=24)
        glow = glow.filter(ImageFilter.GaussianBlur(70))
        light = Image.new("RGB", image.size, (90, 76, 145))
        image = Image.composite(light, image, glow)
        draw = ImageDraw.Draw(image)

        if kind in {"observer", "evidence"}:
            points = [(160, 170), (305, 115), (425, 235), (230, 330), (485, 390)]
            reveal = smoothstep((p - 0.10) / 0.72)
            for i, (a, b) in enumerate(zip(points, points[1:])):
                local = max(0.0, min(1.0, reveal * (len(points) - 1) - i))
                x = a[0] + (b[0] - a[0]) * local
                y = a[1] + (b[1] - a[1]) * local
                draw.line((a[0], a[1], x, y), fill=(75, 40, 105), width=2)
            for i, (x, y) in enumerate(points):
                if reveal > i / len(points):
                    pulse = 5 + int(3 * (0.5 + 0.5 * math.sin(t * 4 + i)))
                    draw.ellipse((x - pulse, y - pulse, x + pulse, y + pulse), outline=(118, 87, 235), width=2)
                    draw.ellipse((x - 2, y - 2, x + 2, y + 2), fill=(210, 215, 235))
        elif kind == "docs":
            y = int(135 + 285 * smoothstep(p))
            draw.line((175, y, 905, y), fill=(95, 77, 210), width=2)
            for i, x in enumerate((245, 435, 625, 815)):
                if p > 0.18 + i * 0.11:
                    alpha_value = 105 + int(35 * math.sin(t * 5 + i))
                    draw.rectangle((x - 32, 126, x + 34, 208), outline=(alpha_value, alpha_value, min(255, alpha_value + 80)), width=2)
            if p > 0.68:
                draw.line((250, 175, 815, 175), fill=(78, 42, 120), width=1)
        elif kind == "notes":
            points = [(315, 330), (410, 290), (500, 355), (570, 260), (665, 310)]
            reveal = smoothstep((p - .08) / .80)
            for i, (a, b) in enumerate(zip(points, points[1:])):
                local = max(0, min(1, reveal * 4 - i))
                draw.line((a[0], a[1], a[0] + (b[0] - a[0]) * local, a[1] + (b[1] - a[1]) * local), fill=(84, 59, 160), width=2)
            for i, point in enumerate(points):
                if reveal > i * .18:
                    draw.ellipse((point[0]-7, point[1]-7, point[0]+7, point[1]+7), outline=(135, 108, 250), width=2)
        elif kind == "eye":
            cx = int(455 + 18 * math.sin(t * 1.8))
            cy = int(270 + 7 * math.sin(t * 2.5 + 1))
            radius = 72 + int(5 * math.sin(t * 3.3))
            draw.ellipse((cx-radius, cy-radius, cx+radius, cy+radius), outline=(74, 55, 150), width=2)
            draw.line((cx-radius-45, cy, cx-radius-8, cy), fill=(100, 90, 170), width=1)
            draw.line((cx+radius+8, cy, cx+radius+45, cy), fill=(100, 90, 170), width=1)
            # Moving reflected scene rectangles.
            rshift = int(7 * math.sin(t * 1.4))
            draw.rectangle((cx-22+rshift, cy-28, cx-7+rshift, cy+14), outline=(125, 132, 170), width=1)
            draw.rectangle((cx+12+rshift, cy-35, cx+30+rshift, cy+20), outline=(110, 102, 180), width=1)
        elif kind == "memory":
            x = FX_WIDTH // 2 + int(8 * math.sin(t * 2.2))
            draw.line((x, 65, x, FX_HEIGHT-65), fill=(108, 80, 235), width=2)
            for radius in (8, 18 + int(3 * math.sin(t*4))):
                draw.ellipse((x-radius, FX_HEIGHT//2-radius, x+radius, FX_HEIGHT//2+radius), outline=(110, 90, 210), width=1)
        elif kind == "desk":
            x = int(180 + p * 610)
            draw.line((x, 110, x - 70, 455), fill=(65, 56, 125), width=2)
            draw.ellipse((160 + int(10*math.sin(t)), 245, 310 + int(10*math.sin(t)), 400), outline=(82, 75, 150), width=2)
        return image

    render_raw_video(output, seconds, frame, crf=18)
    return output


def transform_filter(label_in: str, label_out: str, duration: float, zoom_start: float, zoom_end: float, pan_x: float, pan_y: float, rgba: bool = False) -> str:
    z = f"({zoom_start:.5f}+({zoom_end-zoom_start:.5f})*t/{duration:.5f})"
    width = f"trunc({WIDTH}*{z}/2)*2"
    height = f"trunc({HEIGHT}*{z}/2)*2"
    px = f"(in_w-{WIDTH})/2+({pan_x:.3f})*(t/{duration:.5f}-.5)"
    py = f"(in_h-{HEIGHT})/2+({pan_y:.3f})*(t/{duration:.5f}-.5)"
    fmt = ",format=rgba" if rgba else ""
    return f"[{label_in}]scale=w='{width}':h='{height}':eval=frame,crop={WIDTH}:{HEIGHT}:x='{px}':y='{py}',setsar=1{fmt}[{label_out}]"


def composite_chain(prefix: str, bg_index: int, fg_index: int, duration: float, pan: tuple[float, float]) -> tuple[list[str], str]:
    filters = [
        transform_filter(str(bg_index), f"{prefix}bg", duration, 1.025, 1.070, pan[0], pan[1], False),
        transform_filter(str(fg_index), f"{prefix}fg", duration, 1.048, 1.112, -pan[0] * 1.45, -pan[1] * 1.35, True),
        f"[{prefix}bg][{prefix}fg]overlay=0:0:format=auto[{prefix}comp]",
    ]
    return filters, f"{prefix}comp"


def render_parallax_clip(index: int, name: str, duration: float, background: str, foreground: str, pan: tuple[float, float] = (12, 4), fx_kind: str | None = None, rain: bool = False, fade_in: float = 0.0, fade_out: float = 0.0, iris_motion: bool = False) -> Path:
    output = CLIPS / f"{index:02d}_{name}.mp4"
    ffmpeg = ffmpeg_executable()
    fx_file = render_investigation_fx(fx_kind, duration) if fx_kind else FX / "dust.mp4"
    env_file = FX / ("rain.mp4" if rain else "dust.mp4")
    inputs = [
        "-loop", "1", "-framerate", str(FPS), "-t", str(duration), "-i", str(resolve(background)),
        "-loop", "1", "-framerate", str(FPS), "-t", str(duration), "-i", str(LAYERS / foreground),
        "-stream_loop", "-1", "-i", str(env_file),
    ]
    if fx_kind:
        inputs += ["-stream_loop", "-1", "-i", str(fx_file)]
    filters, comp = composite_chain("a", 0, 1, duration, pan)
    # Environmental movement sits in the photographed space rather than on top as UI.
    # Screen blending must happen in RGB; doing it in YUV shifts neutral black toward magenta.
    filters.append(f"[{comp}]format=gbrp[scene_rgb]")
    filters.append(f"[2:v]scale={WIDTH}:{HEIGHT},setsar=1,format=gbrp[env]")
    filters.append(f"[scene_rgb][env]blend=all_mode=screen:all_opacity={'0.24' if rain else '0.18'}[moved]")
    current = "moved"
    if fx_kind:
        filters.append(f"[3:v]scale={WIDTH}:{HEIGHT},setsar=1,format=gbrp[marks]")
        filters.append(f"[{current}][marks]blend=all_mode=screen:all_opacity=0.58[marked]")
        current = "marked"
    # Micro-flicker and living film texture prevent locked areas from feeling frozen.
    filters.append(f"[{current}]eq=brightness='0.004*sin(17*t)+0.0025*sin(41*t)':eval=frame,vignette=PI/5.4,noise=alls=2:allf=t,format=yuv420p[graded]")
    current = "graded"
    if fade_in:
        filters.append(f"[{current}]fade=t=in:st=0:d={fade_in:.3f}[fi]")
        current = "fi"
    if fade_out:
        filters.append(f"[{current}]fade=t=out:st={max(0,duration-fade_out):.3f}:d={fade_out:.3f}[fo]")
        current = "fo"
    filters.append(f"[{current}]trim=duration={duration:.5f},setpts=PTS-STARTPTS[out]")
    run([
        ffmpeg, "-hide_banner", "-loglevel", "error", "-y", *inputs,
        "-filter_complex", ";".join(filters), "-map", "[out]", "-an",
        "-c:v", "libx264", "-preset", "medium", "-crf", "18", "-tune", "film", "-pix_fmt", "yuv420p", "-r", str(FPS), str(output),
    ])
    return output


def render_change_clip(index: int, name: str, duration: float, base: str, base_fg: str, changed: str, changed_fg: str, change_at: float, pan: tuple[float, float], fx_kind: str | None = None, rain: bool = False, fade_out: float = 0.0) -> Path:
    output = CLIPS / f"{index:02d}_{name}.mp4"
    ffmpeg = ffmpeg_executable()
    env_file = FX / ("rain.mp4" if rain else "dust.mp4")
    fx_file = render_investigation_fx(fx_kind, duration) if fx_kind else None
    inputs = []
    for image in (resolve(base), LAYERS / base_fg, resolve(changed), LAYERS / changed_fg):
        inputs += ["-loop", "1", "-framerate", str(FPS), "-t", str(duration), "-i", str(image)]
    inputs += ["-stream_loop", "-1", "-i", str(env_file)]
    if fx_file:
        inputs += ["-stream_loop", "-1", "-i", str(fx_file)]
    filters0, comp0 = composite_chain("a", 0, 1, duration, pan)
    filters1, comp1 = composite_chain("b", 2, 3, duration, pan)
    filters = filters0 + filters1
    transition = 0.14
    weight = f"clip((T-{change_at-transition/2:.4f})/{transition:.4f}\\,0\\,1)"
    filters.append(f"[{comp0}][{comp1}]blend=all_expr='A*(1-{weight})+B*{weight}'[changed]")
    filters.append("[changed]format=gbrp[changed_rgb]")
    filters.append(f"[4:v]scale={WIDTH}:{HEIGHT},setsar=1,format=gbrp[env]")
    filters.append(f"[changed_rgb][env]blend=all_mode=screen:all_opacity={'0.22' if rain else '0.16'}[alive]")
    current = "alive"
    if fx_file:
        filters.append(f"[5:v]scale={WIDTH}:{HEIGHT},setsar=1,format=gbrp[marks]")
        filters.append(f"[{current}][marks]blend=all_mode=screen:all_opacity=0.62[marked]")
        current = "marked"
    # Short focus bloom at the exact moment reality changes.
    filters.append(f"[{current}]split[sharp][blurinput]")
    filters.append(f"[blurinput]gblur=sigma=7[blurred]")
    focus = f"0.72*exp(-pow((T-{change_at:.4f})/0.17\\,2))"
    filters.append(f"[sharp][blurred]blend=all_expr='A*(1-({focus}))+B*({focus})'[focused]")
    filters.append("[focused]eq=brightness='0.004*sin(19*t)+0.002*sin(47*t)':eval=frame,vignette=PI/5.4,noise=alls=2:allf=t,format=yuv420p[graded]")
    current = "graded"
    if fade_out:
        filters.append(f"[{current}]fade=t=out:st={duration-fade_out:.3f}:d={fade_out:.3f}[fo]")
        current = "fo"
    filters.append(f"[{current}]trim=duration={duration:.5f},setpts=PTS-STARTPTS[out]")
    run([
        ffmpeg, "-hide_banner", "-loglevel", "error", "-y", *inputs,
        "-filter_complex", ";".join(filters), "-map", "[out]", "-an",
        "-c:v", "libx264", "-preset", "medium", "-crf", "18", "-tune", "film", "-pix_fmt", "yuv420p", "-r", str(FPS), str(output),
    ])
    return output


def draw_letterspaced(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, center_x: float, y: float, spacing: float, fill: tuple[int, int, int], reveal: float = 1.0) -> None:
    widths = [draw.textlength(char, font=font) for char in text]
    full_width = sum(widths) + spacing * max(0, len(text)-1)
    x = center_x - full_width / 2
    shown = reveal * len(text)
    for i, (char, width) in enumerate(zip(text, widths)):
        alpha = max(0.0, min(1.0, shown - i))
        if alpha > 0:
            color = tuple(int(channel * alpha) for channel in fill)
            draw.text((x, y), char, font=font, fill=color)
        x += width + spacing


def card_base(n: int, total: int) -> Image.Image:
    yy, xx = np.mgrid[0:HEIGHT, 0:WIDTH]
    p = n / max(1, total - 1)
    cx = WIDTH * (0.49 + 0.025 * math.sin(p * math.pi * 1.4))
    cy = HEIGHT * 0.47
    radial = np.sqrt(((xx-cx)/WIDTH)**2 + ((yy-cy)/HEIGHT)**2)
    glow = np.clip(1-radial*2.25, 0, 1)
    base = np.zeros((HEIGHT, WIDTH, 3), dtype=np.float32)
    pulse = 0.82 + 0.18 * math.sin(p * math.pi * 2.0) ** 2
    base[...,0] = 4 + glow * 8 * pulse
    base[...,1] = 6 + glow * 7 * pulse
    base[...,2] = 11 + glow * 22 * pulse
    return Image.fromarray(np.clip(base, 0, 255).astype(np.uint8), "RGB")


def render_motion_card(index: int, name: str, duration: float, kind: str, text: str = "") -> Path:
    output = CLIPS / f"{index:02d}_{name}.mp4"
    font_big = ImageFont.truetype(str(FONT_BOLD), 65)
    font_medium = ImageFont.truetype(str(FONT), 47)
    font_small = ImageFont.truetype(str(FONT), 21)

    def frame(n: int, total: int) -> Image.Image:
        p = n / max(1, total-1)
        t = n / FPS
        image = card_base(n, total)
        draw = ImageDraw.Draw(image)
        cx, cy = WIDTH//2, HEIGHT//2
        fade_in = smoothstep(p / 0.18)
        fade_out = smoothstep((1-p) / 0.16)
        opacity = fade_in * fade_out

        if kind == "opening":
            aperture = smoothstep((p-.35)/.55)
            span = 34 + 190 * aperture
            draw.arc((cx-span, cy-45, cx+span, cy+45), 185, 355, fill=(65,50,130), width=2)
            draw.arc((cx-span, cy-45, cx+span, cy+45), 5, 175, fill=(65,50,130), width=2)
            if p > .72:
                draw.ellipse((cx-3, cy-3, cx+3, cy+3), fill=PURPLE)
        elif kind == "countdown":
            countdown = max(0.0, 2.0 - p * 2.32)
            radius = 154 + 8 * math.sin(t*4)
            start = -90
            end = start + 360 * countdown / 2
            draw.arc((cx-radius, cy-radius, cx+radius, cy+radius), start, end, fill=PURPLE, width=3)
            count_font = ImageFont.truetype(str(FONT), 74)
            value = f"{countdown:0.2f}"
            box = draw.textbbox((0,0), value, font=count_font)
            draw.text((cx-(box[2]-box[0])/2, cy-58), value, font=count_font, fill=WHITE)
            draw_letterspaced(draw, "THE SCENE IS GONE", font_small, cx, cy+95, 7, MUTED, smoothstep((p-.26)/.45))
            scan_y = int(150 + p * 770)
            draw.line((cx-420, scan_y, cx+420, scan_y), fill=(40,32,85), width=1)
        elif kind in {"title", "final"}:
            settle = smoothstep(p / (.45 if kind == "title" else .28))
            radius_x = 85 + 235 * settle
            radius_y = 24 + 82 * settle
            spin = p * 24
            for offset, alpha in ((0,170),(35,80),(72,40)):
                box=(cx-radius_x-offset, cy-radius_y-offset*.24-95, cx+radius_x+offset, cy+radius_y+offset*.24-95)
                draw.arc(box, 188+spin, 350+spin, fill=(PURPLE[0],PURPLE[1],PURPLE[2]), width=2)
                draw.arc(box, 8+spin, 170+spin, fill=(PURPLE[0]//2,PURPLE[1]//2,PURPLE[2]//2), width=1)
            pupil = 5 + int(3*math.sin(t*4.5))
            draw.ellipse((cx-pupil, cy-95-pupil, cx+pupil, cy-95+pupil), fill=PURPLE)
            reveal = smoothstep((p-(.24 if kind=="title" else .16))/.36)
            draw_letterspaced(draw, "TWO SECOND WITNESS", font_big if kind=="title" else font_medium, cx, cy+80, 11, WHITE, reveal)
            if kind == "title":
                draw_letterspaced(draw, "HOW MUCH CAN YOU NOTICE IN TWO SECONDS?", font_small, cx, cy+185, 4, MUTED, smoothstep((p-.48)/.28))
        elif kind == "end":
            reveal = smoothstep((p-.08)/.54)
            spread = 5 + 10 * smoothstep(p)
            draw_letterspaced(draw, text.upper(), font_medium, cx, cy-22, spread, WHITE, reveal)
            line = 42 + int(105*smoothstep((p-.25)/.5))
            draw.line((cx-line, cy-80, cx+line, cy-80), fill=PURPLE, width=2)
            # Attention point traverses the line.
            dot_x = int(cx-line + 2*line*smoothstep(p))
            draw.ellipse((dot_x-3,cy-83,dot_x+3,cy-77), fill=(210,205,255))

        if opacity < .999:
            black = Image.new("RGB", image.size, "black")
            image = Image.blend(black, image, opacity)
        return image

    render_raw_video(output, duration, frame, size=(WIDTH, HEIGHT), crf=18)
    return output


def render_flash_clip(index: int, duration: float) -> Path:
    output = CLIPS / f"{index:02d}_flashes.mp4"
    names = ["02_hallway.png", "03_desk_documents.png", "05_photo_base.png", "09_face_base.png", "11_documents_base.png", "13_eye_closeup.png", "14_notes.png", "10_face_changed.png"]
    images = []
    for name in names:
        image = Image.open(resolve(name)).convert("RGB").resize((WIDTH, HEIGHT), Image.Resampling.LANCZOS)
        images.append(image)

    def frame(n: int, total: int) -> Image.Image:
        p = n / max(1,total-1)
        slot = min(len(images)-1, int(p*len(images)))
        local = (p*len(images)) % 1
        source = images[slot]
        zoom = 1.0 + .085 * local
        scaled = source.resize((int(WIDTH*zoom), int(HEIGHT*zoom)), Image.Resampling.LANCZOS)
        x = (scaled.width-WIDTH)//2 + int(15*math.sin(slot*2.1))
        y = (scaled.height-HEIGHT)//2 + int(8*math.cos(slot*1.7))
        frame_image = scaled.crop((x,y,x+WIDTH,y+HEIGHT))
        # Two-frame exposure snap sells perception rather than a slideshow cut.
        flash = max(0, 1-local/0.12)
        if flash > 0:
            frame_image = Image.blend(frame_image, Image.new("RGB", frame_image.size, (210,210,225)), flash*.42)
        return frame_image

    render_raw_video(output, duration, frame, size=(WIDTH,HEIGHT), crf=17)
    return output


def moving_average(values: np.ndarray, window: int) -> np.ndarray:
    padded = np.pad(values, (window//2, window-1-window//2), mode="edge")
    cumulative = np.cumsum(np.insert(padded.astype(np.float64),0,0.0))
    return ((cumulative[window:]-cumulative[:-window])/window).astype(np.float32)


def generate_audio() -> None:
    rate = 48000
    count = int(DURATION*rate)
    t = np.arange(count,dtype=np.float64)/rate
    rng = np.random.default_rng(2077)
    score = np.zeros((count,2),dtype=np.float32)

    # Breathing low-frequency room and a restrained upper harmonic.
    bed = 0.035*np.sin(2*np.pi*(42.0+.18*np.sin(2*np.pi*.028*t))*t)
    bed += 0.017*np.sin(2*np.pi*63*t+.7)*(0.7+.3*np.sin(2*np.pi*.045*t))
    bed += 0.006*np.sin(2*np.pi*126*t+1.2)
    noise = rng.normal(0,1,count).astype(np.float32)
    air = moving_average(noise,760)
    air /= max(1e-6,np.max(np.abs(air)))
    bed += air*.018
    score[:,0]=bed
    score[:,1]=bed

    def add_tone(at:float,freq:float,length:float,amp:float,pan:float=0.0,attack:float=.008):
        start=int(at*rate); n=min(int(length*rate),count-start)
        if n<=0:return
        local=np.arange(n,dtype=np.float64)/rate
        env=(1-np.exp(-local/max(attack,1e-4)))*np.exp(-local/max(length*.28,1e-4))
        tone=np.sin(2*np.pi*freq*local)*env*amp
        score[start:start+n,0]+=tone*math.sqrt((1-pan)/2)
        score[start:start+n,1]+=tone*math.sqrt((1+pan)/2)

    def add_boom(at:float,amp:float=.15):
        start=int(at*rate); n=min(int(2.4*rate),count-start)
        local=np.arange(n)/rate
        freq=56-25*local/max(local[-1],1e-6)
        phase=2*np.pi*np.cumsum(freq)/rate
        boom=np.sin(phase)*np.exp(-local*1.75)*amp
        score[start:start+n]+=boom[:,None]

    def add_whoosh(at:float,length:float=.55,amp:float=.055,pan:float=0):
        start=int(at*rate); n=min(int(length*rate),count-start)
        local=np.arange(n)/rate
        raw=rng.normal(0,1,n).astype(np.float32)
        smooth=moving_average(raw,55)
        high=raw-smooth
        env=np.sin(np.pi*np.clip(local/length,0,1))**2
        sound=high*env*amp
        score[start:start+n,0]+=sound*math.sqrt((1-pan)/2)
        score[start:start+n,1]+=sound*math.sqrt((1+pan)/2)

    # Shot transitions, change moments, and title punctuation.
    cuts=[1.5,6.7,10.9,16.1,20.6,24.8,28.8,33.3,37.5,40.5,43.7,45.5,49.5,54.0,58.0,64.0,65.2,71.2,72.8,74.4,76.8]
    for i,at in enumerate(cuts):
        add_whoosh(at-.16,.42,.028,(-.45 if i%2==0 else .45))
        add_tone(at,420 if i%3 else 310,1.0,.015,(-.25 if i%2 else .25))
    for at in (1.2,20.6,37.5,54.0,58.0,65.2,76.8): add_boom(at)
    for at in (23.55,27.55,31.9,36.25,69.7):
        add_tone(at,1680,.12,.060,0,.001)
        add_tone(at+.05,740,.33,.035,0,.001)

    # Two-second mechanism and image flashes.
    for at in np.arange(37.55,45.2,1.0):
        add_tone(float(at),1900,.09,.040,(-.35 if int(at)%2 else .35),.001)
    for at in np.arange(43.7,45.5,.225):
        add_tone(float(at),2450,.055,.032,0,.001)

    # Pencil friction under the observation notes.
    start=int(45.7*rate); end=int(49.35*rate); n=end-start
    scratch=rng.normal(0,1,n).astype(np.float32)
    scratch-=moving_average(scratch,35)
    lt=np.arange(n)/rate
    gate=(np.sin(2*np.pi*6.2*lt)>-.18).astype(np.float32)
    gate=moving_average(gate,180)
    scratch*=gate*.018
    score[start:end,0]+=scratch*.7; score[start:end,1]+=scratch*.4

    narration_bus=np.zeros(count,dtype=np.float32)
    for at,path in [(2.45,AUDIO/"narration_01.wav"),(11.2,AUDIO/"narration_02.wav"),(28.95,AUDIO/"narration_03.wav")]:
        voice=v1.read_wav_mono(path,rate)
        fade=min(int(.08*rate),len(voice)//2)
        voice[:fade]*=np.linspace(0,1,fade,dtype=np.float32)
        voice[-fade:]*=np.linspace(1,0,fade,dtype=np.float32)
        pos=int(at*rate); narration_bus[pos:pos+len(voice)]+=voice*.88
    envelope=moving_average(np.abs(narration_bus),int(.075*rate))
    duck=1-.58*np.clip(envelope/.065,0,1)
    score*=duck[:,None]
    score+=narration_bus[:,None]
    score=np.tanh(score*1.18)/1.18
    peak=np.max(np.abs(score))
    if peak>.94:score*=.94/peak
    v1.write_wav_stereo(GEN/"trailer_v2_mix.wav",score,rate)


def build_clips() -> list[Path]:
    clips: list[Path]=[]
    clips.append(render_motion_card(0,"opening",1.5,"opening"))
    clips.append(render_parallax_clip(1,"quiet",5.2,"01_quiet_room.png","quiet_fg.png",(16,7),rain=True,fade_in=.45))
    clips.append(render_parallax_clip(2,"hallway",4.2,"02_hallway.png","hallway_fg.png",(-20,3),fx_kind="observer"))
    clips.append(render_parallax_clip(3,"desk",5.2,"03_desk_documents.png","desk_fg.png",(20,-7),fx_kind="desk"))
    clips.append(render_parallax_clip(4,"observer",4.5,"04_observer.png","observer_fg.png",(-17,5),fx_kind="observer"))
    clips.append(render_change_clip(5,"photo_change",4.2,"05_photo_base.png","photo_fg.png","06_photo_changed.png","photo_changed_fg.png",2.95,(15,-6)))
    clips.append(render_change_clip(6,"object_move",4.0,"07_room_object_base.png","room_fg.png","08_room_object_changed.png","room_changed_fg.png",2.75,(-16,5)))
    clips.append(render_change_clip(7,"expression",4.5,"09_face_base.png","face_fg.png","10_face_changed.png","face_changed_fg.png",3.10,(13,-4)))
    clips.append(render_change_clip(8,"documents",4.2,"11_documents_base.png","docs_fg.png","12_documents_changed.png","docs_changed_fg.png",2.95,(-18,6),fx_kind="docs"))
    clips.append(render_motion_card(9,"countdown",3.0,"countdown"))
    clips.append(render_parallax_clip(10,"eye",3.2,"13_eye_closeup.png","iris_fg.png",(10,3),fx_kind="eye"))
    clips.append(render_flash_clip(11,1.8))
    clips.append(render_parallax_clip(12,"notes",4.0,"14_notes.png","notes_fg.png",(18,-8),fx_kind="notes"))
    clips.append(render_parallax_clip(13,"evidence",4.5,"04_observer.png","observer_fg.png",(-21,6),fx_kind="evidence"))
    clips.append(render_parallax_clip(14,"memory",4.0,"16_memory_reality.png","memory_fg.png",(14,4),fx_kind="memory"))
    clips.append(render_motion_card(15,"title",6.0,"title"))
    clips.append(render_motion_card(16,"pause",1.2,"opening"))
    clips.append(render_change_clip(17,"final_test",6.0,"01_quiet_room.png","quiet_fg.png","18_quiet_room_changed.png","quiet_changed_fg.png",4.50,(10,4),rain=True,fade_out=.45))
    clips.append(render_motion_card(18,"observe",1.6,"end","OBSERVE."))
    clips.append(render_motion_card(19,"remember",1.6,"end","REMEMBER."))
    clips.append(render_motion_card(20,"discover",2.4,"end","DISCOVER WHAT CHANGED."))
    clips.append(render_motion_card(21,"final",2.5,"final"))
    return clips


def assemble(clips: list[Path]) -> None:
    ffmpeg=ffmpeg_executable()
    concat=RENDER/"concat.txt"
    concat.write_text("".join(f"file '{clip.resolve()}'\n" for clip in clips))
    silent=RENDER/"silent_v2.mp4"
    run([ffmpeg,"-hide_banner","-loglevel","error","-y","-f","concat","-safe","0","-i",str(concat),"-c","copy",str(silent)])
    run([
        ffmpeg,"-hide_banner","-loglevel","error","-y","-i",str(silent),"-i",str(GEN/"trailer_v2_mix.wav"),
        "-map","0:v:0","-map","1:a:0","-c:v","copy",
        "-af","loudnorm=I=-16:TP=-1.5:LRA=11:measured_I=-20.36:measured_TP=-5.23:measured_LRA=17.70:measured_thresh=-33.21:offset=4.57:linear=false",
        "-c:a","aac","-b:a","256k","-ar","48000","-shortest","-movflags","+faststart",
        "-metadata","title=Two Second Witness — 2.5D Cinematic Identity Trailer",
        "-metadata","artist=ITTYBITTYBITES",
        "-metadata","comment=Observe. Remember. Discover what changed.",str(OUTPUT),
    ])


def main() -> None:
    ensure_directories()
    print("Generating changed observation frames...")
    v1.generate_changed_frames()
    # Preserve the first animatic once, so the improvement remains reviewable.
    if OUTPUT.exists() and not ARCHIVE_V1.exists():
        shutil.copy2(OUTPUT,ARCHIVE_V1)
    print("Separating 2.5D depth layers...")
    generate_layers()
    print("Rendering environmental motion...")
    render_environment_effects()
    print("Designing motion shots...")
    clips=build_clips()
    print("Building investigative sound mix...")
    generate_audio()
    print("Assembling final master...")
    assemble(clips)
    print(f"Created {OUTPUT} ({OUTPUT.stat().st_size/1024/1024:.1f} MB)")


if __name__=="__main__":
    main()
