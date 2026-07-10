# Storyboard Example

A small, working version of the automated 2.5D trailer pipeline used for **Two Second Witness**.

This example turns three generated still images and one narration clip into a 15-second motion storyboard containing:

- Layered foreground/background parallax
- Animated rain, dust, light, and evidence scanning
- A photograph that changes during continuous camera movement
- A focus bloom over the hidden change
- An animated aperture and title reveal
- Procedural suspense ambience and transition sounds
- Narration ducking and web loudness normalization
- H.264/AAC final delivery

The included rendered result is:

[`output/two_second_witness_storyboard_example.mp4`](output/two_second_witness_storyboard_example.mp4)

## Quick start

From the repository root:

```bash
python3 -m pip install -r storyboard-example/requirements.txt
python3 storyboard-example/build.py
```

If FFmpeg is installed on the system, the script uses it. Otherwise, `imageio-ffmpeg` supplies a static FFmpeg binary.

## Files

```text
storyboard-example/
├── README.md                 This guide
├── prompts.md                Reusable image-generation prompts
├── storyboard.yaml           Human-editable shot list
├── build.py                  Complete example renderer
├── requirements.txt          Python dependencies
└── output/
    └── two_second_witness_storyboard_example.mp4
```

Temporary masks, changed images, effects, audio, and shot renders are written to `.build/` and ignored by Git.

## How the configuration works

Each image shot in `storyboard.yaml` contains:

```yaml
- name: quiet_room
  type: parallax
  image: ../trailer/assets/01_quiet_room.png
  duration: 4.0
  camera:
    background_zoom: [1.025, 1.070]
    foreground_zoom: [1.050, 1.115]
    pan: [14, 6]
  foreground_polygons:
    - [[0.209, 0.287], [0.616, 0.276], ...]
  effects: [rain, dust, light_flicker]
```

### Normalized mask coordinates

Mask points use values between `0` and `1` rather than pixels:

```text
normalized_x = pixel_x / image_width
normalized_y = pixel_y / image_height
```

That makes the masks independent of render resolution.

For a 1,600×900 image, a point at pixel `(800, 450)` becomes:

```yaml
[0.5, 0.5]
```

Add several points around the foreground subject to create a polygon. The script feathers the result automatically.

## Creating a hidden change

The photograph shot demonstrates a programmatic color change:

```yaml
change:
  type: recolor_red_to_blue
  region: [0.522, 0.616, 0.047, 0.154]
```

The values represent:

```text
center_x, center_y, radius_x, radius_y
```

For production work, a matching image-to-image edit is usually preferable. The script only needs two images with identical framing; the change does not have to be created in Python.

## Camera movement

The illusion of depth comes from moving two versions of the scene differently:

```yaml
background_zoom: [1.025, 1.070]
foreground_zoom: [1.050, 1.115]
```

The foreground starts closer and moves farther than the background. Foreground panning also travels in the opposite direction, creating a restrained dolly effect.

Use small values. Excessive separation exposes the unchanged subject still present in the background plate.

## Replacing the images

1. Generate a 16:9 image using a prompt from `prompts.md`.
2. Put it anywhere in the repository.
3. Change `image:` in `storyboard.yaml`.
4. Draw a normalized polygon around its foreground subject.
5. Adjust camera and effect settings.
6. Run `build.py` again.

If the composition changes, the foreground polygon must also change.

## Extending the system

Useful next steps include:

- Replace polygon masks with Segment Anything or `rembg`.
- Generate depth maps using Depth Anything or MiDaS.
- Add multiple depth planes rather than one foreground layer.
- Add image-to-image edits through an image-generation API.
- Move effect settings such as particle density into YAML.
- Add narration text-to-speech generation before the build.
- Add automatic subtitle generation.
- Create 16:9, 9:16, and 1:1 outputs from the same shot list.

## Important limitation

This is 2.5D compositing, not character animation. It can make still environments feel cinematic through depth, lighting, particles, graphic overlays, and controlled transformations. It cannot make a person naturally walk, turn, or speak without real footage, 3D animation, or a video-generation model.
