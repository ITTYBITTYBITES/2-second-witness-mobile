# Two Second Witness — Cinematic Trailer

**Playable screening room:** [`player.html`](player.html)  
**Master:** [`two_second_witness_trailer.mp4`](two_second_witness_trailer.mp4)

An 83-second, 16:9 cinematic trailer for the psychological observation mystery game **Two Second Witness**.

## Delivery specification

- **Runtime:** 1:23
- **Picture:** 1920×1080, 24 fps, H.264 High Profile, YUV 4:2:0
- **Audio:** 48 kHz stereo AAC, 256 kbps
- **Container:** MP4 with fast-start metadata for web playback
- **Tone:** restrained investigative mystery; cool slate shadows, practical amber light, subtle violet observation motif
- **Accessibility:** sidecar English captions in `two_second_witness_trailer.srt`

## Creative structure

1. **Ordinary reality** — a quiet room, institutional hallway, investigator's desk, and observer are revealed through slow camera movement.
2. **Memory changes** — a photograph's scarf changes color, a chess knight moves, an expression shifts, and a witness portrait is duplicated.
3. **Two-second mechanic** — an eye, timed flashes, written notes, evidence, and overlapping versions of reality introduce the observation loop.
4. **Title reveal** — `TWO SECOND WITNESS` emerges through a minimal aperture motif.
5. **Final test** — the opening room returns. After a held pause, the brass key disappears.
6. **End line** — `OBSERVE. REMEMBER. DISCOVER WHAT CHANGED.`

The narration uses the requested copy verbatim:

> Every moment, your mind decides what to remember.  
> Every detail you notice becomes part of your reality.  
> But what happens when your memory fills in something that was never there?

## Audio direction

The soundtrack is an original procedural sound design built for this trailer: low harmonic room tone, quiet investigative pulses, two-second clinical ticks, restrained transitions, and a sparse sub-bass title reveal. The narration remains calm and centered while the score ducks beneath it.

## Rebuilding the master

The build is deterministic apart from the supplied source stills and narration. It regenerates altered frames, graphics, score, mix, and the final video.

```bash
python3 -m pip install pillow numpy imageio-ffmpeg
python3 trailer/build_trailer.py
```

The script can also use a system `ffmpeg` if one is installed. Temporary render clips and generated intermediates are intentionally ignored by Git.
