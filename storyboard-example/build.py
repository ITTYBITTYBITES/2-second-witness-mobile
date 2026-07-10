#!/usr/bin/env python3
"""Build the reusable Two Second Witness storyboard example from storyboard.yaml.

The example intentionally keeps every production step in one readable file:
configuration, image change, masks, parallax, environmental effects, title
animation, procedural audio, narration placement, loudness normalization, and
final H.264 encoding.
"""

from __future__ import annotations

import argparse
import math
from pathlib import Path
import shutil
import subprocess
import sys
import wave

try:
    import numpy as np
    from PIL import Image, ImageDraw, ImageFilter, ImageFont
    import yaml
except ImportError as exc:
    raise SystemExit(
        "Install dependencies first:\n"
        "  python3 -m pip install -r storyboard-example/requirements.txt"
    ) from exc

HERE = Path(__file__).resolve().parent
BUILD = HERE / ".build"
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
PURPLE = (124, 92, 255)
WHITE = (238, 239, 243)
MUTED = (148, 153, 166)


def ffmpeg_executable() -> str:
    system_binary = shutil.which("ffmpeg")
    if system_binary:
        return system_binary
    try:
        import imageio_ffmpeg
    except ImportError as exc:
        raise SystemExit("Install imageio-ffmpeg or place ffmpeg on PATH.") from exc
    return imageio_ffmpeg.get_ffmpeg_exe()


def run(command: list[str]) -> None:
    print("+", " ".join(command))
    subprocess.run(command, check=True)


def project_path(value: str) -> Path:
    return (HERE / value).resolve()


def normalized_polygons(polygons: list, width: int, height: int) -> list[list[tuple[int, int]]]:
    return [
        [(round(float(x) * width), round(float(y) * height)) for x, y in polygon]
        for polygon in polygons
    ]


def create_foreground_layer(source_path: Path, polygons: list, output_path: Path) -> None:
    image = Image.open(source_path).convert("RGBA")
    mask = Image.new("L", image.size, 0)
    draw = ImageDraw.Draw(mask)
    for polygon in normalized_polygons(polygons, *image.size):
        draw.polygon(polygon, fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(max(6, round(image.width * 0.007))))
    image.putalpha(mask)
    image.save(output_path, optimize=True)


