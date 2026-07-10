# Image-Generation Prompt Templates

The compositing script animates still images. Strong source images matter more than complicated animation settings.

## Base prompt

```text
Cinematic widescreen 16:9 film still for an intelligent psychological observation mystery.

[Describe one ordinary scene and its important objects.]

Compose the scene with clearly separated foreground, middle-ground, and background elements suitable for 2.5D parallax animation. Keep important objects away from the extreme frame edges.

Realistic practical lighting, dramatic shadows, cool slate colors, restrained amber light, subtle violet accents, premium cinema camera, shallow depth of field, natural material detail, subtle film grain. Intriguing and slightly unsettling, but not horror and not action.

No readable words, no logos, no title, no interface, no watermark. Widescreen 16:9.
```

## Quiet-room example

```text
Cinematic widescreen 16:9 film still for an intelligent psychological mystery. An ordinary quiet reading room at night, one warm table lamp, charcoal walls, an empty leather armchair in the foreground, a small round side table with a ceramic cup and a brass key, and rain-softened windows in the background.

Create distinct foreground, middle-ground, and background layers for 2.5D parallax. Everything should look normal and meticulously realistic. Dramatic shadows, volumetric dust, cool slate and restrained amber palette, premium cinema camera, subtle film grain. No people, readable words, logos, title, UI, or watermark.
```

## Investigation-desk example

```text
Cinematic widescreen 16:9 overhead three-quarter film still of an investigator's desk in a dark quiet office. Neatly arranged case documents with illegible tiny type, old family photograph, mechanical pencil, magnifying glass, analog wristwatch, black coffee, paper clips, and one restrained red evidence thread.

Place the documents and tools in a clear foreground plane with darker office details behind them. Realistic tactile paper, dramatic side lighting, dense shadows, cool charcoal and warm tungsten palette, shallow depth of field. No readable words, logos, title, UI, or watermark.
```

## Observation-change pair

Generate the original first:

```text
A printed family photograph held above a dark evidence desk. Three people stand beside a lakeside cabin. The child in the center wears a rust-red scarf. Locked camera, realistic printed photograph texture, tungsten desk light, psychological mystery tone, no readable text.
```

Then edit that exact image:

```text
Edit the supplied image only. Change the child's rust-red scarf to muted blue. Preserve the people, faces, hands, cabin, lake, printed-photo texture, camera position, crop, lighting, shadows, color grade, and every other detail exactly. Do not add or remove anything.
```

## Object-movement pair

Original:

```text
An ordinary minimalist sitting room at dusk. A small ceramic chess knight stands near the LEFT edge of the coffee table. Locked-off camera, realistic practical lighting, quiet psychological mystery, no people or text.
```

Changed version:

```text
Edit the supplied image only. Move the ceramic chess knight from the LEFT edge of the coffee table to the RIGHT edge. Preserve the camera, sofa, table, lamp, curtains, artwork, lighting, shadows, and every other detail exactly.
```

## Consistency checklist

- Reuse the original image as an edit reference for every changed version.
- Explicitly request a locked camera and unchanged lighting.
- Name the one detail that may change and state that everything else must remain identical.
- Generate at 16:9 or crop every image to the same aspect ratio before masking.
- Avoid readable AI-generated text; add typography later with the script.
- Keep foreground subjects from touching frame edges when possible.
- Choose images with obvious depth planes: foreground object, middle subject, distant background.
