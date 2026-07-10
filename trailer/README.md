# Two Second Witness — 2.5D Cinematic Identity Trailer

**Playable screening room:** [`player.html`](player.html)  
**Master:** [`two_second_witness_trailer.mp4`](two_second_witness_trailer.mp4)

A 79-second, 16:9 identity trailer for the psychological observation mystery game **Two Second Witness**. This second-generation cut replaces the original still-image animatic with layered depth motion and continuous in-shot animation.

## Delivery specification

- **Runtime:** 1:19
- **Picture:** 1920×1080, 24 fps, H.264 High Profile, YUV 4:2:0
- **Audio:** 48 kHz stereo AAC, 256 kbps; web-normalized to approximately −16 LUFS
- **Container:** MP4 with fast-start metadata for web playback
- **Tone:** restrained investigative mystery; cool slate shadows, practical amber light, subtle violet observation motif
- **Accessibility:** English captions in SRT and WebVTT formats

## Motion treatment

- Foreground and background planes move at different speeds to create cinematic parallax depth.
- Rain, drifting particles, light flicker, film texture, and moving illumination keep environments alive.
- Photographs, furniture, expressions, and documents transform continuously within shots instead of appearing as separate slides.
- Animated scans, attention reticles, evidence points, connecting threads, and writing marks visualize the investigation.
- Focus blooms conceal each reality change for a fraction of a second.
- The eye makes an independent micro-saccade while reflected evidence and observation rings move across it.
- Countdown, aperture, title, and end cards are fully animated frame-by-frame.
- A rapid perception montage breaks the slow-burn rhythm before the evidence sequence.

## Creative structure

1. **Ordinary reality** — a rain-darkened room, institutional hallway, investigator's desk, and observer move through layered cinematic space.
2. **Memory changes** — a photograph's scarf changes color, a chess knight moves, an expression shifts, and a witness portrait is duplicated.
3. **Two-second mechanic** — an animated countdown, moving eye, timed flashes, written notes, and evidence connections introduce the observation loop.
4. **Memory versus reality** — misaligned depth planes and a scanning comparison divide what was seen from what was present.
5. **Title reveal** — `TWO SECOND WITNESS` assembles inside a moving observation aperture.
6. **Final test** — the opening room returns with rain and parallax motion; after a focus bloom, the brass key disappears.
7. **End line** — `OBSERVE. REMEMBER. DISCOVER WHAT CHANGED.`

The narration uses the requested copy verbatim:

> Every moment, your mind decides what to remember.  
> Every detail you notice becomes part of your reality.  
> But what happens when your memory fills in something that was never there?

## Audio direction

The rebuilt mix adds spatial transition sweeps, perception snaps, two-second ticks, pencil friction, environmental air, stereo evidence cues, and deeper title impacts. The calm narration remains centered while the score dynamically ducks beneath it.

## Rebuilding the master

```bash
python3 -m pip install pillow numpy imageio-ffmpeg
python3 trailer/build_trailer_v2.py
```

The script regenerates changed frames, depth layers, environmental loops, investigative overlays, frame-by-frame motion graphics, sound mix, and final master. It can use either a system `ffmpeg` or the static binary supplied by `imageio-ffmpeg`. Generated intermediates are intentionally ignored by Git.
