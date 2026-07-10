# Complete Two Second Witness Trailer Workflow
## From Creative Prompt to Finished 2.5D Trailer on Windows 11

This document explains the complete production process used to create the **Two Second Witness** 2.5D cinematic identity trailer. It covers concept development, image generation, changed-image creation, foreground masking, parallax animation, environmental effects, title animation, narration, procedural sound, FFmpeg encoding, validation, and Windows 11 setup.

The workflow is designed to be repeatable. Once the source images and narration clips exist, the remaining production can be automated.

---

## Table of contents

1. [What this workflow creates](#1-what-this-workflow-creates)
2. [Important technical distinction](#2-important-technical-distinction)
3. [Original creative brief](#3-original-creative-brief)
4. [Production architecture](#4-production-architecture)
5. [Windows 11 requirements](#5-windows-11-requirements)
6. [Installing the tools on Windows 11](#6-installing-the-tools-on-windows-11)
7. [Downloading and preparing the repository](#7-downloading-and-preparing-the-repository)
8. [Generating the source images](#8-generating-the-source-images)
9. [Exact source-image prompts](#9-exact-source-image-prompts)
10. [Creating changed versions](#10-creating-changed-versions)
11. [Generating or recording narration](#11-generating-or-recording-narration)
12. [Planning the storyboard](#12-planning-the-storyboard)
13. [Creating foreground masks](#13-creating-foreground-masks)
14. [How the 2.5D animation works](#14-how-the-25d-animation-works)
15. [Environmental and evidence animation](#15-environmental-and-evidence-animation)
16. [Hidden-change transitions](#16-hidden-change-transitions)
17. [Motion graphics and title animation](#17-motion-graphics-and-title-animation)
18. [Sound design and mastering](#18-sound-design-and-mastering)
19. [Building the 15-second learning example](#19-building-the-15-second-learning-example)
20. [Building the complete 79-second trailer](#20-building-the-complete-79-second-trailer)
21. [Validating the finished video](#21-validating-the-finished-video)
22. [Customizing the system](#22-customizing-the-system)
23. [Troubleshooting on Windows 11](#23-troubleshooting-on-windows-11)
24. [Production checklist](#24-production-checklist)
25. [What is automated and what remains creative](#25-what-is-automated-and-what-remains-creative)
26. [Recommended next improvements](#26-recommended-next-improvements)

---

# 1. What this workflow creates

The complete build produces a cinematic identity trailer with:

- 1920×1080 output
- 24 frames per second
- H.264 High Profile video
- 48 kHz stereo AAC audio
- Approximately 79 seconds of runtime
- Layered foreground/background camera motion
- Animated rain, dust, light, and film texture
- Animated evidence scans, attention points, and connecting lines
- A photograph whose detail changes during the shot
- A room where an object changes position
- A face whose expression changes subtly
- Documents containing a duplicated witness portrait
- A moving eye and observation reticle
- Frame-by-frame countdown and title animation
- Procedural suspense score and sound effects
- Calm investigative narration
- English SRT and WebVTT caption files
- MP4 fast-start metadata for web playback
- Audio normalized to approximately −16 LUFS

The smaller `storyboard-example` build creates a 15-second demonstration using the same principles.

---

# 2. Important technical distinction

This workflow creates **2.5D animation from still images**.

It is not:

- Full character animation
- Conventional 3D animation
- Motion-captured footage
- A text-to-video model
- A replacement for real cinematography when complex human movement is required

It can make still images feel alive through:

- Depth separation
- Differential camera movement
- Lighting changes
- Particle animation
- Focus effects
- Evidence graphics
- Controlled before/after transformations
- Sound design

It cannot make a still person naturally walk, speak, turn around, or interact with an environment. Those actions require live footage, 3D animation, or a video-generation model.

---

# 3. Original creative brief

The production began with this creative direction:

> Create a cinematic trailer for a psychological observation mystery game called "Two Second Witness."
>
> **Style:** A suspenseful, intelligent, cinematic tone similar to a mystery investigation rather than an action trailer. The atmosphere should feel intriguing, immersive, and slightly unsettling. Focus on perception, memory, and noticing hidden details.
>
> **Opening:** Begin in darkness with subtle ambient sound. Slowly reveal ordinary scenes: a quiet room, a hallway, a desk with documents, a person observing their surroundings. Everything appears normal.
>
> **Narration:**
>
> “Every moment, your mind decides what to remember.”
>
> “Every detail you notice becomes part of your reality.”
>
> “But what happens when your memory fills in something that was never there?”
>
> **Visual sequence:** Show a series of everyday scenes that subtly change:
>
> - A photograph with one altered detail
> - A room where an object moves
> - A person whose expression changes
> - Documents containing hidden inconsistencies
>
> The changes should be subtle enough that the viewer questions whether they actually saw them.
>
> **Introduce the concept:** A mysterious observer studies scenes for only two seconds before they disappear.
>
> Show rapid flashes of images, close-up shots of eyes observing, notes being written, evidence boards, and comparisons between memories and reality.
>
> **Title:** TWO SECOND WITNESS
>
> **Final sequence:** Show a final scene that appears normal. After a pause, something changes. The viewer is left wondering if they noticed it.
>
> **End text:** Observe. Remember. Discover what changed.
>
> **Visual style:** High-quality cinematic animation, realistic lighting, dramatic shadows, slow camera movement, detailed environments, and a psychological mystery atmosphere.
>
> **Duration:** 60–90 seconds.
>
> **Audio:** Minimal suspense soundtrack, subtle sound effects, and calm investigative narration.

## Converting the brief into production requirements

The brief was translated into these concrete requirements:

| Creative requirement | Technical implementation |
|---|---|
| Ordinary scenes that feel alive | Generated 16:9 stills with three depth planes |
| Slow cinematic movement | Differential foreground/background scale and pan |
| Subtle changes | Aligned before/after frames blended during the same camera move |
| Uncertainty around the change | Brief focus bloom at the transition |
| Observer and evidence | Animated points, scans, threads, reticles, and notebook marks |
| Two-second mechanic | Animated 2.00 countdown and timed audio clicks |
| Psychological mystery | Slate/amber color direction, deep shadows, restrained violet accents |
| Calm narration | Three separately generated or recorded WAV clips |
| Suspense score | Procedural drone, impacts, ticks, sweeps, and pencil friction |
| Final web delivery | H.264/AAC MP4 with fast-start and loudness normalization |

---

# 4. Production architecture

The repository contains three related build systems:

```text
trailer/build_trailer.py
    Original image-change and animatic implementation.
    Also creates the changed still frames used by the second build.

trailer/build_trailer_v2.py
    Complete 79-second 2.5D production build.
    Generates depth layers, environmental motion, evidence effects,
    motion graphics, audio, and the final trailer.

storyboard-example/build.py
    Smaller, documented 15-second learning version.
    Reads storyboard-example/storyboard.yaml.
```

## Full build flow

```text
Creative brief
    ↓
Image-generation prompts
    ↓
Ten source images
    ↓
Changed-image variants
    ↓
Foreground masks
    ↓
Background + foreground depth animation
    ↓
Rain, dust, light, evidence, and focus effects
    ↓
Countdown, aperture, title, and end cards
    ↓
Narration + procedural sound design
    ↓
Shot rendering
    ↓
FFmpeg concatenation and audio mastering
    ↓
Final MP4 + captions + poster + preview
```

## Deterministic versus generative stages

The image-generation stage is generative and may produce a different result on every attempt.

After source images are selected, the build is deterministic. The same images, YAML configuration, and code produce the same camera animation, effects, sound timing, and final edit.

---

# 5. Windows 11 requirements

## Minimum practical system

- Windows 11, 64-bit
- Four-core processor
- 8 GB RAM
- 5 GB free disk space
- Internet connection for initial tool installation
- Any image-generation service capable of 16:9 images
- A narration recording or text-to-speech service

## Recommended system

- Windows 11, 64-bit
- Modern six-core or eight-core processor
- 16 GB RAM or more
- 10 GB free SSD space
- 1920×1080 monitor
- Visual Studio Code
- GitHub Desktop or Git for Windows
- FFmpeg installed system-wide

## Typical build time

Build time depends on CPU speed and selected resolution.

Approximate expectations:

- 15-second, 1280×720 example: 1–5 minutes
- 79-second, 1920×1080 trailer: 10–40 minutes
- Slower laptops may require longer

The workflow does not require an NVIDIA GPU. FFmpeg and Pillow use the CPU in the included scripts.

---

# 6. Installing the tools on Windows 11

Open **Windows Terminal** or **PowerShell** as a normal user.

## 6.1 Install Git

Using Windows Package Manager:

```powershell
winget install --id Git.Git -e
```

Close and reopen PowerShell, then verify:

```powershell
git --version
```

You can alternatively install GitHub Desktop, which includes a Git workflow with a visual interface.

## 6.2 Install Python

Python 3.11 or 3.12 is recommended.

```powershell
winget install --id Python.Python.3.12 -e
```

Close and reopen PowerShell, then verify:

```powershell
py --version
python --version
```

If `python` is not recognized but `py` works, use `py` in the commands below.

When installing Python manually from python.org, enable:

```text
Add python.exe to PATH
```

## 6.3 Install FFmpeg

The scripts can use the static FFmpeg binary provided by the Python package `imageio-ffmpeg`. Installing FFmpeg system-wide is still recommended for inspection and troubleshooting.

Try:

```powershell
winget install --id Gyan.FFmpeg -e
```

If that package identifier is unavailable:

```powershell
winget search ffmpeg
```

Choose a full FFmpeg build that includes `libx264` and AAC support.

Close and reopen PowerShell, then verify:

```powershell
ffmpeg -version
ffprobe -version
```

If `ffmpeg` is not recognized, the build scripts will fall back to `imageio-ffmpeg` after Python dependencies are installed.

## 6.4 Install Visual Studio Code — optional

```powershell
winget install --id Microsoft.VisualStudioCode -e
```

VS Code makes editing YAML, prompts, and Python scripts easier.

## 6.5 PowerShell execution policy

Windows may prevent local PowerShell helper scripts from running. Permit scripts only for the current PowerShell window:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

This setting disappears when the PowerShell window closes.

---

# 7. Downloading and preparing the repository

## 7.1 Clone the repository

```powershell
cd $HOME\Documents
git clone https://github.com/ITTYBITTYBITES/2-second-witness-mobile.git
cd 2-second-witness-mobile
```

The repository is private. GitHub may ask you to authenticate through the browser or Git Credential Manager.

## 7.2 Select the branch containing the example

If the pull request has not yet been merged:

```powershell
git fetch origin
git switch arena/019f4ba1-2-second-witness-mobile
```

After PR #20 is merged, use:

```powershell
git switch main
git pull
```

## 7.3 Create a Python virtual environment

From the repository root:

```powershell
py -3.12 -m venv .venv
```

Activate it:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
```

Your PowerShell prompt should now begin with:

```text
(.venv)
```

## 7.4 Upgrade pip

```powershell
python -m pip install --upgrade pip
```

## 7.5 Install the dependencies

```powershell
python -m pip install -r .\storyboard-example\requirements.txt
```

This installs:

- NumPy — image calculations and procedural audio
- Pillow — masks, image edits, and motion graphics
- PyYAML — storyboard configuration
- imageio-ffmpeg — portable FFmpeg fallback

## 7.6 Use the included setup script

The same environment setup can be performed with:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\storyboard-example\setup-windows.ps1
```

---

# 8. Generating the source images

Use an image-generation system that can create realistic 16:9 imagery. The exact vendor is not required; prompt quality and composition are more important.

## Recommended settings

- Aspect ratio: 16:9
- Preferred size: 1920×1080 or larger
- Minimum practical size: approximately 1600×900
- File format: PNG
- Number of candidates per prompt: 2–4
- Camera style: locked cinematic film still
- Avoid generated text
- Avoid objects touching the frame edges
- Request distinct foreground, middle-ground, and background planes

## Selection criteria

Choose images with:

- Clear depth separation
- Strong but plausible practical lighting
- Space for camera movement
- Correct object count and placement
- Natural hands and faces
- No readable nonsense text
- No watermarks
- No extreme blur across the entire scene
- A composition that remains useful after a 5–10% camera push

## Asset naming

Save selected files with stable names:

```text
01_quiet_room.png
02_hallway.png
03_desk_documents.png
04_observer.png
05_photo_base.png
07_room_object_base.png
09_face_base.png
11_documents_base.png
13_eye_closeup.png
14_notes.png
```

The numbers leave space for the changed variants:

```text
06_photo_changed.png
08_room_object_changed.png
10_face_changed.png
12_documents_changed.png
18_quiet_room_changed.png
```

---

# 9. Exact source-image prompts

These are the prompts used to generate the ten source stills for this project.

## 9.1 Quiet room

```text
Cinematic widescreen 16:9 film still for an intelligent psychological mystery. An ordinary quiet reading room at night, one warm table lamp, charcoal walls, an empty armchair, rain-softened window reflections, a small side table with a ceramic cup and a brass key, everything meticulously realistic and normal. Slow-burn investigative mood, slightly unsettling only through composition, dramatic shadows, volumetric dust, realistic lighting, premium cinema camera, subtle film grain, deep blacks, cool slate and restrained amber palette, no people, no words, no logos, no title, no UI.
```

Save as:

```text
trailer/assets/01_quiet_room.png
```

## 9.2 Hallway

```text
Cinematic widescreen 16:9 film still, psychological observation mystery. Long quiet institutional hallway after hours, numbered frosted glass office doors but no readable text, polished dark floor, practical ceiling lights receding into shadow, one chair precisely against the wall, ordinary and plausible yet faintly uncanny, symmetrical investigative composition, realistic high-end cinematography, cool slate shadows with restrained amber pools, atmospheric haze, subtle film grain, no horror creature, no words, no logos, no UI.
```

Save as:

```text
trailer/assets/02_hallway.png
```

## 9.3 Investigation desk

```text
Cinematic widescreen 16:9 overhead three-quarter film still of an investigator's desk in a dark quiet office. Neatly arranged case documents with illegible tiny type, old family photograph, mechanical pencil, magnifying glass, analog wristwatch, black coffee, paper clips and one red evidence thread. Everything feels ordinary and authentic. Realistic tactile paper, dramatic side lighting, dense shadows, intelligent psychological mystery, cool charcoal and warm tungsten palette, premium film look, shallow depth of field, no readable words, no logos, no title, no UI.
```

Save as:

```text
trailer/assets/03_desk_documents.png
```

## 9.4 Observer

```text
Cinematic widescreen 16:9 film still for a cerebral psychological mystery. A composed androgynous investigator in their 30s seen in profile in a dim observation room, calmly studying a wall of ordinary scene photographs beyond frame, hand near chin, subtle reflection in dark glass, realistic eyes and skin, no weapon, no action pose. Intelligent restraint, dramatic practical lighting, soft volumetric haze, deep slate shadows, amber rim light, premium 35mm cinema texture, slightly unsettling, no words, no logos, no UI.
```

Save as:

```text
trailer/assets/04_observer.png
```

## 9.5 Printed family photograph

```text
Cinematic widescreen 16:9 macro film still on a dark evidence desk: a slightly aged family snapshot showing three people standing by a lakeside cabin, held at one corner by a gloved investigator's hand. In the snapshot: cabin window, three figures, pine tree, rowboat, red scarf. Surroundings fall into shadow. Ultra realistic printed photograph texture, shallow depth, restrained psychological investigation mood, tungsten desk lamp, charcoal shadows, no readable text, no labels, no logos, no UI.
```

Save as:

```text
trailer/assets/05_photo_base.png
```

## 9.6 Living room with movable object

```text
Cinematic widescreen 16:9 locked-off film still of an ordinary minimalist apartment sitting room at dusk. Sofa centered, low table, ceramic chess knight placed near the LEFT edge of the table, floor lamp, framed abstract picture, closed curtain, one plant. Perfectly realistic and plausible, quiet psychological mystery, balanced composition built for a spot-the-difference scene, dramatic natural window shadows, cool blue-gray with warm lamp light, subtle film grain, no people, no words, no logos, no UI.
```

Save as:

```text
trailer/assets/07_room_object_base.png
```

## 9.7 Interview subject

```text
Cinematic widescreen 16:9 close portrait film still of an ordinary middle-aged woman seated across an interview table, looking directly toward the observer with a calm NEUTRAL expression, closed relaxed mouth, steady gaze. Dim interrogation-style room but not threatening, soft practical overhead and window light, realistic subtle skin detail, charcoal background, intelligent psychological mystery, shallow focus, premium cinema color grade, no words, no logos, no UI.
```

Save as:

```text
trailer/assets/09_face_base.png
```

## 9.8 Witness documents

```text
Cinematic widescreen 16:9 macro overhead film still of four official-looking witness documents aligned on a dark desk, type is deliberately too small and indistinct to read, matching circular stamps, dates represented only as blurred marks, clipped black-and-white ID photo, handwritten margin symbols, ruler, fountain pen. Looks consistent at first glance. Realistic investigative evidence, hard side light, dramatic shadows, cerebral mystery mood, no legible text, no logos, no title, no UI.
```

Save as:

```text
trailer/assets/11_documents_base.png
```

## 9.9 Eye close-up

```text
Extreme close-up cinematic widescreen 16:9 film still of a human eye observing in darkness, realistic hazel iris reflecting tiny fragments of an ordinary room, photograph and hallway, eyelid and skin rendered naturally, calm focus rather than fear. Premium macro cinema photography, razor detail on iris, shallow focus, cool charcoal darkness with a restrained violet catchlight, psychological mystery, subtle film grain, no words, no logos, no UI.
```

Save as:

```text
trailer/assets/13_eye_closeup.png
```

## 9.10 Observation notes

```text
Cinematic widescreen 16:9 close film still of an investigator's hand rapidly writing observation notes in a black notebook under a narrow desk lamp. Short lines, diagrams, circles, check marks and arrows but no legible language. Stopwatch, graphite pencil shavings, photograph corners and a small magnifier nearby. Realistic hand, paper, ink and motion, dramatic deep shadows, restrained amber and slate palette, intelligent psychological mystery, premium film grain, no readable words, no logos, no title, no UI.
```

Save as:

```text
trailer/assets/14_notes.png
```

## Reusable prompt ending

For future images, reuse this visual consistency block:

```text
Realistic high-end cinematography, dramatic practical lighting, deep charcoal shadows, cool slate and restrained amber palette, subtle violet observation accent, premium cinema camera, shallow depth of field, natural material detail, subtle film grain, intelligent psychological mystery, not action and not horror. Clearly separated foreground, middle-ground, and background planes for 2.5D parallax. No readable words, logos, title, interface, or watermark. Widescreen 16:9.
```

---

# 10. Creating changed versions

## What actually happened in this production

The changed images were created programmatically because the image-generation session was limited to ten source images.

The script performs these edits:

| Original | Change |
|---|---|
| Family photograph | Child's scarf changes from rust red to muted blue |
| Living room | Ceramic knight moves from left to right |
| Interview subject | Mouth is warped into a nearly imperceptible half-smile |
| Witness documents | Fourth portrait is replaced with the first witness portrait |
| Final quiet room | Brass key disappears |

These operations are implemented in:

```text
trailer/build_trailer.py
```

## Preferred production method

For higher fidelity, create changed versions with image-to-image editing. Use the original image as the reference and permit exactly one change.

### Photograph editing prompt

```text
Edit the supplied image only. Change the child's rust-red scarf to a muted blue scarf. Preserve the people, faces, hands, cabin, lake, tree, rowboat, printed-photo texture, camera position, crop, lighting, shadows, color grade, depth of field, and every other detail exactly. Do not add or remove anything.
```

### Furniture editing prompt

```text
Edit the supplied image only. Move the ceramic chess knight from the LEFT edge of the coffee table to the RIGHT edge. Preserve the camera position, sofa, table, plate, lamp, curtains, artwork, plant, lighting, shadows, color grade, and every other detail exactly.
```

### Expression editing prompt

```text
Edit the supplied image only. Change the seated woman's neutral expression into an extremely subtle closed-mouth half-smile. Preserve her identity, gaze direction, head position, hair, clothing, hands, camera position, crop, background, lighting, shadows, skin texture, and every other detail exactly. The change should be difficult to notice.
```

### Document editing prompt

```text
Edit the supplied image only. Replace the portrait clipped to the fourth document with an exact duplicate of the portrait clipped to the first document. Preserve all document positions, paper, clips, stamps, marks, desk, ruler, pen, camera position, crop, lighting, and every other detail exactly.
```

### Final-room editing prompt

```text
Edit the supplied image only. Remove the small brass key from the round side table. Preserve the cup, table, chair, lamp, books, windows, reflections, camera position, crop, lighting, shadows, and every other detail exactly. Reconstruct the tabletop naturally where the key was located.
```

## Evaluating changed versions

Before accepting an edit, rapidly alternate the original and changed images.

Reject the result if any unintended property changes:

- Camera framing
- Person identity
- Hand position
- Furniture geometry
- Window reflections
- Light direction
- Shadow placement
- Depth of field
- Color grade
- Background objects

The one intended difference should be the only visible change.

---

# 11. Generating or recording narration

The trailer uses three narration lines:

```text
Every moment, your mind decides what to remember.
```

```text
Every detail you notice becomes part of your reality.
```

```text
But what happens when your memory fills in something that was never there?
```

## Voice direction

Use this direction with a voice actor or text-to-speech service:

```text
Calm investigative narration. Intelligent, measured, restrained, and intimate. Do not perform it like an action trailer. Leave a small pause before the key nouns. The speaker should sound curious rather than frightened. Neutral American English, medium-low energy, clean studio recording.
```

## Recommended file format

- WAV
- Mono or stereo
- 16-bit or 24-bit PCM
- 24 kHz or 48 kHz
- No background music
- No reverb
- No normalization that causes clipping

The scripts resample narration to 48 kHz.

Save the lines as:

```text
trailer/audio/narration_01.wav
trailer/audio/narration_02.wav
trailer/audio/narration_03.wav
```

## Recording on Windows 11

You can record a human voice with:

- Windows Sound Recorder
- Audacity
- Adobe Audition
- Reaper
- Any clean digital audio workstation

For a basic home recording:

1. Record in a small quiet room with soft furnishings.
2. Keep the microphone 15–20 cm from the speaker.
3. Speak slightly across the microphone rather than directly into it.
4. Record each sentence separately.
5. Remove long silence from the beginning and end.
6. Export WAV without music.

The full build places narration at approximately:

```text
Line 1: 00:02.450
Line 2: 00:11.200
Line 3: 00:28.950
```

---

# 12. Planning the storyboard

The smaller example uses a human-editable YAML file:

```text
storyboard-example/storyboard.yaml
```

Its structure is:

```yaml
project:
  title: Two Second Witness — Storyboard Example
  width: 1280
  height: 720
  fps: 24
  output: output/two_second_witness_storyboard_example.mp4

narration:
  - file: ../trailer/audio/narration_01.wav
    at: 1.0

shots:
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

## Shot types

The example supports:

```text
parallax
change
title_card
```

## Full trailer structure

The complete trailer approximately follows this timeline:

| Time | Shot |
|---|---|
| 00:00–00:01.5 | Darkness and opening aperture |
| 00:01.5–00:06.7 | Quiet room with rain and parallax |
| 00:06.7–00:10.9 | Hallway |
| 00:10.9–00:16.1 | Investigation desk |
| 00:16.1–00:20.6 | Observer and evidence wall |
| 00:20.6–00:24.8 | Photograph changes |
| 00:24.8–00:28.8 | Ceramic knight moves |
| 00:28.8–00:33.3 | Expression changes |
| 00:33.3–00:37.5 | Document inconsistency |
| 00:37.5–00:40.5 | Two-second countdown |
| 00:40.5–00:43.7 | Eye and attention reticle |
| 00:43.7–00:45.5 | Rapid observation flashes |
| 00:45.5–00:49.5 | Notes and animated marks |
| 00:49.5–00:54.0 | Evidence connections |
| 00:54.0–00:58.0 | Memory-versus-reality comparison |
| 00:58.0–00:64.0 | Main title reveal |
| 00:64.0–00:65.2 | Pause |
| 00:65.2–00:71.2 | Final room and missing key |
| 00:71.2–00:79.3 | End statements and final title |

---

# 13. Creating foreground masks

A foreground mask decides which part of the still image moves as the near depth plane.

## Normalized coordinates

The learning example stores mask coordinates between `0` and `1`.

Convert a pixel coordinate using:

```text
normalized_x = pixel_x / image_width
normalized_y = pixel_y / image_height
```

Example:

For a 1,600×900 image, pixel `(800, 450)` becomes:

```text
(0.5, 0.5)
```

## YAML polygon example

```yaml
foreground_polygons:
  - [[0.209, 0.287],
     [0.616, 0.276],
     [0.694, 0.542],
     [0.906, 0.595],
     [0.957, 1.000],
     [0.149, 1.000],
     [0.096, 0.696]]
```

## Manual method

1. Open the image in Photopea, Photoshop, GIMP, Krita, or another editor.
2. Note the image width and height.
3. Click points around the foreground subject.
4. Record the pixel coordinates.
5. Divide X values by width and Y values by height.
6. Enter the normalized points in YAML.
7. Run the build.
8. Inspect edges during movement.
9. Adjust points or feathering if needed.

## Masking recommendations

- Include the complete foreground subject.
- Keep the polygon slightly inside soft shadow boundaries.
- Use more points around complex silhouettes.
- Use fewer points on large straight edges.
- Do not move the foreground excessively.
- Feather the mask to hide minor inaccuracies.

## Automatic alternatives

The manual polygon step can be replaced with:

- Segment Anything
- `rembg`
- Photoshop Select Subject
- Depth Anything
- MiDaS
- Manually painted grayscale depth maps

A depth map is more flexible because it can create many planes instead of only foreground and background.

---

# 14. How the 2.5D animation works

The source image is used twice:

1. As a complete background plate
2. As a transparent foreground cutout

Each layer receives different movement.

## Background movement

Example:

```yaml
background_zoom: [1.025, 1.070]
```

This means:

```text
Start at 102.5% scale
End at 107.0% scale
```

## Foreground movement

```yaml
foreground_zoom: [1.050, 1.115]
```

The foreground starts larger and moves farther than the background.

## Opposing pan

```yaml
pan: [14, 6]
```

The background travels approximately 14 pixels horizontally and 6 pixels vertically. The foreground moves farther in the opposite direction.

This difference creates the impression of camera depth.

## Why values should remain small

The background plate still contains the foreground subject. Large layer separation can reveal a duplicate edge beneath the cutout.

For two-plane animation, restrained movement usually looks more cinematic:

```text
Background zoom range: 1.02–1.08
Foreground zoom range: 1.04–1.13
Pan range: approximately 5–25 pixels at 1080p
```

For larger motion, create a clean background plate with the foreground object removed.

---

# 15. Environmental and evidence animation

The scripts generate effect clips on black backgrounds and blend them into scenes using screen mode.

## Dust

Dust particles use:

- Random starting positions
- Individual speeds
- Small brightness variation
- Sinusoidal drift
- Slow vertical motion

## Rain

Rain uses:

- Random streak positions
- Diagonal movement
- Different streak lengths and speeds
- Restrained blue-gray brightness

## Moving illumination

A blurred ellipse crosses the effect frame. It is tinted dark violet and blended over the footage at low opacity.

## Evidence scanning

The document shot contains:

- A moving horizontal line
- Boxes around witness portraits
- Timed appearance of comparison marks

## Evidence connections

The observer shot contains:

- Animated points
- Lines progressively drawn between points
- Pulsing circles
- Restrained violet and red values

## Eye attention cue

The eye shot includes:

- A moving reticle
- Minute iris-plane movement
- Reflected rectangles
- Observation lines

## Avoiding a magenta color cast

Screen blending neutral black directly in YUV can shift image color. The implementation converts the scene and effects to planar RGB first:

```text
format=gbrp
```

It then performs screen blending and converts back to YUV420P for H.264 delivery.

---

# 16. Hidden-change transitions

A change shot contains two synchronized composites:

```text
Original background + original foreground
Changed background + changed foreground
```

Both use identical camera movement.

At the configured time:

```yaml
change_at: 2.45
```

The script blends from the original composite to the changed composite over approximately 0.14 seconds.

## Focus bloom

A Gaussian-blurred copy of the frame briefly becomes visible at the exact transition. This gives the viewer's visual system a plausible reason to miss the change.

The sequence is:

```text
Sharp original
    ↓
Brief focus bloom
    ↓
Sharp changed version
```

The focus bloom should remain short. If it lasts too long, it advertises the location of the edit.

## Sound cue

The complete trailer adds a restrained perception snap near each change. The cue should be subtle enough that it creates attention without revealing the answer.

---

# 17. Motion graphics and title animation

The title cards are generated frame-by-frame with Pillow.

## Animated components

- Radial dark background
- Observation aperture arcs
- Expanding elliptical rings
- Rotating arc offsets
- Pulsing center point
- Progressive title-letter reveal
- Increasing letter spacing
- Subtitle reveal
- Fade in and fade out

## Why typography is added after image generation

Image models frequently produce malformed text. Generate images without words and add all typography programmatically.

Benefits include:

- Correct spelling
- Consistent font
- Editable timing
- Resolution independence
- Easier localization
- Cleaner title animation

## Fonts

The current scripts use DejaVu Sans because it is widely available. On Windows, you can replace it with another properly licensed font.

Possible alternatives:

- Inter
- Montserrat
- Source Sans 3
- IBM Plex Sans
- Manrope

Update the font path in the Python script after confirming the font license permits your intended use.

---

# 18. Sound design and mastering

The soundtrack is synthesized with NumPy.

## Sound components

- Low 42–43 Hz drone
- 63–65 Hz harmonic layer
- Restrained upper harmonic
- Smoothed noise for environmental air
- Transition sweeps
- Short observation clicks
- Two-second ticks
- Low impacts
- Pencil-friction noise
- Stereo panning

## Narration ducking

The script calculates a smoothed amplitude envelope from the narration. When speech is present, soundtrack volume decreases automatically.

Conceptually:

```text
voice louder → score quieter
voice silent → score returns
```

## Loudness target

The final trailer is normalized to approximately:

```text
Integrated loudness: −16 LUFS
True peak target: approximately −1.5 dBTP
```

This is a practical target for web playback. Different broadcasters and platforms may require different delivery specifications.

## Captions

The repository contains:

```text
trailer/two_second_witness_trailer.srt
trailer/two_second_witness_trailer.vtt
```

SRT is useful for editing and video platforms. WebVTT is used by the HTML player.

---

# 19. Building the 15-second learning example

From the repository root in PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
python .\storyboard-example\build.py
```

Or use the helper:

```powershell
.\storyboard-example\build-on-windows.ps1 -Mode Example
```

The result is written to:

```text
storyboard-example/output/two_second_witness_storyboard_example.mp4
```

## What the example demonstrates

- Four-second quiet-room parallax shot
- Four-second investigation-desk shot
- Four-second changing-photograph shot
- Three-second animated title card
- One narration line
- Procedural ambience
- Loudness normalization
- Final MP4 encoding

## Temporary files

Generated masks, changed frames, effect clips, shot renders, and audio are written to:

```text
storyboard-example/.build/
```

Delete that directory at any time. The next build recreates it.

PowerShell cleanup:

```powershell
Remove-Item -Recurse -Force .\storyboard-example\.build
```

---

# 20. Building the complete 79-second trailer

Activate the environment:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
```

Run:

```powershell
python .\trailer\build_trailer_v2.py
```

Or use:

```powershell
.\storyboard-example\build-on-windows.ps1 -Mode Full
```

The full script performs these steps:

1. Generates changed observation frames.
2. Preserves the earlier animatic if present.
3. Creates foreground layers.
4. Generates rain and dust loops.
5. Generates shot-specific evidence effects.
6. Renders parallax scenes.
7. Renders synchronized hidden-change scenes.
8. Renders countdown and title graphics.
9. Renders the rapid-flash montage.
10. Synthesizes the soundtrack and sound effects.
11. Places and ducks narration.
12. Concatenates all shots.
13. Normalizes audio.
14. Encodes the final MP4.

The result is:

```text
trailer/two_second_witness_trailer.mp4
```

Temporary directories include:

```text
trailer/generated/
trailer/v2_generated/
trailer/.render/
trailer/.render_v2/
```

They are ignored by Git.

## Full-build dependencies

The full build requires:

```text
NumPy
Pillow
imageio-ffmpeg, unless FFmpeg is installed
```

PyYAML is required for the smaller configuration-driven example.

---

# 21. Validating the finished video

## Decode test

In PowerShell:

```powershell
ffmpeg -v error -i .\trailer\two_second_witness_trailer.mp4 -f null NUL
```

If the command prints nothing and returns to the prompt, decoding succeeded.

Using the Python-provided FFmpeg fallback:

```powershell
python -c "import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())"
```

Copy the printed path and use it in place of `ffmpeg`.

## Inspect metadata

```powershell
ffprobe -hide_banner .\trailer\two_second_witness_trailer.mp4
```

Expected properties:

```text
1920×1080
24 fps
H.264 High Profile
YUV420P
48 kHz stereo AAC
Approximately 79 seconds
```

## Check the example

```powershell
ffmpeg -v error -i .\storyboard-example\output\two_second_witness_storyboard_example.mp4 -f null NUL
```

## Visual review checklist

Watch the trailer at least three times:

### First viewing — story

- Does the opening establish intrigue?
- Is the narration intelligible?
- Does the title feel earned?
- Does the final change create a question?

### Second viewing — changes

- Are changed images aligned?
- Are unintended differences visible?
- Is each change subtle but detectable?
- Does the focus bloom hide rather than announce the transition?

### Third viewing — technical

- Look for mask-edge duplication.
- Look for color shifts during effects.
- Listen for clicks at narration boundaries.
- Confirm that audio does not clip.
- Confirm that title text is readable.
- Check the beginning and final frame for unwanted flashes.

## Headphones and speakers

Review on:

- Headphones
- Laptop speakers
- Phone speakers
- Television or external speakers if available

Low drones may disappear on phone speakers. The upper harmonics and clicks should still communicate suspense.

---

# 22. Customizing the system

## Change project resolution

In `storyboard.yaml`:

```yaml
project:
  width: 1920
  height: 1080
  fps: 24
```

Higher resolution takes longer to render.

## Create a vertical version

Use:

```yaml
width: 1080
height: 1920
```

However, source compositions designed for 16:9 may crop badly. Generate or reframe dedicated vertical source images for the best result.

## Change shot duration

```yaml
duration: 5.5
```

Update narration timing if the shot occurs before spoken lines.

## Change camera intensity

Subtle:

```yaml
background_zoom: [1.015, 1.045]
foreground_zoom: [1.030, 1.075]
pan: [8, 3]
```

More pronounced:

```yaml
background_zoom: [1.030, 1.090]
foreground_zoom: [1.060, 1.140]
pan: [20, 8]
```

Increase movement carefully to avoid exposing duplicate foreground edges.

## Replace narration

Change the file and start time:

```yaml
narration:
  - file: audio/my_line.wav
    at: 2.0
```

## Add another image shot

Copy an existing shot block and change:

- `name`
- `image`
- `duration`
- `foreground_polygons`
- `camera`
- `effects`

## Add another type of hidden change

The learning example currently implements `recolor_red_to_blue`. To add another programmatic change:

1. Add a new `change.type` value in YAML.
2. Add a matching branch in `create_changed_image()`.
3. Generate the changed image.
4. Reuse the synchronized blend and focus transition.

For most production work, supply a separately edited changed image instead.

---

# 23. Troubleshooting on Windows 11

## `python` is not recognized

Try:

```powershell
py --version
```

Then create the environment using:

```powershell
py -3.12 -m venv .venv
```

If neither works, reinstall Python and enable `Add Python to PATH`.

## PowerShell blocks `Activate.ps1`

Use:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
```

## `ModuleNotFoundError: No module named yaml`

Activate the environment and install requirements:

```powershell
.\.venv\Scripts\Activate.ps1
python -m pip install -r .\storyboard-example\requirements.txt
```

## FFmpeg is not recognized

The build can still work through `imageio-ffmpeg`.

Verify:

```powershell
python -c "import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())"
```

If that fails:

```powershell
python -m pip install imageio-ffmpeg
```

## FFmpeg reports that `libx264` is unavailable

Use a full FFmpeg distribution or rely on `imageio-ffmpeg`. Some minimal FFmpeg packages omit H.264 encoding.

## The render has a purple or magenta cast

Ensure effect blending occurs after both scene and effects are converted to RGB:

```text
format=gbrp
```

Do not screen-blend neutral black directly in YUV.

## Foreground edges look doubled

The original foreground remains inside the background plate. Try:

- Reduce pan and zoom distance.
- Improve the mask.
- Increase feathering slightly.
- Create a clean background plate with the foreground removed.
- Use an inpainting tool.

## The changed image jumps

The original and changed images are not aligned.

Use image-to-image editing with a locked camera, or align them manually before rendering.

Check:

- Identical dimensions
- Identical crop
- Identical camera position
- Identical furniture and body positions
- Identical lighting

## The title font cannot be found

The scripts automatically search common Windows, Linux, and macOS font locations. On Windows they try Segoe UI first and Arial second:

```text
C:\Windows\Fonts\segoeui.ttf
C:\Windows\Fonts\segoeuib.ttf
C:\Windows\Fonts\arial.ttf
C:\Windows\Fonts\arialbd.ttf
```

If none of those fonts exists, edit the `find_font()` function and add the path to an installed TTF font.

Files containing font discovery:

```text
storyboard-example/build.py
trailer/build_trailer.py
trailer/build_trailer_v2.py
```

For example, add another candidate:

```python
Path(r"C:\Windows\Fonts\myfont.ttf")
```

## The build is very slow

Try:

- Build the 1280×720 example first.
- Close memory-intensive applications.
- Use an SSD.
- Lower output resolution during testing.
- Change FFmpeg preset from `medium` to `veryfast` while iterating.
- Restore `medium` or `slow` for final delivery.

## The output has no audio

Check that narration paths exist:

```powershell
Get-ChildItem .\trailer\audio\*.wav
```

Inspect streams:

```powershell
ffprobe -hide_banner .\trailer\two_second_witness_trailer.mp4
```

The output should list both video and audio streams.

## Antivirus slows rendering

Some antivirus programs inspect every temporary frame or clip. Add a temporary exclusion only if permitted by your security policy. Never disable protection globally for an unknown project.

## Paths containing spaces fail

Use quotes in PowerShell:

```powershell
python ".\storyboard-example\build.py"
```

The included folder uses a hyphen instead of a space to simplify command-line use.

---

# 24. Production checklist

## Creative planning

- [ ] Define the mystery concept.
- [ ] Write the narration.
- [ ] List ordinary scenes.
- [ ] Decide one hidden change per scene.
- [ ] Choose title and end statements.
- [ ] Create a 60–90 second timing plan.

## Image generation

- [ ] Generate every source image at 16:9.
- [ ] Request clear depth planes.
- [ ] Request no text or logo.
- [ ] Select candidates with plausible anatomy.
- [ ] Confirm correct object positions.
- [ ] Save with stable filenames.

## Changed images

- [ ] Use the original as an edit reference.
- [ ] Lock camera and lighting.
- [ ] Permit only one change.
- [ ] Alternate original and changed images rapidly.
- [ ] Reject unintended differences.

## Narration

- [ ] Record or generate each line separately.
- [ ] Export clean WAV files.
- [ ] Remove excess silence.
- [ ] Confirm intelligibility.
- [ ] Save with expected filenames.

## Masks

- [ ] Identify foreground subjects.
- [ ] Record normalized polygon points.
- [ ] Feather mask edges.
- [ ] Review foreground movement.
- [ ] Reduce movement if duplicate edges appear.

## Animation

- [ ] Configure background camera motion.
- [ ] Configure stronger foreground motion.
- [ ] Add rain, dust, or evidence effects.
- [ ] Set hidden-change times.
- [ ] Add focus bloom.
- [ ] Animate title and end text.

## Audio

- [ ] Position narration.
- [ ] Add score ducking.
- [ ] Add restrained transition effects.
- [ ] Check stereo balance.
- [ ] Normalize to the selected delivery target.

## Final quality assurance

- [ ] Run full decode test.
- [ ] Confirm resolution and frame rate.
- [ ] Confirm audio stream.
- [ ] Validate captions.
- [ ] Watch for mask artifacts.
- [ ] Listen on headphones and speakers.
- [ ] Confirm final download package opens.

---

# 25. What is automated and what remains creative

## Fully automated after assets exist

- Programmatic image changes included in the scripts
- Foreground layer generation from polygons
- Camera interpolation
- Parallax animation
- Rain and dust generation
- Evidence scans and connections
- Focus bloom
- Title animation
- Procedural sound design
- Narration placement
- Score ducking
- Loudness normalization
- H.264/AAC encoding
- MP4 fast-start metadata
- Final assembly

## Semi-automated

- Image generation
- Image-to-image changes
- Foreground segmentation
- Narration generation

These can be automated through APIs, but human review remains important.

## Creative decisions that still require judgment

- Selecting a strong image
- Choosing which detail changes
- Deciding how subtle the change should be
- Choosing shot duration
- Adjusting camera movement
- Controlling pace
- Evaluating atmosphere
- Reviewing sound design
- Deciding when the trailer is finished

Automation can render the trailer, but art direction determines whether it is effective.

---

# 26. Recommended next improvements

## Configuration-driven full trailer

Move the full 79-second build from hard-coded Python shot definitions into YAML, following the smaller example.

## Automatic segmentation

Add Segment Anything or `rembg` to create foreground masks from a click or text label.

## Depth-map animation

Replace two planes with a continuous grayscale depth map. This enables more natural camera translation and depth-of-field effects.

## Image-generation API integration

Create a preparation step that:

1. Reads prompts from YAML.
2. Sends them to an image-generation API.
3. Saves candidates.
4. Creates changed versions through image-to-image editing.
5. Records generation metadata.

Do not automatically accept the first generation. Keep human approval between asset generation and rendering.

## Windows font discovery

Replace hard-coded font paths with a function that searches:

```text
C:\Windows\Fonts
/usr/share/fonts
```

## Multiple delivery formats

Generate from one storyboard:

- 1920×1080 landscape trailer
- 1080×1920 vertical social cut
- 1080×1080 square cut
- 1280×720 review file
- Animated GIF preview
- Captioned and clean masters

## Production metadata

Create a JSON report containing:

- Build date
- Git commit
- Source-image hashes
- Runtime
- Resolution
- Frame rate
- Audio loudness
- Output checksum

---

# Final quick-start summary for Windows 11

```powershell
# 1. Install tools
winget install --id Git.Git -e
winget install --id Python.Python.3.12 -e
winget install --id Gyan.FFmpeg -e

# 2. Clone
cd $HOME\Documents
git clone https://github.com/ITTYBITTYBITES/2-second-witness-mobile.git
cd 2-second-witness-mobile

# 3. If PR #20 is not merged yet
git fetch origin
git switch arena/019f4ba1-2-second-witness-mobile

# 4. Create environment
py -3.12 -m venv .venv
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r .\storyboard-example\requirements.txt

# 5. Build the learning example
python .\storyboard-example\build.py

# 6. Build the complete trailer
python .\trailer\build_trailer_v2.py

# 7. Validate
ffmpeg -v error -i .\trailer\two_second_witness_trailer.mp4 -f null NUL
```

Expected outputs:

```text
storyboard-example/output/two_second_witness_storyboard_example.mp4
trailer/two_second_witness_trailer.mp4
```

This completes the same core process used for the Two Second Witness 2.5D identity trailer: generate cinematic stills, create subtle changed variants, separate depth, animate the layers, add environmental and evidence motion, synthesize sound, place narration, and encode a validated final master.