def create_changed_image(source_path: Path, change: dict, output_path: Path) -> None:
    """Create the example's altered photograph while preserving print texture."""
    if change.get("type") != "recolor_red_to_blue":
        raise ValueError(f"Unsupported example change: {change.get('type')}")
    image = Image.open(source_path).convert("RGB")
    pixels = np.asarray(image).astype(np.float32)
    height, width = pixels.shape[:2]
    center_x, center_y, radius_x, radius_y = map(float, change["region"])
    yy, xx = np.mgrid[0:height, 0:width]
    spatial = (
        ((xx - center_x * width) / (radius_x * width)) ** 2
        + ((yy - center_y * height) / (radius_y * height)) ** 2
    ) < 1.0
    red = (pixels[..., 0] > pixels[..., 1] * 1.08) & (pixels[..., 0] > pixels[..., 2] * 1.12)
    selection = spatial & red
    luma = pixels[..., 0] * 0.30 + pixels[..., 1] * 0.59 + pixels[..., 2] * 0.11
    blue = np.stack((luma * 0.53, luma * 0.73, luma * 0.92), axis=-1)
    mask = Image.fromarray((selection * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(2.2))
    changed = Image.composite(
        Image.fromarray(np.clip(blue, 0, 255).astype(np.uint8)), image, mask
    )
    changed.save(output_path, optimize=True)


def render_raw_video(path: Path, seconds: float, width: int, height: int, fps: int, frame_function, crf: int = 21) -> None:
    frame_count = round(seconds * fps)
    command = [
        ffmpeg_executable(), "-hide_banner", "-loglevel", "error", "-y",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{width}x{height}",
        "-r", str(fps), "-i", "-", "-an", "-c:v", "libx264", "-preset", "medium",
        "-crf", str(crf), "-pix_fmt", "yuv420p", "-r", str(fps), str(path),
    ]
    process = subprocess.Popen(command, stdin=subprocess.PIPE)
    assert process.stdin is not None
    try:
        for frame_number in range(frame_count):
            frame = frame_function(frame_number, frame_count).convert("RGB")
            process.stdin.write(np.asarray(frame, dtype=np.uint8).tobytes())
    finally:
        process.stdin.close()
    if process.wait() != 0:
        raise RuntimeError(f"Failed to render {path}")


def smoothstep(value: float) -> float:
    value = max(0.0, min(1.0, value))
    return value * value * (3.0 - 2.0 * value)


def make_effect_video(shot: dict, width: int, height: int, fps: int, output: Path) -> None:
    duration = float(shot["duration"])
    effects = set(shot.get("effects", []))
    effect_width, effect_height = width // 2, height // 2
    seed = sum(ord(character) for character in shot["name"])
    rng = np.random.default_rng(seed)
    count = 45
    px = rng.uniform(0, effect_width, count)
    py = rng.uniform(0, effect_height, count)
    speed = rng.uniform(2, 10, count)
    brightness = rng.integers(18, 70, count)
    rain_x = rng.uniform(-50, effect_width, 65)
    rain_y = rng.uniform(-effect_height, effect_height, 65)
    rain_speed = rng.uniform(10, 22, 65)

    def frame(n: int, total: int) -> Image.Image:
        p = n / max(1, total - 1)
        image = Image.new("RGB", (effect_width, effect_height), "black")
        draw = ImageDraw.Draw(image)
        if "dust" in effects:
            for i in range(count):
                x = (px[i] + n * speed[i] * 0.025 + 8 * math.sin(i + n * 0.02)) % effect_width
                y = (py[i] - n * speed[i] * 0.035) % effect_height
                value = int(brightness[i] * (0.6 + 0.4 * math.sin(i + n * 0.04) ** 2))
                radius = 1 if i % 5 else 2
                draw.ellipse((x-radius, y-radius, x+radius, y+radius), fill=(value, value, min(95, value+8)))
        if "rain" in effects:
            for i in range(len(rain_x)):
                x = (rain_x[i] + n * rain_speed[i] * 0.12) % (effect_width + 50) - 25
                y = (rain_y[i] + n * rain_speed[i]) % (effect_height + 80) - 40
                value = 30 + i % 28
                draw.line((x, y, x+4, y+22), fill=(value//2, value//2+4, value), width=1)
        if "evidence_scan" in effects:
            scan_y = round(effect_height * (0.18 + 0.64 * smoothstep(p)))
            draw.line((effect_width*.12, scan_y, effect_width*.90, scan_y), fill=(65, 52, 155), width=2)
            for i, x in enumerate((.25, .43, .61, .79)):
                if p > .20 + i * .12:
                    left = int(effect_width*x - 18)
                    draw.rectangle((left, int(effect_height*.20), left+38, int(effect_height*.38)), outline=(100, 82, 220), width=1)
        # Moving illumination provides motion even in unmasked background areas.
        glow_x = round(effect_width * (.18 + .64 * smoothstep(p)))
        glow = Image.new("L", image.size, 0)
        ImageDraw.Draw(glow).ellipse((glow_x-75, 35, glow_x+75, effect_height-35), fill=20)
        glow = glow.filter(ImageFilter.GaussianBlur(55))
        image = Image.composite(Image.new("RGB", image.size, (82, 70, 130)), image, glow)
        return image

    render_raw_video(output, duration, effect_width, effect_height, fps, frame, crf=19)


def transform_filter(label_in: str, label_out: str, duration: float, width: int, height: int, zoom: list, pan_x: float, pan_y: float, rgba: bool = False) -> str:
    start, end = map(float, zoom)
    scale = f"({start:.5f}+({end-start:.5f})*t/{duration:.5f})"
    scaled_width = f"trunc({width}*{scale}/2)*2"
    scaled_height = f"trunc({height}*{scale}/2)*2"
    crop_x = f"(in_w-{width})/2+({pan_x:.3f})*(t/{duration:.5f}-.5)"
    crop_y = f"(in_h-{height})/2+({pan_y:.3f})*(t/{duration:.5f}-.5)"
    pixel_format = ",format=rgba" if rgba else ""
    return (
        f"[{label_in}]scale=w='{scaled_width}':h='{scaled_height}':eval=frame,"
        f"crop={width}:{height}:x='{crop_x}':y='{crop_y}',setsar=1{pixel_format}[{label_out}]"
    )


def composite_filters(prefix: str, bg_index: int, fg_index: int, shot: dict, width: int, height: int) -> tuple[list[str], str]:
    duration = float(shot["duration"])
    camera = shot["camera"]
    pan_x, pan_y = map(float, camera.get("pan", [0, 0]))
    filters = [
        transform_filter(str(bg_index), f"{prefix}bg", duration, width, height, camera["background_zoom"], pan_x, pan_y),
        transform_filter(str(fg_index), f"{prefix}fg", duration, width, height, camera["foreground_zoom"], -pan_x*1.45, -pan_y*1.35, True),
        f"[{prefix}bg][{prefix}fg]overlay=0:0:format=auto[{prefix}scene]",
    ]
    return filters, f"{prefix}scene"


def render_image_shot(index: int, shot: dict, width: int, height: int, fps: int) -> Path:
    duration = float(shot["duration"])
    source = project_path(shot["image"])
    shot_dir = BUILD / shot["name"]
    shot_dir.mkdir(parents=True, exist_ok=True)
    foreground = shot_dir / "foreground.png"
    create_foreground_layer(source, shot["foreground_polygons"], foreground)
    effects = shot_dir / "effects.mp4"
    make_effect_video(shot, width, height, fps, effects)
    output = BUILD / f"{index:02d}_{shot['name']}.mp4"

    input_args = [
        "-loop", "1", "-framerate", str(fps), "-t", str(duration), "-i", str(source),
        "-loop", "1", "-framerate", str(fps), "-t", str(duration), "-i", str(foreground),
    ]
    filters, scene = composite_filters("a", 0, 1, shot, width, height)
    effect_index = 2

    if shot["type"] == "change":
        changed = shot_dir / "changed.png"
        changed_foreground = shot_dir / "changed_foreground.png"
        create_changed_image(source, shot["change"], changed)
        create_foreground_layer(changed, shot["foreground_polygons"], changed_foreground)
        input_args += [
            "-loop", "1", "-framerate", str(fps), "-t", str(duration), "-i", str(changed),
            "-loop", "1", "-framerate", str(fps), "-t", str(duration), "-i", str(changed_foreground),
        ]
        changed_filters, changed_scene = composite_filters("b", 2, 3, shot, width, height)
        filters += changed_filters
        effect_index = 4
        change_at = float(shot["change_at"])
        transition = 0.14
        weight = f"clip((T-{change_at-transition/2:.4f})/{transition:.4f}\\,0\\,1)"
        filters.append(f"[{scene}][{changed_scene}]blend=all_expr='A*(1-{weight})+B*{weight}'[changed]")
        scene = "changed"

    input_args += ["-stream_loop", "-1", "-i", str(effects)]
    # Convert to RGB before screen blending. Screen blending neutral black in YUV causes a color cast.
    filters += [
        f"[{scene}]format=gbrp[scene_rgb]",
        f"[{effect_index}:v]scale={width}:{height},format=gbrp[fx]",
        "[scene_rgb][fx]blend=all_mode=screen:all_opacity=0.48[alive]",
    ]
    current = "alive"
    if shot["type"] == "change" and "focus_bloom" in shot.get("effects", []):
        change_at = float(shot["change_at"])
        filters += [
            f"[{current}]split[sharp][blurinput]",
            "[blurinput]gblur=sigma=6[blurred]",
        ]
        focus = f"0.68*exp(-pow((T-{change_at:.4f})/0.18\\,2))"
        filters.append(f"[sharp][blurred]blend=all_expr='A*(1-({focus}))+B*({focus})'[focused]")
        current = "focused"
    flicker = "0.004*sin(17*t)+0.002*sin(41*t)" if "light_flicker" in shot.get("effects", []) else "0"
    filters.append(
        f"[{current}]eq=brightness='{flicker}':eval=frame,vignette=PI/5.5,noise=alls=2:allf=t,"
        f"trim=duration={duration:.5f},setpts=PTS-STARTPTS,format=yuv420p[out]"
    )
    run([
        ffmpeg_executable(), "-hide_banner", "-loglevel", "error", "-y", *input_args,
        "-filter_complex", ";".join(filters), "-map", "[out]", "-an",
        "-c:v", "libx264", "-preset", "medium", "-crf", "21", "-tune", "film",
        "-pix_fmt", "yuv420p", "-r", str(fps), str(output),
    ])
    return output


def letterspaced(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, center_x: float, y: float, spacing: float, color: tuple[int, int, int], reveal: float) -> None:
    widths = [draw.textlength(character, font=font) for character in text]
    x = center_x - (sum(widths) + spacing * max(0, len(text)-1)) / 2
    shown = reveal * len(text)
    for i, (character, character_width) in enumerate(zip(text, widths)):
        opacity = max(0.0, min(1.0, shown-i))
        if opacity:
            draw.text((x, y), character, font=font, fill=tuple(round(value*opacity) for value in color))
        x += character_width + spacing


def render_title_shot(index: int, shot: dict, width: int, height: int, fps: int) -> Path:
    output = BUILD / f"{index:02d}_{shot['name']}.mp4"
    duration = float(shot["duration"])
    headline_font = ImageFont.truetype(str(FONT_BOLD), round(height * 0.060))
    subhead_font = ImageFont.truetype(str(FONT), round(height * 0.020))

    yy, xx = np.mgrid[0:height, 0:width]
    radial = np.sqrt(((xx-width*.5)/width)**2 + ((yy-height*.46)/height)**2)
    glow = np.clip(1-radial*2.25, 0, 1)
    background = np.zeros((height, width, 3), dtype=np.float32)
    background[..., 0] = 4 + glow*8
    background[..., 1] = 6 + glow*7
    background[..., 2] = 11 + glow*22
    background_image = Image.fromarray(np.clip(background, 0, 255).astype(np.uint8))

    def frame(n: int, total: int) -> Image.Image:
        p = n/max(1,total-1)
        t = n/fps
        image = background_image.copy()
        draw = ImageDraw.Draw(image)
        cx, cy = width//2, round(height*.43)
        settle = smoothstep(p/.45)
        radius_x = round(width*(.045+.125*settle))
        radius_y = round(height*(.020+.075*settle))
        spin = p*25
        for offset in (0, round(width*.018), round(width*.037)):
            box=(cx-radius_x-offset,cy-radius_y-round(offset*.22),cx+radius_x+offset,cy+radius_y+round(offset*.22))
            draw.arc(box,188+spin,350+spin,fill=PURPLE,width=2)
            draw.arc(box,8+spin,170+spin,fill=(62,46,128),width=1)
        pupil=4+round(2*math.sin(t*4.5))
        draw.ellipse((cx-pupil,cy-pupil,cx+pupil,cy+pupil),fill=PURPLE)
        letterspaced(draw,shot["headline"],headline_font,cx,round(height*.58),round(width*.006),WHITE,smoothstep((p-.20)/.38))
        letterspaced(draw,shot["subhead"],subhead_font,cx,round(height*.70),round(width*.0025),MUTED,smoothstep((p-.48)/.28))
        fade=smoothstep(p/.12)*smoothstep((1-p)/.12)
        return Image.blend(Image.new("RGB",image.size,"black"),image,fade)

    render_raw_video(output,duration,width,height,fps,frame,crf=20)
    return output


def read_narration(path: Path, target_rate: int) -> np.ndarray:
    with wave.open(str(path),"rb") as source:
        channels=source.getnchannels(); sample_width=source.getsampwidth(); rate=source.getframerate()
        samples=np.frombuffer(source.readframes(source.getnframes()),dtype="<i2").astype(np.float32)/32768
    if sample_width!=2:
        raise ValueError("The example expects 16-bit narration WAV files.")
    if channels>1:
        samples=samples.reshape(-1,channels).mean(axis=1)
    if rate!=target_rate:
        old=np.arange(len(samples))/rate
        new=np.arange(round(len(samples)*target_rate/rate))/target_rate
        samples=np.interp(new,old,samples).astype(np.float32)
    return samples


def write_wav(path: Path, samples: np.ndarray, rate: int) -> None:
    pcm=(np.clip(samples,-1,1)*32767).astype("<i2")
    with wave.open(str(path),"wb") as output:
        output.setnchannels(2); output.setsampwidth(2); output.setframerate(rate); output.writeframes(pcm.tobytes())


def build_audio(config: dict, duration: float) -> Path:
    rate=48000; count=round(duration*rate); t=np.arange(count)/rate
    rng=np.random.default_rng(22)
    bed=.035*np.sin(2*np.pi*(43+.12*np.sin(2*np.pi*.03*t))*t)
    bed+=.016*np.sin(2*np.pi*64.5*t+.5)
    noise=rng.normal(0,1,count).astype(np.float32)
    cumulative=np.cumsum(np.insert(np.pad(noise,(350,349),mode="edge").astype(np.float64),0,0))
    air=((cumulative[700:]-cumulative[:-700])/700).astype(np.float32)
    air/=max(1e-6,np.max(np.abs(air)))
    bed+=air*.016
    mix=np.stack((bed,bed),axis=1).astype(np.float32)

    position=0.0
    for shot in config["shots"][:-1]:
        position+=float(shot["duration"])
        start=round(position*rate); length=min(round(.45*rate),count-start)
        if length>0:
            local=np.arange(length)/rate
            sweep=rng.normal(0,1,length)*np.sin(np.pi*local/.45)**2*.025
            mix[start:start+length,0]+=sweep*.8; mix[start:start+length,1]+=sweep*.5
    # Observation ticks before the title.
    for at in (8.0,10.0,12.0):
        start=round(at*rate); length=round(.12*rate); local=np.arange(length)/rate
        click=np.sin(2*np.pi*1600*local)*np.exp(-local*35)*.045
        mix[start:start+length]+=click[:,None]

    voice_bus=np.zeros(count,dtype=np.float32)
    for narration in config.get("narration",[]):
        voice=read_narration(project_path(narration["file"]),rate)
        start=round(float(narration["at"])*rate)
        length=min(len(voice),count-start)
        voice_bus[start:start+length]+=voice[:length]*.86
    # Simple score ducking around the voice.
    window=round(.075*rate)
    padded=np.pad(np.abs(voice_bus),(window//2,window-1-window//2),mode="edge")
    cumulative=np.cumsum(np.insert(padded.astype(np.float64),0,0))
    envelope=((cumulative[window:]-cumulative[:-window])/window).astype(np.float32)
    mix*= (1-.55*np.clip(envelope/.065,0,1))[:,None]
    mix+=voice_bus[:,None]
    mix=np.tanh(mix*1.15)/1.15
    audio=BUILD/"storyboard_mix.wav"
    write_wav(audio,mix,rate)
    return audio


def build(config_path: Path) -> Path:
    config=yaml.safe_load(config_path.read_text())
    project=config["project"]
    width=int(project["width"]); height=int(project["height"]); fps=int(project["fps"])
    BUILD.mkdir(parents=True,exist_ok=True)
    clips=[]
    for index,shot in enumerate(config["shots"]):
        print(f"Rendering shot {index+1}/{len(config['shots'])}: {shot['name']}")
        if shot["type"]=="title_card":
            clips.append(render_title_shot(index,shot,width,height,fps))
        else:
            clips.append(render_image_shot(index,shot,width,height,fps))
    concat=BUILD/"concat.txt"
    concat.write_text("".join(f"file '{clip.resolve()}'\n" for clip in clips))
    silent=BUILD/"storyboard_silent.mp4"
    run([ffmpeg_executable(),"-hide_banner","-loglevel","error","-y","-f","concat","-safe","0","-i",str(concat),"-c","copy",str(silent)])
    duration=sum(float(shot["duration"]) for shot in config["shots"])
    audio=build_audio(config,duration)
    output=project_path(project["output"])
    output.parent.mkdir(parents=True,exist_ok=True)
    run([
        ffmpeg_executable(),"-hide_banner","-loglevel","error","-y","-i",str(silent),"-i",str(audio),
        "-map","0:v:0","-map","1:a:0","-c:v","copy","-af","loudnorm=I=-16:TP=-1.5:LRA=11",
        "-c:a","aac","-b:a","160k","-ar","48000","-shortest","-movflags","+faststart",
        "-metadata",f"title={project['title']}",str(output),
    ])
    print(f"\nCreated: {output}\nRuntime: {duration:.1f}s")
    return output


def main() -> None:
    parser=argparse.ArgumentParser(description="Build the Two Second Witness storyboard example.")
    parser.add_argument("--config",type=Path,default=HERE/"storyboard.yaml")
    args=parser.parse_args()
    build(args.config.resolve())


if __name__=="__main__":
    main()
