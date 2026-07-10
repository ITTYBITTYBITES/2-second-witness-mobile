# Two Second Witness — 45-Second Cinematic Reveal Trailer (V3.1)

**Screening room:** [`player.html`](player.html)<br>
**1080p master:** [`two_second_witness_trailer.mp4`](two_second_witness_trailer.mp4)<br>
**One-command build:** `python trailer.py`

A frame-accurate 45-second psychological-thriller reveal for **Two Second Witness**. The V3.1 cut explains the complete observation loop through the edit itself: the audience sees a room for two seconds, loses it, sees the altered room, searches, selects the missing key, receives confirmation, and advances to a harder investigation.

## Delivery

- **Runtime:** exactly 00:45.000 / 1,080 frames
- **Picture:** 1920×1080, 24 fps, H.264 High Profile, YUV 4:2:0
- **Audio:** 48 kHz stereo AAC at 256 kbps, two-pass normalized toward −16 LUFS / −1.5 dBTP
- **Web:** MP4 fast-start metadata
- **Captions:** burned English captions plus sidecar SRT and WebVTT
- **End card:** title, `Observe. Remember. Discover.`, Google Play badge, and scannable Play Store QR

## Creative cut

### Act I — Curiosity (0:00–0:15)

Seven shorter shots now establish the world: a rain-darkened room, a steaming key-and-mug insert, a reflection-lit hallway, moving evidence papers, a breathing investigator with a micro-blink, and close/wide family-photograph coverage. The faster visual grammar increases activity without changing the restrained tone.

### Act II — Doubt (0:15–0:30)

A scarf changes colour beneath a print reflection. A chess piece moves during a practical-lamp dip. A witness changes expression on a blink. A case file changes behind a paper-light sweep. These scene-specific transitions replace the repeated focus bloom while the cut accelerates through `OBSERVE / REMEMBER / DETECT / CONFIRM / ADVANCE`.

### Act III — Gameplay (0:30–0:45)

The opening room returns beneath an exact `2.00` countdown. It disappears into intentional silence and returns without the brass key. The viewer searches; a moving reticle selects the key position; `CHANGE CONFIRMED — 1 OF 1 FOUND` responds; and `CASE 02 — 2 CHANGES TO FIND` proves progression. Title, tagline, Android CTA, Google Play badge, and QR resolve in one continuous 5.5-second end card.

## Automated V3.1 pipeline

[`../trailer.py`](../trailer.py) bootstraps an isolated Python environment on a clean machine and runs [`build_trailer_v3.py`](build_trailer_v3.py). The build is driven by [`trailer.yaml`](trailer.yaml).

The pipeline automatically:

1. validates and grades exactly five configured cinematic hero scenes;
2. creates five deterministic, matching changed plates;
3. estimates monocular pseudo-depth from perspective, focus, chroma, and saliency;
4. separates feathered foreground and reconstructed background planes;
5. animates depth-aware parallax with restrained dolly, lateral drift, and breathing;
6. renders independent rain, steam, hallway reflections, paper lift, handwriting, eye movement, character blinks, practical-light flicker, and film movement;
7. blends each object or expression change with a scene-specific reflection, lamp dip, blink, or paper sweep;
8. performs frame-accurate music-driven editing with a faster seven-shot opening;
9. renders the countdown, moving selection reticle, confirmation state, next-investigation state, aperture, unified end card, badge, and QR;
10. synthesizes the score, room tone, rain, footsteps, paper, pencil, selection click, confirmation chime, progression impact, swells, and title lift;
11. places and ducks the intimate investigator narration;
12. writes SRT, WebVTT, and ASS captions and burns the ASS captions into the master;
13. measures and normalizes loudness in two passes;
14. exports and validates the 45-second 1080p H.264/AAC web master;
15. extracts a new player poster.

Generated depth, masks, layers, effects, clips, and audio live in `trailer/.build_v3/` and are cached. They are reproducible and intentionally ignored by Git.

## Build

From the repository root:

```bash
python trailer.py
```

The launcher creates `.trailer-venv/` and installs pinned dependencies only when the current Python environment does not already provide them. FFmpeg is supplied by `imageio-ffmpeg`, so a system FFmpeg installation is optional.

Force every intermediate to rebuild:

```bash
python trailer.py --force
```

Direct development invocation:

```bash
python -m pip install -r trailer/requirements.txt
python trailer/build_trailer_v3.py
```

## Configuration

Edit [`trailer.yaml`](trailer.yaml) to change hero sources, changed plates, narration placement, grade, title metadata, output dimensions, frame rate, or Play Store destination. Shot lengths are authored in whole frames in `SHOTS` so the final cut cannot drift away from exactly 45 seconds.

The built-in depth estimator requires no network or model download. For a production using Depth Anything, MiDaS, or another estimator, replace `estimate_depth()`; the separation and animation stages consume the same grayscale depth output.

## Narration

The V3.1 cut preserves the approved narration and timing:

> Every witness believes they remember what happened.<br>
> Most of them are certain.<br>
> But memory isn't a recording.<br>
> It's a reconstruction.<br>
> Every detail matters.<br>
> Every glance counts.<br>
> Every decision begins with observation.<br>
> You have… two seconds.<br>
> What changed?<br>
> Play Two Second Witness now on Android.

The delivery is calm, measured, intimate, and deliberately non-commercial. Music dynamically ducks under each phrase, and the disappearance receives intentional near-silence.
