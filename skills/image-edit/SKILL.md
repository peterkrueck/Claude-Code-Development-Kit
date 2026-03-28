---
name: image-edit
description: Edit images with precision — crop, resize, mirror, rotate, trim, and reframe. Use this skill whenever the user asks to crop, resize, trim, mirror, flip, rotate, reframe, or otherwise manipulate an image. Also use for creating square crops, portraits/headshots from full-body images, icon sizes, or any image transformation. Even if the request sounds simple, this skill prevents common pitfalls and ensures correct results on the first try.
user_invocable: true
---

# Image Edit — Crop, Resize & Transform

Precision image manipulation using Python/Pillow. This skill exists because macOS `sips` has unreliable crop offset behavior and visual inspection alone leads to bad coordinates — images often have hundreds of pixels of invisible padding that throws off naive crops.

## Setup

The scripts need Pillow and numpy. Create a temp venv on first use:

```bash
python3 -m venv /tmp/imgcrop && /tmp/imgcrop/bin/pip install Pillow numpy -q
```

This only needs to happen once per session. The venv at `/tmp/imgcrop` persists until reboot.

## The Golden Rule: Measure Before You Cut

Never guess crop coordinates from visual inspection. Images routinely have large invisible regions — transparent padding, solid-color borders, or dead space — that make visual estimates wildly wrong.

Always run the analysis script first to get exact pixel coordinates of where the actual content lives.

## Workflow

### Step 1 — Visual inspection

Use the Read tool to look at the image. Understand what's in it and what the user wants to focus on.

### Step 2 — Analyze content bounds

Run the bundled analysis script to find where content actually lives:

```bash
/tmp/imgcrop/bin/python3 .claude/skills/image-edit/scripts/analyze_bounds.py <image_path>
```

This outputs JSON with:
- `content_bounds` — exact pixel coordinates of non-background content
- `padding` — how much dead space exists on each side
- `suggested_square_crops` — pre-calculated crop regions at different zoom levels:
  - `tight_head` (35%) — face/head closeup
  - `upper_body` (55%) — head through chest/arms
  - `three_quarter` (75%) — head through waist
  - `full` (100%) — entire subject

Use `--threshold` to adjust sensitivity (default 30).

### Step 3 — Calculate crop coordinates

Use the analysis output to compute exact crop coordinates:

- **Headroom**: Add 40-70px above the content top
- **Centering**: Center horizontally on the content's center-x, not the image's center
- **Aspect ratio**: For square crops, use `max(width, height)` as the side length
- **Clamping**: Ensure the crop region doesn't extend beyond image dimensions

### Step 4 — Apply operations

Use the bundled script. All operations are optional and composable — applied in order: crop -> mirror -> rotate -> resize.

```bash
/tmp/imgcrop/bin/python3 .claude/skills/image-edit/scripts/crop_image.py \
  <input_path> <output_path> \
  [--left L --top T --right R --bottom B] \
  [--mirror horizontal|vertical] \
  [--rotate DEGREES] \
  [--resize WxH]
```

**Flags:**

| Flag | Required | Description |
|------|----------|-------------|
| `--left/--top/--right/--bottom` | No (but all four if any) | Crop region in pixels. (0,0) is top-left. |
| `--mirror` | No | `horizontal` (or `h`) flips left-right. `vertical` (or `v`) flips top-bottom. |
| `--rotate` | No | Counter-clockwise degrees. 90/180/270 are pixel-perfect; other angles expand the canvas. |
| `--resize` | No | Final dimensions, e.g. `512x512`. Applied after all other operations. Uses LANCZOS resampling. |

**Important**: Always save to a NEW file. Never overwrite the original.

### Step 5 — Verify

Read the output image with the Read tool to visually confirm the result. If it doesn't look right, adjust and re-run — the original is untouched.

## Common Tasks

### Square crop of a subject
1. Analyze bounds to find content region
2. Use the appropriate suggested crop (`upper_body`, `three_quarter`, etc.)
3. Adjust for headroom and centering

### Mirror an image
```bash
/tmp/imgcrop/bin/python3 .claude/skills/image-edit/scripts/crop_image.py \
  input.png output-mirrored.png --mirror horizontal
```

### Resize to specific dimensions
1. Crop first if needed (to set the right aspect ratio)
2. Use `--resize WxH` to scale

### Trim transparent/white padding
1. Analyze bounds — the `padding` field tells you how much dead space exists
2. Crop to `content_bounds` plus a small margin (10-20px)

### Generate multiple sizes (e.g., app icons)
1. Start with the highest-resolution crop
2. Run multiple commands with different `--resize` values

## Do NOT use macOS `sips`

The `sips` command-line tool has unreliable `--cropOffset` behavior. Use the Python scripts instead.
